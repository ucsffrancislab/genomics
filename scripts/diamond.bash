#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-o|--out)
			shift; output=$1; shift;;
		*)
			shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	diamond $ARGS
	if [ ${f:(-3)} == '.gz' ] ; then
		mv ${f} ${f%.gz}
		gzip --best ${f%.gz}
	fi
	chmod a-w $f
fi

