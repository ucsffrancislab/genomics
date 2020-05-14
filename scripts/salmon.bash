#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*



#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		-o|--output)
			shift; output=$1; shift;;
		*)
			shift;;
	esac
done


f=${output}
#
#	NOTE that salmon's output is a directory, not a file so the condition is -d not -f
#
#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	echo "Running salmon"

	salmon $ARGS


#	I copied this from kallisto but have not tested it with salmon yet.


	salmonstatus=$?

	chmod a-w $f

	if [ $salmonstatus -ne 0 ] ; then
		echo "Salmon failed." 
		mv ${f} ${f}.FAILED
	fi

fi

