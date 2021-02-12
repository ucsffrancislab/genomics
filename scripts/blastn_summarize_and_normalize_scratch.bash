#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x	#	print expanded command before executing it

levels="species,genus"
unmapped_read_count=""
db="/francislab/data1/refs/taxadb/taxadb_full.sqlite"
accession="accession"
max=10

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--input)
			shift; input=$1; shift;;
		-l|--levels)
			shift; levels=$1; shift;;
		-u|--unmapped_read_count)
			shift; unmapped_read_count=$1; shift;;
		-d|--db)
			shift; db=$1; shift;;
		-a|--accession)
			shift; accession=$1; shift;;
		-max)
			shift; max=$1; shift;;
	esac
done

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

#	Ex.
#	input="${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz"

inbase=${input%.csv.gz}
scratch_inbase=${TMPDIR}/$( basename ${inbase} )

f="${inbase}.summary.txt.gz"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	cp --archive ${input} ${TMPDIR}/
	scratch_input=${TMPDIR}/$( basename ${input} )
	#~/.local/bin/blastn_summary.bash -input ${TMPDIR}/$( basename ${input} )

	gunzip ${scratch_input}
	awk -F"\t" '( $11 < '${max}' ){print $1"\t"$2}' ${scratch_input%.gz} \
		> ${scratch_input%.gz}.read.acc.txt
	sort --buffer-size 200M --parallel 4 ${scratch_input%.gz}.read.acc.txt \
		> ${scratch_input%.gz}.read.acc.sorted.txt
	uniq ${scratch_input%.gz}.read.acc.sorted.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.txt
	awk '{print $2}' ${scratch_input%.gz}.read.acc.sorted.uniq.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.acc.txt
	sort --buffer-size 200M --parallel 4 ${scratch_input%.gz}.read.acc.sorted.uniq.acc.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.txt
	uniq -c ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.uniqc.txt
	awk '{print $1"\t"$2}' ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.uniqc.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.uniqc.format.txt
	gzip --stdout ${scratch_input%.gz}.read.acc.sorted.uniq.acc.sorted.uniqc.format.txt \
		> ${scratch_inbase}.summary.txt.gz
	chmod a-w ${scratch_inbase}.summary.txt.gz

	cp --archive ${scratch_inbase}.summary.txt.gz $( dirname ${input} )
fi

summary=$f
scratch_summary=${TMPDIR}/$( basename ${summary} )

#			normalize

if [ -n "${unmapped_read_count}" ] ; then
	echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."

	f="${inbase}.summary.normalized.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		if [ ! -f ${scratch_summary} ] ; then
			cp --archive ${inbase}.summary.txt.gz ${TMPDIR}/
		fi

		#	~/.local/bin/normalize_summary.bash -input ${scratch_summary} -d ${unmapped_read_count}

		gunzip -c ${scratch_summary} > ${TMPDIR}/tmp_summary
		awk -F"\t" -v n=1000000 -v d=${unmapped_read_count} '{ print $1*n/d"\t"$2 }' \
			${TMPDIR}/tmp_summary > ${TMPDIR}/tmp_normal
		gzip -c ${TMPDIR}/tmp_normal > ${TMPDIR}/$( basename ${f} )
		\rm ${TMPDIR}/{tmp_summary,tmp_normal}

		chmod a-w ${TMPDIR}/$( basename ${f} )
		cp --archive ${TMPDIR}/$( basename ${f} ) $( dirname ${input} )
	fi

fi

#			sum summaries

for level in $( echo ${levels} | tr ',' ' ' ) ; do

	f="${inbase}.summary.sum-${level}.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		if [ ! -f ${scratch_summary} ] ; then
			cp --archive ${summary} ${TMPDIR}/
		fi

		#~/.local/bin/sum_summary.bash -input ${scratch_summary} -level ${level}

		#	could create script to pipe to bash then sum output? ???

		scratch_db=${TMPDIR}/$( basename ${db} )
		if [ ! -f ${scratch_db} ] ; then
			#	takes about 3 minutes
			cp ${db} ${TMPDIR}/
			chmod +w ${scratch_db}
		fi


#		# Summaries are all unique lines. It is pointless to buffer.
#		awk -F"\t" -v db=$db -v level=$level '{ \
#			cmd="accession_to_taxid_and_name.bash -l "level" -d "db" -a \""$2"\""
#			print cmd >> "debugging"
#			cmd | getline r
#			print r >> "debugging"
#			close(cmd)
#			sums[r]+=$1
#			r=""
#		}
#		END{
#			for( s in sums ){
#				print sums[s]"\t"s
#			}
#		}' ${TMPDIR}/tmp_summary > ${TMPDIR}/tmp_sumsummary
#		sort -k 2n ${TMPDIR}/tmp_sumsummary > ${TMPDIR}/tmp_sumsummary_sorted
#		gzip -c ${TMPDIR}/tmp_sumsummary_sorted > ${TMPDIR}/$( basename ${f} )
#		\rm ${TMPDIR}/{tmp_summary,tmp_sumsummary,tmp_sumsummary_sorted}

		table_exists=$( sqlite3 ${scratch_db} "SELECT name FROM sqlite_master WHERE type='table' AND name='query'" )

		#	No need to do this twice, but its kinda fast so could.
		if [ -z "${table_exists}" ] ; then
			sqlite3 ${scratch_db} "
				CREATE TABLE query ( count INTEGER, accession VARCHAR(255) NOT NULL );
				CREATE UNIQUE INDEX aix ON query(accession);"
			gunzip -c ${scratch_summary} > ${TMPDIR}/tmp_summary
			sqlite3 ${scratch_db} -cmd '.separator "\t"' ".import ${TMPDIR}/tmp_summary query"
			\rm ${TMPDIR}/tmp_summary
		fi

