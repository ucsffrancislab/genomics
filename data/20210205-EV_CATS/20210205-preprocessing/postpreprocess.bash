#!/usr/bin/env bash


module load CBI samtools fastqc

set -x

mkdir post/

#	cd output/
#	ln -s /francislab/data1/raw/20210205-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
#	ln -s /francislab/data1/raw/20210205-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
#	ln -s /francislab/data1/raw/20210205-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz
#	cd ../
#	
#	
#	for f in output/*fastq.gz ; do
#	zcat $f | paste - - - - | wc -l > $f.read_count
#	zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
#	done
#	
#	for f in output/*.toTranscriptome.out.bam ; do
#	samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
#	done
#	
#	transcript_gene=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv
#	
#	for f in output/*.toTranscriptome.out.bam ; do
#	samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
#	awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
#	  ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
#	done
#	
#	awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
#	  output/*.toTranscriptome.out.bam.transcript_ids \
#	  | sort | uniq -c | sort -rn > gene_count
#	
#	awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
#	  output/SFHH0*.toTranscriptome.out.bam.transcript_ids \
#	  | sort | uniq -c | sort -rn > determined_gene_count.txt
#	
#	
#	#for f in ${PWD}/output/*unmapped.fasta.gz ; do
#	#  base=${f%.fasta.gz}
#	#  basename=$(basename $base)
#	#  echo $f
#	#  for m in 0 1 ; do
#	#
#	#    sbatch --job-name=d-${basename}  --time=480 --ntasks=8 --mem=32G \
#	#      --output=${base}.diamond.nr.masking${m}.output.txt \
#	#      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 \
#	#        --db /francislab/data1/refs/diamond/nr \
#	#        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}
#	#
#	#done ; done
#	
#	
#	mirna_gff=/francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3
#	
#	~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	  -o post/STAR_mirna_miRNA_primary_transcript.tsv \
#	  output/*.trimmed.STAR.Aligned.sortedByCoord.out.bam > post/STAR_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	  -o post/STAR_mirna_miRNA.tsv \
#	  output/*.trimmed.STAR.Aligned.sortedByCoord.out.bam > post/STAR_mirna_miRNA.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_all_mirna_miRNA_primary_transcript.tsv \
#	  output/*.trimmed.bowtie2.hg38.all.bam > post/bowtie2_all_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_all_mirna_miRNA.tsv \
#	  output/*.trimmed.bowtie2.hg38.all.bam > post/bowtie2_all_mirna_miRNA.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_mirna_miRNA_primary_transcript.tsv \
#	  output/*.trimmed.bowtie2.hg38.bam > post/bowtie2_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_mirna_miRNA.tsv \
#	  output/*.trimmed.bowtie2.hg38.bam > post/bowtie2_mirna_miRNA.tsv.log 2>&1
#	
#	#featureCounts -a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz -o post/featureCounts.csv *bam
#	
#	
#	for f in output/*STAR.mirna.Aligned.sortedByCoord.out.bam output/*.bowtie{2,}.mirna{.all,}.bam ; do
#	samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.mirna_counts
#	done
#	
#	for f in output/*fasta.gz ; do
#	zcat $f | paste - - | wc -l > $f.read_count
#	done
#	
#	for f in output/*.bam ; do
#	samtools view -c -F 3844 $f > $f.aligned_count
#	samtools view -c -f 4    $f > $f.unaligned_count
#	done
#	
#	fastqc -o post/ output/*fastq.gz
#	
#	./report.bash 
#	./report.bash >> report.md
#	
#	#awk -F"\t" '(($7+$8+$9)>0)' *mirna_miRNA*tsv
#	
#	python3 merge_uniq-c.py --int --output post/mirna_counts.csv output/*mirna_counts
#	
#	python3 merge_uniq-c.py --int --output post/gene_counts.csv output/*gene_count
#	
for f in output/*blastn.nt.txt.gz ; do
add_species_genus_family_to_blast_output.bash -input ${f}
done

for f in output/*blastn.nt.species_genus_family.txt.gz ; do
zcat ${f} | awk 'BEGIN{FS=OFS="\t"}{print $1, $NF}' | uniq | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $2}' | sort | uniq -c | sort -rn > ${f%.txt.gz}.family_counts
done
python3 merge_uniq-c.py --int --output post/family_counts.csv output/*family_counts


#	Brutal on sort memory
#for f in output/*blastn.nt.txt.gz ; do
#~/.local/bin/blastn_summary_with_title.bash -db /francislab/data1/refs/blastn/nt -input ${f}
#done
#python3 merge_uniq-c.py --int --output post/summary_counts.csv output/*blastn.nt.10.summary.txt.gz



