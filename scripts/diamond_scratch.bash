#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#threads=""
SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--db)
			shift; db=$1; shift;;
		--query)
			shift; query=$1; shift;;
		--out)
			shift; out=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done



## 0. Create job-specific scratch folder that ...
#SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
#mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT

SCRATCH_JOB=$TMPDIR

f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${query} ${SCRATCH_JOB}/
	cp ${db}.dmnd ${SCRATCH_JOB}/

	scratch_db=${SCRATCH_JOB}/$( basename ${db} )
	scratch_query=${SCRATCH_JOB}/$( basename ${query} )
	scratch_out=${SCRATCH_JOB}/$( basename ${out} )

	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	mv --update ${scratch_out} $( dirname ${out} )
	chmod a-w ${out}
fi
