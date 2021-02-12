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
set -x	#	print expanded command before executing it


max=10

while [ $# -gt 0 ] ; do
	case $1 in
		-input)
			shift; input=$1; shift;;
		-db)
			shift; db=$1; shift;;
		-max)
			shift; max=$1; shift;;
		*)
			shift;;
	esac
done

#f=${input/.txt.gz/.${max}.summary.txt.gz}
f=${input}
f=${f%.gz}
f=${f%.csv}
f=${f%.txt}
f=${f}.${max}.summary.txt.gz

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#blastdbcmd -db ${db} -entry_batch <( zcat ${input} | awk -F"\t" '( $11 < '${max}' ){print $1"\t"$2}' | sort | uniq | awk '{print $2}' ) -outfmt "%a %t" | sort | uniq -c | gzip > ${f}
	blastdbcmd -db ${db} -entry_batch <( zcat ${input} | awk -F"\t" '( $11 < '${max}' ){print $1"\t"$2}' | sort | uniq | awk '{print $2}' ) -outfmt "%a %t" | sort | uniq -c | awk '{print $1"\t"$2}' | gzip > ${f}
	chmod a-w $f
fi

