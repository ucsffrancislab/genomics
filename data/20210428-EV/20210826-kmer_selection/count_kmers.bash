#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "


threads=2
mem=15G

OUT=${PWD}/out
mkdir -p ${OUT}

for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH00???.{bbduk,cutadapt}?.fastq.gz ; do

	echo $f
	base=$( basename ${f} .fastq.gz )
	outbase="${OUT}/${base}"

#	#	read count greater than 25bp
#	o=${outbase}.25.read_count.txt
#	if [ -f $o ] && [ ! -w $o ] ; then
#		echo "Write-protected $o exists. Skipping."
#	else
#		${sbatch} --job-name=${base}rc --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${o%.txt}.${date}.txt \
#			${PWD}/read_count.bash -m 25 -o ${o} ${f}
#	fi
#
#	#	base count greater than 25bp
#	o=${outbase}.25.base_count.txt
#	if [ -f $o ] && [ ! -w $o ] ; then
#		echo "Write-protected $o exists. Skipping."
#	else
#		${sbatch} --job-name=${base}bc --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} --output=${o%.txt}.${date}.txt \
#			${PWD}/base_count.bash -m 25 -o ${o} ${f}
#	fi


#	kid=$( ${sbatch} --parsable --job-name=${base}kmers --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} \
#		--output=${outbase}.kmers_count.${date}.txt \
#		${PWD}/kmers_count.bash -k ${PWD}/kmers.all.txt -i ${f} -o ${outbase} )
#	echo ${kid}


	${sbatch} --parsable --job-name=${base}bt2 --time=60 --ntasks=${threads} --nodes=1 --mem=${mem} \
		--output=${outbase}.kmers_count.bowtie2.${date}.txt \
		~/.local/bin/bowtie2.bash --very-sensitive -U ${outbase}.kmers.all.fastq.gz \
			--threads ${threads} --sort --output ${outbase}.kmers.all.bam \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts 

done


