#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#		NOPE. Will be "slurm_script" at runtime
if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI bcftools/1.15.1
	fi
	set -x	#	print expanded command before executing it

	line=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line :${line}:"

	#	Use a 1 based index since there is no line 0.

	args=$( sed -n "$line"p ${arguments_file} )
	echo $args

	if [ -z "${args}" ] ; then
		echo "No line at :${line}:"
		exit
	fi

	echo $args

	outdir=${PWD}/vcf
	mkdir -p ${outdir}
	bam=${PWD}/in/${args}
	basename=$( basename ${bam} .bam )

	#ref=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa
	ref=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.chrXYMT_alts.fa

	bcftools mpileup -Ou -f ${ref} ${bam} \
		| bcftools call -m -Oz -o ${outdir}/${basename}.vcf.gz

#		| bcftools call -mv -Oz -o ${outdir}/${basename}.vcf.gz

	chmod a-w ${outdir}/${basename}.vcf.gz


	bcftools index ${outdir}/${basename}.vcf.gz

	chmod a-w ${outdir}/${basename}.vcf.gz.csi


else

	date=$( date "+%Y%m%d%H%M%S" )

#	cat <<- EOF > ${arguments_file}
#SFHH011AC
#SFHH011BB
#SFHH011BZ
#SFHH011CH
#SFHH011I
#SFHH011S
#SFHH011Z
#SFHH011BO
#	EOF

	ls -1 in/*bam | xargs -I% basename % > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%16 --job-name=${script} \
		--output="${PWD}/logs/${script}.${date}.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=4 --mem=30G \
		$( realpath ${0} )

fi
