#!/usr/bin/env bash



mkdir fastq/trimmed
for fq in ${PWD}/fastq/*fastq.gz ; do
bfq=$( basename $fq )
dfq=$( dirname $fq )
ofq="${dfq}/trimmed/${bfq}"
qsub -N ${fq} -l nodes=1:ppn=8 -l vmem=2gb -o ${ofq}.out.txt -e ${ofq}.err.txt ~/.local/bin/cutadapt.bash -F "-j 8 -m 18 -a NNNNNNATCTCGTATGCCGTCTTCTGCTTG -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -o ${ofq} ${fq}"
done



