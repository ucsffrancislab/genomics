#!/bin/bash


# Script to filter to heterozygosity in samples with >3*SD above mean in each ancestry cluster.

module load CBI
module load plink/1.90b6.21
module load plink2
module load r/3.6.3


array=NBD_rsids_2
popfile=NBD_EUR
indir=/home/gguerra/TCGA_WTCCC_merged
scratchdir=$TMPDIR
outdir=$indir
#risk_file=$indir/Risk_allele_rsID.txt





# 1) Generate report of heterozygosity values
plink --bfile $indir/$array --het --keep $indir/$popfile\.txt --out $scratchdir/temphet

# 2) Run R script to get list of indiv names to keep. 
Rscript Het_filter.R $scratchdir/temphet.het $outdir/$popfile\_het.txt

