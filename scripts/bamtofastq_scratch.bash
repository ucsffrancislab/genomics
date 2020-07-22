#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		filename=*)
			filename=${1#filename=}; shift;;
		outputdir=*)
			outputdir=${1#outputdir=}; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1


## 0. Create job-specific scratch folder that ...
#SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
#mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT

SCRATCH_JOB=$TMPDIR

#if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $dir ] && [ ! -w $dir ] ; then
#	echo "Write-protected $dir exists. Skipping."
#else
#	echo "Creating $dir"

	cp ${filename} ${SCRATCH_JOB}/
	#cp ${normal}.bai ${SCRATCH_JOB}/

	scratch_filename=${SCRATCH_JOB}/$( basename ${filename} )
	scratch_outputdir=${SCRATCH_JOB}/$( basename ${outputdir} )/out

	mkdir -p ${scratch_outputdir}

	bamtofastq ${SELECT_ARGS} filename=${scratch_filename} outputdir=${scratch_outputdir}

	#mkdir -p $( dirname ${dir} )	#	just in case
	#mv --update ${SCRATCH_JOB}/runDir/* $( dirname ${dir} )
	mkdir -p ${outputdir}
	mv --update ${scratch_outputdir}/* ${outputdir}/
	#chmod -R a-w ${outputdir}
#fi
