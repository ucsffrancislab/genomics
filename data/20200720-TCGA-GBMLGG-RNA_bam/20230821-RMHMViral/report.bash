#!/usr/bin/env bash

dir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38/out

rawdir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out

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


#echo -n "| Body Site |"
#for s in ${samples} ; do
#
##	study=$( awk -v s=$s 'BEGIN{FS=OFS="\t"}($1==s){print $6"-"$7}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.tsv )
#
#	echo -n " ${study} |"
#done
#echo
#
#
#echo -n "| --- |"
#for s in ${samples} ; do
#	echo -n " --- |"
#done
#echo


echo -n "| Paired Raw R1 Read Count |"
for s in ${samples} ; do
	c=$(cat ${rawdir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


echo -n "| hg38 unaligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| hg38 unaligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| RMHM viral aligned Count |"
for s in ${samples} ; do
	c=$(cat out/${s}.RMHM.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


for q in 20 25 30 ; do
for l in 20 30 40 50 ; do

echo -n "| RMHM viral q${q} l${l} aligned Count |"
for s in ${samples} ; do
	c=$( cat out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null | datamash -W sum 1 2> /dev/null)
	echo -n " ${c} |"
done
echo

done
done





