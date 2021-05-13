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

#cd output/
#for f in /francislab/data1/raw/20191008_Stanford71/??_R?.fastq.gz* ; do
#	ln -s ${f}
#done
#cd ../

#	Really should be doing this much more explicitly rather than just hoping that all of the samples are there and in the right order.


#rawdir=/francislab/data1/raw/20210428-EV/Hansen
rawdir=/francislab/data1/working/20210428-EV/20210511-trimming/trimmed
for fastq in ${rawdir}/S*fastq.gz ; do
	basename=$( basename $fastq .fastq.gz )
	basename=${basename%%_*}
	ln -s ${fastq} output/${basename}.fastq.gz 2> /dev/null
	ln -s ${fastq}.read_count.txt output/${basename}.fastq.gz.read_count.txt 2> /dev/null
	ln -s ${fastq}.average_length.txt output/${basename}.fastq.gz.average_length.txt 2> /dev/null
	ln -s ${rawdir}/${basename}.labkit output/ 2> /dev/null
	ln -s ${rawdir}/${basename}.subject output/ 2> /dev/null
	ln -s ${rawdir}/${basename}.diagnosis output/ 2> /dev/null
done




#ls -1 /francislab/data1/raw/20210428-EV/Hansen/S*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}'

samples="SFHH005aa SFHH005ab SFHH005ac SFHH005ad SFHH005ae SFHH005af SFHH005ag SFHH005ah SFHH005ai SFHH005aj SFHH005ak SFHH005al SFHH005am SFHH005an SFHH005ao SFHH005ap SFHH005aq SFHH005ar SFHH005a SFHH005b SFHH005c SFHH005d SFHH005e SFHH005f SFHH005g SFHH005h SFHH005i SFHH005j SFHH005k SFHH005l SFHH005m SFHH005n SFHH005o SFHH005p SFHH005q SFHH005r SFHH005s SFHH005t SFHH005u SFHH005v SFHH005w SFHH005x SFHH005y SFHH005z SFHH006aa SFHH006ab SFHH006ac SFHH006ad SFHH006ae SFHH006af SFHH006ag SFHH006ah SFHH006ai SFHH006aj SFHH006ak SFHH006al SFHH006am SFHH006an SFHH006ao SFHH006ap SFHH006aq SFHH006ar SFHH006a SFHH006b SFHH006c SFHH006d SFHH006e SFHH006f SFHH006g SFHH006h SFHH006i SFHH006j SFHH006k SFHH006l SFHH006m SFHH006n SFHH006o SFHH006p SFHH006q SFHH006r SFHH006s SFHH006t SFHH006u SFHH006v SFHH006w SFHH006x SFHH006y SFHH006z"

trimmers="bbduk1 bbduk2 bbduk3 cutadapt1 cutadapt2 cutadapt3"

suffix=""	#	_R1

echo -n "|    |"
for s in ${samples} ; do for t in ${trimmers} ; do
	echo -n " ${s} |"
done ; done
echo

echo -n "| --- |"
for s in ${samples} ; do for t in ${trimmers} ; do
	echo -n " --- |"
done ; done
echo

echo -n "| Subject |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.subject 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Lab kit |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.labkit 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Trimmer |"
for s in ${samples} ; do for t in ${trimmers} ; do
	echo -n " ${t} |"
done ; done
echo

echo -n "| Raw Read Count |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}${suffix}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Raw Read Length |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}${suffix}.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Trimmed Read Count |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Trimmed Ave Read Length |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Transcriptome |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Transcriptome % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Aligned to Genome |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to Genome % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Unaligned |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Unaligned % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Unmapped |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Unmapped % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to hg38 (1) |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.hg38.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to hg38 (1) % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.hg38.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.hg38.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| STAR Aligned to mirna |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| STAR Aligned to mirna % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie Aligned to mirna |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie.mirna.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie Aligned to mirna % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie.mirna.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie.mirna.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to mirna |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.mirna.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to mirna % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.mirna.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.mirna.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to RMSK |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.rmsk.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to RMSK % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.rmsk.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.rmsk.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to phiX |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.phiX.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to phiX % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.phiX.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.phiX.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to Salmonella |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.salmonella.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to Salmonella % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.salmonella.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.salmonella.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to masked Salmonella |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.salmonella.masked.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to masked Salmonella % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.salmonella.masked.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.salmonella.masked.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to Burkholderia |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.burkholderia.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to Burkholderia % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.burkholderia.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.burkholderia.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to masked Burkholderia |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.burkholderia.masked.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to masked Burkholderia % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.burkholderia.masked.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.burkholderia.masked.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo


