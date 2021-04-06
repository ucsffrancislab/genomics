#!/usr/bin/env bash

dir=output
#core=${dir}/??.bbduk?.unpaired

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
#core="${dir}/*_R1_001.*@(bbduk|cutadapt)?"
#shopt -s extglob

cd output/
for f in /francislab/data1/raw/20191008_Stanford71/??_R?.fastq.gz* ; do
	ln -s ${f}
done
cd ../

#	Really should be doing this much more explicitly rather than just hoping that all of the samples are there and in the right order.

echo -n "|    |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	echo -n " --- |"
done ; done
echo

echo -n "| Trimmer |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	echo -n " ${t} |"
done ; done
echo

echo -n "| Raw R1 Read Count |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Raw R1 Read Length |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}_R1.fastq.gz.average_length.txt)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Trimmed Read Count |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.fastq.gz.read_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Trimmed Ave Read Length |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.fastq.gz.average_length)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Transcriptome |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Transcriptome % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count
	n=$(cat ${f})
	f=${f%.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Aligned to Genome |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Genome % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count
	n=$(cat ${f})
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Unaligned |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Unaligned % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count
	n=$(cat ${f})
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Unmapped |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Unmapped % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count
	n=$(cat ${f})
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to hg38 (1) |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie2.hg38.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to hg38 (1) % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie2.hg38.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie2.hg38.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Aligned to mirna |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to mirna % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count
	n=$(cat ${f})
	f=${f%.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie Aligned to mirna |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie.mirna.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie Aligned to mirna % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie.mirna.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie.mirna.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to mirna |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie2.mirna.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to mirna % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie2.mirna.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie2.mirna.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to phiX |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie2.phiX.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to phiX % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie2.phiX.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie2.phiX.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to Salmonella |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie2.salmonella.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to Salmonella % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie2.salmonella.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie2.salmonella.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to Burkholderia |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	c=$(cat ${dir}/${s}.${t}.unpaired.bowtie2.burkholderia.bam.aligned_count)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to Burkholderia % |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	f=${dir}/${s}.${t}.unpaired.bowtie2.burkholderia.bam.aligned_count
	n=$(cat ${f})
	f=${f%.bowtie2.burkholderia.bam.aligned_count}
	d=$(cat ${f}.fastq.gz.read_count )
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Gene Counts |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	echo -n " --- |"
done ; done
echo

for gene in $( head -50 post/gene_counts | awk '{print $2}' ) ; do
	echo -n "| ${gene} |"
	for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
		c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.toTranscriptome.out.bam.gene_counts )
		echo -n " ${c} |"
	done ; done
	echo
done



echo -n "| STAR miRNA Counts |"
for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
	echo -n " --- |"
done ; done
echo

for gene in $( head -50 post/mirna_counts | awk '{print $2}' ) ; do
	echo -n "| ${gene} |"
	for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
		c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${dir}/${s}.${t}.unpaired.STAR.hg38.Aligned.toTranscriptome.out.bam.mirna_counts )
		echo -n " ${c} |"
	done ; done
	echo
done





#echo -n "| blastn Family Counts |"
#for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
#	echo -n " --- |"
#done
#echo
#
#save="${IFS}"
#IFS=","
#for family in $( head -50 post/blastn_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	echo -n "| ${family} |"
#	IFS="${save}"
#	for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
#		c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' )
#		#c=$( awk -v family=$family '( $2 == family ){print $1}' ${f} )
#		echo -n " ${c} |"
#	done
#	echo
#	IFS=","
#done
#IFS="${save}"







#echo -n "| diamond Family Counts |"
#for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
#	echo -n " --- |"
#done ; done
#echo
#
#save="${IFS}"
#IFS=","
#for family in $( head -50 post/diamond_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	echo -n "| ${family} |"
#	IFS="${save}"
#	for s in $( seq -w 1 77 ) ; do for t in bbduk1 bbduk2 bbduk3 ; do
#		f=${dir}/${s}.${t}.unpaired.diamond.nr.species_genus_family.family_counts
#		c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' )
#		echo -n " ${c} |"
#	done ; done
#	echo
#	IFS=","
#done
#IFS="${save}"







