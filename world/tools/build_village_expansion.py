#!/usr/bin/env python3
"""P22-T11 original architecture and trade artifacts; deterministic offline GLBs.

Uses the existing standard-library village writer and named material finishes.
Coordinates: meters, Y up, open front at +Z. No external models or dependencies.
"""
import json
import math
from build_village_models import Model, PALETTE, OUT

PALETTE.update({
    'paper': ('e5d4ac', .95), 'leather': ('704637', .85),
    'book_red': ('854940', .9), 'book_green': ('476557', .9),
    'book_blue': ('4b6574', .9), 'bread': ('c98b46', .95),
    'flour': ('c6b88d', 1), 'ceramic': ('d9c8a0', .6),
    'bottle': ('426451', .4), 'iron': ('414641', .65),
})


def barrel(m, p, r=.38, h=.95):
    m.lathe('wood', [(0,0),(r*.85,0),(r,.25*h),(r, .7*h),(r*.85,h),(0,h)], p, 16)
    for y in [.12*h,.8*h]:
        m.lathe('iron',[(r*.94,y),(r*1.015,y+.045),(r*1.015,y+.10),(r*.94,y+.10)],p,16)
    for j in range(16):
        a=j*math.tau/16
        m.beam('timber',(p[0]+r*.99*math.cos(a),p[1]+.22*h,p[2]+r*.99*math.sin(a)),
               (p[0]+r*.99*math.cos(a),p[1]+.72*h,p[2]+r*.99*math.sin(a)),.012)


def vessel(m, p, r=.16, h=.35, mat='ceramic', handle=False):
    m.lathe(mat, [(0,0),(r*.65,0),(r,.1*h),(r,.65*h),(r*.6,.86*h),
                 (r*.6,h),(r*.48,h),(r*.48,.86*h),(r*.8,.63*h),(r*.7,.12*h),(0,.12*h)],p,20)
    if handle:
        for j in range(12):
            a,b=-math.pi/2+j*math.pi/12,-math.pi/2+(j+1)*math.pi/12
            m.beam(mat,(p[0]+r*.8+r*.65*math.cos(a),p[1]+h*.5+h*.3*math.sin(a),p[2]),
                   (p[0]+r*.8+r*.65*math.cos(b),p[1]+h*.5+h*.3*math.sin(b),p[2]),.035)


def bottle(m, p, r=.09, h=.38):
    m.lathe('bottle',[(0,0),(r,0),(r,h*.65),(r*.38,h*.78),(r*.38,h),(0,h)],p,16)
    m.lathe('paper',[(r*1.01,h*.18),(r*1.01,h*.5)],p,16)
    m.lathe('wood',[(r*.4,h),(r*.4,h+.04),(0,h+.04)],p,12)


def book(m, p, w=.17, h=.42, d=.30, color='book_red'):
    x,y,z=p
    m.box('paper',(x,y+h/2,z),(w-.025,h-.035,d-.025))
    for side in [-1,1]: m.box(color,(x+side*w/2,y+h/2,z),(.022,h,d+.025))
    m.box(color,(x,y+h/2,z+d/2),(w,h,.045))
    for yy in [.08,h-.09]: m.box('metal',(x,y+yy,z+d/2+.025),(w*.8,.018,.008))


def shelf(m, x,z,w=2.6,contents='books'):
    for side in [-1,1]: m.box('wood',(x+side*w/2,1.35,z),(.12,2.7,.54))
    m.box('timber',(x,1.35,z-.25),(w,2.7,.07))
    m.box('wood',(x,2.76,z),(w+.25,.16,.62))
    m.box('wood',(x,.12,z),(w+.16,.2,.6))
    for row,y in enumerate([.32,.91,1.5,2.09]):
        m.box('wood',(x,y,z),(w,.065,.55))
        for j in range(int((w-.18)/.22)):
            xx=x-w/2+.2+j*.22
            if contents=='books':
                book(m,(xx,y+.035,z+.02),h=.34+(j*7+row*3)%5*.035,
                     color=['book_red','book_green','book_blue','leather'][ (j+row)%4])
            elif contents=='jars':
                if j%3:
                    bottle(m,(xx,y+.035,z+.02),h=.29+(j%3)*.04)
                else:
                    m.lathe('ceramic',[(0,0),(.085,0),(.095,.05),(.095,.25),(.08,.28),(0,.28)],(xx,y+.035,z+.02),16)
                    m.lathe('wood',[(.10,0),(.10,.035),(0,.035)],(xx,y+.315,z+.02),16)
            elif contents=='pots' and j%2==0:
                vessel(m,(xx,y+.035,z+.02),.13,.30+(j%3)*.06,'terracotta' if row%2 else 'ceramic',True)


