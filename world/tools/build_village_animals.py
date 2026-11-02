#!/usr/bin/env python3
"""Original articulated village animals, meters/+Y up/+Z forward, no dependencies.

Rebuild five tracked GLBs and their SHA-256 manifest. Geometry is authored as
anatomical cross-sections, tapered limbs and feathers; named joint nodes support
runtime distance-driven gait and feeding without an external animation library.
"""
import hashlib
import json
import math
from pathlib import Path
import struct
from build_village_models import Model

OUT = Path(__file__).resolve().parents[1] / 'art' / 'animals'
COLORS = {'pink':'c99082', 'pink_dark':'a56d65', 'cream':'d9c9a5',
          'white':'e0dccb', 'black':'35332c', 'brown':'8f6442', 'tan':'b58a55',
          'horn':'9b8c6d', 'hoof':'4c453c', 'eye':'171b18', 'shine':'b9baa4',
          'red':'a94030', 'gold':'b58a39', 'feather':'8d5b34', 'feather_light':'b48750'}


def tube(m, mat, rings, sides=14):
    """Cross-sections (x,y,z,radius_x,radius_y), closed along local Z."""
    for a,b in zip(rings,rings[1:]):
        for i in range(sides):
            angles = [i*math.tau/sides,(i+1)*math.tau/sides]
            pts = [(r[0]+r[3]*math.cos(t),r[1]+r[4]*math.sin(t),r[2]) for r,t in [(a,angles[0]),(a,angles[1]),(b,angles[1]),(b,angles[0])]]
            color = mat
            if mat == 'cowcoat':
                x,y,z = [sum(p[j] for p in pts)/4 for j in range(3)]
                color = 'black' if math.sin(z*5+x*4)+math.cos(y*9-z*2)+math.sin(x*11+z*3) > .9 else 'white'
            m.quad(color,*pts)


def oval(m,mat,center,size):
    x,y,z=center;w,h,d=size
    tube(m,mat,[(x,y,z+d*.5*math.sin(t),max(.001,w*.5*math.cos(t)),max(.001,h*.5*math.cos(t))) for t in [-math.pi/2,-1.1,-.65,0,.65,1.1,math.pi/2]])


def limb(m,mat,a,b,ra,rb,sides=10):
    # Curved appendages assembled from short tapered cylindrical sections.
    axis = [b[i]-a[i] for i in range(3)]; length=math.sqrt(sum(v*v for v in axis));axis=[v/length for v in axis]
    ref=(0,0,1) if abs(axis[2])<.9 else (0,1,0)
    side=[axis[1]*ref[2]-axis[2]*ref[1],axis[2]*ref[0]-axis[0]*ref[2],axis[0]*ref[1]-axis[1]*ref[0]]
    n=math.sqrt(sum(v*v for v in side));side=[v/n for v in side]
    up=[axis[1]*side[2]-axis[2]*side[1],axis[2]*side[0]-axis[0]*side[2],axis[0]*side[1]-axis[1]*side[0]]
    def ring(p,r,j): return tuple(p[k]+r*(side[k]*math.cos(j*math.tau/sides)+up[k]*math.sin(j*math.tau/sides)) for k in range(3))
    for j in range(sides):
        m.quad(mat,ring(a,ra,j),ring(a,ra,j+1),ring(b,rb,j+1),ring(b,rb,j))
        m.tri(mat,a,ring(a,ra,j+1),ring(a,ra,j));m.tri(mat,b,ring(b,rb,j),ring(b,rb,j+1))


