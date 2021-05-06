#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

if [ $# -gt 0 ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r
	fi
	set -x	#	print expanded command before executing it


	#/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${OUTDIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${OUTDIR}/rollup/

	#/francislab/data1/refs/REdiscoverTE/rollup.R $*
	~/github/ucsffrancislab/REdiscoverTE/rollup.R $*

		
	#		echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt

	#		echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup_repFamily/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup_repFamily.out.txt

else

	INDIR="${PWD}/out"
	sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
	date=$( date "+%Y%m%d%H%M%S" )
	for k in 15 31 ; do for trimmer in bbduk1 bbduk2 bbduk3 cutadapt1 cutadapt2 cutadapt3 ; do
		echo "${trimmer}.k${k}"
		OUTDIR="${PWD}/rollup.${trimmer}.k${k}"
		mkdir -p ${OUTDIR}

		echo -e "sample\tquant_sf_path" > ${OUTDIR}/REdiscoverTE.tsv
		ls -1 ${INDIR}/SFHH00*.${trimmer}.salmon.REdiscoverTE.k${k}/quant.sf \
			| awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${OUTDIR}/REdiscoverTE.tsv

			#--wrap "/francislab/data1/refs/REdiscoverTE/rollup.R \
		${sbatch} --job-name=${trimmer}.k${k}.rollup --time=999 --ntasks=64 --mem=499G \
			--output=${OUTDIR}/rollup.${date}.txt \
			${PWD}/REdiscoverTE_rollup.bash \
			--metadata=${OUTDIR}/REdiscoverTE.tsv \
			--datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ \
			--nozero --threads=64 --assembly=hg38 --outdir=${OUTDIR}/rollup/

	done ; done

fi

