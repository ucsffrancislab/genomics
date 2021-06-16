#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

INDIR=/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210615-hkle-chimera-length-test/raw
OUTDIR=/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210615-hkle-chimera-length-test/raw
mkdir -p $OUTDIR

for r1 in ${INDIR}/??-????-???.SVAs_and_HERVs_KWHE.R1.fastq.gz ; do
	echo $r1
	r2=${r1/R1/R2}
	echo $r2

	basename=$( basename $r1 .R1.fastq.gz )

	for r in R1 R2 ; do
	
		separate_id=""
		in_base=${INDIR}/${basename}
		long_out_base=${in_base}.gt101	#.fastq.gz
		short_out_base=${in_base}.lte101	#.fastq.gz
		out_base=${long_out_base}
		f=${out_base}.${r}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			#	LENGTH IS HARD CODED IN SCRIPT
			#	OUTPUT WILL BE IN THE INPUT DIRECTORY
			separate_id=$( ${sbatch} --parsable --job-name=${basename}.${r} \
				--time=180 --ntasks=2 --mem=15G \
				--output=${out_base}.${r}.${date}.txt \
						${PWD}/fastq_separate_by_length.bash ${in_base}.${r}.fastq.gz )
			echo ${separate_id}

		fi

		in_base=${out_base}
		out_base=${in_base}.trimmed
		f=${out_base}.${r}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z "${separate_id}" ] ; then
				depend="--dependency=afterok:${separate_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=${basename}trim --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${r}.${date}.txt \
				~/.local/bin/cutadapt.bash --length 51 --cores 4 --output ${f} ${in_base}.${r}.fastq.gz
		fi

	done

done

