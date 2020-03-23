#!/usr/bin/env bash


#echo "subject,file,path,count,unmapped_index_count,unmapped_count,unmapped_unmapped_index_count,unmapped_mapped_index.count,mapped_index_count,mapped_unmapped_index_count,mapped_mapped_index_count" > /francislab/data1/raw/1000genomes/read_counts.csv
echo "subject,file,unmapped_index_count,unmapped_unmapped_index_count,unmapped_mapped_index.count,mapped_index_count,mapped_unmapped_index_count,mapped_mapped_index_count" > /francislab/data1/raw/1000genomes/read_counts.csv

for f in /francislab/data1/raw/1000genomes/phase3/data/*/alignment/*.unmapped.ILLUMINA.*bam ; do
echo $f
b=$( basename $f )
s=${b%%.*}

c=$( cat ${f}.read_count.txt )
uc=$( cat ${f}.unmapped_read_count.txt )

ic=$( cat ${f}.bai.read_count.txt )
iuc=$( cat ${f}.bai.unmapped_read_count.txt )
imc=$( cat ${f}.bai.mapped_read_count.txt )

m=${f/unmapped/mapped}
mic=$( cat ${m}.bai.read_count.txt )
miuc=$( cat ${m}.bai.unmapped_read_count.txt )
mimc=$( cat ${m}.bai.mapped_read_count.txt )

#echo "${s},${b},${f},${c},${ic},${uc},${iuc},${imc},${mic},${miuc},${mimc}" >> /francislab/data1/raw/1000genomes/read_counts.csv
echo "${s},${b},${ic},${iuc},${imc},${mic},${miuc},${mimc}" >> /francislab/data1/raw/1000genomes/read_counts.csv
done


