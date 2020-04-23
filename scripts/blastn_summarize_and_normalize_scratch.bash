#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

levels="species,genus"
unmapped_read_count=""

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--input)
			shift; input=$1; shift;;
		-l|--levels)
			shift; levels=$1; shift;;
		-u|--unmapped_read_count)
			shift; unmapped_read_count=$1; shift;;
	esac
done


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
cd $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT



## 1. Copy input files from global disk to local scratch
#	mkdir ${SCRATCH_JOB}/input
#	cp --archive ${SELECT_ARGS} ${SCRATCH_JOB}/input/



## 2. Process input files
#cd $SCRATCH_JOB
#/path/to/my_pipeline --cores=$PBS_NUM_PPN reference.fa sample.fq > output.bam

#scratch_input=${SCRATCH_JOB}/$( basename ${input} )
#scratch_out=${SCRATCH_JOB}/$( basename ${out} )




#	Ex.
#	input="${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz"

inbase=${input%.csv.gz}
scratch_inbase=${SCRATCH_JOB}/$( basename ${inbase} )

f="${inbase}.summary.txt.gz"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	cp --archive ${input} ${SCRATCH_JOB}/
	scratch_input=${SCRATCH_JOB}/$( basename ${input} )
	#~/.local/bin/blastn_summary.bash -input ${SCRATCH_JOB}/$( basename ${input} )

	gunzip ${scratch_input}
	awk -F"\t" '( $11 < '${max}' ){print $1"\t"$2}' ${scratch_input%.gz} \
		> ${scratch_input%.gz}.read.acc.txt
	sort ${scratch_input%.gz}.read.acc.txt \
		> ${scratch_input%.gz}.read.acc.sorted.txt
	uniq ${scratch_input%.gz}.read.acc.sorted.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.txt
	awk '{print $2}' ${scratch_input%.gz}.read.acc.sorted.uniq.txt \
		> ${scratch_input%.gz}.read.acc.sorted.uniq.acc.txt
	sort ${scratch_input%.gz}.read.acc.sorted.uniq.acc.txt \
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
scratch_summary=${SCRATCH_JOB}/$( basename ${summary} )

#			normalize

if [ -n "${unmapped_read_count}" ] ; then
	echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."

	f="${inbase}.summary.normalized.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		if [ ! -f ${scratch_summary} ] ; then
			cp --archive ${inbase}.summary.txt.gz ${SCRATCH_JOB}/
		fi

		#	~/.local/bin/normalize_summary.bash -input ${scratch_summary} -d ${unmapped_read_count}

		gunzip -c ${scratch_summary} > ${SCRATCH_JOB}/tmp_summary
		awk -F"\t" -v n=1000000 -v d=${unmapped_read_count} '{ print $1*n/d"\t"$2 }' \
			${SCRATCH_JOB}/tmp_summary > ${SCRATCH_JOB}/tmp_normal
		gzip -c ${SCRATCH_JOB}/tmp_normal > ${SCRATCH_JOB}/$( basename ${f} )
		\rm ${SCRATCH_JOB}/{tmp_summary,tmp_normal}

		chmod a-w ${SCRATCH_JOB}/$( basename ${f} )
		cp --archive ${SCRATCH_JOB}/$( basename ${f} ) $( dirname ${input} )
	fi

fi

#			sum summaries

