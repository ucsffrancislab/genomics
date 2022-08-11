#!/usr/bin/env bash


l=151

while read chr length a b c ; do
for (( i=1 ; i<=${length}+1-${l} ; i++ )) ; do
samtools faidx -n ${l} hg38.fa ${chr}:${i}-$((i+l-1))
done
done < hg38.fa.fai > hg38.151.fa

