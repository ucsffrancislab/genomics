#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI blast
fi
set -x	# print expanded command before executing it


ARGS=$*

SELECT_ARGS=""
#db=''
#querybase=''
while [ $# -gt 0 ] ; do
	case $1 in
		-out)
			shift; out=$1; SELECT_ARGS="${SELECT_ARGS} -out $1"; shift;;
		-db)
			shift; db=$( basename $1 ); SELECT_ARGS="${SELECT_ARGS} -db $1"; shift;;
		-query)
			shift
			query=$1

			#	.fasta.gz or .fasta
#			if [ ${query: -3} == '.gz' ]; then
#				querybase=${query%.fasta.gz}
#				query="<(zcat ${query})"
#			else
#				querybase=${query%.fasta}
#			fi

			if [ ${query: -4} == 'a.gz' ]; then
				querybase=${query%.*a.gz}
				query="<(zcat ${query})"
			elif [ ${query: -1} == 'a' ]; then
				querybase=${query%.*a}
				query="${query}"
			elif [ ${query: -4} == 'q.gz' ]; then
				querybase=${query%.*q.gz}
				query="<(zcat ${query} | sed -n -E '1~4s/^@/>/;1~4s/ ([[:digit:]]):.*$/\/\1/p;2~4p' )"
			elif [ ${query: -1} == 'a' ]; then
				querybase=${query%.*q}
				query="<( cat ${query} | sed -n -E '1~4s/^@/>/;1~4s/ ([[:digit:]]):.*$/\/\1/p;2~4p' )"
			fi

#				query="<( cat ${query} | paste - - - - | cut -f 1,2n| sed 's/@/>/'g | tr -s '\t' '\n' )"

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
#f=${querybase}.blastn.${db}.txt.gz
#f=${querybase}.blastn.${db}.csv.gz
f=${out}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	need to eval in case doing the <(zcat ...) thing
	#eval "blastn ${SELECT_ARGS} | gzip --best > ${f}"
	eval "blastn ${SELECT_ARGS}"

	if [ ${f:(-3)} == '.gz' ] ; then
		mv ${f} ${f%.gz}
		gzip --best ${f%.gz}
	fi

	chmod a-w $f
fi

