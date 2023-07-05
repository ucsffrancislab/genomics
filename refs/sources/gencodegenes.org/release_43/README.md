

#	gencodegenes.org/release_43


These may be my go to reference set


```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.pc_transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.pc_translations.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.lncRNA_transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/GRCh38.p13.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/GRCh38.primary_assembly.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.primary_assembly.annotation.gtf.gz
```


Make bowtie2, bwa, STAR references


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.log --export=None \
 --wrap="module load star/2.7.7a && STAR --runThreadN 64 --runMode genomeGenerate \
  --genomeFastaFiles ${PWD}/GRCh38.primary_assembly.genome.fa \
  --sjdbGTFfile ${PWD}/gencode.v43.primary_assembly.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.primary_assembly.genome"
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2-build" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build.log --export=None \
 --wrap="module load bowtie2 && bowtie2-build --threads 64 \
  ${PWD}/GRCh38.primary_assembly.genome.fa ${PWD}/GRCh38.primary_assembly.genome"
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bwa-index" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bwa-index.log --export=None \
 --wrap="module load bwa && bwa index -p ${PWD}/GRCh38.primary_assembly.genome ${PWD}/GRCh38.primary_assembly.genome.fa"
```




STAR
--runMode genomeGenerate
--genomeDir <star_index_path>
--genomeFastaFiles <reference>
--sjdbOverhang 100 - this is default. why bother specifying?
--sjdbGTFfile <gencode.v36.annotation.gtf>
--runThreadN 8

Align sample but don't create bam file? Just the sample_name.SJ.out.tag


STAR
--genomeDir <star_index_path>
--readFilesIn <fastq_left_1>,<fastq_left2>,... <fastq_right_1>,<fastq_right_2>,...
--runThreadN <runThreadN>
--outFilterMultimapScoreRange 1
--outFilterMultimapNmax 20
--outFilterMismatchNmax 10
--alignIntronMax 500000
--alignMatesGapMax 1000000
--sjdbScore 2
--alignSJDBoverhangMin 1
--genomeLoad NoSharedMemory
--readFilesCommand <bzcat|cat|zcat>
--outFilterMatchNminOverLread 0.33
--outFilterScoreMinOverLread 0.33
--sjdbOverhang 100
--outSAMstrandField intronMotif
--outSAMtype None
--outSAMmode None


Create a reference for each sample using said SJ.out.tab?

STAR
--runMode genomeGenerate
--genomeDir <output_path>
--genomeFastaFiles <reference>
--sjdbOverhang 100 - this is default. why bother specifying?
--runThreadN <runThreadN>
--sjdbFileChrStartEnd <SJ.out.tab from previous step>

Align again

STAR
--genomeDir <output_path from previous step>
--readFilesIn <fastq_left_1>,<fastq_left2>,... <fastq_right_1>,<fastq_right_2>,...
--runThreadN <runThreadN>
--outFilterMultimapScoreRange 1
--outFilterMultimapNmax 20
--outFilterMismatchNmax 10
--alignIntronMax 500000
--alignMatesGapMax 1000000
--sjdbScore 2
--alignSJDBoverhangMin 1
--genomeLoad NoSharedMemory
--limitBAMsortRAM 0
--readFilesCommand <bzcat|cat|zcat>
--outFilterMatchNminOverLread 0.33
--outFilterScoreMinOverLread 0.33
--sjdbOverhang 100
--outSAMstrandField intronMotif
--outSAMattributes NH HI NM MD AS XS
--outSAMunmapped Within
--outSAMtype BAM SortedByCoordinate
--outSAMheaderHD @HD VN:1.4
--outSAMattrRGline <formatted RG line provided by wrapper>






