#!/usr/bin/env bash

${PWD}/mosdepth -n --fast-mode -t 4 --by 1000 ${TMPDIR}/mosout $1 2>/dev/null

${PWD}/mosdepth2cov.py ${TMPDIR}/mosout.mosdepth.global.dist.txt

