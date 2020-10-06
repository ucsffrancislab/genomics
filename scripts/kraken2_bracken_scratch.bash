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

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${TMPDIR}/
	scratch_r1=${TMPDIR}/$( basename ${r1} )
	if [ -n "${r2}" ] ; then
		cp ${r2} ${TMPDIR}/
		scratch_r2=${TMPDIR}/$( basename ${r2} )
	fi
	cp --recursive --dereference ${db} ${TMPDIR}/
	scratch_db=${TMPDIR}/$( basename ${db} )

	if [ -z "${report}" ] ; then
		report=${f%.gz}
		report=${report%.txt}
		report=${report}.report.txt.gz
	fi
	scratch_report=${TMPDIR}/$( basename ${report} )

	scratch_out=${TMPDIR}/$( basename ${f} )

	kraken2.bash ${SELECT_ARGS} --db ${scratch_db} \
		--report ${scratch_report} \
		--output ${scratch_out} ${scratch_r1} ${scratch_r2}






#	bracken.bash ....







	mv --update ${scratch_out} ${f}
	if [ -n "${report}" ] ; then
		mv --update ${scratch_report} ${report}
	fi
	# unnecessary as kraken2.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
