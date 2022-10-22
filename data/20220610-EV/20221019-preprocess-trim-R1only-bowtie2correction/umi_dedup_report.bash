#!/usr/bin/env bash

dir1=/francislab/data1/working/20220610-EV/20221010-preprocess-trim-R1only-correction/out
dir2=/francislab/data1/working/20220610-EV/20221019-preprocess-trim-R1only-bowtie2correction/out

dir=${dir2}
rawdir=/francislab/data1/raw/20220610-EV
for fastq in ${rawdir}/S*R?_001.fastq.gz ; do
	basename=$( basename $fastq .fastq.gz )
#	basename=${basename%%_*}
	basename=${basename%_001}
	r=${basename##*_}
	basename=${basename%%_*}
	ln -s ${fastq} ${dir}/${basename}_${r}.fastq.gz 2> /dev/null
	if [ -f ${fastq}.read_count.txt ] ; then
		ln -s ${fastq}.read_count.txt ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
	fi
done


samples=$( ls -1 /francislab/data1/raw/20220610-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" " )



echo -n "|    |"
for s in ${samples} ; do
	echo -n " ${s} |"
done
echo

echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

echo -n "| meta |"
for s in ${samples} ; do
	c=$( awk -F, -v s=${s} '( $1 == s ){print $10}' metadata.csv )
	echo -n " ${c} |"
done
echo

echo -n "| Paired Raw Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

q=15

echo -n "| prev Trim Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir1}/${s}.format.umi.quality${q}.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| new Trim Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir2}/${s}.format.umi.quality${q}.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| prev hg38 aligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir1}/${s}.format.umi.quality${q}.t2.t3.hg38.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| new hg38 aligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir2}/${s}.format.umi.quality${q}.t2.t3.hg38.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#sa^Cools view -c -f1024 out/SFHH011D.format.umi.quality15.t2.t3.hg38.name.marked.bam 


echo -n "| prev hg38 dup Count |"
for s in ${samples} ; do
	c=$(cat ${dir1}/${s}.format.umi.quality${q}.t2.t3.hg38.name.marked.bam.f1024.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| new hg38 dup Count |"
for s in ${samples} ; do
	c=$(cat ${dir2}/${s}.format.umi.quality${q}.t2.t3.hg38.name.marked.bam.f1024.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo





echo -n "| prev hg38 deduped Count |"
for s in ${samples} ; do
	c=$(cat ${dir1}/${s}.format.umi.quality${q}.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| new hg38 deduped Count |"
for s in ${samples} ; do
	c=$(cat ${dir2}/${s}.format.umi.quality${q}.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo





