"""Shared P22-T12 shell dimensions; no engine or desktop dependencies."""
import json
from pathlib import Path

SPECS = json.loads((Path(__file__).resolve().parents[1]/'art/village/upstairs.json').read_text())
BY_MODEL = {s['model']: s for s in SPECS}
FLOOR = 3.32
RUN = 4.6
WIDTH = 1.2


def stair_spec(spec):
    start = spec['depth']/2-.8
    return spec['width']/2-1.0, start, start-RUN


def opening(model_name):
    spec = BY_MODEL.get(model_name)
    if not spec:
        return None
    x, start, end = stair_spec(spec)
    # Original lodge/hall meshes are extended rearward after shell generation.
    return x-.68, x+.68, end/spec['rear_scale'], start+.12


def ceiling(m, width, depth):
    hole = opening(m.name)
    if not hole:
        m.box('wood',(0,3.24,0),(width,.16,depth))
        return
    left,right,back,front = hole
    for a,b in [(-width/2,left),(right,width/2)]:
        m.box('wood',((a+b)/2,3.24,0),(b-a,.16,depth))
    for a,b in [(-depth/2,back),(front,depth/2)]:
        m.box('wood',((left+right)/2,3.24,(a+b)/2),(right-left,.16,b-a))
    # The framed opening remains visible from below; no beam crosses the flight.
    for x in [left-.06,right+.06]:
        m.box('timber',(x,3.04,(back+front)/2),(.12,.24,front-back))
    for z in [back-.06,front+.06]:
        m.box('timber',((left+right)/2,3.04,z),(right-left,.24,.12))


def ceiling_beam(m, width, z):
    hole = opening(m.name)
    if not hole:
        m.box('timber',(0,3.05,z),(width-.4,.19,.18))
        return
    spans = [(-width/2+.2,width/2-.2)]
    if hole and hole[2]-.18 < z < hole[3]+.18:
        spans = [(-width/2+.2,hole[0]),(hole[1],width/2-.2)]
    for a,b in spans:
        if b>a: m.box('timber',((a+b)/2,3.05,z),(b-a,.19,.18))


def upper_shell(m):
    s = BY_MODEL[m.name]
    half,front = s['width']/2,s['depth']/2
    # Shell reaches the actual underside of the overhanging roof at the walls.
    top = s['ridge']+(s['eave']-s['ridge'])*half/(s['roof_width']/2)-.13
    outline = [(-half,FLOOR),(half,FLOOR),(half,top),(0,s['ridge']-.13),(-half,top)]
    m.polygon('lime',outline,front,front-.28)
    m.polygon('lime',outline,-front+.28,-front)
    for side in [-1,1]:
        m.box('lime',(side*(half-.14),(FLOOR+top)/2,0),(.28,top-FLOOR,s['depth']))
        m.box('wood',(side*(half-.30),FLOOR+.12,0),(.10,.24,s['depth']-.4))
    for z in [-front+.30,front-.30]:
        m.box('wood',(0,FLOOR+.12,z),(s['width']-.4,.24,.10))
    # The hall's remaining higher storeys stay closed and decorative.
    if s['kind']=='meeting':
        m.box('wood',(0,6.32,0),(s['width']-.35,.18,s['depth']-.35))


def trim_above_roof(model, spec):
    """Clip hidden exterior faces above the main roof, leaving its inside continuous."""
    def distance(row):
        roof_y=spec['ridge']+(spec['eave']-spec['ridge'])*abs(row[0])/(spec['roof_width']/2)
        return row[1]-roof_y
    for material,rows in model.parts.items():
        clipped=[]
        for i in range(0,len(rows),3):
            polygon=[]
            vertices=rows[i:i+3]
            for a,b in zip(vertices,vertices[1:]+vertices[:1]):
                da,db=distance(a),distance(b)
                if da>=0: polygon.append(a)
                if (da>=0)!=(db>=0):
                    t=da/(da-db)
                    polygon.append(tuple(u+(v-u)*t for u,v in zip(a,b)))
            for j in range(1,len(polygon)-1):
                clipped.extend([polygon[0],polygon[j],polygon[j+1]])
        model.parts[material]=clipped
    model.parts={k:v for k,v in model.parts.items() if v}
