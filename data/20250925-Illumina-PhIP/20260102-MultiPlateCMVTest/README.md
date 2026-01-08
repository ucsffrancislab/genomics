
#	20250925-Illumina-PhIP/20260102-MultiPlateCMVTest

```bash

awk 'BEGIN{FS=OFS=","}(NR==1 || $6==0 || $6==1){print $1,$6}' /francislab/data1/refs/AGS/AGS.csv

```


```bash
awk 'BEGIN{FS=OFS=","}(NR==1 || $6==0 || $6==1){print $1,$6}' /francislab/data1/refs/AGS/AGS.csv > CMV.csv

for m in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/manifest.plate*.csv; do
echo $m
out=$( basename $( dirname $m ) )
mkdir -p ${out}

awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4,$5,$6,$7,$8,$9}' ${m} > ${out}/tmp1.csv
head -1 ${out}/tmp1.csv > ${out}/tmp2.csv
tail -n +2 ${out}/tmp1.csv | sort -t, -k1,1 >> ${out}/tmp2.csv

join --header -t, ${out}/tmp2.csv CMV.csv > ${out}/tmp3.csv

# not sure if needed but rearrange columns to previous order
awk -F, 'BEGIN{FS=OFS=","}{if($10==0){g="negative"}else if($10==1){g="positive"}else{g=$6}; print $2,$1,$3,$4,$5,g,$7,$8,$9}' ${out}/tmp3.csv > ${out}/manifest.csv

done


for f in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/Zscores.csv; do
ln -s $f $( basename $( dirname $f ) )
done

for f in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/Zscores.t.csv; do
ln -s $f $( basename $( dirname $f ) )
done

for f in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/Zscores.minimums.csv; do
ln -s $f $( basename $( dirname $f ) )
done

for f in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/Zscores.minimums.t.csv; do
ln -s $f $( basename $( dirname $f ) )
done

for f in /francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/out.plate[1-6]/seropositive.*.csv; do
ln -s $f $( basename $( dirname $f ) )
done
```





```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do

echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.csv -o ${PWD}/out.123456 -p ${plates} --sex F

#echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.communities.csv -o ${PWD}/out.123456 -p ${plates}
#echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.communities.csv -o ${PWD}/out.123456 -p ${plates} --sex M
#echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --zfile_basename Zscores.communities.csv -o ${PWD}/out.123456 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```





```bash
\rm commands
for p in 1 2 3 4 5 6 ; do
plate=out.plate${p}
manifest=${plate}/manifest.csv
for z in 3.5 5 10 15 20 25 30 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study AGS --type \"glioma serum\" -a positive -b negative --zfilename ${plate}/Zscores.csv
done; done >> commands
commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G


\rm commands
plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 15 20 25 30 ; do

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative -o ${PWD}/out.123456 -p ${plates} --zfile_basename Zscores.csv
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --type \"glioma serum\" -a positive -b negative --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex F

done >> commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G
```








```bash

for z in 3.5 5 10 ; do
echo ${z}
for f in out.plate*/seropositive.${z}.csv; do
echo $f
awk -F, '( NR==1 || $3~/_B/ )' $f | cut -d, -f1,4- | datamash transpose -t, | awk -F, '( NR==1 || $1=="Human herpesvirus 5" )' | datamash transpose -t, > $( dirname $f )/tmp1.${z}.csv
head -1 $( dirname $f )/tmp1.${z}.csv > $( dirname $f )/tmp2.${z}.csv
tail -n +2 $( dirname $f )/tmp1.${z}.csv | sort -t, -k1,1 >> $( dirname $f )/tmp2.${z}.csv
done
done

for z in 3.5 5 10 ; do
echo ${z}
join --header -t, <( tail -q -n +2 out.plate*/tmp2.${z}.csv | sort -t, -k1,1 | sed '1ia,b' ) CMV.csv | tail -n +2 | grep -c ",0,0"
join --header -t, <( tail -q -n +2 out.plate*/tmp2.${z}.csv | sort -t, -k1,1 | sed '1ia,b' ) CMV.csv | tail -n +2 | awk -F, '($2>0 && $3==0)' | wc -l
join --header -t, <( tail -q -n +2 out.plate*/tmp2.${z}.csv | sort -t, -k1,1 | sed '1ia,b' ) CMV.csv | tail -n +2 | awk -F, '($2==0 && $3>0)' | wc -l
join --header -t, <( tail -q -n +2 out.plate*/tmp2.${z}.csv | sort -t, -k1,1 | sed '1ia,b' ) CMV.csv | tail -n +2 | awk -F, '($2>0 && $3>0)' | wc -l
echo 
done
```




