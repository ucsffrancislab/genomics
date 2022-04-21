#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out"
OUT="/francislab/data1/working/20220303-FluPaper/20220419-REdiscoverTE/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

r1=$( ls -1 ${IN}/*_trimmed.fq.gz | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi



date=$( date "+%Y%m%d%H%M%S" )


#echo $r1
#r2=${r1/_R1./_R2.}
#echo $r2
s=$( basename $r1 _trimmed.fq.gz )
#s=$( basename $r1 ) # SFHH009L_S7_L001_R1_001
#s=${s%%_*}          # SFHH009L



SALMON="/francislab/data1/refs/salmon"

out_base=${OUT}/${s}.salmon.REdiscoverTE.k15
f=${out_base}
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	index=${SALMON}/REdiscoverTE.k15
	threads=8
	~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
		--no-version-check \
		--libType A --validateMappings \
		--unmatedReads ${r1} \
		-o ${out_base} --threads ${threads}
#	-1 ${r1} -2 ${r2} \
fi



echo "Done"
date

exit



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-89%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083