#	Some taxomies contain : but not ;
#	select * from taxa where tax_name LIKE '%:%';
#	select * from taxa where tax_name LIKE '%;%';
#	Also there are 3 which contain a single or double quote, so results will always be quoted.

#	This query uses about 700MB memory so nothing special.
#	And it only takes a couple minutes.


sqlite3 -cmd '.mode csv' -cmd '.separator "\t" "\n"' -cmd ".output ${TMPDIR}/${level}.csv" ${scratch_db} "
SELECT SUM(count), ${level} FROM (
SELECT count, CASE
WHEN INSTR(${level},';')>0 THEN SUBSTR(${level}, 1, INSTR(${level},';')-1) 
ELSE ${level} END AS ${level} FROM ( 
SELECT count, 
CASE WHEN lineage IS NULL OR lineage = '' THEN accession || ' not found'
ELSE CASE WHEN INSTR(lineage,';${level};') > 0 THEN SUBSTR(lineage, INSTR(lineage,';${level};')+$[${#level}+2]) 
ELSE accession || ' doesn''t have ${level}'
END END as ${level} FROM ( 
SELECT q.count, q.accession, ';' || 
t1.lineage_level || ';' || t1.ncbi_taxid || ' ' || t1.tax_name || ';' || 
t2.lineage_level || ';' || t2.ncbi_taxid || ' ' || t2.tax_name || ';' || 
t3.lineage_level || ';' || t3.ncbi_taxid || ' ' || t3.tax_name || ';' || 
t4.lineage_level || ';' || t4.ncbi_taxid || ' ' || t4.tax_name || ';' || 
t5.lineage_level || ';' || t5.ncbi_taxid || ' ' || t5.tax_name || ';' || 
t6.lineage_level || ';' || t6.ncbi_taxid || ' ' || t6.tax_name || ';' || 
t7.lineage_level || ';' || t7.ncbi_taxid || ' ' || t7.tax_name || ';' || 
t8.lineage_level || ';' || t8.ncbi_taxid || ' ' || t8.tax_name || ';' AS lineage
FROM ( SELECT count, CASE
WHEN INSTR(accession,'.')>0 THEN SUBSTR(accession,1,INSTR(accession,'.')-1) 
ELSE accession END AS accession
FROM query ) AS q LEFT JOIN ${accession} a ON q.accession = a.accession
LEFT JOIN taxa t1 ON t1.ncbi_taxid = a.taxid_id 
LEFT JOIN taxa t2 ON t2.ncbi_taxid = t1.parent_taxid 
LEFT JOIN taxa t3 ON t3.ncbi_taxid = t2.parent_taxid 
LEFT JOIN taxa t4 ON t4.ncbi_taxid = t3.parent_taxid 
LEFT JOIN taxa t5 ON t5.ncbi_taxid = t4.parent_taxid 
LEFT JOIN taxa t6 ON t6.ncbi_taxid = t5.parent_taxid 
LEFT JOIN taxa t7 ON t7.ncbi_taxid = t6.parent_taxid 
LEFT JOIN taxa t8 ON t8.ncbi_taxid = t7.parent_taxid ) AS abc ) AS def ) AS ghi GROUP BY ${level}"

		#	ORDER BY ${level}

		gzip -c ${TMPDIR}/${level}.csv > ${TMPDIR}/$( basename ${f} )
		\rm ${TMPDIR}/${level}.csv

		chmod a-w ${TMPDIR}/$( basename ${f} )
		cp --archive ${TMPDIR}/$( basename ${f} ) $( dirname ${input} )
	fi
	sumsummary=${f}
	scratch_sumsummary=${TMPDIR}/$( basename ${sumsummary} )

	#			normalize

	if [ -n "${unmapped_read_count}" ] ; then
		echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."

		f="${inbase}.summary.sum-${level}.normalized.txt.gz"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else

			if [ ! -f ${scratch_sumsummary} ] ; then
				cp --archive ${sumsummary} ${TMPDIR}/
			fi

			#~/.local/bin/normalize_summary.bash -input ${scratch_sumsummary} -d ${unmapped_read_count}

			gunzip -c ${scratch_sumsummary} > ${TMPDIR}/tmp_summary
			awk -F"\t" -v n=1000000 -v d=${unmapped_read_count} '{ print $1*n/d"\t"$2 }' \
				${TMPDIR}/tmp_summary > ${TMPDIR}/tmp_normal
			gzip -c ${TMPDIR}/tmp_normal > ${TMPDIR}/$( basename ${f} )
			\rm ${TMPDIR}/{tmp_summary,tmp_normal}

			chmod a-w ${TMPDIR}/$( basename ${f} )
			cp --archive ${TMPDIR}/$( basename ${f} ) $( dirname ${input} )
		fi
	fi

done	#	for level in species genus ; do

