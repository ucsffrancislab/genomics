
#	20200720-TCGA-GBMLGG-RNA_bam/20240619-STAR_twopass_basic-hg38_v25


Aligning to an older reference to better compare to TEProF2's published results.

Not sure if this will have any impact.



```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```




```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="featureCounts" \
  --nodes=1 --ntasks=64 --mem=495G --time=14-0 --export=NONE \
  --output=${PWD}/featureCounts.transcript.gene_name.$( date "+%Y%m%d%H%M%S%N" ).log \
  --wrap="~/.local/bin/featureCounts.bash -T 64 -t transcript -g gene_name \
  -a /francislab/data1/refs/sources/gencodegenes.org/release_25/gencode.v25.primary_assembly.annotation.gtf.gz \
  -o ${PWD}/featureCounts.transcript.gene_name.csv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="featureCounts" \
  --nodes=1 --ntasks=64 --mem=495G --time=14-0 --export=NONE \
  --output=${PWD}/featureCounts.exon.gene_name.$( date "+%Y%m%d%H%M%S%N" ).log \
  --wrap="~/.local/bin/featureCounts.bash -T 64 -t exon -g gene_name \
  -a /francislab/data1/refs/sources/gencodegenes.org/release_25/gencode.v25.primary_assembly.annotation.gtf.gz \
  -o ${PWD}/featureCounts.exon.gene_name.csv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

```


##	20240722



```
tail -n +2 featureCounts.exon.gene_name.csv | cut -f1,7- | sed -e '1s/.Aligned.sortedByCoord.out.bam//g' -e '1s"/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240619-STAR_twopass_basic-hg38_v25/out/""g' > tmp1

head -1 tmp1 > featureCounts.exon.gene_name.clean.tsv
tail -n +2 tmp1 | sort -k1,1 >> featureCounts.exon.gene_name.clean.tsv

```







