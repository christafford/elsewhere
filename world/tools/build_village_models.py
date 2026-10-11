#!/usr/bin/env python3
"""Original P22-T04 architectural meshes; deterministic GLB, meters, Y up.

Uses only Python's standard library. Rebuild from the repository root with
python3 world/tools/build_village_models.py. No downloaded source or textures.
The small runtime GLBs are tracked; the construction source is authoritative.
"""
import json
import math
from pathlib import Path
import struct

OUT = Path(__file__).resolve().parents[1] / 'art' / 'village'
# Deliberately plain base finishes; material/lighting curation is P22-T05.
PALETTE = {
    'lime': ('cbbd9f', .9), 'ochre': ('b28a59', .9),
    'stone': ('91958b', .95), 'cut_stone': ('b4b3a1', .85),
    'timber': ('49392c', .85), 'wood': ('755438', .85),
    'slate': ('3e5057', .85), 'tile': ('805447', .85),
    'glass': ('293e43', .25), 'teal': ('355959', .8),
    'metal': ('78613e', .45), 'water': ('426b70', .2),
}


def add(a, b): return tuple(x+y for x, y in zip(a, b))
def sub(a, b): return tuple(x-y for x, y in zip(a, b))
def mul(a, v): return tuple(x*v for x in a)
def cross(a, b): return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])
def unit(a): return mul(a, 1/math.sqrt(sum(x*x for x in a)))


