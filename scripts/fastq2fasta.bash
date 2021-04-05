#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#ARGS=$*

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-o)
#			shift; output=$1; shift;;
#		*)
#			shift;;
#	esac
#done

f=${2}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#cutadapt $ARGS

	if [ ${1: -3} == '.gz' ]; then
		command="zcat ${1}"
	else
		command="cat ${1}"
	fi
	command="${command} | sed -n -E '1~4s/^@/>/;1~4s/ ([[:digit:]]):.*$/\/\1/;1~4p;2~4p'"
	if [ ${2: -3} == '.gz' ]; then
		command="${command} | gzip"
	fi
	command="${command} > ${f}"
	eval $command
	chmod a-w $f
fi

