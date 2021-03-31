#!/usr/bin/env bash

dir=output
core=${dir}/??.bbduk?.unpaired


#cd output/
#for f in /francislab/data1/raw/20191008_Stanford71/01_R?.fastq.gz ; do
#ln -s ${f}
#done
#cd ../

echo -n "|    |"
for f in $( ls ${core}.fastq.gz ) ; do
	base=$( basename $f .fastq.gz )
	base=${base%%.*}
	echo -n " ${base} |"
done
echo

echo -n "| --- |"
for f in $( ls ${core}.fastq.gz ) ; do
	echo -n " --- |"
done
echo

echo -n "| Trimmer |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	case $f in
		*"bbduk1"*)
			c="bbduk1";;
		*"bbduk2"*)
			c="bbduk2";;
		*"bbduk3"*)
			c="bbduk3";;
#		*"cutadapt1"*)
#			c="cutadapt1";;
#		*"cutadapt2"*)
#			c="cutadapt2";;
		*)
			c="unknown"
	esac
	echo -n " ${c} |"
done
echo


echo -n "| Raw R1 Read Count |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	f=${f%.bbduk?.unpaired.fastq.gz.read_count}
	f=${f%.cutadapt?.unpaired.fastq.gz.read_count}
	c=$(cat ${f}_R1.fastq.gz.read_count)
	echo -n " ${c} |"
done
echo

echo -n "| Raw R1 Read Length |"
for f in $( ls ${core}.fastq.gz.average_length ) ; do
	f=${f%.bbduk?.unpaired.fastq.gz.average_length}
	f=${f%.cutadapt?.unpaired.fastq.gz.average_length}
	c=$(cat ${f}_R1.fastq.gz.average_length)
	echo -n " ${c} |"
done
echo 


echo -n "| Trimmed Read Count |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave Read Length |"
for f in $( ls ${core}.fastq.gz.average_length ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo





echo -n "| STAR Aligned to Transcriptome |"
for f in $( ls ${core}.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Transcriptome % |"
for f in $( ls ${core}.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count ) ; do
a=$(cat $f)
f=${f%.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count}
b=$(cat ${f}.fastq.gz.read_count )
c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
echo -n " ${c} |"
done
echo


echo -n "| STAR Aligned to Genome |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to Genome % |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo


echo -n "| STAR Unaligned |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| STAR Unaligned % |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count ) ; do
	a=$(cat $f)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo


echo -n "| STAR Unmapped |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| STAR Unmapped % |"
for f in $( ls ${core}.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count ) ; do
	a=$(cat $f)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to hg38 (1) |"
for f in $( ls ${core}.bowtie2.hg38.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to hg38 (1) % |"
for f in $( ls ${core}.bowtie2.hg38.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie2.hg38.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to mirna |"
for f in $( ls ${core}.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| STAR Aligned to mirna % |"
for f in $( ls ${core}.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to mirna |"
for f in $( ls ${core}.bowtie.mirna.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie Aligned to mirna % |"
for f in $( ls ${core}.bowtie.mirna.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie.mirna.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo


echo -n "| Bowtie2 Aligned to mirna |"
for f in $( ls ${core}.bowtie2.mirna.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to mirna % |"
for f in $( ls ${core}.bowtie2.mirna.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie2.mirna.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo



echo -n "| Bowtie2 Aligned to phiX |"
for f in $( ls ${core}.bowtie2.phiX.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to phiX % |"
for f in $( ls ${core}.bowtie2.phiX.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie2.phiX.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo



echo -n "| Bowtie2 Aligned to Salmonella |"
for f in $( ls ${core}.bowtie2.salmonella.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to Salmonella % |"
for f in $( ls ${core}.bowtie2.salmonella.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie2.salmonella.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo





echo -n "| Bowtie2 Aligned to Burkholderia |"
for f in $( ls ${core}.bowtie2.burkholderia.bam.aligned_count ) ; do
	c=$(cat $f)
	echo -n " ${c} |"
done
echo

echo -n "| Bowtie2 Aligned to Burkholderia % |"
for f in $( ls ${core}.bowtie2.burkholderia.bam.aligned_count ) ; do
	a=$(cat $f)
	f=${f%.bowtie2.burkholderia.bam.aligned_count}
	b=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l )
	echo -n " ${c} |"
done
echo






echo -n "| STAR Gene Counts |"
for f in $( ls ${core}.STAR.hg38.Aligned.toTranscriptome.out.bam.gene_counts ) ; do
	echo -n " --- |"
done
echo

for gene in $( head -50 post/gene_counts | awk '{print $2}' ) ; do
	echo -n "| ${gene} |"
	for f in $( ls ${core}.STAR.hg38.Aligned.toTranscriptome.out.bam.gene_counts ) ; do
		c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${f} )
		echo -n " ${c} |"
	done
	echo
done



echo -n "| STAR miRNA Counts |"
for f in $( ls ${core}.STAR.mirna.Aligned.sortedByCoord.out.bam.mirna_counts ) ; do
	echo -n " --- |"
done
echo

for gene in $( head -50 post/mirna_counts | awk '{print $2}' ) ; do
	echo -n "| ${gene} |"
	for f in $( ls ${core}.STAR.mirna.Aligned.sortedByCoord.out.bam.mirna_counts ) ; do
		c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${f} )
		echo -n " ${c} |"
	done
	echo
done





echo -n "| blastn Family Counts |"
for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
	echo -n " --- |"
done
echo

save="${IFS}"
IFS=","
for family in $( head -50 post/family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
	echo -n "| ${family} |"
	IFS="${save}"
	for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
		c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' )
		#c=$( awk -v family=$family '( $2 == family ){print $1}' ${f} )
		echo -n " ${c} |"
	done
	echo
	IFS=","
done
IFS="${save}"



