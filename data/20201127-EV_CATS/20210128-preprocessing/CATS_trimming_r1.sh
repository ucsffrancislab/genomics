#!/usr/bin/env bash

base=${1%.fastq.gz}
echo $base

cutadapt --trim-n -a GATCGGAAGAGCACACGTCTG -a AGAGCACACGTCTG $1 2> $base.trimmed.A.stderr.txt | cutadapt -u 3 -a A{100} --no-indels -e 0.16666666666666666 - 2> $base.trimmed.B.stderr.txt | cutadapt -O 8 --match-read-wildcards -g GTTCAGAGTTCTACAGTCCGACGATCSSS -m 18 -o $base.trimmed.fastq.gz - > $base.trimmed.C.stdout.txt 2> $base.trimmed.C.stderr.txt

