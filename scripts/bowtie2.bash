#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

ARGS=$*

#output=qsub.subread-align.out

ext='loc'	#	I believe that local is the default

#	Search for an input file
while [ $# -gt 0 ] ; do
	case $1 in
		-1|-U)
			shift; input=$1; shift;;
		-x)
			shift; ref=$( basename $1 ); shift;;
		--end-to-end|--very-fast|--fast|--sensitive|--very-sensitive)
			shift; ext='e2e'; shift;;
		--local|--very-fast-local|--fast-local|--sensitive-local|--very-sensitive-local)
			shift; ext='loc'; shift;;
		*)
			shift;;
	esac
done

#	...bowtie2.vs/vsl.refk
echo $input
echo $ref
echo $ext

exit

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	bowtie2 $ARGS
	chmod a-w $f
fi

