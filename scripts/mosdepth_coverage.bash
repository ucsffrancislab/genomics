#!/usr/bin/env bash

dir=$( dirname $0 )

${dir}/mosdepth -n --fast-mode -t 4 --by 1000 ${TMPDIR}/mosout $1 2>/dev/null

${dir}/mosdepth2cov.py ${TMPDIR}/mosout.mosdepth.global.dist.txt

