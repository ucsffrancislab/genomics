#!/usr/bin/env bash

dir=out


rawdir=/francislab/data1/raw/20230726-Illumina-CystEV/fastq
#for fastq in ${rawdir}/*fastq.gz ; do
#	basename=$( basename $fastq .fastq.gz )
##	basename=${basename%%_*}
#	basename=${basename%_001}
#	r=${basename##*_}
#	basename=${basename%%_*}
#	ln -s ${fastq} ${dir}/${basename}_${r}.fastq.gz 2> /dev/null
#	ln -s ${fastq}.read_count.txt ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
##	ln -s ${fastq}.average_length.txt output/${basename}.fastq.gz.average_length.txt 2> /dev/null
##	ln -s ${rawdir}/${basename}.labkit output/ 2> /dev/null
##	ln -s ${rawdir}/${basename}.subject output/ 2> /dev/null
##	ln -s ${rawdir}/${basename}.diagnosis output/ 2> /dev/null
#done
#



#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}'
#samples="SFHH008A SFHH008B SFHH008C SFHH008D SFHH008E SFHH008F"
#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" "
#samples="SFHH009A SFHH009B SFHH009C SFHH009D SFHH009E SFHH009F SFHH009G SFHH009H SFHH009I SFHH009J SFHH009L SFHH009M SFHH009N"
samples=$( ls ${rawdir}/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz | paste -s -d" " )


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


echo -n "| Study |"
for s in ${samples} ; do

	study=$( awk -v s=$s 'BEGIN{FS=OFS="\t"}($1==s){print $6"-"$7}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.tsv )

	echo -n " ${study} |"
done
echo


echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo


echo -n "| Paired Raw R1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${rawdir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


#	echo -n "| Raw Read Length |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}${suffix}.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo



echo -n "| Format R1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Format % Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| Trimmed R1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed % R1 Read Count |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.trim.R1.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave R1 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave R2 Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.R2.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| hg38 aligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 aligned % |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.trim.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / (2*${d})" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 unaligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 unaligned % |"
for s in ${samples} ; do
	n=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.trim.R1.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / (2*${d})" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| hg38 dup Count |"
for s in ${samples} ; do
	#c=$(cat ${dir}/${s}.format.umi.quality15.t2.t3.readname.hg38.tags.mated.marked.bam.F3844.aligned_count.txt 2> /dev/null)
	c=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam.dup_read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 dup % |"
for s in ${samples} ; do
	#n=$(cat ${dir}/${s}.format.umi.quality15.t2.t3.readname.hg38.tags.mated.marked.bam.F3844.aligned_count.txt 2> /dev/null)
	n=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam.dup_read_count.txt 2> /dev/null)
	d=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo



echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

echo -n "| hg38 deduped Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam.deduped_read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| hg38 aligned deduped Count |"
for s in ${samples} ; do
	s0=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt 2> /dev/null)
	r1=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R1.fastq.gz.read_count.txt 2> /dev/null)
	r2=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R2.fastq.gz.read_count.txt 2> /dev/null)
	o1=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.O1.fastq.gz.read_count.txt 2> /dev/null)
	o2=$(cat ${dir}/${s}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.O2.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "${s0} + ${r1} + ${r2} + ${o1} + ${o2}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done
echo


