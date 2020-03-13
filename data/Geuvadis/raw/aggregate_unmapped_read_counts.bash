#!/usr/bin/env bash


echo "subject,file,path,count,unmapped_count" > /francislab/data1/raw/Geuvadis/read_counts.csv
for f in /francislab/data1/raw/Geuvadis/bam/*bam ; do
echo $f
b=$( basename $f )
s=${b%.unmapped*}
#c=$( samtools view -c ${f} )
c=$( zcat ${f}.read_count.txt.gz )
#uc=$( samtools view -f 4 -c ${f} )
uc=$( zcat ${f}.unmapped_read_count.txt.gz )
echo "${s},${b},${f},${c},${uc}" >> /francislab/data1/raw/Geuvadis/read_counts.csv
done


