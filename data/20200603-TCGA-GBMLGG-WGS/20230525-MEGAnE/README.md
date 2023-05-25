
#	20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE


/francislab/data1/refs/MEGAnE



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MEGAnE" \
--time=20160 --nodes=1 --ntasks=8 --mem=60G \
--wrap="singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/MEGAnE.v1.0.0.beta-20230525.sif call_genotype_38 \
-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa.gz \
-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk -p 8 \
-i /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out/02-2483-01A-01D-1494.bam \
-outdir /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out \
-sample_name 02-2483-01A-01D-1494" \
--output=/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/02-2483-01A-01D-1494.MEGAnE.out.log

```




