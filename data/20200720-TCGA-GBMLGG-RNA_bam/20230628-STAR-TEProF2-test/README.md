
#	20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR-TEProF2-test




Align this pair with STAR

```
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz
```


tagXSstrandedData.awk usage.  Assuming strType=2. No idea if its true"
```
cat Aligned.out.sam | awk -v strType=2 -f tagXSstrandedData.awk 
#	strType defines strandedness of the libraries: strType = mate whose strand is the same as RNA strand.
#	For instance, for Illumina Tru-seq, strType=2 - the 2nd mate's strand is the same as RNA.
```


```
mkdir bams
cd bams
ln -s ../../20200805-STAR_hg38/out/02-0047-01A-01R-1849-01+1.STAR.hg38.Aligned.sortedByCoord.out.bam bams/unknown.Aligned.sortedByCoord.out.bam
ln -s ../../20200805-STAR_hg38/out/02-0047-01A-01R-1849-01+1.STAR.hg38.Aligned.sortedByCoord.out.bam.bai bams/unknown.Aligned.sortedByCoord.out.bam.bai
ln -s ../../20230628-STAR_hg38_XS/out/02-0047-01A-01R-1849-01+1.Aligned.sortedByCoord.out.bam bams/gtf_xs.Aligned.sortedByCoord.out.bam
ln -s ../../20230628-STAR_hg38_XS/out/02-0047-01A-01R-1849-01+1.Aligned.sortedByCoord.out.bam.bai bams/gtf_xs.Aligned.sortedByCoord.out.bam.bai

wget https://raw.githubusercontent.com/alexdobin/STAR/master/extras/scripts/tagXSstrandedData.awk

module load samtools
samtools view -h bams/unknown.Aligned.sortedByCoord.out.bam | awk -v strType=2 -f tagXSstrandedData.awk | samtools view -h -o bams/unknown_xs.Aligned.sortedByCoord.out.bam -
samtools index bams/unknown_xs.Aligned.sortedByCoord.out.bam
```




Then run TEProF2 on each separately.


* 20200805-STAR_hg38 - Unknown details - Fails
* 20200805-STAR_hg38 - add XS tag with awk script 
* to reference without GTF - /francislab/data1/refs/STAR/hg38-golden-none
* to reference with GTF - /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a
* 20230628-STAR_hg38_XS - to reference with GTF and `--outSAMstrandField intronMotif --outSAMattributes Standard XS`
* to reference without GTF then add XS - /francislab/data1/refs/STAR/hg38-golden-none
* to reference with GTF then add XS - /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=10080 --nodes=1 --ntasks=8 --mem=60G \
  --job-name="STARnone" --output=${PWD}/STARnone.log \
  --wrap="~/.local/bin/STAR.bash --runMode alignReads --runThreadN 8 --readFilesType Fastx --readFilesIn /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:02-0047-01A SM:02-0047-01A --outSAMunmapped Within KeepPairs --outFileNamePrefix ${PWD}/bams/nogtf. --genomeDir /francislab/data1/refs/STAR/hg38-golden-none-2.7.7a"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=10080 --nodes=1 --ntasks=8 --mem=60G \
  --job-name="STARgtf" --output=${PWD}/STARgtf.log \
  --wrap="~/.local/bin/STAR.bash --runMode alignReads --runThreadN 8 --readFilesType Fastx --readFilesIn /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:02-0047-01A SM:02-0047-01A --outSAMunmapped Within KeepPairs --outFileNamePrefix ${PWD}/bams/gtf. --genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a"

```


```
module load samtools

samtools view -h bams/gtf.Aligned.sortedByCoord.out.bam | awk -v strType=2 -f tagXSstrandedData.awk | samtools view -h -o bams/gtf_then_xs.Aligned.sortedByCoord.out.bam -
samtools index bams/gtf_then_xs.Aligned.sortedByCoord.out.bam

samtools view -h bams/nogtf.Aligned.sortedByCoord.out.bam | awk -v strType=2 -f tagXSstrandedData.awk | samtools view -h -o bams/nogtf_then_xs.Aligned.sortedByCoord.out.bam -
samtools index bams/nogtf_then_xs.Aligned.sortedByCoord.out.bam

```


````

TEProF2_array_wrapper.bash --threads 4 \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR-TEProF2-test/in \
  --extension .Aligned.sortedByCoord.out.bam \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR-TEProF2-test/bams/*.Aligned.sortedByCoord.out.bam

```




```

TEProF2_aggregation_steps.bash --threads 32 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR-TEProF2-test/in \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR-TEProF2-test/out

```







Notes regarding XS tag from tagXSstrandedData.awk ( using strType=2 )

All reads will get the XS tag based on flags 

* 0x10    16  REVERSE        SEQ is reverse complemented
* 0x20    32  MREVERSE       SEQ of next segment in template is rev.complemented
* 0x40    64  READ1          the first segment in the template
* 0x80   128  READ2          the last segment in the template

* READ1,REVERSE : + ( -f80 )
* READ2,REVERSE : - ( -f144 )
* READ1,MREVERSE : - ( -f96 )
* READ2,MREVERSE : + ( -f160 )


Confirm all flag selected reads have the same designated strand
```
samtools view -f80 gtf_xs_then_xs_again.Aligned.sortedByCoord.out.bam | awk '{print $NF}' | uniq -c
samtools view -f144 gtf_xs_then_xs_again.Aligned.sortedByCoord.out.bam | awk '{print $NF}' | uniq -c
samtools view -f96 gtf_xs_then_xs_again.Aligned.sortedByCoord.out.bam | awk '{print $NF}' | uniq -c
samtools view -f160 gtf_xs_then_xs_again.Aligned.sortedByCoord.out.bam | awk '{print $NF}' | uniq -c
```


```
samtools view gtf_xs_then_xs_again.Aligned.sortedByCoord.out.bam | grep -E -o "XS:A:.*XS:A:.*$" | sort | uniq -c
```




