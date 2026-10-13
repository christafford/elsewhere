#!/usr/bin/env python3
"""Original low-cost fir silhouette for P22-T08; standard-library GLB writer."""
import math
from build_village_models import Model, PALETTE

PALETTE.update({'fir': ('344c32', 1), 'fir_tip': ('485d3a', 1)})


def fir():
    m = Model('distant_fir')
    m.lathe('timber', [(.16, 0), (.11, 4.5), (0, 7.8)], sides=8)
    # Separate drooping boughs and overlapping needle sprays break the skyline;
    # no transparent cards, continuous cone skirts or runtime branch animation.
    for tier in range(9):
        y = 1.0 + tier * .72
        radius = 1.95 * (1 - tier / 10)
        for j in range(7):
            angle = (j / 7 + tier * .37) * math.tau
            length = radius * m.rng.uniform(.8, 1.15)
            dy = m.rng.uniform(-.3, -.1)
            tip = (math.sin(angle)*length, y+dy, math.cos(angle)*length)
            m.beam('timber', (0, y+.2, 0), tip, .025 + length*.02)
            for k in range(5):
                t = .18 + k*.13
                base = (tip[0]*t, y+dy*t, tip[2]*t)
                yaw = angle + (.46 if k%2 else -.46)
                m.leaf(base, length*(1.05-t), yaw, .15+m.rng.random()*.25,
                       'fir_tip' if (j+k+tier)%5 == 0 else 'fir')
    m.lathe('fir', [(.27, 6.5), (.20, 7.2), (0, 7.8)], sides=9)
    m.write()


if __name__ == '__main__':
    fir()
