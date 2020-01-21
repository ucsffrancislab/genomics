#!/usr/bin/env bash



mkdir fastq/trimmed
for fq in ${PWD}/fastq/*fastq.gz ; do
bfq=$( basename $fq )
dfq=$( dirname $fq )
ofq="${dfq}/trimmed/${bfq}"
qsub -N ${bfq} -o ${ofq}.out.txt -e ${ofq}.err.txt ~/.local/bin/cutadapt.bash -F "-m 18 -a NNNNNNATCTCGTATGCCGTCTTCTGCTTG -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -o ${ofq} ${fq}"
#qsub -N ${bfq} -l nodes=1:ppn=8 -l vmem=2gb -o ${ofq}.out.txt -e ${ofq}.err.txt ~/.local/bin/cutadapt.bash -F "-j 8 -m 18 -a NNNNNNATCTCGTATGCCGTCTTCTGCTTG -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -o ${ofq} ${fq}"
#ERROR: Running in parallel is not supported on Python 2
done


#	Circulating miR-323-3p is a biomarker for cardiomyopathy and an indicator of phenotypic variability in Friedreich’s ataxia patients
#	https://www.nature.com/articles/s41598-017-04996-9
#	hsa-miR-128-3p, hsa-miR-625-3p, hsa-miR-130b-5p, hsa-miR-151a-5p, hsa-miR-330-3p, hsa-miR-323a-3p, and hsa-miR-142-3p

#	Small RNA-seq analysis of circulating miRNAs to identify phenotypic variability in Friedreich’s ataxia patients
#	https://www.nature.com/articles/sdata201821

#	should have
#	Therefore, we removed the adapter specifying the -b option in Cutadapt. It indicates to the program that the adapter may appear at the beginning (even degraded), within the read, or at the end of the read (even partially).
