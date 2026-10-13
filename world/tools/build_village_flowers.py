#!/usr/bin/env python3
"""Original decorative flower border; reuses the standard-library village writer."""
from build_village_models import Model


def border():
    model = Model('courtyard_flowers')
    # Mixed pink/amber/orange clumps; exposed soil grounds the foliage.
    for x, color in [(-.6, "pink"), (0, "yellow"), (.6, "blue")]:
        model.lathe('soil', [(0, -.025), (.39, -.025), (.34, .015), (0, .015)], (x, 0, 0), 12)
        clump = Model('flower_clump')
        clump.flowers((0, 0, 0), .28, 10)
        if color != 'pink':
            clump.parts.setdefault(color, []).extend(clump.parts.pop('pink'))
        model.merge(clump, (x, 0, 0), x)
    model.write()


if __name__ == '__main__':
    border()
