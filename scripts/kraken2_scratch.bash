#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
r2=""
scratch_r2=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		--r1)
			shift; r1=$1; shift;;
		--r2)
			shift; r2=$1; shift;;
		--db)
			shift; db=$1; shift;;
		--output)
			shift; f=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1

## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT



if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${SCRATCH_JOB}/
	scratch_r1=${SCRATCH_JOB}/$( basename ${r1} )
	if [ -n "${r2}" ] ; then
		cp ${r2} ${SCRATCH_JOB}/
		scratch_r2=${SCRATCH_JOB}/$( basename ${r2} )
	fi
	cp -r ${db} ${SCRATCH_JOB}/
	scratch_db=${SCRATCH_JOB}/$( basename ${db} )

	scratch_out=${SCRATCH_JOB}/$( basename ${f} )

	kraken2.bash ${SELECT_ARGS} --db ${scratch_db} --output ${scratch_out} ${scratch_input}

	mv --update ${scratch_out} ${f}
	# unnecessary as kraken2.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
