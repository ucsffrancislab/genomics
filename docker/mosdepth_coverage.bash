#!/usr/bin/env bash

mosdepth -n --fast-mode -t 4 --by 1000 /tmp/mosout $1 2>/dev/null

mosdepth2cov.py /tmp/mosout.mosdepth.global.dist.txt

