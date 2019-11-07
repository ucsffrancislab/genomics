#!/usr/bin/env bash

set -x

#	Merge / unpair data
BASE=/data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed

zcat ${BASE}/${1}_*.fastq.gz | sed -E 's/ ([[:digit:]]):.*$/\/\1/' | gzip > ${BASE}/unpaired/${1}.fastq.gz

