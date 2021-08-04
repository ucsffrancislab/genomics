

sort -k2n output_fi.tsv | tail -20 | cut -f1 > output_fi.top20kmers.fw
sort -k2n output_fi.tsv | tail -10 | cut -f1 > output_fi.top10kmers.fw



awk '{print ">"$0;print $0}' output_fi.top10kmers.fw > output_fi.top10kmers.fw.fa

module load bowtie2
bowtie2 --all --xeq --threads 16 --very-sensitive -x /francislab/data1/refs/refseq/mRNA_Prot-20210528/human.rna -f output_fi.top10kmers.fw.fa > output_fi.top10kmers.fw.all.humanrna.sam


module load samtools

for r in $( samtools view output_fi.top10kmers.fw.all.humanrna.sam | awk '{print $1}' | sort | uniq ) ; do
echo $r
transcripts=$( samtools view -F4 output_fi.top10kmers.fw.all.humanrna.sam | grep "NM:i:0" | awk -v r=$r '($1==r){print $3}' | awk -F. '{print $1}' | sort | uniq )
if [ -n "${transcripts}" ] ; then
for t in ${transcripts} ; do
g=$( grep $t /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv | awk '{print $2}' )
if [ -n "${g}" ] ; then
echo ${g}
else
echo ${t}
fi
done | paste -sd " " | tr " " "\n" | sort | uniq -c
fi
done > output_fi.top10kmers.fw.all.humanrna.exactmatch.transcriptgene.counts.txt

for r in $( samtools view output_fi.top10kmers.fw.all.humanrna.sam | awk '{print $1}' | sort | uniq ) ; do
echo $r
transcripts=$( samtools view -F4 output_fi.top10kmers.fw.all.humanrna.sam | awk -v r=$r '($1==r){print $3}' | awk -F. '{print $1}' | sort | uniq )
if [ -n "${transcripts}" ] ; then
for t in ${transcripts} ; do
g=$( grep $t /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv | awk '{print $2}' )
if [ -n "${g}" ] ; then
echo ${g}
else
echo ${t}
fi
done | paste -sd " " | tr " " "\n" | sort | uniq -c
fi
done > output_fi.top10kmers.fw.all.humanrna.transcriptgene.counts.txt


BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/$( basename $PWD )"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T output_fi.top10kmers.fw.all.humanrna.exactmatch.transcriptgene.counts.txt "${BOX}/"
curl -netrc -T output_fi.top10kmers.fw.all.humanrna.transcriptgene.counts.txt "${BOX}/"






#for k in 30 35 ; do
#for s in Astro GBMmut GBMWT Oligo ; do
#echo ${k}.cutadapt2.${s}
#done ; done




