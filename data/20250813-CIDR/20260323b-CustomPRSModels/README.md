
#	20250813-CIDR/20260323b-CustomPRSModels


Redo the scores locally for CIDR cases and controls and include the seven custom models.

/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels


Rerun the scoring for all 4 complete datasets for all models including these new 7.

```bash
for chrnum in {1..22} ; do
echo "pgs-calc.bash ${chrnum}"
done > commands

commands_array_wrapper.bash --array_file commands --time 2-0 --threads 8 --mem 60G --jobcount 8 --jobname pgs-calc
```

---


Recreate the CIDR covariates to include the new ancestry PCs from the UMich PGS imputation.


/francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/subject_sample.csv 
/francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/metadata.tsv 

/francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.20260303.tsv

/francislab/data1/working/20250813-CIDR/20260320g-impute_pgs/pgs-cidr-hg19/estimated-population.txt 



```bash
\rm lists/cidr_covariates.tsv
ln -s /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.20260303.tsv lists/cidr_covariates.tsv

for b in cidr ; do
  cov_in=lists/${b}_covariates.tsv
  cat ${cov_in} | tr -d , | tr '\t' , > $TMPDIR/tmp.csv

  head -1 ${TMPDIR}/tmp.csv > edison_prs_survival_analysis/${b}-covariates_base.csv
  tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> edison_prs_survival_analysis/${b}-covariates_base.csv
  cat ../20250724-pgs/pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
  join --header -t, edison_prs_survival_analysis/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > edison_prs_survival_analysis/${b}-covariates.tsv
done

./normalize_covariates.bash cidr edison_prs_survival_analysis/cidr-covariates.tsv > edison_prs_survival_analysis/cidr-covariates.csv
```