##	20260107


Filter peptides with any similarity to non-HHV5 peptides to avoid any cross over?
Is this what virus score does?

```bash

merge_matrices.py --axis index --de_nan --header_rows 2 --index_col subject --index_col type --index_col sample --out ${PWD}/out.123456/Zscores.csv ${PWD}/out.plate*/Zscores.csv
merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456/Zscores.t.csv ${PWD}/out.plate*/Zscores.t.csv
merge_matrices.py --axis index --de_nan --header_rows 2 --index_col subject --index_col type --index_col group --out ${PWD}/out.123456/Zscores.minimums.csv ${PWD}/out.plate*/Zscores.minimums.csv
merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456/Zscores.minimums.t.csv ${PWD}/out.plate*/Zscores.minimums.t.csv

```





pp65 (UL83)

IE1 (UL123)

gB – Glycoprotein B (UL55)

```bash
awk -F, '($2=="Human herpesvirus 5"){print $3}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sort | uniq -c | grep UL83
awk -F, '($2=="Human herpesvirus 5"){print $3}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sort | uniq -c | grep UL123
awk -F, '($2=="Human herpesvirus 5"){print $3}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sort | uniq -c | grep UL55
```



```bash
pp65 (UL83) -
1 match for UL83: "65 kDa phosphoprotein (pp65) (65 kDa matrix phosphoprotein) (Phosphoprotein UL83) (Tegument protein UL83)" has 22 tiles.

IE1 (UL123) -
No match for UL123
However IE1 matches ...
"55 kDa immediate-early protein 1 (IE1)" has 17 tiles

gB – Glycoprotein B (UL55)
No match for "UL55"
However Glycoprotein B matches ...
"Envelope glycoprotein B (Fragment)" has 6 tiles
"Envelope glycoprotein B (gB) [Cleaved into: Glycoprotein GP55]" has 32 tiles
"Glycoprotein B amino part of (Fragment)" has 3 tiles
"Glycoprotein B (Fragment)" has 64 tiles
"Glycoprotein B variable region (Fragment)" has 6 tiles
```


```bash

awk -F, '(NR<3 || $2=="glioma serum")' out.123456/Zscores.minimums.csv | datamash transpose -t, | awk -F, '(NR<4 || $2=="Human herpesvirus 5")' > out.123456/Zscores.minimums.glioma.t.CMV.csv


awk -F, '($2=="Human herpesvirus 5" && $3~/UL83/){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv 

head -3 out.123456/Zscores.minimums.glioma.t.CMV.csv > out.123456/Zscores.minimums.glioma.t.CMV.UL83.csv
tail -n +4 out.123456/Zscores.minimums.glioma.t.CMV.csv | grep -f <( awk -F, '($2=="Human herpesvirus 5" && $3~/UL83/){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sed -e 's/^/^/' -e 's/$/,/' ) >> out.123456/Zscores.minimums.glioma.t.CMV.UL83.csv

head -3 out.123456/Zscores.minimums.glioma.t.CMV.csv > out.123456/Zscores.minimums.glioma.t.CMV.IE1.csv
tail -n +4 out.123456/Zscores.minimums.glioma.t.CMV.csv | grep -f <( awk -F, '($2=="Human herpesvirus 5" && $3~/IE1/){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sed -e 's/^/^/' -e 's/$/,/' ) >> out.123456/Zscores.minimums.glioma.t.CMV.IE1.csv

head -3 out.123456/Zscores.minimums.glioma.t.CMV.csv > out.123456/Zscores.minimums.glioma.t.CMV.gB.csv
tail -n +4 out.123456/Zscores.minimums.glioma.t.CMV.csv | grep -f <( awk -F, '($2=="Human herpesvirus 5" && $3~/lycoprotein B/){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sed -e 's/^/^/' -e 's/$/,/' ) >> out.123456/Zscores.minimums.glioma.t.CMV.gB.csv


head -3 out.123456/Zscores.minimums.glioma.t.CMV.csv > out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.csv
tail -n +4 out.123456/Zscores.minimums.glioma.t.CMV.csv | grep -f <( awk -F, '($2=="Human herpesvirus 5" && ($3~/UL83/||$3~/IE1/||$3~/lycoprotein B/)){print $1}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv | sed -e 's/^/^/' -e 's/$/,/' ) >> out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.csv

```


