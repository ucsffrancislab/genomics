#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
r2=""
scratch_r2=""
report=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-1|--r1)
			shift; r1=$1; shift;;
		-2|--r2)
			shift; r2=$1; shift;;
		-d|--db)
			shift; db=$1; shift;;
		-o|--output)
			shift; f=$1; shift;;
		--report)
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

	cp ${r1} ${SCRATCH_JOB}/
	scratch_r1=${SCRATCH_JOB}/$( basename ${r1} )
	if [ -n "${r2}" ] ; then
		cp ${r2} ${SCRATCH_JOB}/
		scratch_r2=${SCRATCH_JOB}/$( basename ${r2} )
	fi
	cp --recursive --dereference ${db} ${SCRATCH_JOB}/
	scratch_db=${SCRATCH_JOB}/$( basename ${db} )

	if [ -z "${report}" ] ; then
		report=${f%.gz}
		report=${report%.txt}
		report=${report}.report.txt.gz
	fi
	scratch_report=${SCRATCH_JOB}/$( basename ${report} )

	scratch_out=${SCRATCH_JOB}/$( basename ${f} )

	kraken2.bash ${SELECT_ARGS} --db ${scratch_db} \
		--report ${scratch_report} \
		--output ${scratch_out} ${scratch_r1} ${scratch_r2}

	mv --update ${scratch_out} ${f}
	if [ -n "${report}" ] ; then
		mv --update ${scratch_report} ${report}
	fi
	# unnecessary as kraken2.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