def table(m,x,z,w=2.2,d=.85,h=.88):
    m.box('wood',(x,h-.065,z),(w,.13,d))
    for xx in [-w*.38,w*.38]:
        for zz in [-d*.32,d*.32]: m.box('timber',(x+xx,(h-.13)/2,z+zz),(.13,h-.13,.13))
    m.beam('wood',(x-w*.38,.25,z),(x+w*.38,.25,z),.10)


def bench(m,x,z,w=2):
    m.box('wood',(x,.48,z),(w,.12,.42))
    for xx in [-w*.36,w*.36]: m.box('timber',(x+xx,.22,z),(.18,.44,.36))
    m.beam('wood',(x-w*.36,.2,z),(x+w*.36,.2,z),.09)


def crate(m,p,w=.75):
    x,y,z=p
    m.box('wood',(x,y+.05,z),(w,.1,w*.8))
    for side in [-1,1]:
        for yy in [.16,.33,.50]:
            m.box('wood',(x,y+yy,z+side*w*.4),(w,.12,.045))
            m.box('wood',(x+side*w*.5,y+yy,z),(.045,.12,w*.8))
        for zz in [-w*.35,w*.35]: m.box('timber',(x+side*w*.45,y+.3,z+zz),(.06,.6,.06))


def sack(m,p):
    m.lathe('flour',[(0,0),(.27,0),(.34,.18),(.30,.57),(.12,.73),(.13,.78),(.04,.81),(0,.81)],p,16)
    m.lathe('timber',[(.125,.72),(.13,.75)],p,16)


def loaf(m,p):
    # A rounded, scored loaf with a broad flat sole.
    m.lathe('bread',[(0,0),(.21,0),(.24,.07),(.19,.18),(.08,.23),(0,.24)],p,16)
    for dx in [-.085,.03]: m.beam('flour',(p[0]+dx,p[1]+.223,p[2]-.08),(p[0]+dx+.04,p[1]+.223,p[2]+.08),.025)


def hearth(m,x,z,oven=False):
    for side in [-1,1]: m.box('stone',(x+side*.7,.64,z),(.35,1.28,.9))
    m.box('cut_stone',(x,.08,z+.12),(1.9,.16,1.3))
    m.box('stone',(x,.66,z-.43),(1.5,1.32,.12))
    m.box('iron',(x,.15,z+.1),(1.05,.06,.65))
    # Individual arch stones above an actual open cavity.
    for j in range(12):
        a,b=j*math.pi/12,(j+1)*math.pi/12
        m.polygon('cut_stone',[(x+.52*math.cos(a),.73+.52*math.sin(a)),
                  (x+.78*math.cos(a),.73+.78*math.sin(a)),
                  (x+.78*math.cos(b),.73+.78*math.sin(b)),
                  (x+.52*math.cos(b),.73+.52*math.sin(b))],z+.49,z-.42)
    m.box('stone',(x,2.15,z-.1),(1.4,1.6,.7))
    m.box('cut_stone',(x,1.49,z),(1.95,.16,1.03))
    for j in range(3):
        m.beam('wood',(x-.4+j*.32,.25,z-.1),(x-.28+j*.32,.25,z+.35),.13)
    if oven: m.box('iron',(x,1.5,z+.56),(1.2,.04,.5))


def balance(m,p):
    x,y,z=p
    m.lathe('metal',[(0,0),(.22,0),(.22,.04),(.08,.12),(.04,.6)],p,16)
    m.beam('metal',(x-.36,y+.6,z),(x+.36,y+.6,z),.035)
    for side in [-1,1]:
        xx=x+side*.32
        for zz in [-.12,.12]: m.beam('metal',(xx,y+.59,z),(xx,y+.3,z+zz),.012)
        m.lathe('metal',[(0,0),(.18,.08),(.16,.10),(0,.025)],(xx,y+.22,z),16)


