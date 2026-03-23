
#	20250813-CIDR/20260320e-prep_for_imputation

Prep for imputing genotype, hla and PGS


```bash
mkdir work
cd work
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.bed
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.bim 
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.fam 
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.frq 
cd ..
```

Check bim.

This was done before merging, but do it again to check

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=cidr_check-bim \
 --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose \
 --bim ${PWD}/work/cidr.bim --frequency ${PWD}/work/cidr.frq \
 --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" \
 --out=${PWD}/work/HRC-1000G-check-bim.pl.log
```


Don't need the individual chromosome bed/bim/fam files. Just the vcfs.

```bash
sed -i -e '/--make-bed --chr/s/^/#/' work/Run-plink.sh
```


```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=run-plink \
 --wrap="module load plink; sh ${PWD}/work/Run-plink.sh;\rm ${PWD}/work/TEMP?.*" \
 --out=${PWD}/work/Run-plink.sh.log
```




```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=bgzip \
 --wrap="module load htslib; bgzip ${PWD}/work/*vcf; chmod a-w ${PWD}/work/*{bim,bed,fam,vcf.gz}" \
 --out=${PWD}/work/bgzip.log

```

Prepped. That should be good.




