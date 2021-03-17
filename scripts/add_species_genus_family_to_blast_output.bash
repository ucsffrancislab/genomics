#!/usr/bin/env bash

set -e  # exit if any command fails
set -u  # Error on usage of unset variables
set -o pipefail

#set -x

db=/francislab/data1/refs/taxadb/taxadb_full.sqlite

while [ $# -gt 0 ] ; do
	case $1 in
		-input)
			shift; input=$1; shift;;
		-d|-db)
			shift; db=$1; shift;;
		*)
			shift;;
	esac
done

f=${input}
f=${f%.gz}
f=${f%.csv}
f=${f%.tsv}
f=${f%.txt}
f=${f}.species_genus_family.txt.gz

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	"cmd | getline r" will return just the first line

	zcat ${input} | awk -v db=${db} 'BEGIN{ FS=OFS="\t" }{
			species=genus=subfamily=family=""
			split($2,a,".")
			accession=a[1]

			if( ! ( accession in lineage ) ){

				cmd="sqlite3 "db" \"select t1.lineage_level || \x27:\x27 || t1.ncbi_taxid || \x27 \x27 || t1.tax_name, t2.lineage_level || \x27:\x27 || t2.ncbi_taxid || \x27 \x27 || t2.tax_name, t3.lineage_level || \x27:\x27 || t3.ncbi_taxid || \x27 \x27 || t3.tax_name, t4.lineage_level || \x27:\x27 || t4.ncbi_taxid || \x27 \x27 || t4.tax_name, t5.lineage_level || \x27:\x27 || t5.ncbi_taxid || \x27 \x27 || t5.tax_name, t6.lineage_level || \x27:\x27 || t6.ncbi_taxid || \x27 \x27 || t6.tax_name, t7.lineage_level || \x27:\x27 || t7.ncbi_taxid || \x27 \x27 || t7.tax_name, t8.lineage_level || \x27:\x27 || t8.ncbi_taxid || \x27 \x27 || t8.tax_name from accession a join taxa t1 on t1.ncbi_taxid = a.taxid_id join taxa t2 on t2.ncbi_taxid = t1.parent_taxid join taxa t3 on t3.ncbi_taxid = t2.parent_taxid join taxa t4 on t4.ncbi_taxid = t3.parent_taxid join taxa t5 on t5.ncbi_taxid = t4.parent_taxid join taxa t6 on t6.ncbi_taxid = t5.parent_taxid join taxa t7 on t7.ncbi_taxid = t6.parent_taxid join taxa t8 on t8.ncbi_taxid = t7.parent_taxid where a.accession = \x27"accession"\x27\""
				cmd | getline results
				close(cmd)

				split(results,entries,"|")
				for( i in entries ){
					split(entries[i],parts,":")
					l[parts[1]]=parts[2]
				}

				species=(("species" in l)?l["species"]:$2);
				genus=(("genus" in l)?l["genus"]:((species=="")?$2:species));
				subfamily=(("subfamily" in l)?l["subfamily"]:((genus=="")?$2:genus));
				family=(("family" in l)?l["family"]:((subfamily=="")?$2:subfamily));

				#	if not deleted and next record missing field, it will include previous one.
				delete(l)

				lineage[accession]["species"]=species
				lineage[accession]["genus"]=genus
				lineage[accession]["family"]=family
			}

			print $0, lineage[accession]["species"], lineage[accession]["genus"], lineage[accession]["family"]
		}' | gzip > ${f}
	chmod a-w $f
fi

#	sqlite3 /francislab/data1/refs/taxadb/taxadb_full.sqlite  "select a.accession, t1.ncbi_taxid, t1.tax_name, t1.lineage_level, t2.ncbi_taxid, t2.tax_name, t2.lineage_level, t3.ncbi_taxid, t3.tax_name, t3.lineage_level, t4.ncbi_taxid, t4.tax_name, t4.lineage_level, t5.ncbi_taxid, t5.tax_name, t5.lineage_level, t6.ncbi_taxid, t6.tax_name, t6.lineage_level, t7.ncbi_taxid, t7.tax_name, t7.lineage_level, t8.ncbi_taxid, t8.tax_name, t8.lineage_level from accession a join taxa t1 on t1.ncbi_taxid = a.taxid_id join taxa t2 on t2.ncbi_taxid = t1.parent_taxid join taxa t3 on t3.ncbi_taxid = t2.parent_taxid join taxa t4 on t4.ncbi_taxid = t3.parent_taxid join taxa t5 on t5.ncbi_taxid = t4.parent_taxid join taxa t6 on t6.ncbi_taxid = t5.parent_taxid join taxa t7 on t7.ncbi_taxid = t6.parent_taxid join taxa t8 on t8.ncbi_taxid = t7.parent_taxid where a.accession = 'NC_031270'"
