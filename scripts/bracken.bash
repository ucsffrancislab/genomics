#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	while [ $# -gt 0 ] ; do
#		case $1 in
#			--output)
#				shift; output=$1; shift;;
#			*)
#				shift;;
#		esac
#	done

SELECT_ARGS=""
report=""
while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
		-w)
			shift; report=$1; shift;;
#		--output)
#			shift; output=$1; shift;;
#		--report)
#			shift; report=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

#	bracken -d ${KRAKEN_DB} -i ${SAMPLE}.kreport -o ${SAMPLE}.bracken -r ${READ_LEN} -l ${LEVEL} -t ${THRESHOLD}
	bracken $ARGS

#	kraken2 $SELECT_ARGS | gzip > ${f}
#	chmod a-w $f
#
#	kraken2 $ARGS
#	if [ ${f:(-3)} == '.gz' ] ; then
#		mv ${f} ${f%.gz}
#		gzip ${f%.gz}
#	fi
#	if [ -n "${report}" ] && [ ${report:(-3)} == '.gz' ] ; then
#		mv ${report} ${report%.gz}
#		gzip ${report%.gz}
#	fi

	chmod a-w ${f} ${report}
fi

