#!/usr/bin/env bash


if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools fastqc
else
	echo -e "\nThis will probably fail as could not load modules.\n"
	echo -e "You should probably cancel and run on appropriate node.\n"
	sleep 10	
fi

set -x

mkdir post/

#cd output/
#for f in /francislab/data1/raw/20210309-EV_Lexogen/*.fastq.gz ; do
#	ln -s ${f}
#done
#cd ../

#for f in output/*fastq.gz ; do
#	zcat $f | paste - - - - | wc -l > $f.read_count
#	zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
#done

for bam in output/*.toTranscriptome.out.bam ; do
	f=${bam}.transcript_count
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -F4 $bam | awk '{print $3}' | sort --parallel=8 \
			| uniq -c | sort -rn > ${f}
		chmod -w $f
	fi
done

transcript_gene=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv
	
for bam in output/*.toTranscriptome.out.bam ; do
	f=${bam}.transcript_ids
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -F4 $bam | awk '{print $3}' > ${f}
		chmod -w $f
	fi

	f=${bam}.gene_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
			${bam}.transcript_ids | sort --parallel=8 | uniq -c | sort -rn > ${f}
		chmod -w $f
	fi
done
#python3 ~/.local/bin/merge_uniq-c.py --int --output post/gene_counts.csv output/*gene_counts





f=post/gene_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	mkdir ~/.sort_gene_counts
	awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
		output/*.toTranscriptome.out.bam.transcript_ids \
		| sort --temporary-directory=$HOME/.sort_gene_counts --parallel=8 \
		| uniq -c | sort -rn > $f
	chmod -w $f
	rmdir ~/.sort_gene_counts
fi



#	Exclude the Undetermined data
#awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
#  output/SFHH0*.toTranscriptome.out.bam.transcript_ids \
#  | sort | uniq -c | sort -rn > post/determined_gene_count.txt

#for f in ${PWD}/output/*unmapped.fasta.gz ; do
#  base=${f%.fasta.gz}
#  basename=$(basename $base)
#  echo $f
#  for m in 0 1 ; do
#
#    sbatch --job-name=d-${basename}  --time=480 --ntasks=8 --mem=32G \
#      --output=${base}.diamond.nr.masking${m}.output.txt \
#      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 \
#        --db /francislab/data1/refs/diamond/nr \
#        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}
#
#done ; done

#	mirna_gff=/francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3

#	~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	  -o post/STAR_mirna_miRNA_primary_transcript.tsv \
#	  output/*.STAR.mirna.Aligned.sortedByCoord.out.bam > post/STAR_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	  -o post/STAR_mirna_miRNA.tsv \
#	  output/*.STAR.mirna.Aligned.sortedByCoord.out.bam > post/STAR_mirna_miRNA.tsv.log 2>&1
#	
#	#~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	#  -o post/bowtie2_all_mirna_miRNA_primary_transcript.tsv \
#	#  output/*.trimmed.bowtie2.hg38.all.bam > post/bowtie2_all_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	#
#	#~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	#  -o post/bowtie2_all_mirna_miRNA.tsv \
#	#  output/*.trimmed.bowtie2.hg38.all.bam > post/bowtie2_all_mirna_miRNA.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_mirna_miRNA_primary_transcript.tsv \
#	  output/*.bowtie2.hg38.bam > post/bowtie2_mirna_miRNA_primary_transcript.tsv.log 2>&1
#	
#	~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
#	  -o post/bowtie2_mirna_miRNA.tsv \
#	  output/*.bowtie2.hg38.bam > post/bowtie2_mirna_miRNA.tsv.log 2>&1
#	
#	#featureCounts -a \
#	#	/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz \
#	#	-o post/featureCounts.csv *bam


#for bam in output/*STAR.mirna.Aligned.sortedByCoord.out.bam output/*.bowtie{2,}.mirna{.all,}.bam ; do
for bam in output/*STAR.mirna.Aligned.sortedByCoord.out.bam ; do
	f=${bam}.mirnas
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -F4 $bam | awk '{print $3}' > ${f}
		chmod -w $f
	fi

	f=${bam}.mirna_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat ${bam}.mirnas | sort --parallel=8 | uniq -c | sort -rn > ${f}
		chmod -w $f
	fi
done


f=post/mirna_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	mkdir ~/.sort_mirna_counts
	cat output/*.STAR.mirna.Aligned.sortedByCoord.out.bam.mirnas \
		| sort --temporary-directory=$HOME/.sort_mirna_counts --parallel=8 \
		| uniq -c | sort -rn > $f
	chmod -w $f
	rmdir ~/.sort_mirna_counts
fi



#python3 ~/.local/bin/merge_uniq-c.py --int --output post/mirna_counts.csv output/*mirna_counts

#for f in output/*fasta.gz ; do
#	zcat $f | paste - - | wc -l > $f.read_count
#done

#for f in output/*.bam ; do
#	samtools view -c -F 3844 $f > $f.aligned_count
#	samtools view -c -f 4    $f > $f.unaligned_count
#done

#fastqc -o post/ output/*fastq.gz


#awk -F"\t" '(($7+$8+$9)>0)' *mirna_miRNA*tsv



#for f in output/*blastn.nt.species_genus_family.txt.gz ; do
#cat output/*.blastn.nt.species_genus_family.families | sort | uniq -c | sort -rn > post/family_counts
#	zcat ${f} | awk 'BEGIN{FS=OFS="\t"}{print $1, $NF}' | uniq | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $2}' | sort | uniq -c | sort -rn > ${f%.txt.gz}.family_counts


for sgf in output/*diamond.nr.species_genus_family.txt.gz ; do
	f=${sgf%.txt.gz}.families
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${sgf} | awk 'BEGIN{FS=OFS="\t"}{print $1, $NF}' | \
			uniq | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $2}' > ${f}
		chmod -w $f
	fi

	f=${sgf%.txt.gz}.family_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		mkdir ~/.sort_family_counts
		cat ${sgf%.txt.gz}.families | \
			sort --parallel=8 --temporary-directory=$HOME/.sort_family_counts | \
			uniq -c | sort -rn > ${f}
		rmdir ~/.sort_family_counts
		chmod -w $f
	fi
done

f=post/diamond_family_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	mkdir ~/.sort_family_counts
	zcat output/*.diamond.nr.species_genus_family.families.gz \
		| sort --parallel=8 --temporary-directory=$HOME/.sort_family_counts \
		| uniq -c | sort -rn > $f
	rmdir ~/.sort_family_counts
	chmod -w $f
fi

#python3 ~/.local/bin/merge_uniq-c.py --int --output post/family_counts.csv output/*family_counts


#	sed -i '1s/_L001_R1_001_w_umi.trimmed.blastn.nt.species_genus_family.family_counts//g' post/family_counts.csv



mkdir ~/.sort_sequences
for bam in output/SF*.bowtie2.rmsk.bam ; do
	base=${bam%.bam}
	
	f=${base}.aligned_sequences.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -F4 $bam | awk '{print $3}' | gzip > ${f}
		chmod -w $f
	fi

	f=${base}.aligned_sequences.names.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.txt.gz \
			| awk -F\; '{print $1}' | awk -F\= '{print $2}' \
			| gzip > $f
		chmod -w $f
	fi

	f=${base}.rmsk_name_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.names.txt.gz \
			| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
			| uniq -c | sort -rn > $f
		chmod -w $f
	fi

	f=${base}.aligned_sequences.classes.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.txt.gz \
			| awk -F\; '{print $2}' | awk -F\= '{print $2}' \
			| gzip > $f
		chmod -w $f
	fi

	f=${base}.rmsk_class_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.classes.txt.gz \
			| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
			| uniq -c | sort -rn > $f
		chmod -w $f
	fi

	f=${base}.aligned_sequences.families.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.txt.gz \
			| awk -F\; '{print $3}' | awk -F\= '{print $2}' | awk -F: '{print $1}' \
			| gzip > $f
		chmod -w $f
	fi

	f=${base}.rmsk_family_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		zcat ${base}.aligned_sequences.families.txt.gz \
			| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
			| uniq -c | sort -rn > $f
		chmod -w $f
	fi

done
rmdir ~/.sort_sequences

mkdir ~/.sort_sequences
f=post/rmsk_name_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	zcat output/*.aligned_sequences.names.txt.gz \
		| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
		| uniq -c | sort -rn > $f
	chmod -w $f
fi

f=post/rmsk_class_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	zcat output/*.aligned_sequences.classes.txt.gz \
		| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
		| uniq -c | sort -rn > $f
	chmod -w $f
fi

f=post/rmsk_family_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	zcat output/*.aligned_sequences.families.txt.gz \
		| sort --parallel=8 --temporary-directory=$HOME/.sort_sequences \
		| uniq -c | sort -rn > $f
	chmod -w $f
fi

rmdir ~/.sort_sequences




for bam in output/*.bowtie2.mRNA_Prot.bam ; do
	f=${bam}.mrnas
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -F4 $bam | awk '{print $3}' > ${f}
		chmod -w $f
	fi
	#	sbatch --parsable samtools_aligned_sequences.bash $bam $bam.mrnas

	f=${bam}.mrna_counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat ${bam}.mrnas | sort --parallel=8 | uniq -c | sort -rn > ${f}
		chmod -w $f
	fi
	#	sbatch --depends ....   uniq_list_counts.bash $bam.mrnas ${bam}.mrna_counts
done

f=post/mrna_counts
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	mkdir ~/.sort_mrna_counts
	cat output/*.bowtie2.mRNA_Prot.bam.mrnas \
		| sort --temporary-directory=$HOME/.sort_mrna_counts --parallel=8 \
		| uniq -c | sort -rn > $f
	rmdir ~/.sort_mrna_counts
	chmod -w $f
fi




#./report.bash > report.md
#cat report.md
#sed -e 's/ | /,/g' -e 's/ \?| \?//g' report.md > report.csv

