#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
FILES=""
while [ $# -gt 0 ] ; do
	case $1 in
		-a)
			shift; anno=$1; shift;;
		-o)
			shift; out=$1; shift;;
		-T)
			shift; threads=$1; shift;;
		*)
			if [ -f "${1}" ] ; then
				FILES="${FILES} $1"
			else
				SELECT_ARGS="${SELECT_ARGS} $1"
			fi
			shift;;
	esac
done


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT


f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	mkdir ${SCRATCH_JOB}/input
	cp ${FILES} ${SCRATCH_JOB}/input/
	cp ${anno} ${SCRATCH_JOB}/

	scratch_anno=${SCRATCH_JOB}/$( basename ${anno} )
	scratch_out=${SCRATCH_JOB}/$( basename ${out} )

	featureCounts -a ${scratch_anno} \
		-o ${scratch_out} \
		-T ${PBS_NUM_PPN:-1} \
		${SELECT_ARGS} \
		${SCRATCH_JOB}/input/*

	mv --update ${scratch_out} $( dirname ${out} )
	chmod a-w ${out}

fi

