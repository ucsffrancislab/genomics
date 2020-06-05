#!/usr/bin/env bash


for f1 in /raid/data/raw/TCGA_GBM_RNAseq/TCGA-*1.fastq.gz ; do
f2=${f1/.1./.2.}
basename=${f1##*/}
basename=${basename%.1.fastq.gz}
echo $f1 $f2
echo $basename

#kallisto quant --threads 40 --index /raid/refs/refseq/mRNA_Prot/human.rna --output-dir /raid/data/working/TCGA_GBM_RNAseq/20180928-kallisto/${basename}.human.rna $f1 $f2

#kallisto quant --threads 40 --index /raid/refs/refseq/RefSeqGene/refseqgene.genomic --output-dir /raid/data/working/TCGA_GBM_RNAseq/20180928-kallisto/${basename}.refseqgene.genomic $f1 $f2

#kallisto quant --threads 40 --index /raid/refs/kallisto/Homo_sapiens.GRCh38.idx --output-dir /raid/data/working/TCGA_GBM_RNAseq/20180928-kallisto/${basename}.Homo_sapiens.GRCh38 --genomebam --gtf /raid/refs/kallisto/Homo_sapiens.GRCh38.93.gtf.gz $f1 $f2

#kallisto quant --threads 40 --index /raid/refs/kallisto/Homo_sapiens.GRCh38.idx --output-dir /raid/data/working/TCGA_GBM_RNAseq/20180928-kallisto/${basename}.Homo_sapiens.GRCh38 --gtf /raid/refs/kallisto/Homo_sapiens.GRCh38.93.gtf.gz $f1 $f2


#	https://scilifelab.github.io/courses/rnaseq/labs/kallisto

#time kallisto quant -i hsGRCh38_kallisto -t 40 -b 100 $f1 $f2 -o $basename.test



#	Apparently NEED to use my combined index Homo_sapiens.GRCh38.rna which matches
#	the ensembl stuff from sleuth and the following works ...
#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
#	wget ftp://ftp.ensembl.org/pub/release-93/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz
#	cat Homo_sapiens.GRCh38.cdna.all.fa.gz Homo_sapiens.GRCh38.ncrna.fa.gz > Homo_sapiens.GRCh38.rna.fa.gz
#	kallisto index --index Homo_sapiens.GRCh38.rna.idx Homo_sapiens.GRCh38.rna.fa.gz

#	Also, sleuth seems to need some bootstraps. Not sure how many. 100 takes a while. Use less next time?

kallisto quant -b 100 --threads 40 --index /raid/refs/kallisto/Homo_sapiens.GRCh38.rna.idx --output-dir /raid/data/working/TCGA_GBM_RNAseq/20180928-kallisto/${basename}.Homo_sapiens.GRCh38.rna $f1 $f2


done

