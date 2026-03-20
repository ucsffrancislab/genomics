
#	20250813-CIDR/20260320b-check-bim


Check hg19 against the 1000 genomes panel


```bash
mkdir work
cd work
ln -s /francislab/data1/working/20250813-CIDR/20260320a-liftover_to_hg19/work/CIDR.bed
ln -s /francislab/data1/working/20250813-CIDR/20260320a-liftover_to_hg19/work/CIDR.bim
ln -s /francislab/data1/working/20250813-CIDR/20260320a-liftover_to_hg19/work/CIDR.fam
ln -s /francislab/data1/working/20250813-CIDR/20260320a-liftover_to_hg19/work/CIDR.frq
cd ..

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=cidr_check-bim \
 --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose \
 --bim ${PWD}/work/CIDR.bim --frequency ${PWD}/work/CIDR.frq \
 --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" \
 --out=${PWD}/work/HRC-1000G-check-bim.pl.log

```

I don't want the individual chromosome files

```bash
#	just the bed/bim/fam
#sed -i -e '/--make-bed --chr/s/^/#/' work/Run-plink.sh

#	all chromosome specific files
sed -i -e '/--real-ref-alleles/s/^/#/' work/Run-plink.sh
```


```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=cidr_run-plink \
 --wrap="module load plink; sh ${PWD}/work/Run-plink.sh;\rm ${PWD}/work/TEMP?.*" \
 --out=${PWD}/work/Run-plink.sh.log
```



```bash

module load plink; plink --freq --bfile work/CIDR-updated --out work/CIDR-updated ; chmod -w work/CIDR-updated.*

ln -s work/CIDR-updated.bed cidr-updated.bed
ln -s work/CIDR-updated.bim cidr-updated.bim
ln -s work/CIDR-updated.fam cidr-updated.fam
ln -s work/CIDR-updated.frq cidr-updated.frq
```




