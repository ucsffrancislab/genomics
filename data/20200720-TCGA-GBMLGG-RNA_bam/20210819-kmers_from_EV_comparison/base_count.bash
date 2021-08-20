#!/usr/bin/env bash

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-m|--min)
			shift; min=$1; shift;;
		-o|--output)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


#zcat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/02-0047_R1.fastq.gz | paste - - - - | cut -f2 | head | tr -d "\n" | wc -c


c=$( zcat ${SELECT_ARGS} | paste - - - - | cut -f2 | grep -x ".\{${min},\}" |tr -d "\n" | wc --chars )

echo ${c} > ${output}

chmod -w ${output}

