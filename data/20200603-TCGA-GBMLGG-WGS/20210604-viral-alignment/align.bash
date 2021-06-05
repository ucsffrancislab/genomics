#!/usr/bin/env bash


sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
date=$( date "+%Y%m%d%H%M%S" )

mkdir out

for r1 in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sample/*R1.fastq.gz ; do

	echo $r1
	r2=${r1/R1.fastq/R2.fastq}
	echo $r2
	base=$( basename $r1 _R1.fastq.gz )

#	outbase=${PWD}/out/${base}.virus
#	${sbatch} --job-name=${base} --time=999 --ntasks=8 --mem=61G --output=${outbase}.${date}.txt ~/.local/bin/bowtie2_scratch.bash --sort --threads 8 -x --very-sensitive --no-unal -x ${PWD}/virus -1 ${r1} -2 ${r2} -o ${outbase}.bam

#	Most of the above alignments are useless repeats.
#	Virtually nothing aligns below.

	outbase=${PWD}/out/${base}.virus.masked
	${sbatch} --job-name=m${base} --time=999 --ntasks=8 --mem=61G --output=${outbase}.${date}.txt ~/.local/bin/bowtie2_scratch.bash --sort --threads 8 -x --very-sensitive --no-unal -x ${PWD}/virus.masked -1 ${r1} -2 ${r2} -o ${outbase}.bam

done

