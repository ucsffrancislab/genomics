#!/usr/bin/env bash

dir=/francislab/data1/working/20201006-GTEx/20230818-STAR-GRCh38/out

rawdir=/francislab/data1/raw/20201006-GTEx/fastq

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


echo -n "| biospecimen_repository_sample_id |"
for s in ${samples} ; do
	study=$( awk -v s=$s 'BEGIN{FS=OFS=","}($1==s){print $2}' biospecimen_repository_sample_id.csv )
	echo -n " ${study} |"
done
echo

echo -n "| BioSample |"
for s in ${samples} ; do
	study=$( awk -v s=$s 'BEGIN{FS=OFS=","}($1==s){print $2}' BioSample.csv )
	echo -n " ${study} |"
done
echo

echo -n "| Body Site |"
for s in ${samples} ; do
	study=$( awk -v s=$s 'BEGIN{FS=OFS=","}($1==s){print $2}' body_site.csv )
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


echo -n "| hg38 unaligned Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#echo -n "| hg38 unaligned Count |"
#for s in ${samples} ; do
#	c=$(cat ${dir}/${s}.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt 2> /dev/null)
#	echo -n " ${c} |"
#done
#echo

echo -n "| RMHM viral aligned Count |"
for s in ${samples} ; do
	c=$(cat out/${s}.RMHM.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


#	for q in 30 35 40 ; do
#	for l in 40 50 60 70 80 90 ; do
#	echo -n "| RMHM viral q${q} l${l} aligned Count |"
#	for s in ${samples} ; do
#		c=$( cat out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null | datamash -W sum 1 2> /dev/null)
#		echo -n " ${c} |"
#	done
#	echo
#	done
#	done
#	
#	
#	echo -n "| --- |"
#	for s in ${samples} ; do
#		echo -n " --- |"
#	done
#	echo
#	

for q in 30 ; do
for l in 30 30 40 50 60 ; do
echo -n "| RMHM viral q${q} l${l} EBV Count |"
for s in ${samples} ; do
	c=$( awk '($2=="NC_007605.1"){print $1}' out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo
done
done
#	grep NC_007605 12915_2020_785_MOESM11_ESM.sorted.csv
#	NC_007605.1,Human_gammaherpesvirus_4_complete_genome,ID_2
#	EBV
echo -n "| Human Virome EBV Count |"
for s in ${samples} ; do
	c=$( awk '($1=="ID_2"){print $2}' /francislab/data1/working/20201006-GTEx/20230819-Human_Virome_Analysis/out/${s}.count.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo 


echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo




for q in 30 ; do
for l in 30 40 50 60 ; do
echo -n "| RMHM viral q${q} l${l} CMV Count |"
for s in ${samples} ; do
	c=$( awk '($2=="NC_006273.2"){print $1}' out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo
done
done
#	grep NC_006273 12915_2020_785_MOESM11_ESM.sorted.csv
#	NC_006273.2,Human_herpesvirus_5_strain_Merlin_complete_genome,ID_1242
#	CMV
echo -n "| Human Virome CMV Count |"
for s in ${samples} ; do
	c=$( awk '($1=="ID_1242"){print $2}' /francislab/data1/working/20201006-GTEx/20230819-Human_Virome_Analysis/out/${s}.count.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo 




#	grep NC_001806 12915_2020_785_MOESM11_ESM.sorted.csv
#	NC_001806.2,Human_herpesvirus_1_strain_17_complete_genome,ID_2457
#	HSV1
echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

for q in 30 ; do
for l in 30 40 50 60 ; do
echo -n "| RMHM viral q${q} l${l} HSV1 Count |"
for s in ${samples} ; do
	c=$( awk '($2=="NC_001806.2"){print $1}' out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo
done
done
echo -n "| Human Virome HSV1 Count |"
for s in ${samples} ; do
	c=$( awk '($1=="ID_2457"){print $2}' /francislab/data1/working/20201006-GTEx/20230819-Human_Virome_Analysis/out/${s}.count.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo 


#	grep NC_001798 12915_2020_785_MOESM11_ESM.sorted.csv
#	NC_001798.2,Human_herpesvirus_2_strain_HG52_complete_genome,ID_2456
#	HSV2
echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

for q in 30 ; do
for l in 30 40 50 60 ; do
echo -n "| RMHM viral q${q} l${l} HSV2 Count |"
for s in ${samples} ; do
	c=$( awk '($2=="NC_001798.2"){print $1}' out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo
done
done
echo -n "| Human Virome HSV2 Count |"
for s in ${samples} ; do
	c=$( awk '($1=="ID_2456"){print $2}' /francislab/data1/working/20201006-GTEx/20230819-Human_Virome_Analysis/out/${s}.count.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo 


#	#	grep NC_009333 12915_2020_785_MOESM11_ESM.sorted.csv
#	#	NC_009333.1,Human_herpesvirus_8_complete_genome,ID_1230
#	#	KSHV
#	echo -n "| --- |"
#	for s in ${samples} ; do
#		echo -n " --- |"
#	done
#	echo
#	
#	for q in 30 ; do
#	for l in 30 40 50 60 ; do
#	echo -n "| RMHM viral q${q} l${l} KSHV Count |"
#	for s in ${samples} ; do
#		c=$( awk '($2=="NC_009333.1"){print $1}' out/${s}.RMHM.bam.q${q}.l${l}.aligned_sequence_counts.txt 2> /dev/null )
#		echo -n " ${c} |"
#	done
#	echo
#	done
#	done
#	echo -n "| Human Virome KSHV Count |"
#	for s in ${samples} ; do
#		c=$( awk '($1=="ID_1230"){print $2}' /francislab/data1/working/20201006-GTEx/20230819-Human_Virome_Analysis/out/${s}.count.txt 2> /dev/null )
#		echo -n " ${c} |"
#	done
#	echo 
#	
