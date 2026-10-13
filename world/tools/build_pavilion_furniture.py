#!/usr/bin/env python3
"""Original P22-T07 furniture. Reuses the deterministic standard-library GLB writer."""
from build_village_models import Model


def desk():
    m = Model('pavilion_worktable')
    # Solid framed plank top with exposed end grain, aprons and trestle joinery.
    for z in [-.4, -.2, 0, .2, .4]:
        m.beam('wood', (-1.2, .9, z), (1.2, .9, z), .10, .195)
    for x in [-1.22, 1.22]:
        m.box('timber', (x, .9, 0), (.08, .12, 1.04))
    for z in [-.40, .40]:
        m.box('timber', (0, .76, z), (2.3, .18, .08))
    for x in [-.9, .9]:
        m.box('timber', (x, .07, 0), (.22, .14, .95))
        for z in [-.32, .32]:
            m.beam('wood', (x, .14, z), (x, .85, z), .12)
        m.beam('wood', (x, .2, -.32), (x, .7, .32), .075)
        for z in [-.46, .46]:
            m.lathe('metal', [(.028, 0), (.028, .012), (0, .012)], (x, .966, z), sides=12)
    m.beam('timber', (-.9, .25, 0), (.9, .25, 0), .10)
    # A broad, quiet pad is a physical placement anchor, not a runtime binding.
    m.box('teal', (0, .965, .02), (1.8, .03, .62))
    for x in [-.88, .88]:
        for z in [-.27, .31]:
            m.box('metal', (x, .982, z), (.10, .004, .018))
    m.write()


def stool():
    m = Model('pavilion_stool')
    m.lathe('wood', [(.32,.49),(.35,.51),(.35,.56),(.32,.58),(0,.58)], sides=32)
    for x in [-.21,.21]:
        for z in [-.21,.21]:
            m.beam('timber',(x,.025,z),(x*.85,.51,z*.85),.065)
        m.beam('wood',(x,.22,-.21),(x,.22,.21),.045)
    for z in [-.21,.21]: m.beam('wood',(-.21,.25,z),(.21,.25,z),.045)
    m.write()


if __name__ == '__main__':
    desk()
    stool()