class Animal:
    def __init__(self,species):
        self.species=species;self.nodes=[{'name':species,'children':[]}];self.parts=[]
    def part(self,name,origin=(0,0,0),parent=0):
        m=Model(name);idx=len(self.nodes)
        self.nodes.append({'name':name,'translation':origin,'mesh':len(self.parts),'children':[]})
        self.nodes[parent]['children'].append(idx);self.parts.append(m)
        return m,idx
    def write(self):
        blob=bytearray();views=[];accessors=[];meshes=[];materials=[]
        for color,hexval in COLORS.items():
            srgb=[int(hexval[i:i+2],16)/255 for i in (0,2,4)]
            linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in srgb]
            materials.append({'name':color,'pbrMetallicRoughness':{'baseColorFactor':linear+[1],'metallicFactor':0,'roughnessFactor':.3 if color=='eye' else .86}})
        for model in self.parts:
            prims=[]
            for mat,rows in model.parts.items():
                # Average shared vertex normals for organic surfaces; preserve
                # deliberate sharp horn, beak and hoof edges.
                if mat not in ['horn','hoof','gold']:
                    normals={}
                    for r in rows:
                        key=tuple(round(v,6) for v in r[:3]);n=normals.setdefault(key,[0.,0.,0.])
                        for k in range(3):n[k]+=r[k+3]
                    smooth=[]
                    for r in rows:
                        n=normals[tuple(round(v,6) for v in r[:3])];length=math.sqrt(sum(v*v for v in n))
                        smooth.append((*r[:3],*(v/length for v in n),*r[6:]))
                    rows=smooth
                attrs={}
                for semantic,start,count in [('POSITION',0,3),('NORMAL',3,3)]:
                    values=[r[start:start+count] for r in rows];offset=len(blob)
                    for v in values:blob.extend(struct.pack('<'+str(count)+'f',*v))
                    views.append({'buffer':0,'byteOffset':offset,'byteLength':len(blob)-offset,'target':34962})
                    acc={'bufferView':len(views)-1,'componentType':5126,'count':len(rows),'type':'VEC3'}
                    if semantic=='POSITION':
                        acc.update(min=[min(v[j] for v in values) for j in range(3)],max=[max(v[j] for v in values) for j in range(3)])
                    accessors.append(acc);attrs[semantic]=len(accessors)-1
                prims.append({'attributes':attrs,'material':list(COLORS).index(mat)})
            meshes.append({'name':model.name,'primitives':prims})
        data={'asset':{'version':'2.0','generator':'Elsewhere original animal authoring'},'scene':0,'scenes':[{'nodes':[0]}],'nodes':self.nodes,'meshes':meshes,'materials':materials,'buffers':[{'byteLength':len(blob)}],'bufferViews':views,'accessors':accessors}
        raw=json.dumps(data,separators=(',',':')).encode();raw+=b' '*(-len(raw)%4);blob+=b'\0'*(-len(blob)%4)
        output=struct.pack('<4sII',b'glTF',2,28+len(raw)+len(blob))+struct.pack('<I4s',len(raw),b'JSON')+raw+struct.pack('<I4s',len(blob),b'BIN\0')+blob
        (OUT/(self.species+'.glb')).write_bytes(output)
        return {'species':self.species,'file':self.species+'.glb','bytes':len(output),'sha256':hashlib.sha256(output).hexdigest(),'triangles':sum(len(rows)//3 for p in self.parts for rows in p.parts.values()),'joints':[n['name'] for n in self.nodes[1:]]}


def quadruped(species):
    # Body length, width, shoulder height, limb height and coat.
    length,width,top,legs,coat={'cow':(1.85,.75,1.42,.78,'cowcoat'),'pig':(1.2,.57,.72,.31,'pink'),'goat':(1.05,.37,.94,.58,'cream'),'dog':(.85,.32,.68,.42,'brown')}[species]
    a=Animal(species);body,_=a.part('Body')
    cy=(top+legs)/2;ry=(top-legs)/2
    tube(body,coat,[(0,cy+dy,length*z,width*w,ry*h) for z,w,h,dy in [(-.5,.01,.02,0),(-.44,.32,.7,0),(-.3,.49,1,0),(0,.5,1.05,-.015),(.28,.46,1,0),(.43,.31,.75,.015),(.5,.01,.03,0)]],18)
    # Four two-segment legs with broad shoulders/haunches, slender lower shanks.
    for j,(x,z) in enumerate([(-1,1),(1,1),(-1,-1),(1,-1)]):
        upper,idx=a.part('Leg%d'%j,(x*width*.34,legs+.015,z*length*.32))
        radius=width*(.22 if z<0 else .18)
        limb(upper,coat if coat!='cowcoat' else 'white',(0,.14 if species=='cow' else .09,0),(0,-legs*.52,-.025*z),radius,radius*.52)
        oval(upper,coat if coat!='cowcoat' else 'white',(0,.04,0),(radius*2.15,.22 if species=='cow' else .14,radius*2.15))
        lower,_=a.part('Shin%d'%j,(0,-legs*.52,-.025*z),idx)
        limb(lower,coat if coat!='cowcoat' else 'white',(0,.02,0),(0,-legs*.48+.04,.025*z),radius*.53,radius*.4)
        oval(lower,'hoof' if species!='dog' else 'black',(0,-legs*.48+.03,.045),(radius*1.25,.12 if species=='cow' else .075,radius*1.7))
        if species in ['cow','goat','pig']:
            lower.box('black',(0,-legs*.48+.035,.045+radius*.65),(.009,.06,.015))
    # Neck attached at withers, then head pivots for grazing/sniffing.
    neck_y=top-.12;neck_z=length*.35
    head,head_idx=a.part('Head',(0,neck_y,neck_z))
    if species=='pig':
        tube(head,'pink',[(0,-.02,0,.20,.21),(0,-.08,.28,.18,.20),(0,-.14,.48,.13,.13),(0,-.14,.51,.115,.10)])
        oval(head,'pink_dark',(0,-.14,.51),(.25,.19,.035))
        for side in [-1,1]:
            oval(head,'black',(side*.047,-.13,.532),(.028,.04,.008))
            head.polygon('pink',[(side*.1,.13),(side*.25,.25),(side*.22,.035)],.14,.10)
        eye_pos=(.165,.01,.29)
    elif species=='cow':
        oval(head,'white',(0,.02,.12),(.38,.44,.48))
        tube(head,'white',[(0,0,.22,.16,.19),(0,-.16,.44,.13,.15),(0,-.24,.63,.14,.10),(0,-.24,.65,.01,.01)])
        oval(head,'pink_dark',(0,-.23,.61),(.3,.18,.16));eye_pos=(.177,.11,.24)
        for side in [-1,1]:
            oval(head,'black',(side*.33,.11,.08),(.35,.13,.16))
            limb(head,'horn',(side*.14,.23,.02),(side*.23,.36,-.02),.045,.025)
            limb(head,'horn',(side*.23,.36,-.02),(side*.24,.43,.015),.025,.003)
        oval(body,'pink_dark',(0,legs-.04,-length*.24),(.29,.22,.34))
        for x in [-.075,.075]:
            for z in [-.1,.05]:limb(body,'pink_dark',(x,legs-.1,-length*.24+z),(x,legs-.19,-length*.24+z),.02,.013)
    else:
        oval(head,coat,(0,.12,.13),(.24,.34,.32))
        tube(head,coat,[(0,.1,.18,.105,.115),(0,-.015,.38,.07,.07),(0,-.02,.44,.055,.05)])
        oval(head,'black',(0,-.02,.44),(.12,.08,.04));eye_pos=(.115,.17,.22)
        for side in [-1,1]:
            if species=='goat':
                oval(head,'cream',(side*.18,.22,.07),(.29,.08,.12))
                limb(head,'horn',(side*.075,.26,.02),(side*.095,.46,-.04),.045,.023)
                limb(head,'horn',(side*.095,.46,-.04),(side*.09,.53,-.15),.023,.002)
                limb(head,'cream',(0,-.09,.26),(0,-.24,.23),.055,.005)
            else:
                head.polygon('brown',[(side*.065,.22),(side*.13,.43),(side*.18,.23)],.09,.03)
                head.polygon('pink_dark',[(side*.09,.25),(side*.13,.37),(side*.15,.25)],.095,.093)
                oval(body,'cream',(0,legs+.16,length*.37),(.22,.25,.16))
    if species in ['cow','goat','dog']:
        rise = .35 if species=='cow' else .22
        reach = .24 if species=='cow' else .15
        for material,rows in head.parts.items():
            head.parts[material]=[(r[0],r[1]+rise,r[2]+reach,*r[3:]) for r in rows]
        a.nodes[head_idx]['translation']=(0,neck_y-rise,neck_z-reach)
        oval(head,'white' if species=='cow' else coat,(0,rise*.45,reach*.45),(.3 if species=='cow' else .19,rise*1.7,reach*1.9))
        eye_pos=(eye_pos[0],eye_pos[1]+rise,eye_pos[2]+reach)
    for side in [-1,1]:
        x,y,z=eye_pos
        oval(head,'eye',(side*x,y,z),(.032,.038,.044))
        oval(head,'shine',(side*(x+.01),y+.008,z+.012),(.008,.01,.01))
    tail,_=a.part('Tail',(0,top-.08,-length*.44))
    if species=='pig':
        pts=[(.06*math.sin(t),-.03+.06*math.cos(t),-.02-t*.014) for t in [i*.5 for i in range(17)]]
    elif species=='cow': pts=[(0,0,0),(0,-.26,-.1),(.04,-.55,-.12),(.03,-.72,-.1)]
    elif species=='dog':pts=[(0,0,0),(0,.1,-.17),(.03,.25,-.29),(.06,.34,-.27)]
    else:pts=[(0,0,0),(0,.13,-.12),(0,.18,-.2)]
    for j,(p,q) in enumerate(zip(pts,pts[1:])):limb(tail,'pink' if species=='pig' else ('white' if species=='cow' else coat),p,q,.016 if species in ['pig','cow'] else .055-j*.012,.012 if species in ['pig','cow'] else max(.005,.043-j*.012))
    if species=='cow':oval(tail,'black',pts[-1],(.09,.19,.09))
    return a


def chicken():
    a=Animal('chicken');body,_=a.part('Body')
    oval(body,'feather',(0,.32,-.035),(.29,.34,.43))
    for side in [-1,1]:
        wing,_=a.part('Wing'+str(side),(side*.125,.35,0))
        for j in range(5):
            oval(wing,'feather_light' if j%2 else 'feather',(side*.013*j,-.015*j,-.025-j*.026),(.055,.16,.2))
    tail,_=a.part('Tail',(0,.38,-.19))
    for j in range(7):
        limb(tail,'black' if j%2 else 'feather',((j-3)*.018,0,0),((j-3)*.033,.20-abs(j-3)*.02,-.16),.03,.004)
    head,_=a.part('Head',(0,.43,.11))
    oval(head,'feather_light',(0,.025,.015),(.15,.23,.14))
    oval(head,'feather_light',(0,.14,.035),(.13,.13,.14))
    limb(head,'gold',(0,.125,.09),(0,.105,.18),.038,.001)
    for j in range(4):oval(head,'red',(0,.205+j%2*.009,.065-j*.025),(.025,.065,.044))
    oval(head,'red',(0,.075,.095),(.035,.075,.045))
    for side in [-1,1]:oval(head,'eye',(side*.061,.15,.065),(.018,.022,.022))
    for j,x in enumerate([-.065,.065]):
        leg,idx=a.part('Leg%d'%j,(x,.23,.015))
        limb(leg,'feather',(0,0,0),(0,-.10,-.015),.04,.022)
        shin,_=a.part('Shin%d'%j,(0,-.10,-.015),idx)
        limb(shin,'gold',(0,0,0),(0,-.105,.015),.014,.011)
        for dx in [-.035,0,.035]:limb(shin,'gold',(0,-.105,.015),(dx,-.115,.08),.01,.003)
        limb(shin,'gold',(0,-.105,.015),(0,-.115,-.035),.008,.002)
    return a


if __name__=='__main__':
    OUT.mkdir(exist_ok=True)
    entries=[(chicken() if s=='chicken' else quadruped(s)).write() for s in ['pig','chicken','dog','goat','cow']]
    (OUT/'manifest.json').write_text(json.dumps({'author':'Elsewhere / Codex','source':'world/tools/build_village_animals.py','units':'meters; +Y up; +Z forward','models':entries},indent=2)+'\n')
    for e in entries:print(e['species'],e['triangles'],e['bytes'])
