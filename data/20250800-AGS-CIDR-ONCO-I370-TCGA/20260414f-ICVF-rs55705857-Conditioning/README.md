
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260409-ICVF-rs55705857-Conditioning

Link are necessary files to check. Certain that this is overkill based on the script.

```bash
basedir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA
base=$PWD
dir=input/scored
mkdir -p ${dir}
cd $dir
for ds in cidr i370 onco tcga ; do
ln -s ${basedir}/20260326-GWAS_summary_stats/${ds}-covariates.csv
ln -s ${basedir}/20260410-compute_PGS_hg19/pgs-calc-scores/${ds}/scores.z-scores.txt.gz ${ds}.scores.z-scores.txt.gz
ln -s ${basedir}/20260410-compute_PGS_hg19/pgs-calc-scores/${ds}/scores.info ${ds}.scores.info
done
cd $base

dir=input/imputed
mkdir -p ${dir}
cd $dir
for ds in onco i370 tcga ; do
mkdir ${ds}
for vcf in ${basedir}/20251218-survival_gwas/imputed-umich-${ds}/chr*.dose.vcf.gz ; do
ln -s ${vcf} ${ds}/
ln -s ${vcf}.tbi ${ds}/
done
done
ds=cidr
mkdir ${ds}
for vcf in /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-${ds}/chr*.dose.vcf.gz ; do
ln -s ${vcf} ${ds}/
ln -s ${vcf}.tbi ${ds}/
done
cd $base

dir=input/raw
mkdir -p ${dir}
cd $dir

mkdir onco
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed onco/onco.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim onco/onco.bim
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam onco/onco.fam
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.frq onco/onco.frq
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.log onco/onco.log

mkdir i370
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed i370/i370.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim i370/i370.bim
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam i370/i370.fam
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.frq i370/i370.frq
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.log i370/i370.log

mkdir tcga
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bed tcga/tcga.bed
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bim tcga/tcga.bim
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.fam tcga/tcga.fam
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.frq tcga/tcga.frq
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.log tcga/tcga.log

mkdir cidr
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.bed cidr/cidr.bed
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.bim cidr/cidr.bim
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.fam cidr/cidr.fam
ln -s /francislab/data1/working/20250813-CIDR/20260320d-merge_with_mdsaml/cidr.frq cidr/cidr.frq
cd $base
```


```bash
~/github/ucsffrancislab/Claude-ICVF-rs55705857-Conditioning/validate_icvf_conditioning_inputs.sh \
  --scores-dir ${PWD}/input/scored \
  --vcf-hg19-dir ${PWD}/input/imputed \
  --raw-geno-dir ${PWD}/input/raw \
  --scores-json-dir ${PWD}/input/scored \
  --output validation_report.txt
```



So the SNP in question appears to be in the raw ONCO.
It exists in the imputation of all 4. 
However, the imputation R2 quality if below the 0.8 cutoff (0.52 and 0.59) in the data so was filtered out.
Therefore the PGS scores were calculated without it for those 2 dataset.
What to do?
Recompute PGS scores with a lower threshold?
Locally or on UMich?
Redo everything else so this is clean and consistent?





