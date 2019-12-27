#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	# Display command before running

#	Produce a csv file formatted like featureCounts output for use by DESeq2

ARGS=$*

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-o|--output)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	#	input files will be gzipped so can't process normally and get FILENAME
	#	gunzip all in temp dir
	tmpdir=${TMPDIR}/tmp/tablify_sample_uniq_counts.$$
	mkdir -p ${tmpdir}
	cp ${SELECT_ARGS} ${tmpdir}/
	gunzip ${tmpdir}/*gz

	#	/tmp/gwendt/tmp/tablify_sample_uniq_counts.202619/77.h38au.bowtie2-e2e.unmapped.kraken2.standard.summary.txt
	#	to just "s77"
	gawk '
	(FNR<=1){
		count=split(FILENAME, pieces, "/")
		f=pieces[count]
		count=split(f, pieces, ".")
		f=pieces[1]
		sample="s"f
		s[sample]=1
	}
	{
		tax=$2
		for(i=3;i<=NF;i++)
			tax=sprintf("%s %s",tax,$i)
		gsub("\047", "", tax)
		t[tax]++
		c[sample,tax]=$1
	} END{
		printf("Geneid\tChr\tStart\tEnd\tStrand\tLength")
		len_s=asorti(s)
		for(i=1;i<=len_s;i++)
			printf("\t%s",s[i])
		printf "\n"
		len_t=asorti(t)
		for(i=1;i<=len_t;i++){
			printf("%s\t0\t0\t0\t0\t0",t[i])
			for(j=1;j<=len_s;j++){
				printf("\t%i",c[s[j],t[i]])
			}
			printf("\n")
		}
	}' ${tmpdir}/* > ${f}
	chmod a-w $f
	/bin/rm -rf ${tmpdir}
fi

#	tablify_sample_uniq_counts.bash -o testing.csv.gz /francislab/data1/raw/20191008_Stanford71/trimmed/unpaired/*krak*summary.txt.gz

