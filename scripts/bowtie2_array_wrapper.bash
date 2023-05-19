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

bowtie2_options=""
threads=${SLURM_NTASKS:-4}
extension=".bam"
#IN="${PWD}/in"
#OUT="${PWD}/out"
outdir=""

while [ $# -gt 0 ] ; do
	case $1 in
#		-i|--in)
#			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out|--outdir)
			shift; outdir=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
		-x|-r|--ref)
			shift; ref=$1; shift;;
		-h|--help)
			echo
			echo $0 --ref /PATH/TO/ref_genome.fa path/*1.fastq.gz
			echo
			exit;;
		-*)
			#echo
			#echo "Unknown params :${1}:"
			#echo
			#exit ;;
			bowtie2_options="${bowtie2_options} $1"
			shift;;
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
		module load CBI bowtie2 samtools
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
	#bam=${line}
	#vcf=${base}.vcf.gz
	R1=${line}
	#R2=${line/_R1./_R2.}
	R2=${line/1.fastq/2.fastq}

	bam=${base}.$(basename ${ref}).bam
	if [ -n "${outdir}" ] ; then
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

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	f="${bam}"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running bowtie2"

		echo "bowtie2.bash --threads ${SLURM_NTASKS} -x ${ref} -1 ${R1} -2 ${R2} ${bowtie2_options}"

		#chmod -w ${f} ${f}.csi
	fi

	date


else

	mv ${arguments_file}.tmp ${arguments_file}

	#ls -1 ${IN}/*${extension} > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	outdir_option=""
	[ -n "${outdir}" ] && outdir_option="--outdir ${outdir}"

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) -x ${ref} --extension ${extension} ${outdir_option} ${bowtie2_options} )

	echo "Throttle with ..."
	echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

fi


