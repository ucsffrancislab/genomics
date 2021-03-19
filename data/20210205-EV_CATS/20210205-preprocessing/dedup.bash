#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
fi
set -x	#	print expanded command before executing it

ARGS=$*

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
#		-i)
#			shift; input=$1; shift;;
		-o)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


#	Expects sorted input

${PWD}/bin/fumi_tools_dedup ${SELECT_ARGS} --output - | samtools sort -o ${output} -
chmod -w ${output}

