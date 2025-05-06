#!/bin/bash


# Script to filter to heterozygosity in samples with >3*SD above mean in each ancestry cluster.
# and SNPs with HWE p < 1x10^-6
# and SNPs with MAF <0.005

module load CBI
module load plink/1.90b6.21
module load plink2
module load r/3.6.3


array=NBD_rsids_2
popfile=NBD_EUR
indir=/home/gguerra/TCGA_WTCCC_merged
scratchdir=$TMPDIR
outdir=$indir
risk_file=/home/gguerra/TCGA_WTCCC_merged/Risk_allele_rsID.txt





# 1) Generate report of heterozygosity values
plink --bfile $indir/$array --het --keep $indir/$popfile\.txt --out $scratchdir/temphet

# 2) Run R script to get list of indiv names to keep. 
Rscript Het_filter.R $scratchdir/temphet.het $outdir/$popfile\_het.txt
br=$(wc -l $indir/$popfile.txt |awk '{print $1}')
if [ $br == 1 ]
then
scp $indir/$popfile.txt $outdir/$popfile\_het.txt
fi

# 3) Calculate HWE for each SNP
plink --bfile $indir/$array --hardy --keep $outdir/$popfile\_het.txt  --out $scratchdir/tempHWE
grep "ALL" $scratchdir/tempHWE.hwe > $scratchdir/temp2.hwe
#Filter to exclude if < 10^-6
awk '$9 < 0.000001 {print $2}' $scratchdir/temp2.hwe > $scratchdir/tofilter.hwe
# dont filter the whitelisted snps 
grep -v -f $risk_file $scratchdir/tofilter.hwe > $scratchdir/hwe.final
echo 
echo 
echo HWE to exclude
wc -l $scratchdir/hwe.final
echo 
echo 
# plink filter the snps
plink --bfile $indir/$array --keep $outdir/$popfile\_het.txt --exclude $scratchdir/hwe.final --make-bed --out $scratchdir/tempb

echo
echo
echo
echo after het and hwe 
wc -l $scratchdir/tempb.bim
echo snps
wc -l $scratchdir/tempb.fam
echo samples 

echo
echo

# 4) Filter for MAF 
plink --bfile $scratchdir/tempb --maf 0.005 --make-bed --out $scratchdir/tempc


#5) Filter for duplicate SNPs
plink --bfile $scratchdir/tempc --list-duplicate-vars --out $scratchdir/dupfile
plink --bfile $scratchdir/tempc --exclude $scratchdir/dupfile.dupvar --make-bed --out $outdir/$popfile

echo 
echo
echo
echo Number SNPs remaining
wc -l $outdir/$popfile.bim
echo
echo 
echo 
