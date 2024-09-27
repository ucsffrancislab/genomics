#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20240802-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20240802-Illumina-PhIP/20240802-cutadapt/out
bowdir=/francislab/data1/working/20240802-Illumina-PhIP/20240803-bowtie2/out


samples="S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12"



#echo -n " --- ,"
#for s in ${samples} ; do
#	echo -n "${s},"
#done
#echo
#
#echo -n " --- ,"
#for s in ${samples} ; do
#	echo -n " --- ,"
#done
#echo
#
#echo -n "sample id,"
#for s in ${samples} ; do
#	a=$( realpath ${rawdir}/${s}.fastq.gz )
#	b=$( basename ${a} )
#	echo -n "${b%%_*},"
#done
#echo
#
#echo -n "sample type,"
#for s in ${samples} ; do
#	a=$( realpath ${rawdir}/${s}.fastq.gz )
#	b=$( basename ${a} )
#	echo -n "${b%%-*},"
#done
#echo
#
#echo -n "Raw Read Count,"
#for s in ${samples} ; do
#	c=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	echo -n "${c},"
#done
#echo
#
#echo -n "Trimmed Read Count,"
#for s in ${samples} ; do
#	c=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	echo -n "${c},"
#done
#echo
#
#echo -n "Trimmed % Read Count,"
#for s in ${samples} ; do
#	n=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	d=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#	echo -n "${c},"
#done
#echo
#
#
#echo -n "Aligned Read Count,"
#for s in ${samples} ; do
#	c=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_count.txt 2> /dev/null)
#	echo -n "${c},"
#done
#echo
#
#echo -n "Alighed % Read Count,"
#for s in ${samples} ; do
#	n=$(cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_count.txt 2> /dev/null)
#	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#	echo -n "${c},"
#done
#echo




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

echo -n "sample id"
for s in ${samples} ; do
	a=$( realpath ${rawdir}/${s}.fastq.gz )
	b=$( basename ${a} )
	echo -n ",${b%%_*}"
done
echo

echo -n "sample type"
for s in ${samples} ; do
	a=$( realpath ${rawdir}/${s}.fastq.gz )
	b=$( basename ${a} )
	echo -n ",${b%%-*}"
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




echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-160.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo


