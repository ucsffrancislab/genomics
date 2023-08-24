#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
#set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	echo
	echo "Example: "
	echo
	echo "for v in \$( seq 10 ); do echo \"echo 's(\$v)^2 + c(\$v)^2' | bc -l\" ; done > my_commands"
	echo
	echo "cat my_commands "
	echo "echo 's(1)^2 + c(1)^2' | bc -l"
	echo "echo 's(2)^2 + c(2)^2' | bc -l"
	echo "echo 's(3)^2 + c(3)^2' | bc -l"
	echo "echo 's(4)^2 + c(4)^2' | bc -l"
	echo "echo 's(5)^2 + c(5)^2' | bc -l"
	echo "echo 's(6)^2 + c(6)^2' | bc -l"
	echo "echo 's(7)^2 + c(7)^2' | bc -l"
	echo "echo 's(8)^2 + c(8)^2' | bc -l"
	echo "echo 's(9)^2 + c(9)^2' | bc -l"
	echo "echo 's(10)^2 + c(10)^2' | bc -l"
	echo
	echo $0 --array_file my_commands
	echo c4-log2
	echo Slurm job id::
	echo Thu Aug 24 08:45:55 PDT 2023
	echo Preparing array job :20230824084555281768333:
	echo 
	echo sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --array=1-10%1 --parsable --job-name=commands_array_wrapper.bash --time=7-0 --nodes=1 --ntasks=4 --mem=30000M --gres=scratch:112G --output=/ucsf/logs/commands_array_wrapper.bash.20230824084555281768333-%A_%a.out.log /ucsf/scripts/commands_array_wrapper.bash --array_file /ucsf/my_commands
	echo 
	echo Logging to /ucsf/logs/commands_array_wrapper.bash.20230824084555281768333-1557276_\*.out.log
	echo 
	echo Throttle with ...
	echo scontrol update JobId=1557276 ArrayTaskThrottle=8
	echo
	echo ...
	echo
	echo cat logs/commands_array_wrapper.bash.20230824084555281768333-1557276_10.out.log 
	echo c4-n17
	echo Slurm job id:1557276:
	echo Thu Aug 24 09:05:13 PDT 2023
	echo Running an individual array job
	echo Thu Aug 24 09:05:13 PDT 2023
	echo Running line_number :10:
	echo Using array_file :my_commands:
	echo echo 's(10)^2 + c(10)^2' \| bc -l
	echo Running :echo 's(10)^2 + c(10)^2' \| bc -l:
	echo Thu Aug 24 09:05:13 PDT 2023
	echo .99999999999999999997
	echo Thu Aug 24 09:05:13 PDT 2023
	echo 
	echo
	echo "Usage:"
	echo
	echo $0 --array_file my_commands
	echo
	echo $0 --array_file my_commands --array 25-75 --threads 8 --mem 10G --scratch 200G
	echo
	echo $0 --array_file my_commands --array 10,15,25-35 --threads 8 --mem 10G --scratch 200G
	echo
	exit
}


#	slurm_script is the name of the copy of the script used by the handler when actually run
if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

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

	echo "Running :${line}:"

	date

	eval "${line}"

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Preparing array job :${date}:"
	
	threads="4"
	array=""
	mem=""
	scratch=""
	time="7-0"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			--array_file)
				shift; array_file=$( realpath $1 ); shift;;
			--threads)
				shift; threads=$1; shift;;
			--mem)
				shift; mem=$1; shift;;
			--scratch)
				shift; scratch=$1; shift;;
			--time)
				shift; time=$1; shift;;
			-h*|--h*)
				usage;;
			*)
				echo "Unknown param :${1}:";
				usage;;
		esac
	done

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI 	#	samtools star
	fi

	array_options="--array_file ${array_file} "

	#	-n True if the length of string is non-zero.
	#	-s True if file exists and has a size greater than zero.
	if [ -n "${array_file}" ] && [ -s "${array_file}" ] ; then
		
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

		#	True if the length of string is zero.
		[ -z "${array}" ] && array="1-${max}"

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".
		# --time=0 is actually invalid, at least here. Not passing a valies results in a 10 minute limit.

		sbatch_command="sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
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