for level in $( echo ${levels} | tr ',' ' ' ) ; do

	f="${inbase}.summary.sum-${level}.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		if [ ! -f ${scratch_summary} ] ; then
			cp --archive ${summary} ${SCRATCH_JOB}/
		fi

		#~/.local/bin/sum_summary.bash -input ${scratch_summary} -level ${level}

		#	could create script to pipe to bash then sum output? ???

		if [ ! -f ${SCRATCH_JOB}/taxadb_full.sqlite ] ; then
			#	takes about 3 minutes
			cp /francislab/data1/refs/taxadb/taxadb_full.sqlite ${SCRATCH_JOB}/
			chmod +w ${SCRATCH_JOB}/taxadb_full.sqlite
		fi
		db=${SCRATCH_JOB}/taxadb_full.sqlite


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
#		}' ${SCRATCH_JOB}/tmp_summary > ${SCRATCH_JOB}/tmp_sumsummary
#		sort -k 2n ${SCRATCH_JOB}/tmp_sumsummary > ${SCRATCH_JOB}/tmp_sumsummary_sorted
#		gzip -c ${SCRATCH_JOB}/tmp_sumsummary_sorted > ${SCRATCH_JOB}/$( basename ${f} )
#		\rm ${SCRATCH_JOB}/{tmp_summary,tmp_sumsummary,tmp_sumsummary_sorted}

		table_exists=$( sqlite3 taxadb_full.sqlite "SELECT name FROM sqlite_master WHERE type='table' AND name='query'" )

		#	No need to do this twice, but its kinda fast so could.
		if [ -z "${table_exists}" ] ; then
			sqlite3 taxadb_full.sqlite "
				CREATE TABLE query ( count INTEGER, accession VARCHAR(255) NOT NULL );
				CREATE UNIQUE INDEX ix ON query(accession);"
			gunzip -c ${scratch_summary} > ${SCRATCH_JOB}/tmp_summary
			sqlite3 taxadb_full.sqlite -cmd '.separator "\t"' ".import ${SCRATCH_JOB}/tmp_summary query"
			\rm ${SCRATCH_JOB}/tmp_summary
		fi

#	Some taxomies contain : but not ;
#	select * from taxa where tax_name LIKE '%:%';
#	select * from taxa where tax_name LIKE '%;%';
#	Also there are 3 which contain a single or double quote, so results will always be quoted.

#	This query uses about 700MB memory so nothing special.
#	And it only takes a couple minutes.


sqlite3 -cmd '.mode csv' -cmd '.separator "\t" "\n"' -cmd ".output ${SCRATCH_JOB}/${level}.csv" taxadb_full.sqlite "
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
FROM query ) AS q LEFT JOIN accession a ON q.accession = a.accession
LEFT JOIN taxa t1 ON t1.ncbi_taxid = a.taxid_id 
LEFT JOIN taxa t2 ON t2.ncbi_taxid = t1.parent_taxid 
LEFT JOIN taxa t3 ON t3.ncbi_taxid = t2.parent_taxid 
LEFT JOIN taxa t4 ON t4.ncbi_taxid = t3.parent_taxid 
LEFT JOIN taxa t5 ON t5.ncbi_taxid = t4.parent_taxid 
LEFT JOIN taxa t6 ON t6.ncbi_taxid = t5.parent_taxid 
LEFT JOIN taxa t7 ON t7.ncbi_taxid = t6.parent_taxid 
LEFT JOIN taxa t8 ON t8.ncbi_taxid = t7.parent_taxid ) AS abc ) AS def ) AS ghi GROUP BY ${level}"

		#	ORDER BY ${level}

		gzip -c ${SCRATCH_JOB}/${level}.csv > ${SCRATCH_JOB}/$( basename ${f} )
		\rm ${SCRATCH_JOB}/${level}.csv

		chmod a-w ${SCRATCH_JOB}/$( basename ${f} )
		cp --archive ${SCRATCH_JOB}/$( basename ${f} ) $( dirname ${input} )
	fi
	sumsummary=${f}
	scratch_sumsummary=${SCRATCH_JOB}/$( basename ${sumsummary} )

	#			normalize

	if [ -n "${unmapped_read_count}" ] ; then
		echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."

		f="${inbase}.summary.sum-${level}.normalized.txt.gz"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else

			if [ ! -f ${scratch_sumsummary} ] ; then
				cp --archive ${sumsummary} ${SCRATCH_JOB}/
			fi

			#~/.local/bin/normalize_summary.bash -input ${scratch_sumsummary} -d ${unmapped_read_count}

			gunzip -c ${scratch_sumsummary} > ${SCRATCH_JOB}/tmp_summary
			awk -F"\t" -v n=1000000 -v d=${unmapped_read_count} '{ print $1*n/d"\t"$2 }' \
				${SCRATCH_JOB}/tmp_summary > ${SCRATCH_JOB}/tmp_normal
			gzip -c ${SCRATCH_JOB}/tmp_normal > ${SCRATCH_JOB}/$( basename ${f} )
			\rm ${SCRATCH_JOB}/{tmp_summary,tmp_normal}

			chmod a-w ${SCRATCH_JOB}/$( basename ${f} )
			cp --archive ${SCRATCH_JOB}/$( basename ${f} ) $( dirname ${input} )
		fi
	fi

done	#	for level in species genus ; do

