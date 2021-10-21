#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "

#IN="/francislab/data1/raw/20211001-EV"	#/SFHH008A_S1_L001_R2_001.fastq.gz
IN="/francislab/data1/working/20211001-EV/20211003-explore/out"	#/*.quality.R1.fastq.gz
OUT="${PWD}/out"
mkdir -p ${OUT}

for r1 in ${IN}/SFHH0*.quality.R1.fastq.gz ; do

	echo $r1
	r2=${r1/.R1./.R2.}
	echo $r2
	s=$( basename $r1 )
	s=${s%%.quality.R1.fastq.gz}

#	b1=${s}.quality.R1.fastq.gz
#	b2=${s}.quality.R2.fastq.gz
#	echo $b1
#	echo $b2

	for i in 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 60 70 80 90 100 110 120 130 140 ; do
		outbase="${OUT}/${s}.quality.${i}"
		f=${outbase}.R1.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
#			if [ -z ${t2id} ] ; then
				depend=""
#			else
#				depend=" --dependency=afterok:${t2id} "
#			fi

#					-m 15 --trim-n \
#					--match-read-wildcards -n 5 \
			id=$( ${sbatch} ${depend} --job-name=${i}${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${outbase}.${date}.out.txt \
				~/.local/bin/cutadapt.bash \
					--error-rate 0.20 \
					-a A{${i}} \
					-G T{${i}} \
					-o ${outbase}.R1.fastq.gz \
					-p ${outbase}.R2.fastq.gz \
					${r1} ${r2} )
			echo $id
		fi
	done

done

