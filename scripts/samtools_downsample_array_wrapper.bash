#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo
	echo "add target read count option ..."
	echo "add output filename "
	echo
	echo
	echo $0 --array_file my_commands *bam
	echo
	echo $0 --array_file my_commands --array 25-75 --threads 8 --mem 10G --scratch 200G *bam
	echo
	echo $0 --array_file my_commands --array 10,15,25-35 --threads 8 --mem 10G --scratch 200G *bam
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"
	iterations=1
	read_count=1000000

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			--outdir)
				shift; outdir=$1; shift;;
			--read_count)
				shift; read_count=$1; shift;;
			--iterations)
				shift; iterations=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

	echo "iterations:${iterations}:"
	echo "read_count:${read_count}:"
	echo "outdir:${outdir}:"
	mkdir -p ${outdir}

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools
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

	base=$( basename $line .bam )
	bam=${line}

	echo
	echo "base : ${base}"
	echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	tmpbam=${TMPDIR}/$( basename ${bam} )
	samtools view -F 3844 -q40 -o ${tmpbam} ${bam}
	# 0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
	samtools index ${tmpbam}

#	for i in $( seq ${iterations} ) ; do

#		f=${outdir}/${base}.${i}.bam
		f=${outdir}/${base}.bam

		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#fraction=$(samtools idxstats ${bam} | cut -f3 | awk -v ct=${read_count} 'BEGIN {total=0} {total += $1} END {print ct/total}') 
			fraction=$(samtools idxstats ${tmpbam} | awk -v ct=${read_count} 'BEGIN {total=0} {total += $3} END {print ct/total}') 
			echo "fraction:${fraction}:"

			#	not sure of the order of operations here
			#	fraction, flags or quality first?
			#	I think that they are do them together. The counts are lower than expect.
			#samtools view -b -s ${fraction} --subsample-seed ${i} -F 3844 -q40 -o ${f} ${bam} 
			#	prefiltering into a tmp file is a much better option

			#samtools view -b -s ${fraction} --subsample-seed ${i} -o ${f} ${tmpbam} 
			samtools view -b -s ${fraction} -o ${f} ${tmpbam} 

			samtools index ${f}

			#	select reads that aligned starting at position < 10, sort, count
			#	swap output positions and add a comma, add a header line





#			samtools view ${bam} \
#				| awk '( $4 < 10 ){print $3}' | sort -k1n | uniq -c \
#				| awk '{print $2","$1}' | sed -e "1 i id,${sample}" \
#				| gzip > ${f%.bam}.count.csv.gz




			chmod a-w ${f} ${f}.bai 
		fi

#	done


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

	echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""
	mem=""
	scratch=""
	jobname=$(basename $0)
	time="7-0"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			--array_file)
				shift; array_file=$( realpath $1 ); shift;;
			-@|--ntasks|--threads)
				shift; threads=$1; shift;;
			--mem)
				shift; mem=$1; shift;;
			--jobname)
				shift; jobname=$1; shift;;
			--scratch)
				shift; scratch=$1; shift;;
			--time)
				shift; time=$1; shift;;
			-h*|--h*)
				usage;;
			--outdir|--read_count|--iterations)
				array_options="${array_options} $1 $2"; shift; shift;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks ${1} >> ${array_file}; shift ;;
		esac
	done


	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		if [ -n "${mem}" ] ;then
			# using M so can be more precise-ish
			mem_option="--mem=${mem} "
		else
			mem_option="--mem=$[threads*7500]M "
		fi

		if [ -n "${scratch}" ] ;then
			scratch_option="--gres=scratch:${scratch} "
		else
			scratch_option="--gres=scratch:$[threads*28]G "
		fi

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs


		[ -z "${array}" ] && array="1-${max}"


		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".
		# --time=0 is actually invalid, at least here. Not passing a value results in a 10 minute limit.

		sbatch_command="sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="${jobname}" \
			--time=${time} --nodes=1 --ntasks=${threads} ${mem_option} ${scratch_option} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options}"

		echo
		echo ${sbatch_command}

		array_id=$( ${sbatch_command} )


		echo
		echo "Logging to ${PWD}/logs/$(basename $0).${date}-${array_id}_*.out.log"
		echo
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"
		echo

	else

		echo "No files given"
		usage

	fi

fi

