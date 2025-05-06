#!/bin/bash

# TCGA WTCCC only

# Script to process post imputed data, remove low imputation quality snps and process to pgen/pvar via plink 2 
module load CBI
module load plink/1.90b6.21
module load plink2




indir=/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/imputation
scratchdir=$TMPDIR
outdir=/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230223-for_analysis

mkdir -p $outdir

chrs=(22 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21) 
#chrs=(21 22)

for chr in ${chrs[@]};
do
# 1) Get list of SNPs with Rsq less than threshold
zcat $indir/chr$chr.info.gz | awk '{ if ($7 < 0.3) print $1}' > $scratchdir/removesnps.txt
scp $scratchdir/removesnps.txt $outdir/chr$chr.remove.snps


# 2) Filter out those SNPs and convert to Pgen
#scp $indir/chr$chr.dose.vcf.gz $scratchdir/
#gunzip $scratchdir/chr$chr.dose.vcf.gz

plink2 --vcf $indir/chr$chr.dose.vcf.gz dosage=DS --hard-call-threshold 0.49999999 --exclude $scratchdir/removesnps.txt --make-pgen --out $scratchdir/chr$chr.dose

# 3) Filter SNPs with low MAF (<0.0001)
plink2 --pfile $scratchdir/chr$chr.dose --freq --out $scratchdir/chr$chr.dose
awk '{ if ($5 < 0.0001) print $2}' $scratchdir/chr$chr.dose.afreq > $scratchdir/removemaf.txt
plink2 --pfile $scratchdir/chr$chr.dose --remove $scratchdir/removemaf.txt --make-pgen --out $outdir/chr$chr.dose

# 4) Generate HWE report using only controls 
# Get list of TCGA, and exclude them
grep "TCGA" $outdir/chr$chr.dose.psam | awk '{print $1}' > $scratchdir/cases.txt
plink2 --pfile $outdir/chr$chr.dose --remove $scratchdir/cases.txt --hardy --out $outdir/chr$chr.dose


##### FOR AGS MAYO MERGING ONLY####
# -- comment out the plink2 command above and run this 
#plink2 --vcf $indir/chr$chr.dose.vcf.gz dosage=DS --exclude $scratchdir/removesnps.txt --remove /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-covariates/AGS_Mayo_duplicate_controls.txt --make-pgen --out $outdir/chr$chr.dose
#####


#scp $scratchdir/removesnps.txt $outdir/chr$chr.remove.snps
#rm $scratchdir/chr*
done
