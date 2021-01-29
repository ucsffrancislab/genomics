#!/usr/bin/env bash

base=${1%.fastq.gz}
echo $base

cutadapt --trim-n --match-read-wildcards -n 2 -g T{100} -a SSSGATCGTCGG -m 18 -o $base.trimmed.fastq.gz $1 > $base.trimmed.stdout.txt 2> $base.trimmed.stderr.txt

