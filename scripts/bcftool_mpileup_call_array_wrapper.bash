#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments
\rm -f ${arguments_file}.tmp

threads=${SLURM_NTASKS:-4}
extension=".bam"
#IN="${PWD}/in"
#OUT="${PWD}/out"

while [ $# -gt 0 ] ; do
	case $1 in
#		-i|--in)
#			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
#		-o|--out)
#			shift; OUT=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
		-r|--ref)
			shift; ref=$1; shift;;
		-h|--help)
			echo
			echo bcftool_mpileup_call_array_wrapper.bash --ref /PATH/TO/ref_genome.fa trimmed/*bam
			echo
			exit;;
		-*)
			echo
			echo "Unknown params :${1}:"
			echo
			exit ;;
		*)
			realpath --no-symlinks $1 >> ${arguments_file}.tmp
			shift;;
	esac
done

# using M so can be more precise-ish
mem=$[threads*7500]M
scratch_size=$[threads*28]G

if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI bcftools
	fi
	
	date
	
	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	line=$( sed -n "$line_number"p ${arguments_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	#base=$( basename $line ${extension} )
	base=${line%${extension}}
	bam=${line}
	vcf=${base}.vcf.gz
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	echo "bam : $bam"
	echo "vcf : $vcf"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	f="${vcf}"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running bcftools"

		#	not sure if -q 60 is always appropriate here
		# STAR The mapping quality MAPQ (column 5) is 255 for uniquely mapping reads, and int(-10*log10(1-. 1/Nmap)) for multi-mapping reads.
		#	Bowtie 2 generates MAPQ scores between 0–42. BWA generates MAPQ scores between 0–37. 

		#	this calls for all positions with data, not just variants.

		bcftools mpileup -q 60 -Ou -f ${ref} ${bam} | bcftools call -m -Oz -o ${vcf}
		bcftools index ${f}
		chmod -w ${f} ${f}.csi
	fi

	date


else

	mv ${arguments_file}.tmp ${arguments_file}

	#ls -1 ${IN}/*${extension} > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) --ref ${ref} )

	echo "Throttle with ..."
	echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

fi


