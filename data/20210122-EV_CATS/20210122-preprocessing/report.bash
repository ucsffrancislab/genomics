#!/usr/bin/env bash


echo -n "|    |"
for f in output/*_001_w_umi.fastq.gz.read_count ; do
c=$( basename $f _001_w_umi.fastq.gz.read_count )
c=${c/_*_/_}
echo -n " ${c} |"
done
echo

echo -n "| --- |"
for f in output/*_001_w_umi.fastq.gz.read_count ; do
echo -n " --- |"
done
echo



echo -n "| Raw Read Count |"
for f in output/*_001_w_umi.fastq.gz.read_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Raw Read Length |"
for f in output/*_001_w_umi.fastq.gz.average_length ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo 

echo -n "| Trimmed Read Count |"
for f in output/*_001_w_umi.trimmed.fastq.gz.read_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave Read Length |"
for f in output/*_001_w_umi.trimmed.fastq.gz.average_length ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Transcriptome |"
for f in output/*_001_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Transcriptome % |"
for f in output/*_001_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.bam.aligned_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.toTranscriptome.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Genome |"
for f in output/*_001_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Genome % |"
for f in output/*_001_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam.aligned_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.sortedByCoord.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to phiX |"
for f in output/*_001_w_umi.trimmed.bowtie2phiX.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to phiX % |"
for f in output/*_001_w_umi.trimmed.bowtie2phiX.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2phiX.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo







for gene in $( head -20 gene_count | awk '{print $2}' ) ; do
echo -n "| ${gene} |"
for f in output/*_001_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.bam.gene_count ; do
c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${f} )
echo -n " ${c} |"
done
echo
done



