#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

input=$1

## 0. Create job-specific scratch folder that ...
#SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
#mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT

SCRATCH_JOB=$TMPDIR

f=${input}.length_hist.csv.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${input} ${SCRATCH_JOB}/

	scratch_input=${SCRATCH_JOB}/$( basename ${input} )
	scratch_out=${SCRATCH_JOB}/$( basename ${f} )

	read_length_hist.bash ${scratch_input}

	mv --update ${scratch_out} $( dirname ${f} )
	chmod a-w ${out}
fi
