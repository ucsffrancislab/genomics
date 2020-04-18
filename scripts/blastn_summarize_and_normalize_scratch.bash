#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

levels="species,genus"
unmapped_read_count=""

#SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-i|--input)
			shift; input=$1; shift;;
		-l|--levels)
			shift; levels=$1; shift;;
		-u|--unmapped_read_count)
			shift; unmapped_read_count=$1; shift;;
		#*)
		#	SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
cd $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT



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
		fi
		db=${SCRATCH_JOB}/taxadb_full.sqlite

		gunzip -c ${scratch_summary} > ${SCRATCH_JOB}/tmp_summary

		# Summaries are all unique lines. It is pointless to buffer.
		awk -F"\t" -v db=$db -v level=$level '{ \
			cmd="accession_to_taxid_and_name.bash -l "level" -d "db" -a \""$2"\""
			print cmd >> "debugging"
			cmd | getline r
			print r >> "debugging"
			close(cmd)
			sums[r]+=$1
			r=""
		}
		END{
			for( s in sums ){
				print sums[s]"\t"s
			}
		}' ${SCRATCH_JOB}/tmp_summary > ${SCRATCH_JOB}/tmp_sumsummary
		sort -k 2n ${SCRATCH_JOB}/tmp_sumsummary > ${SCRATCH_JOB}/tmp_sumsummary_sorted
		gzip -c ${SCRATCH_JOB}/tmp_sumsummary_sorted > ${SCRATCH_JOB}/$( basename ${f} )
		\rm ${SCRATCH_JOB}/{tmp_summary,tmp_sumsummary,tmp_sumsummary_sorted}

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

