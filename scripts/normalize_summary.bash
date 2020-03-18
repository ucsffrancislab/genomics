#!/usr/bin/env bash

set -e  # exit if any command fails
set -u  # Error on usage of unset variables
set -o pipefail

#set -x

numerator=1000000

while [ $# -gt 0 ] ; do
	case $1 in
		-input)
			shift; input=$1; shift;;
		-n|-numerator)
			shift; numerator=$1; shift;;
		-d|-denominator)
			shift; denominator=$1; shift;;
		*)
			shift;;
	esac
done

f=${input}
f=${f%.gz}
f=${f%.csv}
f=${f%.txt}
f=${f}.normalized.txt.gz

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	zcat ${input} | awk -F"\t" -v n=$numerator -v d=$denominator '{ print $1*n/d"\t"$2 }' | gzip > ${f}
	chmod a-w $f
fi