class Model:
    def __init__(self, name):
        self.name = name
        self.parts = {}

    def tri(self, mat, a, b, c):
        n = cross(sub(b, a), sub(c, a))
        if sum(x*x for x in n) < 1e-14: return
        n = unit(n)
        dominant = max(range(3), key=lambda i: abs(n[i]))
        axes = [(2,1),(0,2),(0,1)][dominant]
        self.parts.setdefault(mat, []).extend((*p, *n, p[axes[0]], p[axes[1]]) for p in (a, b, c))

    def quad(self, mat, a, b, c, d):
        self.tri(mat, a, b, c)
        self.tri(mat, a, c, d)

    def box(self, mat, center, size):
        x, y, z = center
        w, h, d = (v/2 for v in size)
        p = [(x+a*w, y+b*h, z+c*d) for a,b,c in
             [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),
              (-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
        for face in [(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(3,7,6,2),(0,1,5,4)]:
            self.quad(mat, *(p[i] for i in face))

    def beam(self, mat, a, b, width, depth=None):
        axis = unit(sub(b, a))
        side = unit(cross(axis, (0,0,1) if abs(axis[2]) < .9 else (0,1,0)))
        side = mul(side, width/2)
        up = mul(unit(cross(axis, side)), (depth or width)/2)
        p = [add(t, add(mul(side,s),mul(up,u))) for t in [a,b] for s,u in [(-1,-1),(1,-1),(1,1),(-1,1)]]
        for face in [(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(3,7,6,2),(0,1,5,4)]:
            self.quad(mat, *(p[i] for i in face))

    def lathe(self, mat, profile, center=(0,0,0), sides=32):
        # Profile follows bottom outer -> top -> inside -> bottom; radius/Y.
        for (r0,y0),(r1,y1) in zip(profile, profile[1:]):
            for j in range(sides):
                a,b = j*math.tau/sides,(j+1)*math.tau/sides
                self.quad(mat, *[add(center,p) for p in
                    [(r0*math.cos(a),y0,r0*math.sin(a)),
                     (r1*math.cos(a),y1,r1*math.sin(a)),
                     (r1*math.cos(b),y1,r1*math.sin(b)),
                     (r0*math.cos(b),y0,r0*math.sin(b))]])

    def polygon(self, mat, outline, front, back):
        # CCW x/y outline viewed from +Z; sealed extrusion.
        for i in range(1,len(outline)-1):
            self.tri(mat, *((x,y,front) for x,y in [outline[0],outline[i],outline[i+1]]))
            self.tri(mat, *((x,y,back) for x,y in [outline[0],outline[i+1],outline[i]]))
        for i,(x,y) in enumerate(outline):
            u,v=outline[(i+1)%len(outline)]
            self.quad(mat,(x,y,front),(x,y,back),(u,v,back),(u,v,front))

    def roof(self, width, depth, eave, ridge, mat='slate', hip=0):
        x,z=width/2,depth/2
        # Roof sheets have actual thickness, underside and fascia; no planes.
        faces=[[(0,ridge,-z+hip),(-x,eave,-z),(-x,eave,z),(0,ridge,z-hip)],
               [(0,ridge,z-hip),(x,eave,z),(x,eave,-z),(0,ridge,-z+hip)]]
        if hip:
            faces += [[(-x,eave,z),(x,eave,z),(0,ridge,z-hip)],
                      [(x,eave,-z),(-x,eave,-z),(0,ridge,-z+hip)]]
        for face in faces:
            bottom=[add(p,(0,-.18,0)) for p in face]
            for i in range(1,len(face)-1):
                self.tri(mat,face[0],face[i],face[i+1])
                self.tri('wood',bottom[0],bottom[i+1],bottom[i])
            for i in range(len(face)):
                j=(i+1)%len(face)
                self.quad('timber',face[i],bottom[i],bottom[j],face[j])
        self.beam(mat,(0,ridge+.06,-z+hip),(0,ridge+.06,z-hip),.22)
        # Raised battens define roof courses and make slopes read at eye level.
        for side in [-1,1]:
            for i in range(1,9):
                t=i/9
                xx=side*x*t
                yy=ridge+(eave-ridge)*t+.018
                end=z-hip*(1-t)
                self.beam(mat,(xx,yy,-end),(xx,yy,end),.035)

    def window(self, x,y,z,w=1.05,h=1.5,shutters=False):
        self.box('timber',(x,y,z+.04),(w+.26,h+.25,.18))
        self.box('glass',(x,y,z+.145),(w,h,.06))
        for xx in [-w/2,0,w/2]: self.box('wood',(x+xx,y,z+.2),(.065,h+.1,.09))
        for yy in [-h/2,0,h/2]: self.box('wood',(x,y+yy,z+.2),(w+.12,.065,.09))
        self.box('cut_stone',(x,y-h/2-.15,z+.22),(w+.48,.14,.38))
        if shutters:
            for side in [-1,1]:
                sx=x+side*(w*.75+.23)
                self.box('teal',(sx,y,z+.08),(w*.45,h+.12,.12))
                for dy in [-h*.32,h*.32]: self.box('timber',(sx,y+dy,z+.16),(w*.45,.07,.07))

    def door(self,x,z,width=1.45,arch=False):
        h=2.25
        if arch:
            outline=[(x-width/2,0),(x+width/2,0),(x+width/2,h-width/2)]
            outline += [(x+math.cos(i*math.pi/16)*width/2,h-width/2+math.sin(i*math.pi/16)*width/2) for i in range(1,17)]
            self.polygon('timber',outline,z+.13,z-.03)
            for i in range(16):
                a,b=i*math.pi/16,(i+1)*math.pi/16
                self.beam('cut_stone',(x+math.cos(a)*(width/2+.14),h-width/2+math.sin(a)*(width/2+.14),z+.2),(x+math.cos(b)*(width/2+.14),h-width/2+math.sin(b)*(width/2+.14),z+.2),.24,.28)
        else:
            self.box('timber',(x,h/2,z+.09),(width,h,.18))
            self.box('wood',(x,h+.1,z+.2),(width+.4,.18,.32))
        for i in range(7):
            self.box('wood',(x-width*.43+i*width*.143,.91,z+.195),(.08,1.7,.045))
        for side in [-1,1]: self.box('cut_stone',(x+side*(width/2+.14),.76,z+.12),(.24,1.52,.26))
        self.box('metal',(x+width*.28,1.05,z+.25),(.06,.25,.07))
        self.box('cut_stone',(x,.04,z+.4),(width+.5,.08,.8))

    def merge(self, other, origin, yaw):
        c,s=math.cos(yaw),math.sin(yaw)
        def rotate(p): return (c*p[0]+s*p[2],p[1],-s*p[0]+c*p[2])
        for mat,rows in other.parts.items():
            self.parts.setdefault(mat, []).extend((*add(rotate(row[:3]),origin),*rotate(row[3:6]),*row[6:]) for row in rows)

    def elevations(self, half_width, half_depth, levels, bays, shutters=False):
        for side in [-1,1]:
            facade=Model('side')
            for y in levels:
                for x in bays: facade.window(x,y,0,.9,1.25,shutters)
            self.merge(facade,(side*(half_width+.01),0,0),side*math.pi/2)
        rear=Model('rear')
        for y in levels:
            for x in [-half_width*.55,half_width*.55]: rear.window(x,y,0,.95,1.25,shutters)
        self.merge(rear,(0,0,-half_depth-.01),math.pi)

    def write(self):
        blob=bytearray(); views=[]; accessors=[]; primitives=[]; materials=[]
        for name,rows in self.parts.items():
            color,roughness=PALETTE[name]
            # glTF factors are linear; author colors as familiar sRGB swatches.
            srgb=[int(color[i:i+2],16)/255 for i in (0,2,4)]
            linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in srgb]
            materials.append({'name':name,'pbrMetallicRoughness':{'baseColorFactor':linear+[1],'metallicFactor':.55 if name=='metal' else 0,'roughnessFactor':roughness}})
            attributes={}
            for semantic,start,count in [('POSITION',0,3),('NORMAL',3,3),('TEXCOORD_0',6,2)]:
                values=[r[start:start+count] for r in rows]
                offset=len(blob)
                for v in values: blob.extend(struct.pack('<'+str(count)+'f',*v))
                views.append({'buffer':0,'byteOffset':offset,'byteLength':len(blob)-offset,'target':34962})
                accessor={'bufferView':len(views)-1,'componentType':5126,'count':len(rows),'type':'VEC'+str(count)}
                if semantic=='POSITION':
                    accessor['min']=[min(v[i] for v in values) for i in range(3)]
                    accessor['max']=[max(v[i] for v in values) for i in range(3)]
                accessors.append(accessor); attributes[semantic]=len(accessors)-1
            primitives.append({'attributes':attributes,'material':len(materials)-1})
        data={'asset':{'version':'2.0','generator':'Elsewhere original village model authoring'},'scene':0,'scenes':[{'nodes':[0]}],'nodes':[{'name':self.name,'mesh':0}],'meshes':[{'name':self.name,'primitives':primitives}],'materials':materials,'buffers':[{'byteLength':len(blob)}],'bufferViews':views,'accessors':accessors}
        encoded=json.dumps(data,separators=(',',':')).encode()
        encoded+=b' '*((-len(encoded))%4); blob+=b'\0'*((-len(blob))%4)
        output=struct.pack('<4sII',b'glTF',2,12+8+len(encoded)+8+len(blob))+struct.pack('<I4s',len(encoded),b'JSON')+encoded+struct.pack('<I4s',len(blob),b'BIN\0')+blob
        (OUT/(self.name+'.glb')).write_bytes(output)
        print(f'{self.name}: {sum(len(p)//3 for p in self.parts.values())} triangles, {len(output)} bytes')


def lodge():
    m=Model('alpine_lodge')
    m.box('slate',(0,-.7,0),(10,1.8,7.5))
    m.polygon('lime',[(-5,0),(5,0),(5,5.1),(0,7.3),(-5,5.1)],3.75,-3.75)
    m.roof(11.5,9.1,5.1,7.7)
    for x in [-4.9,-2.5,0,2.5,4.9]:
        m.box('timber',(x,2.6,3.85),(.19,5.2,.18))
    for y in [.22,2.8,5.0]: m.box('timber',(0,y,3.85),(10.1,.19,.18))
    for side in [-1,1]:
        m.beam('timber',(0,7.2,3.87),(side*4.8,5.1,3.87),.19)
        m.beam('timber',(side*2.5,2.9,3.87),(side*4.8,4.9,3.87),.16)
    m.door(0,3.8)
    for x in [-3.3,3.3]: m.window(x,1.55,3.82,1.1,1.45,True)
    for x in [-3.3,0,3.3]: m.window(x,3.98,3.82,1.05,1.45,True)
    m.window(0,6.05,3.82,.8,.9)
    # Cantilevered timber balcony, brackets and individual balusters.
    m.box('wood',(0,2.86,4.4),(8.3,.2,1.5))
    for x in [-3.7,0,3.7]: m.beam('timber',(x,1.85,3.8),(x,2.76,4.9),.17)
    for i in range(29): m.box('wood',(-4+i*8/28,3.39,5.05),(.075,.92,.08))
    m.box('timber',(0,3.9,5.05),(8.35,.12,.17))
    for side in [-1,1]: m.box('timber',(side*4.07,3.4,4.42),(.12,1.0,1.4))
    # Rear/side elevations also have crafted trim and windows, not blank cubes.
    for side in [-1,1]:
        for z in [-2.7,0,2.7]: m.box('timber',(side*5.04,2.55,z),(.15,5.1,.18))
        for y in [.25,2.8,4.9]: m.box('timber',(side*5.04,y,0),(.15,.16,7.5))
    m.box('stone',(-3,6.5,-1.8),(.8,3.3,.85))
    m.box('cut_stone',(-3,8.2,-1.8),(1.05,.22,1.1))
    m.elevations(5,3.75,[1.55,3.98],[-1.5,1.5],True)
    m.write()


def guildhall():
    m=Model('guildhall')
    m.box('slate',(0,-.75,0),(7.8,1.8,6.5))
    m.polygon('ochre',[(-3.9,0),(3.9,0),(3.9,6.3),(0,9.1),(-3.9,6.3)],3.25,-3.25)
    m.roof(8.2,7.3,6.25,9.35,'tile')
    # Stepped stone front gable and projecting cornices.
    for side in [-1,1]:
        for i in range(5):
            x=side*(3.6-i*.72); y=6.5+i*.55
            m.box('cut_stone',(x,y,3.4),(.76,.7,.42))
            m.box('cut_stone',(x,y+.37,3.4),(.91,.12,.52))
        for y in [.4,1.05,1.7,2.35,3.0,3.65,4.3,4.95,5.6]:
            m.box('cut_stone',(side*3.84,y,3.33),(.38,.26,.23))
    for y in [.22,3.3,6.1]: m.box('cut_stone',(0,y,3.4),(8.0,.17,.4))
    m.door(0,3.3,1.75,True)
    for x in [-2.4,2.4]:
        m.window(x,1.7,3.3,.95,1.5)
        m.window(x,4.65,3.3,1.25,1.85,True)
    m.window(0,4.65,3.3,.95,1.85)
    # Clock face is fixed decorative geometry, not a fake runtime widget.
    # Lathe is Y-up, so build front-facing rings explicitly.
    for j in range(48):
        a,b=j*math.tau/48,(j+1)*math.tau/48
        m.quad('metal',(math.cos(a)*.95,7.25+math.sin(a)*.95,3.63),(math.cos(b)*.95,7.25+math.sin(b)*.95,3.63),(math.cos(b)*.8,7.25+math.sin(b)*.8,3.63),(math.cos(a)*.8,7.25+math.sin(a)*.8,3.63))
        m.tri('lime',(0,7.25,3.59),(math.cos(a)*.81,7.25+math.sin(a)*.81,3.59),(math.cos(b)*.81,7.25+math.sin(b)*.81,3.59))
    for j in range(12):
        a=j*math.tau/12
        m.beam('timber',(math.sin(a)*.65,7.25+math.cos(a)*.65,3.65),(math.sin(a)*.74,7.25+math.cos(a)*.74,3.65),.045)
    m.beam('timber',(0,7.25,3.68),(-.33,7.58,3.68),.06)
    m.beam('timber',(0,7.25,3.68),(.18,7.85,3.68),.045)
    m.box('cut_stone',(0,9.18,3.4),(.5,.7,.48))
    m.lathe('metal',[(.14,0),(.14,.15),(0,.4)],(0,9.55,3.4),16)
    m.elevations(3.9,3.25,[1.7,4.65],[-1.5,1.5])
    m.write()


def workshop():
    m=Model('stone_workshop')
    m.box('stone',(0,1.45,0),(8,5.3,6.5))
    m.roof(9.5,8.0,4.1,5.75,'slate',2.0)
    for y in [.15,3.9]: m.box('cut_stone',(0,y,3.34),(8.1,.2,.26))
    m.door(-1.8,3.3,1.8,True)
    m.window(1.55,2.0,3.3,2.4,1.5)
    # Tall capped chimney and a lower side lean-to produce an asymmetric profile.
    m.box('cut_stone',(2.45,4.1,-.8),(1.0,5.2,1.05))
    for y in [5.7,6.6]: m.box('stone',(2.45,y,-.8),(1.3,.22,1.35))
    for x in [2.15,2.7]: m.lathe('tile',[(.17,0),(.17,.7),(.23,.72),(.23,.84),(.12,.84),(.12,.05)],(x,6.7,-.8),16)
    # Masonry corner blocks and voussoirs differentiate the stone facade.
    for side in [-1,1]:
        for i in range(9): m.box('cut_stone',(side*3.86,.3+i*.42,3.29),(.35,.29,.22))
    m.box('wood',(-4.7,1.05,0),(1.4,2.1,5.0))
    m.beam('slate',(-4,3.15,0),(-5.7,2.35,0),.2,5.6)
    m.elevations(4,3.25,[2.3],[-1.7,1.7])
    for side in [-1,1]:
        m.box('cut_stone',(side*4.04,.15,0),(.18,.2,6.5))
        m.box('cut_stone',(side*4.04,3.9,0),(.18,.2,6.5))
    m.write()


def fountain():
    m=Model('square_fountain')
    m.lathe('cut_stone',[(0,-.1),(2.05,-.1),(2.05,.13),(1.9,.23),(1.9,.35),(1.7,.4),(1.7,.78),(1.85,.82),(1.85,.99),(1.57,.99),(1.5,.83),(1.5,.39),(0,.39)],sides=12)
    m.lathe('water',[(1.49,.56),(0,.56)],sides=48)
    m.lathe('stone',[(0,.35),(.65,.35),(.65,.65),(.47,.75),(.38,1.0),(.34,2.75),(.55,2.87),(.55,3.05),(.3,3.16)],sides=8)
    # Four bronze spouts project over the basin.
    for a in [0,math.pi/2,math.pi,math.pi*1.5]:
        m.beam('metal',(math.cos(a)*.3,1.6,math.sin(a)*.3),(math.cos(a)*.8,1.48,math.sin(a)*.8),.12)
    m.lathe('metal',[(.0,3.12),(.25,3.2),(.39,3.4),(.42,3.65),(.3,3.9),(0,4.02)],sides=24)
    # Compass crown: distinct from the building clocks and roofs.
    for a in [0,math.pi/2]:
        m.beam('metal',(-math.cos(a)*.7,3.65,-math.sin(a)*.7),(math.cos(a)*.7,3.65,math.sin(a)*.7),.07)
    m.lathe('metal',[(.1,3.9),(.1,4.18),(0,4.5)],sides=16)
    m.write()


def pavilion():
    m=Model('work_pavilion')
    m.box('cut_stone',(0,-.14,0),(9,.28,7))
    m.roof(10.8,8.7,3.35,5.5,'slate',1.5)
    for x in [-4,4]:
        for z in [-2.9,0,2.9]:
            m.box('stone',(x,.15,z),(.56,.3,.56))
            m.box('timber',(x,1.77,z),(.25,3.05,.25))
            m.box('wood',(x,3.08,z),(.45,.23,.45))
            for dz in [-.85,.85]: m.beam('timber',(x,2.36,z),(x,3.25,z+dz),.16)
        m.beam('timber',(x,3.23,-3.5),(x,3.23,3.5),.23)
    # Exposed king-post roof trusses, rafters and purlins, visible from below.
    for z in [-2.9,0,2.9]:
        m.beam('timber',(-4.6,3.27,z),(4.6,3.27,z),.22)
        m.beam('timber',(0,3.3,z),(0,5.22,z),.2)
        for side in [-1,1]:
            m.beam('wood',(side*4.65,3.33,z),(0,5.25,z),.18)
            m.beam('timber',(side*2.8,3.35,z),(0,4.9,z),.14)
    for side in [-1,1]:
        m.beam('wood',(side*2.5,4.12,-3.1),(side*2.5,4.12,3.1),.14)
    m.write()


if __name__ == '__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    for build in [lodge,guildhall,workshop,fountain,pavilion]: build()
