#!/usr/bin/env bash

cutadapt --trim-n --match-read-wildcards -n 2 -g T{100} -a SSSGATCGTCGG -m 18 -o trimmed_$1 $1

