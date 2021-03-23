#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

while [ $# -gt 0 ] ; do
	case $1 in
		-i)
			shift; input=$1; shift;;
		-o)
			shift; output=$1; shift;;
		*)
			shift;
	esac
done

python3 ~/github/ucsffrancislab/umi/consolidate.py $input $output 15 0.9

mv ${output} ${output%.gz}
gzip ${output%.gz}

chmod -w ${output}

