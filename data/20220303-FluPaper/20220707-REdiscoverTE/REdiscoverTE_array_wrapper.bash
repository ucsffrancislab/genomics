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

SALMON="/francislab/data1/refs/salmon"
index=${SALMON}/REdiscoverTE.k15
cp -r ${index} ${TMPDIR}/
scratch_index=${TMPDIR}/$( basename ${index} )

IN="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/merged"
OUT="/francislab/data1/working/20220303-FluPaper/20220707-REdiscoverTE/out"
#WORK="/francislab/data1/working/20220303-FluPaper/20220707-REdiscoverTE"

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

#fasta=$( ls -tr1d ${IN}/*fa.gz | sed -n "$line"p )
fasta=$( ls -1 ${IN}/*fa.gz | sed -n "$line"p )
echo $fasta

if [ -z "${fasta}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

base=$( basename ${fasta} .fa.gz )

out_base=${OUT}/${base}.salmon.REdiscoverTE.k15
f=${out_base}
#if [ -d $f ] && [ ! -w $f ] ; then
if [ -d $f ] ; then
	#echo "Write-protected $f exists. Skipping."
	echo "$f exists. Skipping."

	if [ -f ${f}/quant.sf ] ; then
		echo "Gzipping"
		chmod -R +w ${f}
		gzip ${f}/quant.sf
		chmod -R -w ${f}
	fi

else

	cp ${fasta} ${TMPDIR}/
	scratch_fasta=${TMPDIR}/$( basename ${fasta} )
	scratch_out=${TMPDIR}/$( basename ${out_base} )

	~/.local/bin/salmon.bash quant --seqBias --gcBias --index ${scratch_index} \
		--no-version-check \
		--libType A --validateMappings \
		--unmatedReads ${scratch_fasta} \
		-o ${scratch_out} --threads ${SLURM_NTASKS}

	#	GOTTA move an existing dir or we'll move this INTO it.
	if [ -d ${f} ] ; then
		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
		mv ${f} ${f}.${date}
	fi

	chmod -R +w ${scratch_out}	#	so script can move and delete the contents (not crucial but stops error messages)
	gzip ${scratch_out}/quant.sf

	mv ${scratch_out} $( dirname ${f} )
	chmod -R a-w ${f}

	/bin/rm -rf ${scratch_fasta}

fi




echo "Done"
date

exit



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1579%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083

