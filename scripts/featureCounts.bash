#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

last_arg=${!#}
#	echo $last_arg
last_arg_dir="${last_arg%/*}/"
#	echo $last_arg_dir
last_arg_file=${last_arg##*/}
#	echo $last_arg_file
last_arg_file_base=".${last_arg_file#*.}"
#	echo $last_arg_file_base
#	echo sed -e \'2s\"${last_arg_dir}\"\"g\' -e \'2s\"${last_arg_file_base}\"\"g\' -i FILE

while [ $# -gt 0 ] ; do
	case $1 in
		-o)
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
	featureCounts $ARGS
	#	-F GFF -t miRNA -g Name -a /data/shared/francislab/refs/fasta/hg38.chr.hsa.gff3 -o testingfc 77.h38au.bowtie2.e2e.bam

	#	sed -e '2s"/data/shared/francislab/data/raw/20191008_Stanford71/trimmed/unpaired/""g' -e '2s/.h38au.subread-dna.bam//g' -i ${f}
	#	strip out just the base name, in this case a number. add an "s" prefix or R will add an "X"
	sed -e "2s\"${last_arg_dir}\"s\"g" -e "2s\"${last_arg_file_base}\"\"g" -i ${f}

	chmod a-w $f
fi

