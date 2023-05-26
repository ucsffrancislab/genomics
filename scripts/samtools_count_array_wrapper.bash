#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
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

#threads=${SLURM_NTASKS:-4}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools #star/2.7.7a
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

	base=$( basename $line .bam )
	bam=${line}

	echo
	echo "base : ${base}"
	echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x

	f=${bam%.bam}.read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view $* -c -F2304 ${bam} > ${f}
		chmod a-w $f
	fi

# 0x900	2304	SECONDARY,SUPPLEMENTARY
# 0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY

#   0x1     1  PAIRED         paired-end / multiple-segment sequencing technology
#   0x2     2  PROPER_PAIR    each segment properly aligned according to aligner
#   0x4     4  UNMAP          segment unmapped
#   0x8     8  MUNMAP         next segment in the template unmapped
#  0x10    16  REVERSE        SEQ is reverse complemented
#  0x20    32  MREVERSE       SEQ of next segment in template is rev.complemented
#  0x40    64  READ1          the first segment in the template
#  0x80   128  READ2          the last segment in the template
# 0x100   256  SECONDARY      secondary alignment
# 0x200   512  QCFAIL         not passing quality controls or other filters
# 0x400  1024  DUP            PCR or optical duplicate
# 0x800  2048  SUPPLEMENTARY  supplementary alignment

	date


else

	threads=${SLURM_NTASKS:-4}
	mem=$[threads*7500]M
	scratch_size=$[threads*28]

	\rm -f ${arguments_file}

	while [ $# -gt 0 ] ; do
		case $1 in
			-@|--threads)
				shift; threads=$1; shift;;
			-h|--help)
				echo
				echo "Good question"
				echo
				exit;;
			*)
				echo "Unknown params :${1}: Assuming file"; 
				realpath --no-symlinks ${1} >> ${arguments_file}
				shift
				;;
		esac
	done

	if [ -f ${arguments_file} ] ; then
		max=$( cat ${arguments_file} | wc -l )

		mkdir -p ${PWD}/logs
		date=$( date "+%Y%m%d%H%M%S%N" )

		#--gres=scratch:${scratch_size}G \

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%10 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) --threads ${threads} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No arguments passed"

	fi

fi

