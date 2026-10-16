#!/usr/bin/env python3
"""Original P22-T12 timber stairs, guards and modest upstairs furnishings."""
from build_village_models import Model
from build_village_expansion import table, bench, shelf, vessel, book
from village_upper import SPECS, FLOOR, RUN, WIDTH, stair_spec


def build(spec):
    name = spec['id'].lower()
    treads = Model('upstairs_'+name+'_treads')
    room = Model('upstairs_'+name)
    x,start,end = stair_spec(spec)
    steps=20
    rise=FLOOR/steps
    run=RUN/steps
    # Individually modeled steps retain solid treads for panels and objects.
    for i in range(steps):
        y=(i+1)*rise
        z=start-(i+.5)*run
        treads.box('wood',(x,y-.06,z),(WIDTH,.12,run+.015))
        treads.box('wood',(x,y-rise/2,start-i*run-.02),(WIDTH,rise,.04))
        treads.box('timber',(x,y+.007,start-i*run-.025),(WIDTH+.04,.025,.065))
    for side in [-1,1]:
        xx=x+side*(WIDTH/2+.025)
        room.beam('timber',(xx,.02,start),(xx,FLOOR-.12,end),.10,.24)
        room.beam('wood',(xx,1.02,start),(xx,FLOOR+1.02,end),.095)
        for i in range(steps+1):
            z=start-i*run;y=i*rise
            room.box('wood',(xx,y+.52,z),(.07,1.04,.07))
    # Guard the inside and foot of the upstairs opening; the top is the exit.
    left=x-.68;right=x+.68;front=start+.12
    def guard(a,b):
        room.beam('wood',(a[0],FLOOR+1.06,a[1]),(b[0],FLOOR+1.06,b[1]),.11)
        room.beam('timber',(a[0],FLOOR+.14,a[1]),(b[0],FLOOR+.14,b[1]),.09)
        length=((a[0]-b[0])**2+(a[1]-b[1])**2)**.5
        count=max(1,round(length/.22))
        for i in range(count+1):
            t=i/count
            room.box('wood',(a[0]+(b[0]-a[0])*t,FLOOR+.56,a[1]+(b[1]-a[1])*t),(.065,1.05,.065))
    guard((left,end),(left,front));guard((left,front),(right,front))
    # Furnishings are separate from the stair flight and clear worktable pad.
    props=Model('props')
    back=-spec['depth']/2*spec['rear_scale']+.65
    if spec['kind']=='library':
        shelf(props,-1.45,back,3.2)
        table(props,-1.6,1.8,2.0,.9)
        book(props,(-2.1,.88,1.8),w=.2,h=.42)
        bench(props,-1.6,2.65,2.0)
    elif spec['kind']=='meeting':
        table(props,-.5,back+.45,3.2,1.1)
        bench(props,-.5,back+1.45,3.0)
        props.box('paper',(-.5,.90,back+.45),(.6,.035,.4))
        shelf(props,-2.8,1.8,1.2)
    elif spec['kind']=='tavern':
        table(props,-.6,back+.05,2.4,.9)
        bench(props,-.6,back+.95,2.3)
        for xx in [-1.3,0]: vessel(props,(xx,.88,back+.05),.12,.24,handle=True)
        vessel(props,(-.6,.88,back+.05),.17,.4,'terracotta',True)
    else:
        bench(props,-1.3,1.8,2.3)
        for j in range(3): props.box('flour',(-1.3,.57+j*.09,1.8),(1.0,.08,.4))
        for xx in [-2.1,-.4]:
            props.box('leather',(xx,.3,back),(1.4,.6,.8))
            for dx in [-.4,.4]:props.box('metal',(xx+dx,.3,back+.41),(.05,.55,.025))
            props.box('metal',(xx,.35,back+.43),(.23,.05,.04))
    room.merge(props,(0,FLOOR,0),0)
    # Visible pendant hangs from the retained roof or the hall's closed ceiling.
    ceiling_y=6.23 if spec['kind']=='meeting' else spec['ridge']-.15
    room.beam('metal',(0,ceiling_y,0),(0,FLOOR+2.48,0),.03)
    room.lathe('metal',[(.1,0),(.36,.16),(.38,.2),(.1,.23)],(0,FLOOR+2.25,0),24)
    room.lathe('petal_white',[(0,0),(.32,0),(.1,.04),(0,.04)],(0,FLOOR+2.26,0),24)
    treads.write();room.write()


if __name__=='__main__':
    for spec in SPECS: build(spec)
