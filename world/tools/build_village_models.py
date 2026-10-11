#!/usr/bin/env python3
"""Original village meshes; deterministic GLB, meters, Y up.

Uses only Python's standard library. Rebuild from the repository root with
python3 world/tools/build_village_models.py. No downloaded source or textures.
The small runtime GLBs are tracked; the construction source is authoritative.
"""
import json
import math
import random
from pathlib import Path
import struct

OUT = Path(__file__).resolve().parents[1] / 'art' / 'village'
# Reference 2: weathered timber, cool limestone, dark slate and restrained ivy.
PALETTE = {
    'lime': ('aaa99b', .95), 'ochre': ('989a90', .95),
    'stone': ('91958b', .95), 'cut_stone': ('b4b3a1', .85),
    'timber': ('373932', .95), 'wood': ('69665b', .95),
    'slate': ('3f4b55', .9), 'tile': ('805447', .85),
    'glass': ('293e43', .25), 'teal': ('355959', .8),
    'metal': ('78613e', .45), 'water': ('426b70', .2),
    'leaf': ('3b782b', .85), 'leaf_light': ('6c9c35', .85),
    'leaf_dark': ('275529', .9), 'pink': ('d53486', .7),
    'yellow': ('ecc044', .7), 'blue': ('398ed1', .7),
    'petal_white': ('ddd9c1', .75), 'soil': ('302c20', 1),
    'terracotta': ('705744', .95), 'canvas': ('864936', .95),
    'water_jet': ('bbcdd0', .28), 'snow': ('8b9ca3', .9), 'mountain': ('4e6570', 1.0),
    **{f'roof{i}': (c,.9) for i,c in enumerate(['47545e','53606a','3a4650','606970','424c56'])},
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
        self.rng = random.Random(41011)

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
        start = len(self.parts.get(mat, []))
        for face in [(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(3,7,6,2),(0,1,5,4)]:
            self.quad(mat, *(p[i] for i in face))
        if mat in ('wood', 'timber'):
            # Grain follows each brace/post rather than world-vertical stripes.
            for i in range(start, len(self.parts[mat])):
                v = self.parts[mat][i]
                transverse = unit(side) if abs(sum(v[3+j]*unit(up)[j] for j in range(3))) > .5 else unit(up)
                uv = (sum(v[j]*transverse[j] for j in range(3)), sum(v[j]*axis[j] for j in range(3)))
                self.parts[mat][i] = (*v[:6], *uv)

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
        def point(t, zz, side):
            return (side*x*t, ridge+(eave-ridge)*t+.05*t**8, zz)
        rows=max(3,math.ceil(x/.34))
        for side in [-1,1]:
            for row in range(rows):
                t0,t1=row/rows,(row+1)/rows
                z0,z1=z-hip*(1-t0),z-hip*(1-t1)
                a,b,c,d=point(t0,-z0,side),point(t1,-z1,side),point(t1,z1,side),point(t0,z0,side)
                face=[a,b,c,d] if side<0 else [d,c,b,a]
                self.quad(mat,*face)
                self.quad('wood',*[add(v,(0,-.14,0)) for v in reversed(face)])
                # Individual thick overlapping slate courses, with staggered joints.
                tiles=math.ceil(2*max(z0,z1)/.42)
                for j in range(tiles):
                    lo=max(-z1,-z1+(j+(row%2)*.5)*.42)
                    hi=min(z1,lo+.405)
                    if hi-lo<.08: continue
                    lo0=max(-z0,lo); hi0=min(z0,hi)
                    if hi0-lo0<.05: continue
                    aa=add(point(t0,lo0,side),(0,.025,0))
                    bb=add(point(t1,lo,side),(0,.045,0))
                    cc=add(point(t1,hi,side),(0,.045,0))
                    dd=add(point(t0,hi0,side),(0,.025,0))
                    face=[aa,bb,cc,dd] if side<0 else [dd,cc,bb,aa]
                    color='roof'+str((row*7+j*13)%5)
                    self.quad(color,*face)
                    self.quad(color,bb,add(bb,(0,-.055,0)),add(cc,(0,-.055,0)),cc) if side<0 else self.quad(color,cc,add(cc,(0,-.055,0)),add(bb,(0,-.055,0)),bb)
        # Hipped ends and boxed eaves close the roof shell.
        if hip:
            for side in [-1,1]:
                a,b,c=(-x,eave+.16,side*z),(x,eave+.16,side*z),(0,ridge,side*(z-hip))
                self.tri(mat,*( [a,b,c] if side>0 else [b,a,c]))
                self.tri('wood',*[add(v,(0,-.14,0)) for v in ([b,a,c] if side>0 else [a,b,c])])
        for side in [-1,1]:
            self.beam('timber',(side*x,eave+.1,-z),(side*x,eave+.1,z),.18)
            if not hip:
                for end in [-1,1]:
                    for i in range(rows):
                        self.beam('timber',point(i/rows,end*z,side),point((i+1)/rows,end*z,side),.16)
        self.beam(mat,(0,ridge+.05,-z+hip),(0,ridge+.05,z-hip),.18)

    def leaf(self, center, length, yaw, tilt, mat='leaf'):
        direction=(math.sin(yaw)*math.cos(tilt),math.sin(tilt),math.cos(yaw)*math.cos(tilt))
        across=(math.cos(yaw)*length*.22,0,-math.sin(yaw)*length*.22)
        base=center; mid=add(center,mul(direction,length*.48)); tip=add(center,mul(direction,length))
        ridge=add(mid,(0,length*.09,0))
        left=add(mid,across); right=sub(mid,across)
        for a,b,c in [(base,left,ridge),(left,tip,ridge),(tip,right,ridge),(right,base,ridge)]:
            self.tri(mat,a,b,c); self.tri(mat,c,b,a)

    def flowers(self, center, spread, count=16):
        for i in range(count):
            a=self.rng.random()*math.tau; r=spread*math.sqrt(self.rng.random())
            foot=add(center,(math.cos(a)*r,0,math.sin(a)*r))
            top=add(foot,(0,.16+self.rng.random()*.16,0))
            self.beam('leaf_dark',foot,top,.012)
            for j in range(6): self.leaf(add(foot,(0,.04,0)),.36+self.rng.random()*.16,a+j*1.047,.18,'leaf_light' if j%2 else 'leaf')
            color='petal_white' if i%9==0 else ['pink','yellow','blue'][int(abs(center[0]*1.2+center[2]*.7))%3]
            for j in range(5):
                t=j*math.tau/5
                tip=add(top,(math.cos(t)*.16,.015,math.sin(t)*.16))
                l=add(top,(math.cos(t-.48)*.095,.035,math.sin(t-.48)*.075))
                r=add(top,(math.cos(t+.48)*.095,.035,math.sin(t+.48)*.075))
                self.quad(color,top,l,tip,r); self.quad(color,r,tip,l,top)
            self.lathe('yellow',[(0,0),(.034,0),(.02,.025),(0,.035)],top,6)

    def planter(self,x,y,z,w):
        self.box('terracotta',(x,y,z),(w,.27,.4))
        self.box('soil',(x,y+.14,z),(w-.08,.02,.32))
        for side in [-1,1]: self.box('wood',(x,y+.1,z+side*.2),(w+.06,.065,.06))
        for i in range(max(1,int(w/.32))): self.flowers((x-w*.34+i*.32,y+.16,z),.18,7)

    def ivy(self, origin, width, drop):
        # Irregular trailing stems with small lobed, turned leaves.
        for j in range(max(2,int(width/.24))):
            x=origin[0]+j*.24+self.rng.uniform(-.1,.1)
            length=drop*(.3+.7*self.rng.random())
            top=(x,origin[1],origin[2]); bottom=(x+.12*math.sin(j),origin[1]-length,origin[2]+.03)
            self.beam('leaf_dark',top,bottom,.012)
            for k in range(max(2,int(length/.13))):
                p=add(top,(self.rng.uniform(-.2,.2),-k*.13+self.rng.uniform(-.08,.08),.04))
                w=.065+self.rng.random()*.055
                angle=self.rng.uniform(-1,1);c,s=math.cos(angle),math.sin(angle)
                outline=[(0,.5),(-.9,.1),(-1,-.8),(-.4,-.7),(0,-2),(.45,-.7),(1,-.8),(.9,.1)]
                points=[add(p,((x*c-y*s)*w,(x*s+y*c)*w,.05)) for x,y in outline]
                center=add(p,(0,-w*.5,.075))
                mat=self.rng.choice(['leaf','leaf','leaf_light','leaf_dark'])
                for i in range(len(points)):
                    a,b=points[i],points[(i+1)%len(points)]
                    self.tri(mat,center,a,b);self.tri(mat,center,b,a)

    def dormer(self, origin, yaw):
        d=Model('dormer')
        d.polygon('lime',[(-.65,0),(.65,0),(.65,1),(0,1.8),(-.65,1)],.8,-.65)
        d.roof(1.65,1.85,1.05,1.9)
        d.window(0,.56,.81,.73,.82)
        self.merge(d,origin,yaw)

    def window(self, x,y,z,w=1.05,h=1.5,shutters=False):
        self.box('timber',(x,y,z+.04),(w+.26,h+.25,.18))
        self.box('glass',(x,y,z+.145),(w,h,.06))
        for xx in [-w/2,0,w/2]: self.box('wood',(x+xx,y,z+.2),(.065,h+.1,.09))
        for yy in [-h/2,0,h/2]: self.box('wood',(x,y+yy,z+.2),(w+.12,.065,.09))
        # Fine leaded lattice inside the pane, clipped to the frame.
        for sign in [-1,1]:
            for offset in [-.66,-.33,0,.33,.66]:
                points=[]
                for u in [-.5,.5]:
                    v=sign*u+offset
                    if -.5<=v<=.5: points.append((u,v))
                for v in [-.5,.5]:
                    u=(v-offset)/sign
                    if -.5<=u<=.5 and (u,v) not in points: points.append((u,v))
                if len(points)==2:
                    a,b=points
                    self.beam('timber',(x+a[0]*w,y+a[1]*h,z+.2),(x+b[0]*w,y+b[1]*h,z+.2),.018)
        self.box('cut_stone',(x,y-h/2-.15,z+.22),(w+.48,.14,.38))
        if y>3.5: self.ivy((x-w*.5,y-h/2-.15,z+.4),w*.8,.7)
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
    m.box('stone',(0,-.7,0),(10,1.8,7.5))
    m.polygon('lime',[(-5,0),(5,0),(5,5.1),(0,9.1),(-5,5.1)],3.75,-3.75)
    m.polygon('wood',[(-4.9,5.12),(4.9,5.12),(0,9.05)],3.79,3.75)
    m.roof(11.5,9.1,5.1,9.3)
    for side in [-1,1]: m.dormer((side*3.3,6.4,-.7),side*math.pi/2)
    for x in [-4.9,-2.5,0,2.5,4.9]:
        m.box('timber',(x,2.6,3.85),(.27,5.2,.24))
    for y in [.22,2.8,5.0]: m.box('timber',(0,y,3.85),(10.1,.19,.18))
    for side in [-1,1]:
        m.beam('timber',(0,8.8,3.87),(side*4.8,5.1,3.87),.19)
        m.beam('timber',(side*2.5,2.9,3.87),(side*4.8,4.9,3.87),.22)
        m.beam('timber',(side*.2,.35,3.88),(side*2.35,2.65,3.88),.21)
        m.ivy((side*2.6,5.15,3.99),1.9,2.7)
    m.door(0,3.8)
    for x in [-3.3,3.3]: m.window(x,1.55,3.82,1.1,1.45,True)
    for x in [-3.3,0,3.3]: m.window(x,3.98,3.82,1.05,1.45,True)
    for side in [-1,1]: m.beam('timber',(side*1.0,5.1,3.89),(side*2.8,6.8,3.89),.15)
    m.window(0,6.7,3.82,1.0,1.35)
    m.box('timber',(0,6.8,3.88),(.18,4.0,.2))
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
    m.box('stone',(0,-.75,0),(7.8,1.8,6.5))
    m.polygon('lime',[(-3.9,0),(3.9,0),(3.9,8.1),(0,11.9),(-3.9,8.1)],3.25,-3.25)
    m.roof(9.1,8.0,8.1,12.2)
    for x in [-3.8,-1.4,1.4,3.8]: m.box('timber',(x,4.05,3.38),(.27,8.1,.25))
    for y in [.3,2.85,5.55,8.0]: m.box('timber',(0,y,3.38),(8,.23,.25))
    for side in [-1,1]:
        m.beam('timber',(0,11.8,3.4),(side*3.8,8.1,3.4),.26)
        for y in [.4,3.0,5.7]:
            m.beam('timber',(side*1.5,y,3.42),(side*3.65,y+2.2,3.42),.18)
        for y in [1.5,4.25,6.95]: m.window(side*2.4,y,3.43,1.0,1.5)
        m.ivy((side*2.9,8.1,3.6),2.1,3.6)
    m.window(0,9.55,3.32,.9,1.35)
    m.door(0,3.3,1.65,True)
    m.elevations(3.9,3.25,[1.6,4.3,6.95],[-1.5,1.5])
    # Attached tower stays inside the building footprint. Exterior only.
    center=(-2.05,0,-1.25)
    m.lathe('stone',[(1.55,0),(1.55,8.6),(1.8,8.7),(1.8,9.0),(1.5,9.05),(1.5,11.1)],center,8)
    m.lathe('wood',[(1.5,8.95),(1.5,11.15)],center,8)
    for j in range(8):
        a=j*math.tau/8
        m.box('timber',(-2.05+1.5*math.cos(a),10.1,-1.25+1.5*math.sin(a)),(.15,2.2,.15))
    # A continuous slate shell keeps the spire watertight and avoids bright ring gaps.
    m.lathe('slate',[(1.95,11.1),(.02,15.06)],center,32)
    m.beam('metal',(-2.05,15.0,-1.25),(-2.05,16.4,-1.25),.045)
    flag=[(-2.05,16.3,-1.25),(-4.3,15.9,-1.16),(-3.8,15.62,-1.23),(-2.05,15.85,-1.25)]
    m.quad('canvas',*flag);m.quad('canvas',*reversed(flag))
    m.write()


def workshop():
    m=Model('stone_workshop')
    m.box('stone',(0,1.45,0),(8,5.3,6.5))
    m.roof(9.5,8.0,4.1,7.05,'slate',1.3)
    m.dormer((2.7,4.9,-.8),math.pi/2)
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
    m.ivy((-3.5,4.0,3.5),2.8,2.2)
    for side in [-1,1]:
        m.box('cut_stone',(side*4.04,.15,0),(.18,.2,6.5))
        m.box('cut_stone',(side*4.04,3.9,0),(.18,.2,6.5))
    m.write()


def fountain():
    m=Model('square_fountain')
    # Same outer footprint as A; broad stepped stone replaces the flower ring.
    m.lathe('stone',[(0,-.1),(3.15,-.1),(3.15,.26),(2.95,.3),(2.95,.48),(2.65,.5),(2.65,.65),(0,.65)],sides=64)
    m.lathe('cut_stone',[(0,.6),(2.35,.6),(2.35,.82),(2.28,1.25),(2.42,1.32),(2.42,1.45),(2.13,1.45),(2.05,1.28),(2.05,.86),(0,.86)],sides=64)
    m.lathe('water',[(2.05,1.06),(0,1.06)],sides=64)
    m.lathe('stone',[(.65,.7),(.65,1.3),(.45,1.45),(.32,3.75),(.18,4.4),(0,4.62)],sides=32)
    for radius,y in [(1.55,1.8),(1.12,2.6),(.66,3.35)]:
        m.lathe('cut_stone',[(.3,y-.35),(radius*.65,y-.2),(radius,y),(radius,y+.15),(radius-.13,y+.18),(radius-.18,y+.04),(.25,y+.04)],sides=64)
        m.lathe('water',[(radius-.15,y+.1),(.25,y+.1)],sides=64)
        for j in range(24):
            a=j*math.tau/24
            for k in range(8):
                t,u=k/8,(k+1)/8
                r0,r1=radius+.12*t,radius+.12*u
                m.beam('water_jet',(math.cos(a)*r0,y+.13-.65*t*t,math.sin(a)*r0),(math.cos(a)*r1,y+.13-.65*u*u,math.sin(a)*r1),.012)
    # Four clearly visible decorative jets arc from the upper bowl into the pool.
    for a in [0,math.pi/2,math.pi,math.pi*1.5]:
        for i in range(32):
            t,u=i/32,(i+1)/32
            def p(t):
                r=.45+1.45*t
                return (math.cos(a)*r,3.47+1.1*t-3.5*t*t,math.sin(a)*r)
            m.beam('water_jet',p(t),p(u),.028)
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



def courtyard_tree():
    m=Model('courtyard_tree')
    m.lathe('timber',[(.34,-.2),(.31,.25),(.21,2.1),(.14,4.8),(.05,6.8)],sides=12)
    for j in range(12):
        a=j*2.39996
        base=(0,2.5+j*.2,0)
        end=(math.cos(a)*(1.3+j*.07),4.6+j*.19,math.sin(a)*(1.3+j*.07))
        m.beam('timber',base,end,.11)
        for k in range(300):
            az=m.rng.random()*math.tau; yy=m.rng.uniform(-1,1); rr=math.sqrt(1-yy*yy)
            p=add(end,(math.cos(az)*rr*1.5,yy*1.1,math.sin(az)*rr*1.5))
            m.leaf(p,.40+m.rng.random()*.26,m.rng.random()*math.tau,m.rng.uniform(-1.1,1.1),['leaf','leaf_light','leaf_dark'][k%3])
    m.write()


def courtyard_link():
    m=Model('courtyard_link')
    for z in [-.85,.85]:
        m.beam('timber',(-6.6,-.13,z),(6.6,-.13,z),.25)
        m.beam('wood',(-6.6,1.08,z),(6.6,1.08,z),.14)
        for j in range(29): m.box('wood',(-6.5+j*13/28,.5,z),(.09,1.0,.09))
        for j in range(32):
            a,b=-6.6+j*13.2/32,-6.6+(j+1)*13.2/32
            m.beam('timber',(a,-.4-1.35*(a/6.6)**2,z),(b,-.4-1.35*(b/6.6)**2,z),.25)
        for x in [-5,-3,0,3,5]: m.beam('timber',(x,-.4-1.35*(x/6.6)**2,z),(x,-.16,z),.12)
    for j in range(44): m.box('wood',(-6.45+j*.3,0,0),(.29,.12,1.85))
    m.write()

def mountain_backdrop():
    m=Model('mountain_backdrop')
    peaks=[(-110,-160,94,65),(-30,-210,142,70),(90,-170,106,61),(175,-95,72,60),(-190,-70,66,60),(155,145,66,65),(-135,160,58,62),(30,220,75,85)]
    def height(x,z):
        r=math.hypot(x,z)
        h=max(.72*h*math.exp(-((x-px)**2+(z-pz)**2)/(w*w)) for px,pz,h,w in peaks)
        rough=math.sin(x*.13+z*.07)*math.cos(z*.17)*4+math.sin(x*.4-z*.21)*1.4
        return max(-3,h+rough)*min(1,max(0,(r-52)/34))-3
    step=5
    for x in range(-280,280,step):
        for z in range(-280,280,step):
            if abs(x)<50 and abs(z)<50: continue
            a,b,c,d=[(xx,height(xx,zz),zz) for xx,zz in [(x,z),(x+step,z),(x+step,z+step),(x,z+step)]]
            for tri in [(a,c,b),(a,d,c)]:
                n=unit(cross(sub(tri[1],tri[0]),sub(tri[2],tri[0])))
                avg=sum(p[1] for p in tri)/3
                mat='snow' if avg>59+math.sin(x*.11+z*.17)*6 and n[1]>.58 else 'mountain'
                m.tri(mat,*tri)
    for rows in m.parts.values():
        for i,row in enumerate(rows):
            x,y,z=row[:3]
            dx=height(x+.5,z)-height(x-.5,z)
            dz=height(x,z+.5)-height(x,z-.5)
            rows[i]=(*row[:3],*unit((-dx,1,-dz)),*row[6:])
    m.write()


if __name__ == '__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    for build in [lodge,guildhall,workshop,fountain,pavilion,courtyard_tree,mountain_backdrop]: build()
