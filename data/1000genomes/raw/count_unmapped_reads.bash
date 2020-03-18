#!/usr/bin/env bash

echo "Replaced with samtools_count.bash and aggregate_unmapped_read_counts.bash"
exit

echo "subject,file,path,count,unmapped_count" > /francislab/data1/raw/1000genomes/unmapped_read_counts.csv
for f in /francislab/data1/raw/1000genomes/phase3/data/*/alignment/*.unmapped.ILLUMINA.*bam ; do
echo $f
b=$( basename $f )
s=${b%.unmapped*}
c=$( samtools view -c ${f} )
uc=$( samtools view -f 4 -c ${f} )
echo "${s},${b},${f},${c},${uc}" >> /francislab/data1/raw/1000genomes/unmapped_read_counts.csv
done

