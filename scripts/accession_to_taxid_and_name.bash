#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

#set -x


db=/francislab/data1/refs/taxadb/taxadb_prot.sqlite
level='species'

while [ $# -gt 0 ] ; do
	case $1 in
		-d|-db)
			shift; db=$1; shift;;
		-l|-level)
			shift; level=$1; shift;;
		-a|-accession)
			shift; accession=$1; shift;;
		*)
			shift;;
	esac
done


#	Trim version from accession

accession=${accession%%.*}

entry=$( sqlite3 ${db} "select t1.parent_taxid, t1.ncbi_taxid, t1.tax_name, t1.lineage_level from accession a join taxa t1 on t1.ncbi_taxid = a.taxid_id where a.accession = '${accession}'" )
if [ -z "${entry}" ] ; then
	#echo "00000000 Accession number '${accession}' not found"
	echo "${accession} not found"
	exit 1
fi

#while [ "$( echo "${entry}" | cut -d \| -f 4 )" != "${level}" ] ; do
#while [[ ",${level}," != *",$( echo "${entry}" | cut -d \| -f 4 ),"* ]] ; do
#while [[ ! ",${level}," =~ .*",$( echo "${entry}" | cut -d \| -f 4 ),".* ]] ; do

while [[ ! ",${level}," == *",$( echo "${entry}" | cut -d \| -f 4 ),"* ]] ; do

	taxid=$( echo "${entry}" | cut -d \| -f 1 )
	entry=$( sqlite3 ${db} "select t1.parent_taxid, t1.ncbi_taxid, t1.tax_name, t1.lineage_level from taxa t1 where t1.ncbi_taxid = '${taxid}'" )
	if [ ${taxid} -eq 1 ] ; then
		#echo "999999999 Accession number '${accession}' doesn't have $level"
		echo "${accession} doesn't have $level"
		exit 1	#break
	fi
done

echo "${entry}" | cut -d \| -f 2,3 --output-delimiter=" "

