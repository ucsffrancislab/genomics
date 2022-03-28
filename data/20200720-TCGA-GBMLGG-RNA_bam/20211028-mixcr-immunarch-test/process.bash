#!/usr/bin/env bash

OUT="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/out"
mkdir -p ${OUT}

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "

date=$( date "+%Y%m%d%H%M%S" )
threads=8


#	Should have made this an array script like the complete genome processing
#	/francislab/data1/working/20211012-hg38-complete-homology/array_wrapper.bash 


#	sadly there are a couple duplicates which complicate things, so take just the first

for sample in $( ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/??-????-01?-*1_R1*z | xargs -I% basename % | cut -d- -f1,2,3 | uniq ) ; do

	r1=$( ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/${sample}-*1_R1*z | head -1 )
	echo $r1

#	continue

#for r1 in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/06-0???-01?-*1_R1*z ; do
	r2=${r1/_R1./_R2.}
	b=$( basename $r1 1_R1.fastq.gz )
	b=${b%-*}
	b=${b%-*}
	b=${b%-*}
	echo $b

	outbase=${OUT}/${b}

	f=${outbase}.vdjca
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		align=$( ${sbatch} --parsable --job-name=1.${b} --time=480 --nodes=1 --ntasks=$((threads*1)) --mem=$((1*threads*480/64))G --output=${f}.${date}.txt --wrap="~/.local/mixcr-3.0.13/mixcr align --threads $((threads*1)) --species human ${r1} ${r2} ${f}; chmod -w ${f}*" )
		echo $align
	fi

	assemble=""
	f=${outbase}.clns
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${align} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${align} "
		fi
		assemble=$( ${sbatch} ${depend} --parsable --job-name=2.${b} --time=60 --nodes=1 --ntasks=${threads} --mem=$((threads*480/64))G --output=${f}.${date}.txt --wrap="~/.local/mixcr-3.0.13/mixcr assemble --threads ${threads} ${outbase}.vdjca ${f}; chmod -w ${f}*" )
		echo $assemble
	fi

	exportClones=""
	f=${outbase}.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${assemble} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${assemble} "
		fi
		exportClones=$( ${sbatch} ${depend} --parsable --job-name=3.${b} --time=60 --nodes=1 --ntasks=${threads} --mem=$((threads*480/64))G --output=${f}.${date}.txt --wrap="~/.local/mixcr-3.0.13/mixcr exportClones ${outbase}.clns ${f}; chmod -w ${f}*" )
		echo $exportClones
	fi

done

