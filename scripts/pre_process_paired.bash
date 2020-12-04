#!/usr/bin/env bash

set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail

REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
date=$( date "+%Y%m%d%H%M%S" )

unpair=false
bbduk_options=""
while [ $# -gt 0 ] ; do
	case $1 in
		--unpair)
			shift; unpair=true;;
		-out|--out)
			shift; OUT=$1; shift;;
		-r1|--r1)
			shift; R1=$1; shift;;
		--bbduk)
			shift; bbduk_options="${bbduk_options} $1"; shift;;
#		-r2)
#			shift; R2=$1; shift;;
	esac
done


base=${R1%_R1.*}
#base=${R1%_R1.fastq.gz}
R2=${R1/_R1/_R2}

base=$( basename ${base} )
echo $base



#	threads = ${PBS_NUM_PPN}
#	vmem = ?????







#	#	This is necessary only for some TARGET data.
#	#	Commenting out once done.
#	mkdir -p ${OUT}/fastq-nodots/
#	newR1=${OUT}/fastq-nodots/$( basename ${R1} )
#	newR2=${OUT}/fastq-nodots/$( basename ${R2} )
#	echo "Replacing dots with Ns in R1"
#	zcat ${R1} | sed -n '2~4s/\./N/g;p' | gzip > ${newR1}
#	echo "Replacing dots with Ns in R2"
#	zcat ${R2} | sed -n '2~4s/\./N/g;p' | gzip > ${newR2}
#	R1=${newR1}
#	R2=${newR2}






mkdir -p ${OUT}/trimmed
outbase="${OUT}/trimmed/${base}"

bbduk.bash ${bbduk_options} \
	-Xmx16g \
	in1=${R1} \
	in2=${R2} \
	out1=${outbase}_R1.fastq.gz \
	out2=${outbase}_R2.fastq.gz \
	outs=${outbase}_S.fastq.gz \
	ref=${FASTA}/illumina_adapters.fa \
	ktrim=r \
	k=23 \
	mink=11 \
	hdist=1 \
	tbo \
	ordered=t \
	bhist=${outbase}.bhist.txt \
	qhist=${outbase}.qhist.txt \
	gchist=${outbase}.gchist.txt \
	aqhist=${outbase}.aqhist.txt \
	lhist=${outbase}.lhist.txt \
	stats=${outbase}.stats.txt \
	refstats=${outbase}.refstats.txt \
	rpkm=${outbase}.rpkm.txt \
	gcbins=auto \
	maq=10 \
	qtrim=w trimq=5 minavgquality=0

read_length_hist.bash ${outbase}_R1.fastq.gz
read_length_hist.bash ${outbase}_R2.fastq.gz
read_length_hist.bash ${outbase}_S.fastq.gz

inbase="${outbase}"
mkdir -p ${OUT}/trimmed/length
outbase="${OUT}/trimmed/length/${base}"

filter_paired_fastq_on_equal_read_length.bash \
	${inbase}_R1.fastq.gz \
	${inbase}_R2.fastq.gz \
	${outbase}_R1.fastq.gz \
	${outbase}_R2.fastq.gz \
	${outbase}_R1_diff.fastq.gz \
	${outbase}_R2_diff.fastq.gz

read_length_hist.bash ${outbase}_R1.fastq.gz
read_length_hist.bash ${outbase}_R2.fastq.gz
read_length_hist.bash ${outbase}_R1_diff.fastq.gz
read_length_hist.bash ${outbase}_R2_diff.fastq.gz

#
#	Unpair only if investigating miRNA, Exosomes, Extracellular Vessicles, ...
#
if $unpair; then
	inbase="${outbase}"
	mkdir -p ${OUT}/trimmed/length/unpaired
	outbase="${OUT}/trimmed/length/unpaired/${base}"
	unpair_fastqs.bash -o ${outbase}.fastq.gz ${inbase}_R?.fastq.gz
	read_length_hist.bash ${outbase}.fastq.gz
fi


