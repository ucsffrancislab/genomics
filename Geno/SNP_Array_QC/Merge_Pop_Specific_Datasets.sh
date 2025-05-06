#!/bin/bash


# Script to combine datasets for a specific population. 

module load CBI
module load plink/1.90b6.21
module load plink2


datasets=(TCGA_EUR_2 BBC_EUR NBD_EUR)
indir=/home/gguerra/TCGA_WTCCC_merged
scratchdir=$TMPDIR
cSNPfile=$indir/Common_EUR_SNPs.txt
outdir=$indir
outfilename=Merged_EUR

# 1) For each dataset, filter down to common SNPs
for ds in ${datasets[@]};
do
plink --bfile $indir/$ds --extract $cSNPfile --make-bed --out $scratchdir/$ds\_f
echo
echo ds
wc -l $scratchdir/$ds\_f.bim
echo $scratchdir/$ds\_f >> $scratchdir/merge_files.txt
done

# 2) Merge the files into one, and return to output

plink --merge-list $scratchdir/merge_files.txt --make-bed --out $outdir/$outfilename



# If strand flip issues, flip in one 
FILE=$outdir/$outfilename-merge.missnp
if test -f "$FILE";then
plink --bfile $scratchdir/${datasets[0]]}\_f --flip $FILE --make-bed --out $scratchdir/${datasets[0]]}\_1 
echo $scratchdir/${datasets[0]]}\_1 >> $scratchdir/merge_files_2.txt
echo $scratchdir/${datasets[1]]}\_f >> $scratchdir/merge_files_2.txt
plink --merge-list $scratchdir/merge_files_2.txt --make-bed --out $outdir/$outfilename
fi


