#!/bin/bash


# Script to remove all variants with > 5% missingness and then samples with > 5% missingness, numbers are reported in the output file 

module load CBI
module load plink/1.90b6.21
module load plink2



array=TCGA_rsids
indir=/home/gguerra/TCGA_WTCCC_merged
scratchdir=$TMPDIR
outdir=$indir
risk_file=/home/gguerra/TCGA_WTCCC_merged/Risk_allele_rsID.txt



# 1) Generate report of % missing by SNP
plink --bfile $indir/$array --missing --memory 30000 --out $scratchdir/missing

# Get list of rsIds >0.05 missing 
awk '{if($5>0.05)print$2}' $scratchdir/missing.lmiss| sed '1d' > $scratchdir/is.missing

# Cross list with whitelisted SNPs 
grep -v -f $risk_file $scratchdir/is.missing > $scratchdir/to.filter

plink --bfile $indir/$array --exclude $scratchdir/to.filter --make-bed --out $scratchdir/s1

echo Num SNPS remaining 
wc -l $scratchdir/s1.bim

# 2) Remove all subjects with call rates < 95%
plink2 --bfile $scratchdir/s1 --mind 0.05 --memory 30000 --threads 1 --make-bed --out $outdir/$array\_2

echo Num Samples remaining
wc -l $outdir/$array\_2.fam

