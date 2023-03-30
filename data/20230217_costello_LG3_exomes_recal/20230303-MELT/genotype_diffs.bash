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

	indir=${PWD}/vcfallq60
	outdir=${PWD}/vcfallq60
	mkdir -p ${outdir}

	#bam=${PWD}/in/${args}
	#basename=$( basename ${bam} .bam )
	#vcf=${PWD}/vcfallq60/${args}
	#basename=$( basename ${vcf} .vcf.gz )

	ntasks=${SLURM_NTASKS:-2}

	patient=$( echo ${args} | cut -d" " -f1 )
	normal=$( echo ${args} | cut -d" " -f2 )
	tumor=$( echo ${args} | cut -d" " -f3 )

	normal_letter=$( echo ${normal} | cut -c1 )
	tumor_letter=$( echo ${tumor} | cut -c1 )

	if [[ "XZ" == *"${normal_letter}"* ]] && [[ "XZ" == *"${tumor_letter}"* ]] ; then

		echo "Both samples are X or Z. Processing."

		normal_gts=${indir}/${patient}.${normal}.regions.genotypes.gz
		tumor_gts=${indir}/${patient}.${tumor}.regions.genotypes.gz

		if [ -s ${normal_gts} ] && [ -s ${tumor_gts} ]; then

			echo "Both gts exist. Running."

			trap "{ chmod -R +w $TMPDIR ; }" EXIT

			cp ${normal_gts} ${TMPDIR}
			cp ${tumor_gts} ${TMPDIR}
			scratch_out=${TMPDIR}/${patient}.${normal}.${tumor}.regions.genotype_snp_diffs.tsv

			f=${outdir}/${patient}.${normal}.${tumor}.regions.genotype_snp_diffs.tsv	
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				${PWD}/genotype_diffs.py -o ${scratch_out} ${normal_gts} ${tumor_gts}
				cp ${scratch_out} ${f}
				chmod -w ${f}
			fi

		else

			echo "One of the gts doesn't exist or is empty."

		fi

	else

		echo "Both samples aren't X or Z. Skipping."

	fi

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

	#ls -1 vcfallq60/*vcf.gz | xargs -I% basename % > ${arguments_file}

	tail -n +2 tumor_normal_pairs.tsv > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%16 --job-name=${script} \
		--output="${PWD}/logs/${script}.${date}.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=8 --mem=60G \
		--gres=scratch:250G \
		$( realpath ${0} )

#	64 500 2000
# 32 240 1000
# 16 120  500
#  8  60  250
#  4  30  120
#	 2  15   60
#	 1   7   30




fi

#echo "Complete" #	to ensure job doesn't report as "Failed"

