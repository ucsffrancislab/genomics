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
#		-x)
#			shift; x=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${input} ${TMPDIR}/

#	#	Quick test script so assuming that ${x} includes FULL PATH
#	cp ${x}.?.bt2 ${x}.rev.?.bt2 ${TMPDIR}/

	scratch_input=${TMPDIR}/$( basename ${input} )
	scratch_out=${TMPDIR}/$( basename ${f} )
#	scratch_x=${TMPDIR}/$( basename ${x} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	samtools_view.bash ${SELECT_ARGS} -o ${scratch_out} ${scratch_input}

	#mv --update ${scratch_out} $( dirname ${f} )
	#chmod a-w ${f}
	mv --update ${scratch_out}* $( dirname ${f} )
	chmod a-w ${f}*
fi
