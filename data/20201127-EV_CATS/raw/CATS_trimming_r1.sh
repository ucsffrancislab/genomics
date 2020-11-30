#!/usr/bin/env bash

cutadapt --trim-n -a GATCGGAAGAGCACACGTCTG -a AGAGCACACGTCTG $1 2> trimmed_$1.A.stderr.txt | cutadapt -u 3 -a A{100} --no-indels -e 0.16666666666666666 - 2> trimmed_$1.B.stderr.txt | cutadapt -O 8 --match-read-wildcards -g GTTCAGAGTTCTACAGTCCGACGATCSSS -m 18 -o trimmed_$1 - > trimmed_$1.C.stdout.txt 2> trimmed_$1.C.stderr.txt

