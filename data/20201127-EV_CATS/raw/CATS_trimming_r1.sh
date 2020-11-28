#!/usr/bin/env bash

cutadapt --trim-n -a GATCGGAAGAGCACACGTCTG -a AGAGCACACGTCTG $1 | cutadapt -u 3 -a A{100} --no-indels -e 0.16666666666666666 - | cutadapt -O 8 --match-read-wildcards -g GTTCAGAGTTCTACAGTCCGACGATCSSS -m 18 -o trimmed_$1 -

