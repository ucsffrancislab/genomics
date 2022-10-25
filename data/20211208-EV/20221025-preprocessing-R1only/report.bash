#!/usr/bin/env bash

dir=out


rawdir=/francislab/data1/raw/20211208-EV
for fastq in ${rawdir}/S*fastq.gz ; do
	basename=$( basename $fastq .fastq.gz )
#	basename=${basename%%_*}
	basename=${basename%_001}
	r=${basename##*_}
	basename=${basename%%_*}
	ln -s ${fastq} ${dir}/${basename}_${r}.fastq.gz 2> /dev/null
	ln -s ${fastq}.read_count.txt ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
#	ln -s ${fastq}.average_length.txt output/${basename}.fastq.gz.average_length.txt 2> /dev/null
#	ln -s ${rawdir}/${basename}.labkit output/ 2> /dev/null
#	ln -s ${rawdir}/${basename}.subject output/ 2> /dev/null
#	ln -s ${rawdir}/${basename}.diagnosis output/ 2> /dev/null
done




#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}'
#samples="SFHH008A SFHH008B SFHH008C SFHH008D SFHH008E SFHH008F"
#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" "
samples="SFHH009A SFHH009B SFHH009C SFHH009D SFHH009E SFHH009F SFHH009G SFHH009H SFHH009I SFHH009J SFHH009L SFHH009M SFHH009N"


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

echo -n "| Paired Raw Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#	echo -n "| Raw Read Length |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}${suffix}.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo



echo -n "| Format Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Format % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo



echo -n "| Quality Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Quality % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.quality15.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| Trimmed1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed1 % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.quality15.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.quality15.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed1 Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#echo -n "| Trimmed1 Ave R2 Read Length |"
#for s in ${samples} ; do
#	c=$(cat ${dir}/${s}.format.umi.quality15.t1.R2.fastq.gz.average_length.txt 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo




echo -n "| Trimmed2 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed2 % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.quality15.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed2 Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#echo -n "| Trimmed2 Ave R2 Read Length |"
#for s in ${samples} ; do
#	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.R2.fastq.gz.average_length.txt 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo

echo -n "| Trimmed3 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed3 % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed3 Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.t3.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#echo -n "| Trimmed3 Ave R2 Read Length |"
#for s in ${samples} ; do
#	c=$(cat ${dir}/${s}.format.umi.quality15.t1.t2.t3.R2.fastq.gz.average_length.txt 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo




#echo -n "| HG38 Read Count |"
#for s in ${samples} ; do
#	c=$(cat ${dir}/${s}.format.umi.quality.format.consolidate.t1.t2.t3.notphiX.hg38.bam.aligned_count.txt 2> /dev/null )
#	c=$( echo "scale=0;  ${c} / 2" | bc -l 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo
#
#echo -n "| HG38 % Read Count |"
#for s in ${samples} ; do
#	a=$(cat ${dir}/${s}.format.umi.quality.format.consolidate.t1.t2.t3.notphiX.hg38.bam.aligned_count.txt 2> /dev/null )
#	u=$(cat ${dir}/${s}.format.umi.quality.format.consolidate.t1.t2.t3.notphiX.hg38.bam.unaligned_count.txt 2> /dev/null )
#	c=$( echo "scale=2; 100 * ${a} / ( ${a} + ${u} )" | bc -l 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo



