
#	20250813-CIDR/20260323-liftover_imputation_to_hg38


FILTER 'INFO/R2 > 0.8' and liftover the recent imputation results from hg19 to hg38 and normalize

Copy the script so I don't muck it up if I edit while running.

```bash
for c in {1..22}; do
echo cp liftover_and_prep_for_pgs_by_chromosome.bash \${TMPDIR}\; \${TMPDIR}/liftover_and_prep_for_pgs_by_chromosome.bash /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-cidr ${PWD}/hg38 ${c} 
done > commands

commands_array_wrapper.bash --array_file commands --time 3-0 --threads 2 --mem 15G --jobcount 32 --jobname lift 
```

creates .... `final.chr*.dose.vcf.gz`

Isolate lifted/final data into their own chromosome files. pgs-calc will fail if you don't.

Really would be good to parallelize this

```bash
#for data in cidr i370 onco tcga; do
#sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=redis --time=2-0 --export=None \
#  --output="${PWD}/redistribute_snps_to_proper_chromosome_files.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
#  redistribute_snps_to_proper_chromosome_files.bash ${PWD}/hg38 ${PWD}/hg38
#done
```
creates .... `20251218-survival_gwas/imputed-umich-*/hg38_0.8/final.chr*.dose.corrected.vcf.gz`


Parallelized this into 2 separate runs ...

```bash
for f in ${PWD}/hg38/final.chr*.dose.vcf.gz ; do
echo cp extract_snps_to_proper_chromosome_files.bash \${TMPDIR}\; \${TMPDIR}/extract_snps_to_proper_chromosome_files.bash ${f}
done > commands

commands_array_wrapper.bash --array_file commands --time 3-0 --threads 2 --mem 15G --jobcount 32 --jobname extract
```

WAIT UNTIL COMPLETE

```bash
for c in {1..22}; do
echo cp concat_snps_to_proper_chromosome_files.bash \${TMPDIR}\; \${TMPDIR}/concat_snps_to_proper_chromosome_files.bash ${PWD}/hg38/redistribution_temp ${PWD}/hg38 ${c} 
done > commands

commands_array_wrapper.bash --array_file commands --time 3-0 --threads 2 --mem 15G --jobcount 32 --jobname concat
```

creates .... `final.chr*.dose.corrected.vcf.gz`

WAIT UNTIL COMPLETE, THEN CLEANUP

```bash
/bin/rm -rf ${PWD}/hg38/redistribution_temp
/bin/rm -rf ${PWD}/hg38/final.chr*.dose.vcf.gz ${PWD}/hg38/final.chr*.dose.vcf.gz.csi
```

