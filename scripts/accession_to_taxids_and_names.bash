#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

#	set -x


db=/francislab/data1/refs/taxadb/taxadb_full.sqlite

while [ $# -gt 0 ] ; do
	case $1 in
		-d|-db)
			shift; db=$1; shift;;
		-a|-accession)
			shift; accession=$1; shift;;
		*)
			shift;;
	esac
done


#	Trim version from accession

accession=${accession%%.*}

entry=$( sqlite3 ${db} "select t1.lineage_level || ':' || t1.ncbi_taxid || ' ' || t1.tax_name, t2.lineage_level || ':' || t2.ncbi_taxid || ' ' || t2.tax_name, t3.lineage_level || ':' || t3.ncbi_taxid || ' ' || t3.tax_name, t4.lineage_level || ':' || t4.ncbi_taxid || ' ' || t4.tax_name, t5.lineage_level || ':' || t5.ncbi_taxid || ' ' || t5.tax_name, t6.lineage_level || ':' || t6.ncbi_taxid || ' ' || t6.tax_name, t7.lineage_level || ':' || t7.ncbi_taxid || ' ' || t7.tax_name, t8.lineage_level || ':' || t8.ncbi_taxid || ' ' || t8.tax_name from accession a join taxa t1 on t1.ncbi_taxid = a.taxid_id join taxa t2 on t2.ncbi_taxid = t1.parent_taxid join taxa t3 on t3.ncbi_taxid = t2.parent_taxid join taxa t4 on t4.ncbi_taxid = t3.parent_taxid join taxa t5 on t5.ncbi_taxid = t4.parent_taxid join taxa t6 on t6.ncbi_taxid = t5.parent_taxid join taxa t7 on t7.ncbi_taxid = t6.parent_taxid join taxa t8 on t8.ncbi_taxid = t7.parent_taxid where a.accession = '${accession}'" ) 

echo $entry

#echo $entry | sed 's/|/\n/g' | awk -v a=${accession} -F: '{
#	o[$1]=$2;
#}
#END {
#	print "species:",((o["species"]=="")?a:o["species"]);
#	print "genus:",(o["genus"]=="")?a:o["genus"];
#	print "family:",(o["family"]=="")?a:o["family"];
#}'

