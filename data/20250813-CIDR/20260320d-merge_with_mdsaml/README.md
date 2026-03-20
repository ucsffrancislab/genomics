
#	20250813-CIDR/20260320d-merge_with_mdsaml



```bash
mkdir work
cd work

ln -s /francislab/data1/working/20250813-CIDR/20260320c-cases/cidr_cases.bed
ln -s /francislab/data1/working/20250813-CIDR/20260320c-cases/cidr_cases.bim
ln -s /francislab/data1/working/20250813-CIDR/20260320c-cases/cidr_cases.fam
ln -s /francislab/data1/working/20250813-CIDR/20260320c-cases/cidr_cases.frq

ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320b-controls/mdsaml_controls.bed
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320b-controls/mdsaml_controls.bim
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320b-controls/mdsaml_controls.fam
ln -s /francislab/data1/working/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320b-controls/mdsaml_controls.frq


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
wc -l merged-merge.missnp 
#	14 merged-merge.missnp

# Get the missnp variants
cat merged-merge.missnp > variants_to_exclude.txt

# Add the multiple-position variants from the log
grep "Multiple positions\|Multiple chromosomes" merged.log | awk -F"'" '{print $2}' >> variants_to_exclude.txt

# Sort and deduplicate
sort -u variants_to_exclude.txt -o variants_to_exclude.txt

wc -l variants_to_exclude.txt
#	29 variants_to_exclude.txt

# Re-merge excluding them
module load plink
plink --bfile cidr_shared --exclude variants_to_exclude.txt --make-bed --out cidr_clean
plink --bfile mdsaml_shared --exclude variants_to_exclude.txt --make-bed --out mdsaml_clean
plink --bfile cidr_clean --bmerge mdsaml_clean --make-bed --out merged

```


