#!/usr/bin/env bash

dir=out


rawdir=/francislab/data1/raw/20211001-EV
for fastq in ${rawdir}/S*fastq.gz ; do
	basename=$( basename $fastq .fastq.gz )
	basename=${basename%%_*}
	ln -s ${fastq} ${dir}/${basename}.fastq.gz 2> /dev/null
	ln -s ${fastq}.read_count.txt ${dir}/${basename}.fastq.gz.read_count.txt 2> /dev/null
#	ln -s ${fastq}.average_length.txt output/${basename}.fastq.gz.average_length.txt 2> /dev/null
#	ln -s ${rawdir}/${basename}.labkit output/ 2> /dev/null
#	ln -s ${rawdir}/${basename}.subject output/ 2> /dev/null
#	ln -s ${rawdir}/${basename}.diagnosis output/ 2> /dev/null
done




#ls -1 /francislab/data1/raw/20210428-EV/Hansen/S*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}'

samples="SFHH008A SFHH008B SFHH008C SFHH008D SFHH008E SFHH008F"


echo -n "|    |"
for s in ${samples} ; do
	echo -n " ${s} |"
done
echo

echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

echo -n "| Paired Raw Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

#	echo -n "| Raw Read Length |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}${suffix}.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo

echo -n "| Quality Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Format Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Consolidated Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Trimmed Ave Read Length |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.R1.fastq.gz.average_length.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Not phiX Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.phiX.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Not Salmonella Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.phiX.salmon.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| Not Burkholderia Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| HG38 Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38.bam.aligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| NOT HG38 Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38.bam.unaligned_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo




#	echo -n "| GT30 Read Count |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.fastq.gz.read_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| GT30 Ave Read Length |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| LTE30 Read Count |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.lte30.fastq.gz.read_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| LTE30 Ave Read Length |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.lte30.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	
#	echo -n "| STAR Aligned to Transcriptome |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| STAR Aligned to Transcriptome % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.STAR.hg38.Aligned.toTranscriptome.out.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| STAR Aligned to Genome |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| STAR Aligned to Genome % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| STAR Unaligned |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| STAR Unaligned % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.STAR.hg38.Aligned.sortedByCoord.out.bam.unaligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| STAR Unmapped |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| STAR Unmapped % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.STAR.hg38.Aligned.sortedByCoord.out.unmapped.fasta.gz.read_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to hg38 (1) |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.hg38.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to hg38 (1) % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.hg38.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.hg38.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| STAR Aligned to mirna |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.lte30.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| STAR Aligned to mirna % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.lte30.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.STAR.mirna.Aligned.sortedByCoord.out.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie Aligned to mirna |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.lte30.bowtie.mirna.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie Aligned to mirna % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.lte30.bowtie.mirna.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie.mirna.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to mirna |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.lte30.bowtie2.mirna.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to mirna % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.lte30.bowtie2.mirna.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.mirna.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to RMSK |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.rmsk.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to RMSK % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.rmsk.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.rmsk.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to phiX |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.phiX.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to phiX % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.phiX.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.phiX.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to Salmonella |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.salmonella.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to Salmonella % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.salmonella.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.salmonella.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to masked Salmonella |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.salmonella.masked.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to masked Salmonella % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.salmonella.masked.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.salmonella.masked.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to Burkholderia |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.burkholderia.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to Burkholderia % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.burkholderia.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.burkholderia.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to masked Burkholderia |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.burkholderia.masked.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to masked Burkholderia % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.burkholderia.masked.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.burkholderia.masked.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	
#	echo -n "| Bowtie2 Aligned to mRNA_Prot |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		c=$(cat ${dir}/${s}.${t}.gt30.bowtie2.mRNA_Prot.bam.aligned_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo
#	
#	echo -n "| Bowtie2 Aligned to mRNA_Prot % |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		f=${dir}/${s}.${t}.gt30.bowtie2.mRNA_Prot.bam.aligned_count.txt
#		n=$(cat ${f} 2> /dev/null)
#		f=${f%.bowtie2.mRNA_Prot.bam.aligned_count.txt}
#		d=$(cat ${f}.fastq.gz.read_count.txt 2> /dev/null)
#		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#		echo -n " ${c} |"
#	done ; done
#	echo





















#	
#	
#	
#	echo -n "| STAR Gene Counts |"
#	for s in ${samples} ; do for t in ${trimmers} ; do
#		#echo -n " --- |"
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
#		#echo -n " --- |"
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
#	#		echo -n " --- |"
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
#		#echo -n " --- |"
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
#		#echo -n " --- |"
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
#		#echo -n " --- |"
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
#		#echo -n " --- |"
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

