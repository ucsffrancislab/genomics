#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
FILES=""
while [ $# -gt 0 ] ; do
	case $1 in
		-a)
			shift; anno=$1; shift;;
		-o)
			shift; out=$1; shift;;
		-T)
			shift; threads=$1; shift;;
		*)
			#	this is a tough one. I really only want the last files,
			#	but I don't want to included every option above.
			if [ -f "${1}" ] ; then
				FILES="${FILES} $1"
			else
				SELECT_ARGS="${SELECT_ARGS} $1"
			fi
			shift;;
	esac
done

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	mkdir ${TMPDIR}/input
	cp ${FILES} ${TMPDIR}/input/
	cp ${anno} ${TMPDIR}/

	scratch_anno=${TMPDIR}/$( basename ${anno} )
	scratch_out=${TMPDIR}/$( basename ${out} )

	#featureCounts -a ${scratch_anno} \
	featureCounts.bash -a ${scratch_anno} \
		-o ${scratch_out} \
		-T ${SLURM_NTASKS:-1} \
		${SELECT_ARGS} \
		${TMPDIR}/input/*

	#mv --update ${scratch_out} $( dirname ${out} )
	mv --update ${scratch_out}* $( dirname ${out} )
	chmod a-w ${out}

fi

