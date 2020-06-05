#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#threads=""
SELECT_ARGS=""
r1=""
r2=""
u=""
while [ $# -gt 0 ] ; do
	case $1 in
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
		-U)
			shift; u=$1; shift;;
		-o)
			shift; f=$1; shift;;
		-x)
			shift; x=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT


if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	scratch_inputs=""
	if [ -n "${r1}" ] ; then
		cp ${r1} ${SCRATCH_JOB}/
		scratch_inputs="${scratch_inputs} -1 ${SCRATCH_JOB}/$( basename ${r1} )"
	fi
	if [ -n "${r2}" ] ; then
		cp ${r2} ${SCRATCH_JOB}/
		scratch_inputs="${scratch_inputs} -2 ${SCRATCH_JOB}/$( basename ${r2} )"
	fi
	if [ -n "${u}" ] ; then
		cp ${u} ${SCRATCH_JOB}/
		scratch_inputs="${scratch_inputs} -U ${SCRATCH_JOB}/$( basename ${u} )"
	fi

	#	Quick test script so assuming that ${x} includes FULL PATH
	cp ${x}.?.bt2 ${x}.rev.?.bt2 ${SCRATCH_JOB}/

	scratch_out=${SCRATCH_JOB}/$( basename ${f} )
	scratch_x=${SCRATCH_JOB}/$( basename ${x} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	bowtie2.bash ${SELECT_ARGS} -x ${scratch_x} -o ${scratch_out} ${scratch_inputs}

	mv --update ${scratch_out} $( dirname ${f} )
	mv --update ${SCRATCH_JOB}/*.err.txt $( dirname ${f} )
	chmod a-w ${f}
fi
