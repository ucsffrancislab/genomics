
#	20250813-CIDR/20260323-liftover_imputation_to_hg38


FILTER 'INFO/R2 > 0.8' and liftover the recent imputation results from hg19 to hg38 and normalize

Copy the script so I don't muck it up if I edit while running. (seems a bit excessive)

```bash
for c in {1..22}; do
echo cp liftover_and_prep_for_pgs_by_chromosome.bash \${TMPDIR}\; \${TMPDIR}/liftover_and_prep_for_pgs_by_chromosome.bash /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-cidr ${PWD}/hg38 ${c} 
done > commands

commands_array_wrapper.bash --array_file commands --time 3-0 --threads 4 --mem 30G --jobcount 16 --jobname lift 
```




Isolate lifted/final data into their own chromosome files.

```bash
for data in cidr i370 onco tcga; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${data}-redi --time=2-0 --export=None \
  --output="${PWD}/redistribute_snps_to_proper_chromosome_files.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  redistribute_snps_to_proper_chromosome_files.bash ${data}
done
```

creates .... `20251218-survival_gwas/imputed-umich-*/hg38_0.8/final.chr*.dose.corrected.vcf.gz`


