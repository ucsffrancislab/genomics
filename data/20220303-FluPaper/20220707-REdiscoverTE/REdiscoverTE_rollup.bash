#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

OUTBASE="${PWD}/rollup"

if [ $# -gt 0 ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r
	fi
	set -x	#	print expanded command before executing it

	line=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line :${line}:"

	metadata=$( ls -1 rollup/REdiscoverTE.??.tsv | sed -n "${line}"p )

	if [ -z "${metadata}" ] ; then
		echo "No line at :${line}:"
		exit
	fi

	d=$( basename $metadata .tsv )
	d=${d#*.}
	OUTDIR="${OUTBASE}/rollup.${d}"
	mkdir -p ${OUTDIR}

	~/github/ucsffrancislab/REdiscoverTE/rollup.R $* --metadata=${metadata} --outdir=${OUTDIR}/

else

	INDIR="${PWD}/out"
	k=15

	date=$( date "+%Y%m%d%H%M%S" )

	mkdir -p ${OUTBASE}

	ls -1 ${INDIR}/*.salmon.REdiscoverTE.k${k}/quant.sf.gz \
		| awk -F/ '{split($8,a,".");print a[1]"\t"$0}' > ${OUTBASE}/REdiscoverTE.tsv

	#split --lines=1000 --numeric-suffixes --additional-suffix=.tsv ${OUTBASE}/REdiscoverTE.tsv ${OUTBASE}/REdiscoverTE.
	split --lines=100 --numeric-suffixes --additional-suffix=.tsv ${OUTBASE}/REdiscoverTE.tsv ${OUTBASE}/REdiscoverTE.

	for f in ${OUTBASE}/REdiscoverTE.??.tsv ; do
		echo $f
		sed -i '1i sample\tquant_sf_path' $f
	done

	max=$( ls -1 ${OUTBASE}/REdiscoverTE.??.tsv | wc -l )

	mkdir ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%1 --job-name="Rollup" \
		--output="${PWD}/logs/REdiscoverTE.${date}.rollup.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=32 --mem=240G \
		${PWD}/REdiscoverTE_rollup.bash \
			--datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ \
			--nozero --threads=32 --assembly=hg38 

#	Question or no question? That is the question.
#			--datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion/ \

fi

