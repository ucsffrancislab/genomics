

#	gencodegenes.org/release_43

https://www.gencodegenes.org/human/release_43.html


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



Pseudo pipeline

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

```


##	20230801


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2-build" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build-hg38-viral.log --export=None \
 --wrap="module load bowtie2 && bowtie2-build --threads 64 \
  ${PWD}/GRCh38.primary_assembly.genome.fa,/francislab/data1/refs/refseq/viral-20230801/viral.1.1.genomic.fna.gz \
  ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20230801"
```

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.human-virallog --export=None \
 --wrap="module load star/2.7.7a && STAR --runThreadN 64 --runMode genomeGenerate \
  --genomeFastaFiles ${PWD}/GRCh38.primary_assembly.genome.fa /francislab/data1/refs/refseq/viral-20230801/viral.1.1.genomic.fna \
  --sjdbGTFfile ${PWD}/gencode.v43.primary_assembly.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20230801"
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bwa-index" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bwa-index-humanviral.log --export=None \
 --wrap="module load bwa && cat ${PWD}/GRCh38.primary_assembly.genome.fa /francislab/data1/refs/refseq/viral-20230801/viral.1.1.genomic.fna | bwa index -p ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20230801 -"
```

keeps failing

```
[BWTIncConstructFromPacked] 780 iterations done. 7264665570 characters processed.
[BWTIncConstructFromPacked] 790 iterations done. 7288393506 characters processed.
[bwt_gen] Finished constructing BWT in 798 iterations.
[bwa_index] 6608.50 seconds elapse.
[bwa_index] Update BWT... 49.56 sec
[bwa_index] Pack forward-only FASTA... [gzread] Bad file descriptor
```


```
cat ${PWD}/GRCh38.primary_assembly.genome.fa /francislab/data1/refs/refseq/viral-20230801/viral.1.1.genomic.fna > GRCh38.primary_assembly.genome.plus.viral-20230801.fa
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bwa-index" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bwa-index-humanviral.log --export=None \
 --wrap="module load bwa && bwa index -p ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20230801 ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20230801.fa"

```

Seems to be working. Not sure why piping fails, but that's that.








##	20230804 - Try RMHM version

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2-build" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build-hg38-viral.log --export=None \
 --wrap="module load bowtie2 && bowtie2-build --threads 64 \
  ${PWD}/GRCh38.primary_assembly.genome.fa,/francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta.gz \
  ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM"
```

##	20230811

There's already a release_44!
Not upgrading yet.


Create a STAR ref with the larger fa for "better" deduplication?


```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.chr_patch_hapl_scaff.annotation.gtf.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.chr_patch_hapl_scaff.basic.annotation.gtf.gz
```

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.$( date "+%Y%m%d%H%M%S%N" ).log --export=None \
 --wrap="module load star && STAR --runThreadN 64 --runMode genomeGenerate \
  --genomeFastaFiles ${PWD}/GRCh38.p13.genome.fa \
  --sjdbGTFfile ${PWD}/gencode.v43.chr_patch_hapl_scaff.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.p13.genome"
```


##	20230825

```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.tRNAs.gtf.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.2wayconspseudos.gtf.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.polyAs.gtf.gz

```

##	20231002


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.$( date "+%Y%m%d%H%M%S%N" ).log --export=None \
 --wrap="module load star/2.7.7a && STAR --runThreadN 64 --runMode genomeGenerate \
  --genomeFastaFiles ${PWD}/GRCh38.primary_assembly.genome.fa /francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta \
  --sjdbGTFfile ${PWD}/gencode.v43.primary_assembly.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM"

```




##	20240122

Create reference with human, viral and bacteria

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2-build-hg38-viral-bacteria" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build-hg38-viral-bacteria.log --export=None \
 --wrap="module load bowtie2 && bowtie2-build --threads 64 \
  ${PWD}/GRCh38.primary_assembly.genome.fa,/francislab/data1/refs/refseq/viral-20230801/viral.genomic.cleaned.fna.gz,/francislab/data1/refs/refseq/bacteria-20210916/NC_only.fa.gz \
  ${PWD}/GRCh38.primary_assembly.genome.viral-20230801.bacteria-20210916-NC_only"
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate-hg38-viral-bacteria" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.$( date "+%Y%m%d%H%M%S%N" ).log --export=None \
 --wrap="module load star/2.7.7a && STAR --runThreadN 64 --runMode genomeGenerate \
--limitGenomeGenerateRAM 400000000000 \
  --genomeFastaFiles ${PWD}/GRCh38.primary_assembly.genome.fa /francislab/data1/refs/refseq/viral-20230801/viral.genomic.cleaned.fna /francislab/data1/refs/refseq/bacteria-20210916/NC_only.fa \
  --sjdbGTFfile ${PWD}/gencode.v43.primary_assembly.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.primary_assembly.genome.viral-20210916.bacteria-20210916-NC_only"

```




