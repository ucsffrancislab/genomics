#!/usr/bin/env bash


# Script to prepare an hg38 dataset for snp2hla analysis by pulling the correct SNPs and assigning proper rsids. 

module load CBI
module load plink/1.90b6.21
module load plink2



array=chr6.dose
indir=/francislab/data1/working/20210302-AGS-illumina/20210303-for_analysis
scratchdir=$TMPDIR
outdir=/francislab/data1/working/20210302-AGS-illumina/20210304-snp2hla
snpfile=/home/gguerra/reference/snp_2_hla_t1dgc_hg38_coords.txt
refbimfile=/francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.bim


# 1) Get the list of SNPs from the pvar that match the snpfile
grep "rs" $snpfile |awk '{print $1}' > $scratchdir/snpfile.txt
grep -f $scratchdir/snpfile.txt $indir/$array.pvar |awk '{print $3}' > $scratchdir/to_keep.txt

# 2) Use plink2 to filter down to those SNPs
plink2 --pfile $indir/$array --extract $scratchdir/to_keep.txt --make-bed --out $scratchdir/bfiles

# 3) Find and replace all snp ids by the proper rsids 
Rscript /home/gguerra/Programs/snp2hla/SNP2HLA_rsid_matching.R $scratchdir/bfiles.bim $refbimfile $snpfile

# 4) Transfer the files to their new home
mv $scratchdir/bfiles.bed $outdir/chr6-t1dgc-matched.bed
mv $scratchdir/bfiles.fam $outdir/chr6-t1dgc-matched.fam
mv $scratchdir/bfiles.bim.2 $outdir/chr6-t1dgc-matched.bim



