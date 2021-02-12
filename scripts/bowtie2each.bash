#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		--suffix)
			shift; suffix=$1; shift;;
		--extension)
			shift; extension=$1; shift;;
		-x)
			shift; index=$1;
			SELECT_ARGS="${SELECT_ARGS} -x $1"; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

ref=$( basename $index )

for ali in e2e loc ; do
	case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac

	#for ref in $( echo ${refs} | tr ',' '\n') ; do
	for sample in ${dir}/*${suffix}${extension} ; do

		base=$( basename ${sample} ${extension} )
		rgbase=$( basename ${base} ${suffix} )
		outbase=${dir}/${base}

		f="${outbase}.${ref}.bowtie2-${ali}.bam"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected ${f} already exists. Skipping."
		else
			echo "Creating ${f}"

			bowtie2.bash -U ${sample} $SELECT_ARGS ${opt} --rg-id ${rgbase}.${ali} --rg SM:${rgbase} -o ${f}

		fi

	done

done	#	for ali in e2e loc ; do

