#!/usr/bin/env bash


sort -k2n output_fi.tsv | tail -10 | cut -f1 > output_fi.top10kmers.fw


awk '{print ">"$0;print $0}' output_fi.top10kmers.fw > output_fi.top10kmers.fw.fa

module load bowtie2
bowtie2 --all --xeq --threads 16 --very-sensitive -x /francislab/data1/refs/sources/igv.broadinstitute.org/annotations/hg38/rmsk/rmsk -f output_fi.top10kmers.fw.fa > output_fi.top10kmers.fw.all.rmsk.sam

module load samtools




for r in $( samtools view output_fi.top10kmers.fw.all.rmsk.sam | awk '{print $1}' | sort | uniq ) ; do
echo $r
samtools view -F4 output_fi.top10kmers.fw.all.rmsk.sam | grep "NM:i:0" | awk -v r=$r '($1==r){print $3}' | sort | uniq -c
done > output_fi.top10kmers.fw.all.rmsk.exactmatch.counts.txt



for r in $( samtools view output_fi.top10kmers.fw.all.rmsk.sam | awk '{print $1}' | sort | uniq ) ; do
echo $r
samtools view -F4 output_fi.top10kmers.fw.all.rmsk.sam | awk -v r=$r '($1==r){print $3}' | sort | uniq -c
done > output_fi.top10kmers.fw.all.rmsk.counts.txt


BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/$( basename $PWD )"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T output_fi.top10kmers.fw.all.rmsk.exactmatch.counts.txt "${BOX}/"
curl -netrc -T output_fi.top10kmers.fw.all.rmsk.counts.txt "${BOX}/"






#for k in 30 35 ; do
#for s in Astro GBMmut GBMWT Oligo ; do
#echo ${k}.cutadapt2.${s}
#done ; done


