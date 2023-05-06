

ln -s /raleighlab/data1/naomi/HUMAN_REF_ANNO/Gencode/GRCh38.p13.genome.fa

module load samtools
samtools faidx GRCh38.p13.genome.fa 


module load gatk


gatk CreateSequenceDictionary -R GRCh38.p13.genome.fa 


gatk SplitNCigarReads -R GRCh38.p13.genome.fa -I /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/GATK_Analysis/QM100_marked_duplicates.bam -O ./QM100_split_reads.bam




