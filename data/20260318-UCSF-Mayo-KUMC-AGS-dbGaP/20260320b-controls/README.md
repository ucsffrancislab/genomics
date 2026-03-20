
#	20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320b-controls

Select only controls.


```bash
mkdir work
cd work
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320a-check-bim/mdsaml-updated.bed
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320a-check-bim/mdsaml-updated.bim
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320a-check-bim/mdsaml-updated.fam
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320a-check-bim/mdsaml-updated.frq
cd ..

cut -d' ' -f6 work/mdsaml-updated.fam | sort | uniq -c
   1095 1
    616 2

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=mdsaml_select_controls \
 --wrap="module load plink; plink --bfile work/mdsaml-updated --filter-controls --make-bed --out work/mdsaml_controls" \
 --out=${PWD}/work/mdsaml_select_controls.log
```

```bash
module load plink; plink --freq --bfile work/mdsaml_controls --out work/mdsaml_controls ; chmod -w work/mdsaml_controls.*

ln -s work/mdsaml_controls.bed
ln -s work/mdsaml_controls.bim
ln -s work/mdsaml_controls.fam
ln -s work/mdsaml_controls.frq
```






---











CIDR has some non-IPS samples. Remove them before the merge?

```bash
awk '$2 ~ /^G/ {print $1, $2}' /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/prep-cidr-1000g/cidr-updated.fam > prep/cidr_cases_to_keep.txt

b=mdsaml
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=mdsaml_select_controls \
 --wrap="module load plink; plink --bfile /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/prep-cidr-1000g/cidr-updated --keep prep/cidr_cases_to_keep.txt --make-bed --out prep/cidr_cases" \
 --out=${PWD}/prep/cidr_select_cases.log

```



```bash
cd prep

# Get shared variants
cut -f2 mdsaml_controls.bim | sort > variants_mdsaml.txt
cut -f2 cidr_cases.bim | sort > variants_cidr.txt
comm -12 variants_mdsaml.txt variants_cidr.txt > shared_variants.txt


wc -l *variants*
 1075361 shared_variants.txt
 1092774 variants_cidr.txt
 1471084 variants_mdsaml.txt
 3639219 total


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=cidr_extract \
 --wrap="module load plink; plink --bfile cidr_cases --extract shared_variants.txt --make-bed --out cidr_shared" \
 --out=cidr_extract.log

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=mdsaml_extract \
 --wrap="module load plink; plink --bfile mdsaml_controls --extract shared_variants.txt --make-bed --out mdsaml_shared" \
 --out=mdsaml_extract.log

wc -l cidr_shared.bim mdsaml_shared.bim
 1075361 cidr_shared.bim
 1075361 mdsaml_shared.bim


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=merge \
 --wrap="module load plink; plink --bfile cidr_shared --bmerge mdsaml_shared --make-bed --out merged" \
 --out=merge.log

```

The merge failed. A handful are off by 1 position and are strand flipped or something. Dropping them.

These each take a few seconds so I'm not using the cluster.


```bash
# Get the missnp variants
cat merged-merge.missnp > variants_to_exclude.txt

# Add the multiple-position variants from the log
grep "Multiple positions\|Multiple chromosomes" merged.log | awk -F"'" '{print $2}' >> variants_to_exclude.txt

# Sort and deduplicate
sort -u variants_to_exclude.txt -o variants_to_exclude.txt

# Re-merge excluding them
module load plink
plink --bfile cidr_shared --exclude variants_to_exclude.txt --make-bed --out cidr_clean
plink --bfile mdsaml_shared --exclude variants_to_exclude.txt --make-bed --out mdsaml_clean
plink --bfile cidr_clean --bmerge mdsaml_clean --make-bed --out merged

```



