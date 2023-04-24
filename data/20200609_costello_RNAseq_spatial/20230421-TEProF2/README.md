
#	First run of TEProF2

/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/

```

TEProF2_array_wrapper.bash --threads 4 \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out \
  --extension .STAR.hg38.Aligned.out.bam

```




Create TEProF2_aggregation_steps.bash




```

TEProF2_aggregation_steps.bash --threads 64 --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out

```

```
-rw-r----- 1 gwendt francislab   179250859 Apr 22 15:42 out/filter_combined_candidates.tsv
-rw-r----- 1 gwendt francislab     8678838 Apr 22 15:42 out/initial_candidate_list.tsv
-rw-r----- 1 gwendt francislab   300008731 Apr 22 15:43 out/Step4.RData
```




