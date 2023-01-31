#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

#hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools	#/1.10
fi
#set -x

ARGS=$*

#	#	Search for the output file
#	while [ $# -gt 0 ] ; do
#		case $1 in
#			-o)
#				shift; output=$1; shift;;
#			*)
#				shift;;
#		esac
#	done

#	No easily computable output file so pick custom argument, pass on the rest

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-c*|--chr*)
			shift; chr=$1; shift;;
		-p*|--pos*)
			shift; pos=$1; shift;;
		-b*|--bam*)
			shift; bam=$1; shift;;
#			SELECT_ARGS="${SELECT_ARGS} -o $1"; shift;;
#		*)		#	NEEEEEEED THIS!
#			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#f=${output}
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	echo "Creating $f"
#	#	samtools $SELECT_ARGS > ${f}
#	#	eval "samtools $SELECT_ARGS > ${f}"
#	if [ ${output: -3} == '.gz' ] ; then
#		cmd="${cmd} | gzip --best"
#	fi
#	cmd="${cmd} > ${f}"
#	eval "${cmd}"
#	samtools view $ARGS


	#	This may be wrong if clipped

	#echo samtools view ${bam} ${chr}:${pos}-${pos} #$| awk -F"\t" '{print $3 - $4 - $10}'
	#samtools view ${bam} ${chr}:${pos}-${pos} | awk -F"\t" -v pos=$pos '{p=1+pos-$4;print $3,$4,substr($10,p,1),$10}'
	samtools view ${bam} ${chr}:${pos}-${pos} | awk -F"\t" -v pos=$pos '{p=1+pos-$4;print substr($10,p,1)}'

#	chmod a-w $f
#fi

