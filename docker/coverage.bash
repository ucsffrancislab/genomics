#!/usr/bin/env bash

ave_read_length=$( samtools view -F3844 ${1} | head -1000 | awk '{s+=length($10)}END{print int(s/NR)}' )

aligned_read_count=$( cat ${1}.bai | bamReadDepther | grep "^#" | awk '{s+=$2;s+=$3}END{print s}' )

coverage=$( echo "scale=2; ($aligned_read_count*$ave_read_length)/3088286401" | bc -l )

echo $coverage

