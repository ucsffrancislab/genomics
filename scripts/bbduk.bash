#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#out1=""
#	Not all samples are paired so avoid unbound variables by setting to nothing
out2=""
outs=""

while [ $# -gt 0 ] ; do
	case $1 in
		out1=*)
			out1=$( echo $1 | awk -F= '{print $2}' ); shift;;
		out2=*)
			out2=$( echo $1 | awk -F= '{print $2}' ); shift;;
		outs=*)
			outs=$( echo $1 | awk -F= '{print $2}' ); shift;;
		*)
			shift;;
	esac
done

f=${out1}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	~/.local/BBMap/bbduk.sh $ARGS
	chmod a-w $out1 $out2 $outs
fi

