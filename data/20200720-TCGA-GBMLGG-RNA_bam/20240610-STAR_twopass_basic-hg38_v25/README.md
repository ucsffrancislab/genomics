
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

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="featureCounts" --nodes=1 --ntasks=64 --mem=495G --time=14-0 --export=NONE --output=${PWD}/featureCounts.transcripts.gene_name.$( date "+%Y%m%d%H%M%S%N" ).log --wrap="~/.local/bin/featureCounts.bash -T 64 -a /francislab/data1/refs/sources/gencodegenes.org/release_25/gencode.v25.primary_assembly.annotation.gtf.gz -t transcript -g gene_name -o ${PWD}/featureCounts.transcripts.gene_name.csv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

```
