
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_case_control_analysis_full_catalog



```bash

for f in ~/github/ucsffrancislab/edison_prs_case_control_analysis/*{R,py,sh} ; do
ln -s $f
done

ln -s ../edison_prs_case_control_analysis/upload input

```



```bash
sbatch run_pipeline.sh --test


mkdir test
mv plots/ results/ slurm_10690* test/
```


sbatch run_pipeline.sh






