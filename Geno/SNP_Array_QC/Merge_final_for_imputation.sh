#!/bin/bash


# Script to combine dataset across populations, and remove chr 23 stuff. 

module load CBI
module load plink/1.90b6.21
module load plink2


datasets=(Merged_EUR TCGA_ADMX_2 TCGA_AFR_2)
dataforKing=(Merged_EUR TCGA_ADMX_2 TCGA_AFR_2)
indir=/home/gguerra/TCGA_WTCCC_merged
scratchdir=$TMPDIR
outdir=$indir
outfilename=20230214_TCGA_WTCCC_for_QC

# 1) For each dataset, remove chr 23 and write new filename to a merge-list
for ds in ${datasets[@]};
do
plink --bfile $indir/$ds --chr 1-22 --make-bed --out $scratchdir/$ds
echo
echo ds
echo $scratchdir/$ds >> $scratchdir/mymergelist.txt
done

# 2) Merge the files into one, one at a time
ndsets="${#datasets[@]}"
scp $scratchdir/${datasets[0]}.bim $scratchdir/temp_1.bim
scp $scratchdir/${datasets[0]}.bed $scratchdir/temp_1.bed
scp $scratchdir/${datasets[0]}.fam $scratchdir/temp_1.fam

for ((i=1;i<$ndsets;i++));
do
i2=$((i + 1)) 
plink --bfile $scratchdir/temp_$i --bmerge $scratchdir/${datasets[i]} --make-bed --out $scratchdir/temp_$i2

# If strand flip issues, flip in one
FILE=$scratchdir/temp_$i2-merge.missnp
if test -f "$FILE";then
plink --bfile $indir/${datasets[i]]} --flip $FILE --make-bed --out $scratchdir/spare
plink --bfile $scratchdir/temp_$i --bmerge $scratchdir/spare --make-bed --out $scratchdir/temp_$i2
fi
done

# Now do KING filtering

for ds in ${dataforKing[@]};
do
plink2 --bfile $indir/$ds --make-king triangle bin --out $scratchdir/$ds

plink2 --bfile $indir/$ds --king-cutoff $scratchdir/$ds 0.12 --out $scratchdir/$ds
cat $scratchdir/$ds.king.cutoff.out.id |tail -n+2 >> $scratchdir/related.txt
done

echo 
echo Removing bc related
cat $scratchdir/related.txt
echo 


plink --bfile $scratchdir/temp_$i2 --remove $scratchdir/related.txt --make-bed --out $outdir/$outfilename



#awk '{print $3}' $scratchdir/$outfilename.hh |sort |uniq > $scratchdir/toremove.txt
#plink --bfile $scratchdir/$outfilename --exclude $scratchdir/toremove.txt --make-bed --out $outdir/$outfilename
