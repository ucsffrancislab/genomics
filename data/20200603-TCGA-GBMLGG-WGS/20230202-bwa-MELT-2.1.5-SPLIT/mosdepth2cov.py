#!/usr/bin/env python3

## run as python $script xx.mosdepth.global.dist.txt
import sys

pairs = [map(float, x.split()[1:]) for x in open(sys.argv[1]) if x.startswith("total")]

total = 0
lastp = 0
for dp, p in pairs:
    total += dp * (p - lastp)
    lastp = p
print(total)

