#!/usr/bin/env bash


echo "subject,file,path,count,unmapped_count" > /francislab/data1/raw/1000genomes/unmapped_read_counts.csv
for f in /francislab/data1/raw/1000genomes/phase3/data/*/alignment/*.unmapped.ILLUMINA.*bam ; do
echo $f
b=$( basename $f )
s=${b%.unmapped*}
#c=$( samtools view -c ${f} )
#c=$( zcat ${f}.read_count.txt.gz )
c=$( cat ${f}.read_count.txt )
#uc=$( samtools view -f 4 -c ${f} )
#uc=$( zcat ${f}.unmapped_read_count.txt.gz )
uc=$( cat ${f}.unmapped_read_count.txt )
echo "${s},${b},${f},${c},${uc}" >> /francislab/data1/raw/1000genomes/unmapped_read_counts.csv
done


