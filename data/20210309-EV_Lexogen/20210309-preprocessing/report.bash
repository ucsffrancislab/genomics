#!/usr/bin/env bash


echo -n "|    |"
for f in output/*_001.fastq.gz.read_count ; do
c=$( basename $f _001.fastq.gz.read_count )
c=${c/_*_/_}
echo -n " ${c} |"
done
echo

echo -n "| --- |"
for f in output/*_001.fastq.gz.read_count ; do
echo -n " --- |"
done
echo



echo -n "| Raw Read Count |"
for f in output/*_001.fastq.gz.read_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Raw Read Length |"
for f in output/*_001.fastq.gz.average_length ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo 

echo -n "| Trimmed Read Count |"
for f in output/*_001.trimmed.fastq.gz.read_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave Read Length |"
for f in output/*_001.trimmed.fastq.gz.average_length ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Transcriptome |"
for f in output/*_001.trimmed.STAR.Aligned.toTranscriptome.out.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Transcriptome % |"
for f in output/*_001.trimmed.STAR.Aligned.toTranscriptome.out.bam.aligned_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.toTranscriptome.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Genome |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Genome % |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.bam.aligned_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.sortedByCoord.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo


echo -n "| STAR Unaligned |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.bam.unaligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Unaligned % |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.bam.unaligned_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.sortedByCoord.out.bam.unaligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo



echo -n "| STAR Unmapped |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Unmapped % |"
for f in output/*_001.trimmed.STAR.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count ; do
a=$(cat $f)
f=${f%.STAR.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo


#	echo -n "| Bowtie2 Aligned to hg38 --all |"
#	for f in output/*_001.trimmed.bowtie2.hg38.all.bam.aligned_count ; do
#	c=$(cat $f)
#	echo -n " ${c} |"
#	done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to hg38 --all % |"
#	for f in output/*_001.trimmed.bowtie2.hg38.all.bam.aligned_count ; do
#	a=$(cat $f)
#	f=${f%.bowtie2.hg38.all.bam.aligned_count}
#	b=$(cat ${f}.fastq.gz.read_count )
#	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
#	echo -n " ${c} |"
#	done
#	echo


echo -n "| Bowtie2 Aligned to hg38 (1) |"
for f in output/*_001.trimmed.bowtie2.hg38.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to hg38 (1) % |"
for f in output/*_001.trimmed.bowtie2.hg38.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2.hg38.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo


echo -n "| STAR Aligned to mirna |"
for f in output/*_001.trimmed.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to mirna % |"
for f in output/*_001.trimmed.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count ; do
a=$(cat $f)
f=${f%.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to mirna |"
for f in output/*_001.trimmed.bowtie.mirna.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to mirna % |"
for f in output/*_001.trimmed.bowtie.mirna.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie.mirna.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo




echo -n "| Bowtie2 Aligned to mirna |"
for f in output/*_001.trimmed.bowtie2.mirna.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to mirna % |"
for f in output/*_001.trimmed.bowtie2.mirna.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2.mirna.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo








echo -n "| Bowtie2 Aligned to phiX |"
for f in output/*_001.trimmed.bowtie2phiX.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to phiX % |"
for f in output/*_001.trimmed.bowtie2phiX.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2phiX.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo




echo -n "| Bowtie2 Aligned to Salmonella |"
for f in output/*_001.trimmed.bowtie2salmonella.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to Salmonella % |"
for f in output/*_001.trimmed.bowtie2salmonella.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2salmonella.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo




echo -n "| Bowtie2 Aligned to Burkholderia |"
for f in output/*_001.trimmed.bowtie2burkholderia.bam.aligned_count ; do
c=$(cat $f)
echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to Burkholderia % |"
for f in output/*_001.trimmed.bowtie2burkholderia.bam.aligned_count ; do
a=$(cat $f)
f=${f%.bowtie2burkholderia.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo







for gene in $( head -50 gene_count | awk '{print $2}' ) ; do
echo -n "| ${gene} |"
for f in output/*_001.trimmed.STAR.Aligned.toTranscriptome.out.bam.gene_count ; do
c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${f} )
echo -n " ${c} |"
done
echo
done



