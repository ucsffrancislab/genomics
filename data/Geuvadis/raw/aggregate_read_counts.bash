#!/usr/bin/env bash


#echo "subject,file,path,count,index_count,index_mapped_count,unmapped_count,index_unmapped_count" > /francislab/data1/raw/Geuvadis/read_counts.csv
echo "subject,file,index_count,index_mapped_count,index_unmapped_count" > /francislab/data1/raw/Geuvadis/read_counts.csv
for f in /francislab/data1/raw/Geuvadis/bam/*bam ; do
echo $f
b=$( basename $f )
s=${b%%.*}
#c=$( samtools view -c ${f} )
#c=$( cat ${f}.read_count.txt )
#uc=$( samtools view -f 4 -c ${f} )
#uc=$( cat ${f}.unmapped_read_count.txt )

ic=$( cat ${f}.bai.read_count.txt )
imc=$( cat ${f}.bai.mapped_read_count.txt )
iuc=$( cat ${f}.bai.unmapped_read_count.txt )
#echo "${s},${b},${f},${c},${ic},${imc},${uc},${iuc}" >> /francislab/data1/raw/Geuvadis/read_counts.csv
echo "${s},${b},${ic},${imc},${iuc}" >> /francislab/data1/raw/Geuvadis/read_counts.csv
done


