#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
#while [ $# -gt 0 ] ; do
while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-o)
			shift; f=$1; shift;;
		-x)
			shift; x=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

input=$1


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

	cp ${input} ${SCRATCH_JOB}/

	#	Quick test script so assuming that ${x} includes FULL PATH
	cp ${x}.?.bt2 ${x}.rev.?.bt2 ${SCRATCH_JOB}/

	scratch_input=${SCRATCH_JOB}/$( basename ${input} )
	scratch_out=${SCRATCH_JOB}/$( basename ${f} )
	scratch_x=${SCRATCH_JOB}/$( basename ${x} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	samtools_view.bash ${SELECT_ARGS} -o ${scratch_out} ${scratch_input}

	mv --update ${scratch_out} $( dirname ${f} )
	chmod a-w ${out}
fi