echo -n "| Bowtie2 Aligned to mRNA_Prot |"
for s in ${samples} ; do for t in ${trimmers} ; do
	c=$(cat ${dir}/${s}.${t}.bowtie2.mRNA_Prot.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| Bowtie2 Aligned to mRNA_Prot % |"
for s in ${samples} ; do for t in ${trimmers} ; do
	f=${dir}/${s}.${t}.bowtie2.mRNA_Prot.bam.aligned_count.txt
	n=$(cat ${f} 2> /dev/null)
	f=${f%.bowtie2.mRNA_Prot.bam.aligned_count.txt}
	d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo








#	
#	
#	
#	echo -n "| STAR Gene Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	
#	
#	#	In the next notebook, can you please pull the genes EGFR, IDH, ATRX, CDKN2A/B, NF1, tp53, RB1 and TERT and force box plots on those. They are known Glioma genes and I want to peek.
#	
#	#		EGFR, Many IDH*, several CDKN2*, NF1, TP53, RB1, TERT
#	
#	#cat ../20210428-preprocessing/post/gene_counts  | awk '{print $2}' | grep -E "^(EGFR|IDH|CDKN2|NF1|TP53|RB1|TERT)" | sort > requested_genes 
#	
#	#		vi requested_genes
#	
#	#touch requested_genes	#	just to make sure it exists
#	#head -50 post/gene_counts | awk '{print $2}' > post/top_genes
#	
#	#for gene in $( head -50 post/gene_counts | awk '{print $2}' ) ; do
#	#for gene in $( awk '{if( seen[$0]++ == 1 )print;}' requested_genes post/top_genes | head -50 ) ; do
#	for gene in $( cat post/gene_counts | awk '{print $2}' ) ; do
#		echo -n "| ${gene} |"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${dir}/${s}.${t}.STAR.hg38.Aligned.toTranscriptome.out.bam.gene_counts 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#	done
#	
#	
#	
#	echo -n "| STAR miRNA Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	#for gene in $( head -50 post/mirna_counts | awk '{print $2}' ) ; do
#	for gene in $( cat post/mirna_counts | awk '{print $2}' ) ; do
#		echo -n "| ${gene} |"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${dir}/${s}.${t}.STAR.mirna.Aligned.sortedByCoord.out.bam.mirna_counts 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#	done
#	
#	
#	
#	
#	
#	#	echo -n "| blastn Family Counts |"
#	#	for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
#	#		echo -n " |"
#	#	done
#	#	echo
#	#	
#	#	save="${IFS}"
#	#	IFS=","
#	#	for family in $( head -50 post/blastn_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	#		echo -n "| ${family} |"
#	#		IFS="${save}"
#	#		for f in $( ls ${core}.blastn.nt.species_genus_family.family_counts ) ; do
#	#			c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' )
#	#			#c=$( awk -v family=$family '( $2 == family ){print $1}' ${f} )
#	#			echo -n " ${c} |"
#	#		done
#	#		echo
#	#		IFS=","
#	#	done
#	#	IFS="${save}"
#	
#	
#	echo -n "| diamond Family Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	save="${IFS}"
#	IFS=","
#	#for family in $( head -50 post/diamond_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	for family in $( cat post/diamond_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#		echo -n "| ${family} |"
#		IFS="${save}"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			f=${dir}/${s}.${t}.diamond.nr.species_genus_family.family_counts
#			c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#		IFS=","
#	done
#	IFS="${save}"
#	
#	
#	
#	
#	echo -n "| rmsk Family Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	save="${IFS}"
#	IFS=","
#	#for family in $( head -50 post/rmsk_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	for family in $( cat post/rmsk_family_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#		echo -n "| rf${family} |"
#		IFS="${save}"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			f=${dir}/${s}.${t}.bowtie2.rmsk.rmsk_family_counts
#			c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#		IFS=","
#	done
#	IFS="${save}"
#	
#	
#	
#	
#	
#	
#	echo -n "| rmsk Class Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	save="${IFS}"
#	IFS=","
#	#for family in $( head -50 post/rmsk_class_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	for family in $( cat post/rmsk_class_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#		echo -n "| rc${family} |"
#		IFS="${save}"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			f=${dir}/${s}.${t}.bowtie2.rmsk.rmsk_class_counts
#			c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#		IFS=","
#	done
#	IFS="${save}"
#	
#	
#	
#	
#	
#	
#	echo -n "| rmsk Name Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		echo -n " |"
#	done ; done
#	echo
#	
#	save="${IFS}"
#	IFS=","
#	#for family in $( head -50 post/rmsk_name_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#	for family in $( cat post/rmsk_name_counts | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" '{print $2}' | paste -sd ',' ) ; do
#		echo -n "| rn${family} |"
#		IFS="${save}"
#		for s in ${samples} ; do for t in ${trimmers} ; do
#			f=${dir}/${s}.${t}.bowtie2.rmsk.rmsk_name_counts
#			c=$( cat ${f} | sed -e 's/^ *//' -e 's/ /\t/' | awk -F"\t" -v family="${family}" '( $2 == family ){print $1}' 2> /dev/null)
#			echo -n " ${c} |"
#		done ; done
#		echo
#		IFS=","
#	done
#	IFS="${save}"
#	
#	
#	
#	

