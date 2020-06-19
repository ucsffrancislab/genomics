#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
#r2=""
#scratch_r2=""
report=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-i)
			shift; input=$1; shift;;
		-d)
			shift; db=$1; shift;;
		-o)
			shift; f=$1; shift;;
		-w)
			shift; report=$1; shift;;
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

	cp ${input} ${SCRATCH_JOB}/
	scratch_input=${SCRATCH_JOB}/$( basename ${input} )

	cp --recursive --dereference ${db} ${SCRATCH_JOB}/
	scratch_db=${SCRATCH_JOB}/$( basename ${db} )

	if [ -z "${report}" ] ; then
		report=${f%.gz}
		report=${report%.txt}
		report=${report}.report.txt.gz
	fi
	scratch_report=${SCRATCH_JOB}/$( basename ${report} )

	scratch_out=${SCRATCH_JOB}/$( basename ${f} )

	bracken.bash ${SELECT_ARGS} -d ${scratch_db} \
		-w ${scratch_report} \
		-o ${scratch_out} -i ${scratch_input}

	mv --update ${scratch_out} ${f}
	if [ -n "${report}" ] ; then
		mv --update ${scratch_report} ${report}
	fi
	# unnecessary as bracken.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
