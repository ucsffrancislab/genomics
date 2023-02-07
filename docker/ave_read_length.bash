#!/usr/bin/env bash

ave_read_length=$( samtools view -F3844 ${1} | head -1000 | awk '{s+=length($10)}END{print int(s/NR)}' )

echo $ave_read_length