```bash
for z in 3.5 5 10 15 20 25 ; do
python3 - <<EOF
import pandas as pd
df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83.csv', header=[0,1,2], index_col=[0,1])
df=(df>=${z}).astype(int)
df.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold-z${z}.csv')
sums=df.sum(axis='index')
sums.name='sums'
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold-z${z}.sum.csv')
df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.IE1.csv', header=[0,1,2], index_col=[0,1])
df=(df>=${z}).astype(int)
df.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold-z${z}.csv')
sums=df.sum(axis='index')
sums.name='sums'
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold-z${z}.sum.csv')
df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.gB.csv', header=[0,1,2], index_col=[0,1])
df=(df>=${z}).astype(int)
df.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold-z${z}.csv')
sums=df.sum(axis='index')
sums.name='sums'
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold-z${z}.sum.csv')
EOF

join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold-z${z}.sum.csv | cut -d, -f1,2,5 > out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold-z${z}.sum.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold-z${z}.sum.csv | cut -d, -f1,2,5 > out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold-z${z}.sum.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold-z${z}.sum.csv | cut -d, -f1,2,5 > out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold-z${z}.sum.comparison.csv

done

```







Create single matrix of ELISA call and all z score calls

```bash

python3 - <<EOF
import pandas as pd

df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.csv', header=[0,1,2], index_col=[0,1])
sums = pd.DataFrame(index=df.columns)
for z in [3.5,5,10,15,20,25,30,35,40,45,50]:
  tmp=(df>=z).astype(int)
  sums[z]=tmp.sum(axis='index')
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.threshold.sums.csv')

df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83.csv', header=[0,1,2], index_col=[0,1])
sums = pd.DataFrame(index=df.columns)
for z in [3.5,5,10,15,20,25,30,35,40,45,50]:
  tmp=(df>=z).astype(int)
  sums[z]=tmp.sum(axis='index')
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold.sums.csv')

df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.IE1.csv', header=[0,1,2], index_col=[0,1])
sums = pd.DataFrame(index=df.columns)
for z in [3.5,5,10,15,20,25,30,35,40,45,50]:
  tmp=(df>=z).astype(int)
  sums[z]=tmp.sum(axis='index')
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold.sums.csv')

df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.gB.csv', header=[0,1,2], index_col=[0,1])
sums = pd.DataFrame(index=df.columns)
for z in [3.5,5,10,15,20,25,30,35,40,45,50]:
  tmp=(df>=z).astype(int)
  sums[z]=tmp.sum(axis='index')
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold.sums.csv')

df = pd.read_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.csv', header=[0,1,2], index_col=[0,1])
sums = pd.DataFrame(index=df.columns)
for z in [3.5,5,10,15,20,25,30,35,40,45,50]:
  tmp=(df>=z).astype(int)
  sums[z]=tmp.sum(axis='index')
sums.to_csv('out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.threshold.sums.csv')

EOF

join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.threshold.sums.csv | cut -d, -f1,2,5- > out.123456/Zscores.minimums.glioma.t.CMV.threshold.sums.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold.sums.csv | cut -d, -f1,2,5- > out.123456/Zscores.minimums.glioma.t.CMV.UL83.threshold.sums.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold.sums.csv | cut -d, -f1,2,5- > out.123456/Zscores.minimums.glioma.t.CMV.IE1.threshold.sums.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold.sums.csv | cut -d, -f1,2,5- > out.123456/Zscores.minimums.glioma.t.CMV.gB.threshold.sums.comparison.csv
join --header -t, CMV.csv out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.threshold.sums.csv | cut -d, -f1,2,5- > out.123456/Zscores.minimums.glioma.t.CMV.UL83-IE1-gB.threshold.sums.comparison.csv

```

