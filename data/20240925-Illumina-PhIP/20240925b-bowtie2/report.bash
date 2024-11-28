#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20240925-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20240925-Illumina-PhIP/20240925a-cutadapt/out
bowdir=/francislab/data1/working/20240925-Illumina-PhIP/20240925b-bowtie2/out


samples="L1 L2 L3 L4 L5 L6 L7 L8 L9 L10 L11 L12 L13 L14 L15 L16 L17 L18 L19 L20 L21 L22 L23 L24"



echo -n " --- "
for s in ${samples} ; do
	echo -n ",${s}"
done
echo

echo -n " --- "
for s in ${samples} ; do
	echo -n ", --- "
done
echo

#head -1 /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv | tr , "\n"
#Library
#Sample
#Item NO
#IDNO
#LabNO
#condition
#BSA blocked plate
#Protein A/G beads (uL)
#Phage Library 
#Index
#Sequence
#Qubit Concentration(ng/uL)
#pool volume(uL)
#Total amount(ng)


#echo -n "sample id"
#for s in ${samples} ; do
#	a=$( realpath ${rawdir}/${s}.fastq.gz )
#	b=$( basename ${a} )
#	echo -n ",${b%%_*}"
#done
#echo

echo -n "sample type"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $2}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
	echo -n ",${v}"
done
echo

echo -n "condition"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $6}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
	echo -n ",${v}"
done
echo

echo -n "BSA blocked"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $7}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
	echo -n ",${v}"
done
echo

echo -n "beads (uL)"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $8}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
	echo -n ",${v}"
done
echo






echo -n "Raw Read Count"
for s in ${samples} ; do
	c=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed Read Count"
for s in ${samples} ; do
	c=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed % Read Count"
for s in ${samples} ; do
	n=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q40 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.q40.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q40 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.q40.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo




echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




