#!/usr/bin/env bash


#	 count_mapped_paired_reads.bash /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera/out/*viral.hg38.bam


module load samtools

dir=out

rawdir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out

#	for fastq in ${rawdir}/*_R1.fastq.gz ; do
#		basename=$( basename $fastq .fastq.gz )
#	#	basename=${basename%%_*}
#	#	basename=${basename%_001}
#		r=${basename##*_}
#		basename=${basename%%_*}
#		#\rm {dir}/${basename}_${r}.fastq.gz 2> /dev/null
#		ln -s ${fastq} ${dir}/${basename}_${r}.fastq.gz 2> /dev/null
#		#\rm ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
#		ln -s ${fastq}.read_count.txt ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
#	
#		ln -s ${fastq}.average_length.txt ${dir}/${basename}_${r}.fastq.gz.average_length.txt 2> /dev/null
#	done


samples=$( ls -1 ${rawdir}/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz )

#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}'
#samples="SFHH008A SFHH008B SFHH008C SFHH008D SFHH008E SFHH008F"
#ls -1 /francislab/data1/raw/20211208-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" "
#samples="SFHH009A SFHH009B SFHH009C SFHH009D SFHH009E SFHH009F SFHH009G SFHH009H SFHH009I SFHH009J SFHH009L SFHH009M SFHH009N"


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

#	echo -n "| Paired Raw Read Count |"
#	for s in ${samples} ; do
#		c=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done
#	echo
#	
#	
#	echo -n "| Raw Read Length |"
#	for s in ${samples} ; do
#		c=$(cat ${dir}/${s}_R1.fastq.gz.average_length.txt 2> /dev/null)
#		echo -n " ${c} |"
#	done
#	echo

echo -n "| Viral aligned pair Count |"
for s in ${samples} ; do
	#c=$( samtools view -f64 -c ${dir}/${s}.viral.bam 2> /dev/null)
	c=$( cat ${dir}/${s}.viral.R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo

echo -n "| HG38 aligned pair Count |"
for s in ${samples} ; do
#	c=$( samtools view -f64 -F4 -c ${dir}/${s}.viral.hg38.bam 2> /dev/null)	#	ehh
#	c=$( samtools view -f64 ${dir}/${s}.viral.hg38.bam 2> /dev/null | gawk '( !and($2,4) || !and($2,8) ){ print }' | wc -l )
	c=$( cat ${dir}/${s}.viral.hg38.bam.mapped_pair_read_count.txt 2> /dev/null )
	echo -n " ${c} |"
done
echo


#viruses=$( zcat ${dir}/*.viral.bam.aligned_sequences.txt.gz | uniq | sort | uniq )	 #	too long
viruses=$( cat out/*.viral.bam.aligned_sequence_counts.txt | awk '{print $2}' | sort | uniq )	#	~6000
#viruses="NC_000898.1 NC_001664.4 NC_001716.2 NC_001798.2 NC_001806.2 NC_006273.2 NC_006577.2 NC_007605.1 NC_009333.1 NC_009334.1"
for v in ${viruses} ; do
	echo -n "| ${v} Count |"
	for s in ${samples} ; do
		#c=$( samtools view -F68 -c ${dir}/${s}.viral.hg38.bam 2> /dev/null)
		#samtools view out/02-0047-01A-01R-1849-01+2.viral.bam | grep NC_001806.2 | awk '{print $1}' | uniq
#		samtools view ${dir}/${s}.viral.bam 2> /dev/null | grep ${v} | awk '{print "^"$1"\t"}' | uniq > ${dir}/${s}.viral.bam.${v}.seqs
		#c=$( samtools view -F4 ${dir}/${s}.viral.hg38.bam 2> /dev/null | grep -f ${dir}/${s}.viral.bam.${v}.seqs | wc -l )


#		c=$( samtools view -f64 ${dir}/${s}.viral.hg38.bam 2> /dev/null | grep -f ${dir}/${s}.viral.bam.${v}.seqs | gawk '( !and($2,4) || !and($2,8) ){ print }' | wc -l )


		#c=$( cat ${dir}/${s}.viral.hg38.bam.${v}.count.txt 2>/dev/null )
		c=$( cat ${dir}/${s}.viral/${v}.hg38.bam.mapped_pair_read_count.txt 2>/dev/null )
#out/02-0047-01A-01R-1849-01+1.viral/NC_055901.1.hg38.bam.mapped_pair_read_count.txt

		#echo -n " ${c:-0} |"
		echo -n " ${c} |"
	done
	echo
done


#	head -1 /francislab/data1/working/20211111-hg38-viral-homology/out/raw/AC_000001.1.fasta
#	>AC_000001.1 Ovine adenovirus A, complete genome

