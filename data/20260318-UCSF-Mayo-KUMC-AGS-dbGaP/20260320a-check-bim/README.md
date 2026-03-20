
#	20260318-UCSF-Mayo-KUMC-AGS-dbGaP/20260320a-check-bim

Clean up and harmonize the new plink dataset.


```bash
mkdir work
cd work
ln -s /francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/mdsaml.bed
ln -s /francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/mdsaml.bim
ln -s /francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/mdsaml.fam
ln -s /francislab/data1/raw/20260318-UCSF-Mayo-KUMC-AGS-dbGaP/mdsaml.frq
cd ..

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=mdsaml_check-bim \
 --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose \
 --bim ${PWD}/work/mdsaml.bim --frequency ${PWD}/work/mdsaml.frq \
 --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" \
 --out=${PWD}/work/HRC-1000G-check-bim.pl.log
```


Wait


Don't need any of the individual chromosome files

```bash
sed -i -e '/--real-ref-alleles/s/^/#/' work/Run-plink.sh
```


```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=mdsaml_run-plink \
 --wrap="module load plink; sh ${PWD}/work/Run-plink.sh;\rm ${PWD}/work/TEMP?.*" \
 --out=${PWD}/work/Run-plink.sh.log
```


```bash

module load plink; plink --freq --bfile work/mdsaml-updated --out work/mdsaml-updated ; chmod -w work/mdsaml-updated.*

ln -s work/mdsaml-updated.bed
ln -s work/mdsaml-updated.bim
ln -s work/mdsaml-updated.fam
ln -s work/mdsaml-updated.frq

```

