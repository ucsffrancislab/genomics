#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

#if [ $( basename ${0} ) == "slurm_script" ] ; then
#	script=${SLURM_JOB_NAME}
#else
#	script=$( basename $0 )
#fi
#
##	PWD preserved by slurm for where job is run? I guess so.
#arguments_file=${PWD}/${script}.arguments
#\rm -f ${arguments_file}.tmp



if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	bowtie2_options=""
	#threads=${SLURM_NTASKS:-4}
	extension="_R1.fastq.gz"
	outdir=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out|--outdir)
				shift; outdir=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			-x|-r|--ref)
				shift; ref=$1; shift;;
			-*)
				#echo
				#echo "Unknown params :${1}:"
				#echo
				#exit ;;
				bowtie2_options="${bowtie2_options} $1"
				shift;;
			*)
				echo "Unexpected argument"
				echo $1
				echo $*
				exit;;
			#	realpath --no-symlinks $1 >> ${arguments_file}.tmp
			#	shift;;
		esac
	done

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI bowtie2 samtools
	fi
	
	date
	
	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	echo "Using array_file :${array_file}:"

	line=$( sed -n "$line_number"p ${array_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	#base=$( basename $line ${extension} )
	base=${line%${extension}}
	#bam=${line}
	#vcf=${base}.vcf.gz
	R1=${line}
	#R2=${line/_R1./_R2.}
	R2=${line/1.fastq/2.fastq}

	bam=${base}.$(basename ${ref}).bam
	if [ -n "${outdir}" ] ; then
		mkdir -p ${outdir}
		bam=${outdir}/$( basename ${bam} )
	fi

	bowtie2_options="${bowtie2_options} -o ${bam}"

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	echo "r1 : $R1"
	echo "r2 : $R2"
	echo "bam : $bam"
	#echo "vcf : $vcf"
	echo 

	date	#=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x  #       print expanded command before executing it

	f="${bam}"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running bowtie2"

		~/.local/bin/bowtie2.bash --threads ${SLURM_NTASKS} -x ${ref} -1 ${R1} -2 ${R2} ${bowtie2_options}

		#chmod -w ${f} ${f}.csi
	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=4

	while [ $# -gt 0 ] ; do
		case $1 in
			-t|--threads)
				shift; threads=$1; shift;;
			-o|--out|--outdir|-e|--extension|-x|-r|--ref)
				array_options="${array_options} $1 $2"
				shift; shift;;
			-h|--help)
				echo
				echo $0 --ref /PATH/TO/ref_genome.fa path/*1.fastq.gz
				echo
				exit;;
			-*)
				array_options="${array_options} $1"
				shift;;
			*)
				#echo "Unexpected argument"
				#echo $1
				#echo $*
				#exit;;
				realpath --no-symlinks $1 >> ${array_file}
				shift;;
		esac
	done

	# using M so can be more precise-ish
	mem=$[threads*7500]M
	scratch_size=$[threads*28]G	#	not always necessary

	max=$( cat ${array_file} | wc -l )

	mkdir -p ${PWD}/logs

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) ${array_options} )

	echo "Throttle with ..."
	echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

fi


