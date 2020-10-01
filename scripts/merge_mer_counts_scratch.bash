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

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	## 1. Copy input files from global disk to local scratch
	#cp /data/$USER/sample.fq $TMPDIR/
	#cp /data/$USER/reference.fa $TMPDIR/

	mkdir ${TMPDIR}/input
	cp --archive ${SELECT_ARGS} ${TMPDIR}/input/

	## 2. Process input files
	#cd $TMPDIR
	#/path/to/my_pipeline --cores=$PBS_NUM_PPN reference.fa sample.fq > output.bam

#	scratch_infile=${TMPDIR}/$( basename ${infile} )
	scratch_out=${TMPDIR}/$( basename ${out} )



	#merge_mer_counts.py ${threads} -o ${scratch_out} ${TMPDIR}/input/*
	merge_mer_counts.py -p ${PBS_NUM_PPN:-1} -o ${scratch_out} ${TMPDIR}/input/*




#	## 3. Move output files back to global disk
#	mv output.bam /data/$USER/

	mv --update ${scratch_out} $( dirname ${out} )
	chmod a-w ${out}

fi

