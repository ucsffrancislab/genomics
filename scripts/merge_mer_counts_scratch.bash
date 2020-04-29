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
		-o)
			shift; out=$1; shift;;
#		-p|--threads)
#			shift; threads="-p $1"; shift;;
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


f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	## 1. Copy input files from global disk to local scratch
	#cp /data/$USER/sample.fq $SCRATCH_JOB/
	#cp /data/$USER/reference.fa $SCRATCH_JOB/

	mkdir ${SCRATCH_JOB}/input
	cp --archive ${SELECT_ARGS} ${SCRATCH_JOB}/input/

	## 2. Process input files
	#cd $SCRATCH_JOB
	#/path/to/my_pipeline --cores=$PBS_NUM_PPN reference.fa sample.fq > output.bam

#	scratch_infile=${SCRATCH_JOB}/$( basename ${infile} )
	scratch_out=${SCRATCH_JOB}/$( basename ${out} )



	#merge_mer_counts.py ${threads} -o ${scratch_out} ${SCRATCH_JOB}/input/*
	merge_mer_counts.py -p ${PBS_NUM_PPN:-1} -o ${scratch_out} ${SCRATCH_JOB}/input/*




#	## 3. Move output files back to global disk
#	mv output.bam /data/$USER/

	mv --update ${scratch_out} $( dirname ${out} )
	chmod a-w ${out}

fi

