#!/usr/bin/env bash

dir=out


rawdir=/francislab/data1/raw/20220610-EV
for fastq in ${rawdir}/S*R1_001.fastq.gz ; do
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
#samples="SFHH009A SFHH009B SFHH009C SFHH009D SFHH009E SFHH009F SFHH009G SFHH009H SFHH009I SFHH009J SFHH009L SFHH009M SFHH009N"
#samples=$( ls -1 /francislab/data1/raw/20220610-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" " )
samples=$( ls -1 /francislab/data1/raw/20220610-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" " )

#samples=$( ls -1 /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/out/SFHH*.quality.consolidate.range2-5000.t1.t3.R1.fastq.gz | xargs -I% basename % .quality.consolidate.range2-5000.t1.t3.R1.fastq.gz | paste -s -d" " )



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

echo -n "| Quality Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Quality % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.quality.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo





echo -n "| Trimmed1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed1 % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.quality.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	#d=$(cat ${dir}/${s}.quality.umi.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.quality.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| Trimmed1 Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| Trimmed3 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed3 % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.quality.umi.t1.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.quality.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed3 Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.t3.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo



echo -n "| hg38 aligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.t3.hg38.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 aligned % |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.quality.umi.t1.t3.hg38.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.quality.umi.t1.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| hg38 unaligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.umi.t1.t3.hg38.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 unaligned % |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.quality.umi.t1.t3.hg38.bam.unaligned_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.quality.umi.t1.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