def artifacts(spec):
    m=Model('village_'+spec['id'].lower()+'_artifacts')
    w,d=spec['width'],spec['depth']; back=-d/2+.65; right=w/2-.85
    kind=spec['kind']
    # Furniture stays outside the entrance/central aisle and west worktable.
    bench(m,-2,.85,2.05)
    if kind in ['tavern','hearth']:
        table(m,1.95,.35,2.15,1.05)
        bench(m,1.95,1.3)
        for x,z in [(1.4,.4),(2.3,.25)]: vessel(m,(x,.88,z),.12,.23,handle=True)
        vessel(m,(2.1,.88,.55),.19,.46,'terracotta',True)
        if kind=='hearth':
            hearth(m,-1.9,back)
            for j in range(7): m.beam('wood',(-3.2,.13+(j//3)*.16,back+(j%3)*.17),(-2.6,.13+(j//3)*.16,back+(j%3)*.17),.13)
        else:
            for x in [-2.8,-1.85,-.9]: barrel(m,(x,0,back))
        # Paneled bar and bottle shelves.
        table(m,1.7,back+.2,2.5,.9,1.05)
        m.box('wood',(1.7,.5,back+.6),(2.5,.95,.08))
        for x in [.65,1.35,2.05,2.75]: m.box('timber',(x,.5,back+.66),(.06,.9,.05))
        for y in [1.6,2.2]:
            m.box('wood',(1.7,y,back-.31),(2.6,.08,.34))
            for j in range(7): bottle(m,(.65+j*.32,y+.04,back-.3))
        vessel(m,(1.1,1.05,back+.2),handle=True)
    elif kind in ['inn','meadow']:
        table(m,1.6,back+.2,2.8,1.05,1.0)
        m.box('wood',(1.6,.48,back+.67),(2.8,.86,.09))
        for x in [.5,1.6,2.7]: m.box('timber',(x,.48,back+.74),(.08,.86,.05))
        m.box('paper',(1.3,1.015,back+.3),(.6,.035,.42))
        m.box('leather',(1.3,1,back+.3),(.64,.025,.46))
        m.beam('metal',(1.7,1.03,back+.2),(1.85,1.18,back+.08),.018)
        # Key board, individual brass hooks and pendant key shapes.
        m.box('timber',(1.6,1.95,back-.35),(2.4,1.1,.09))
        for row in range(2):
            for col in range(6):
                x=.6+col*.4; y=1.7+row*.45
                m.beam('metal',(x,y,back-.28),(x,y-.18,back-.17),.025)
                m.box('metal',(x+.04,y-.18,back-.17),(.12,.035,.035))
                m.box('paper',(x,y+.12,back-.29),(.18,.09,.02))
        for i in range(2):
            m.box('leather',(-2.2, .25+i*.48,back), (1.65-i*.2,.46,.8))
            for x in [-2.7,-1.7]: m.box('metal',(x,.25+i*.48,back+.41),(.055,.4,.025))
            m.box('metal',(-2.2,.28+i*.48,back+.43),(.25,.055,.04))
        if kind=='meadow':
            table(m,right,.2,1.0,1.3)
            vessel(m,(right,.88,.2),.18,.36,handle=True)
            loaf(m,(right,.88,-.2))
        else:
            bench(m,right,.3,1.4)
            for j in range(3): m.box('flour',(right,.57+j*.09,.3),(1.0,.08,.4))
    elif kind=='library':
        shelf(m,-2.4,back,3.1)
        shelf(m,1.7,back,3.0)
        side=Model('bookwall'); shelf(side,0,0,3.0)
        m.merge(side,(right+.45,0,-.2),-math.pi/2)
        # Sloped lectern, open book, page seam and pedestal.
        m.box('timber',(1.6,.12,1.6),(.85,.24,.65))
        m.box('wood',(1.6,.64,1.6),(.18,1.05,.18))
        m.beam('wood',(1.6,1.18,1.3),(1.6,.98,1.95),1.0,.10)
        m.beam('paper',(1.6,1.24,1.35),(1.6,1.08,1.87),.8,.025)
        m.beam('leather',(1.6,1.26,1.35),(1.6,1.10,1.87),.012)
    elif kind=='binder':
        shelf(m,-1.9,back,2.7)
        table(m,1.65,back+.25,2.4,1.05)
        for x in [.9,2.4]: m.beam('iron',(x,.9,back+.3),(x,2.0,back+.3),.08)
        m.box('wood',(1.65,1.95,back+.3),(1.8,.17,.45))
        m.beam('iron',(1.65,1.1,back+.3),(1.65,2.2,back+.3),.07)
        m.box('wood',(1.65,1.15,back+.3),(1.35,.13,.7))
        m.box('paper',(1.65,.99,back+.3),(1.0,.22,.6))
        m.beam('wood',(1.3,2.2,back+.3),(2.0,2.2,back+.3),.07)
        table(m,right,.3,1.0,1.2)
        for i in range(6): m.box('paper',(right,.91+i*.055,.3),(.65,.035,.65))
        for i in range(3): m.lathe('paper',[(0,0),(.075,0),(.075,.55),(0,.55)],(right-.3+i*.27,0,1.6),12)
    elif kind=='bakery':
        hearth(m,-2.0,back,True)
        table(m,1.7,back+.15,2.6,1.0)
        m.box('iron',(1.7,.9,back+.25),(2.5,.04,.7))
        for x in [.8,1.45,2.1,2.75]: loaf(m,(x,.92,back+.3))
        for y in [1.5,2.1]:
            m.box('wood',(1.7,y,back-.22),(2.6,.07,.5))
            for x in [.8,1.45,2.1,2.75]: loaf(m,(x,y+.035,back-.18))
        for p in [(right,0,.1),(right-.3,0,1),(right+.05,0,1.65)]: sack(m,p)
        m.beam('wood',(-.85,.2,back+.7),(-.55,2.25,back+.45),.045)
        m.box('wood',(-.8,.48,back+.68),(.42,.6,.06))
    elif kind=='herbs':
        shelf(m,-2.1,back,2.8,'jars'); shelf(m,1.5,back,2.7,'jars')
        table(m,right,.1,1.0,1.3)
        vessel(m,(right,.88,.1),.22,.18,'stone')
        m.beam('cut_stone',(right,.93,.1),(right+.19,1.26,.13),.075)
        for i in range(5):
            x=-2+i
            m.beam('metal',(x,2.9,back+.4),(x,2.5,back+.4),.015)
            for j in range(8): m.leaf((x,2.4,back+.4),.35,j*.78,-.7,'leaf_dark' if j%2 else 'leaf')
        for i in range(3):
            m.box('wood',(right,.2+i*.22,1.7),(.9,.2,.65))
            m.box('metal',(right,.2+i*.22,2.04),(.08,.04,.04))
    elif kind=='store':
        shelf(m,-2.0,back,2.8,'jars')
        table(m,1.8,back+.2,2.5,1.0)
        balance(m,(1.6,.88,back+.2))
        for j in range(3):
            p=(right,0,-.2+j*.9); crate(m,p)
            for k in range(8):
                m.lathe('yellow' if j==0 else 'leaf_light',[(0,0),(.09,.02),(.11,.09),(.07,.16),(0,.18)],
                        (p[0]-.22+(k%3)*.21,.39+(k//6)*.12,p[2]-.17+(k//3)*.17),10)
        sack(m,(.4,0,back+.2)); sack(m,(-.4,0,back+.2))
    elif kind=='pottery':
        hearth(m,-2.1,back,True)
        shelf(m,1.5,back,2.9,'pots')
        m.lathe('wood',[(0,0),(.55,0),(.55,.16),(.17,.2),(.17,.65)],(right,0,.15),24)
        m.lathe('cut_stone',[(0,.65),(.43,.65),(.43,.72),(0,.72)],(right,0,.15),32)
        vessel(m,(right,.72,.15),.18,.38,'terracotta',True)
        for i in range(3): vessel(m,(right-.3+i*.3,0,1.5),.22,.5+i*.12,'terracotta',True)
        for i in range(3): m.box('terracotta',(.1,.1+i*.19,back+.1),(.55,.18,.4))
    m.write()


def architecture(spec):
    m=Model('village_'+spec['id'].lower())
    w,d,e,r=spec['width'],spec['depth'],spec['eave'],spec['ridge']
    front=d/2; half=w/2; kind=spec['kind']; accent=spec['accent']
    wall='stone' if kind in ['hearth','pottery'] else 'lime'
    m.room_shell(w,d,wall)
    if spec['hip']:
        m.box(wall,(0,(3.32+e)/2,0),(w,e-3.32,d))
    else:
        m.polygon(wall,[(-half,3.32),(half,3.32),(half,e),(0,r-.2),(-half,e)],front,-front)
    m.roof(w+1.0,d+1.2,e,r,hip=spec['hip'])
    for side in [-1,1]:
        for z in [-front+.1,0,front-.1]: m.box('timber',(side*(half+.02),e/2,z),(.15,e,.18))
        for y in [.22,3.15,e-.1]: m.box('timber',(side*(half+.02),y,0),(.15,.15,d))
        m.box('timber',(side*(half-.1),e/2,front+.06),(.22,e,.21))
        m.window(side*(half*.62),1.55,front+.02,1.25,1.35,kind not in ['library','pottery'])
        if e>5.0:
            m.window(side*(half*.62),4.25,front+.02,1.05,1.45,True)
            m.beam('timber',(side*1.3,3.3,front+.12),(side*(half-.2),e-.2,front+.12),.16)
        if not spec['hip']: m.beam('timber',(0,r-.25,front+.04),(side*half,e,front+.04),.18)
    for y in [3.15,e-.1]: m.box('timber',(0,y,front+.08),(w,.18,.2))
    m.split_band('timber',0,.22,front+.08,w,.18,.2)
    m.elevations(half,front,[1.6]+([4.3] if e>5.0 else []),[-d*.26,d*.26],e>5)
    if not spec['hip']:
        m.window(0,e+(r-e)*.4,front+.03,.8,1.0)
        m.box('timber',(0,e+(r-e)/2,front+.03),(.14,r-e,.16))
    if kind in ['inn','meadow','library']:
        m.dormer((half*.66,e+.7,-.5),math.pi/2)
        if kind!='library':
            m.box('wood',(0,3.13,front+.65),(w-.8,.18,1.25))
            for j in range(int(w/.28)-2):
                x=-half+.6+j*.28
                m.box('wood',(x,3.68,front+1.22),(.055,.95,.06))
            m.box('timber',(0,4.16,front+1.22),(w-.8,.10,.12))
            for side in [-1,1]: m.beam('timber',(side*(half-1),2.35,front+.05),(side*(half-1),3.02,front+1.15),.14)
    else:
        # Two striped fabric shop canopies leave the lintel and entry visible.
        for side in [-1,1]:
            cx=side*half*.63
            for j in range(8):
                x=cx-.88+j*.22
                mat=accent if j%2 else 'paper'
                canopy=[(x,2.65,front+.25),(x+.22,2.65,front+.25),(x+.22,2.35,front+1.15),(x,2.35,front+1.15)]
                valance=[(x,2.35,front+1.15),(x+.22,2.35,front+1.15),(x+.22,2.18,front+1.15),(x,2.18,front+1.15)]
                for face in [canopy,valance]:
                    m.quad(mat,*face)
                    m.quad(mat,*reversed(face))
            m.beam('iron',(cx-.9,2.6,front+.15),(cx-.9,2.3,front+1.15),.025)
            m.beam('iron',(cx+.9,2.6,front+.15),(cx+.9,2.3,front+1.15),.025)
    # Signboard is an actual framed plaque; text is supplied by Label3D.
    sign_z=front+(1.32 if kind in ['inn','meadow'] else .23)
    m.box('timber',(0,3.65,sign_z),(3.25,.82,.18))
    m.box(accent,(0,3.65,sign_z+.105),(3.05,.65,.045))
    for y in [3.24,4.06]: m.box('metal',(0,y,sign_z+.12),(3.3,.035,.025))
    # Capped masonry chimney, with two ceramic pots.
    x=-half*.65; z=-d*.24
    # Keep the decorative exterior flue above the finished ground-floor ceiling.
    m.box('stone',(x,e+.8,z),(.75,2.2,.8))
    m.box('cut_stone',(x,e+1.94,z),(.98,.16,1.02))
    for dx in [-.22,.22]: m.lathe('tile',[(.12,0),(.12,.45),(.17,.47),(.17,.56),(.08,.56),(.08,0)],(x+dx,e+2.02,z),12)
    for side in [-1,1]:
        m.ivy((side*(half-.6),min(e,4.5),front+.21),.45,1.5)
        # Raised flower boxes flank the doorway, never its walkable ramp.
        m.planter(side*(half*.65),.35,front+.47,.9)
    m.write()


if __name__=='__main__':
    for specification in json.loads((OUT/'expansion.json').read_text()):
        architecture(specification)
        artifacts(specification)
