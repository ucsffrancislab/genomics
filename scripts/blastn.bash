#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

SELECT_ARGS=""
#db=''
#querybase=''
while [ $# -gt 0 ] ; do
	case $1 in
		-db)
			shift; db=$( basename $1 ); SELECT_ARGS="${SELECT_ARGS} -db $1"; shift;;
		-query)
			shift
			query=$1
			#	.fasta.gz or .fasta
			if [ ${query: -3} == '.gz' ]; then
				querybase=${query%.fasta.gz}
				query="<(zcat ${query})"
			else
				querybase=${query%.fasta}
			fi
			SELECT_ARGS="${SELECT_ARGS} -query ${query}";
			shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


##	Search for the output file
#while [ $# -gt 0 ] ; do
#	case $1 in
#		-db)
#			shift; db=$( basename $1 ); shift;;
#		-query)
#			shift; query=$1; shift;;
#		*)
#			shift;;
#	esac
#done

#f=${query/.fasta/.blastn.${db}.txt.gz}
f=${querybase}.blastn.${db}.txt.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	need to eval in case doing the <(zcat ...) thing
	eval "blastn ${SELECT_ARGS} | gzip --best > ${f}"
	chmod a-w $f
fi

