#!/usr/bin/env bash

dir=output

#core="${dir}/*_R1_001.*{bbduk,cutadapt}?"
#core="${dir}/*_R1_001.*\{bbduk,cutadapt\}?"
#
#	try this instead of curly braces
#	?(list): Matches zero or one occurrence of the given patterns.
#	*(list): Matches zero or more occurrences of the given patterns.
#	+(list): Matches one or more occurrences of the given patterns.
#	@(list): Matches one of the given patterns.
#	!(list): Matches anything but the given patterns.
#	The list inside the parentheses is a list of globs or extended globs separated by the | character.
#
core="${dir}/*_R1_001.*@(bbduk|cutadapt)?"
shopt -s extglob


echo -n "|    |"
for f in $( ls ${core}.fastq.gz ) ; do
	base=$( basename $f .fastq.gz )
	base=${base%%_*}
	echo -n " ${base} |"
done
echo

echo -n "| --- |"
for f in $( ls ${core}.fastq.gz ) ; do
	echo -n " --- |"
done
echo

echo -n "| Consolidation |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	if [[ "$f" == *"consolidated"* ]]; then
		c="consolidated"
	else
		c="unconsolidated"
	fi
	echo -n " ${c} |"
done
echo

echo -n "| Trimmer |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	case $f in
		*"bbduk1"*)
			c="bbduk1";;
		*"bbduk2"*)
			c="bbduk2";;
		*"cutadapt1"*)
			c="cutadapt1";;
		*"cutadapt2"*)
			c="cutadapt2";;
		*)
			c="unknown"
	esac
	echo -n " ${c} |"
done
echo

echo -n "| Raw Read Count |"
for f in $( ls ${core}.fastq.gz.read_count ) ; do
	f=${f%.bbduk?.fastq.gz.read_count}
	f=${f%.cutadapt?.fastq.gz.read_count}
	c=$(cat ${f}.fastq.gz.read_count)
	echo -n " ${c} |"
done
echo

echo -n "| Raw Read Length |"
for f in $( ls ${core}.fastq.gz.average_length ) ; do
	f=${f%.bbduk?.fastq.gz.average_length}
	f=${f%.cutadapt?.fastq.gz.average_length}
	c=$(cat ${f}.fastq.gz.average_length)
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
		echo -n " ${c} |"
	done
	echo
	IFS=","
done
IFS="${save}"

