
#	20230628-Costello/20240624-STAR_twopass_basic-hg38_v25

Rerunning using STAR's Basic twopassMode rather than manually with entire dataset's splice junctions.

568 samples


```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz

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




