
#	20250813-CIDR/20260320c-cases_only

CIDR has some non-IPS samples. Remove them



```bash
mkdir work
cd work
ln -s /francislab/data1/working/20250813-CIDR/20260320b-check-bim/cidr-updated.bed cidr.bed
ln -s /francislab/data1/working/20250813-CIDR/20260320b-check-bim/cidr-updated.bim cidr.bim
ln -s /francislab/data1/working/20250813-CIDR/20260320b-check-bim/cidr-updated.fam cidr.fam
ln -s /francislab/data1/working/20250813-CIDR/20260320b-check-bim/cidr-updated.frq cidr.frq
awk '$2 ~ /^G/ {print $1, $2}' cidr.fam > cidr_cases_to_keep.txt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=cidr_select_cases \
 --wrap="module load plink; plink --bfile cidr --keep cidr_cases_to_keep.txt --make-bed --out cidr_cases" \
 --out=${PWD}/cidr_select_cases.log
cd ..  



```


```bash

module load plink; plink --freq --bfile work/cidr_cases --out work/cidr_cases ; chmod -w work/cidr_cases.*

ln -s work/cidr_cases.bed
ln -s work/cidr_cases.bim
ln -s work/cidr_cases.fam
ln -s work/cidr_cases.frq
```



 
