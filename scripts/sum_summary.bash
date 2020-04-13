#!/usr/bin/env bash

set -e  # exit if any command fails
set -u  # Error on usage of unset variables
set -o pipefail

#set -x

db=/francislab/data1/refs/taxadb/taxadb_full.sqlite
level='species'

while [ $# -gt 0 ] ; do
	case $1 in
		-input)
			shift; input=$1; shift;;
		-d|-db)
			shift; db=$1; shift;;
		-l|-level)
			shift; level=$1; shift;;
#		-s|-summary)
#			shift; summary=$1; shift;;
		*)
			shift;;
	esac
done

#	level can be a level list, separated by commas
#firstlevel=${level%%,*}
firstlevel=${level}

f=${input}
f=${f%.gz}
f=${f%.csv}
f=${f%.txt}
f=${f}.sum-${firstlevel}.txt.gz

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	"cmd | getline r" will return just the first line
	zcat ${input} | awk -F"\t" -v db=$db -v level=$level '{ \
			cmd="accession_to_taxid_and_name.bash -l "level" -d "db" -a \""$2"\""
			cmd | getline r
			close(cmd)
			sums[r]+=$1
		}
		END{
			for( s in sums ){
				print sums[s]"\t"s
			}
		}' | sort -k 2n | gzip > ${f}
	chmod a-w $f
fi

