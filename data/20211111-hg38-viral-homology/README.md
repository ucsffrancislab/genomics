



```

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-982%10 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211111-hg38-viral-homology/array_wrapper.bash

```


```

./prep_refs.bash

```

```
module load bowtie2

for a in Raw RM RawHM RMHM ; do
echo ${a}
#cat ${a}/*.fasta > ${a}.fasta
chmod -w ${a}.fasta
bowtie2-build --threads 32 ${a}.fasta ${a}
chmod -w ${a}.*.bt2
done

```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```


```
# G,1,5.4
# f(x) = 1.0 + 5.4 * ln(x)
#	default local is G,20,8
for score in G,20,8 G,15,8 G,10,8 G,5,8 G,0,8 ; do 

for a in NC_038858.1 NC_001506.1 ; do
for score in G,20,8 G,20,7 G,20,6 G,20,5 G,20,4 G,20,3 G,20,2 G,20,1 G,20,0 ; do 
echo $a $score
o=/francislab/data1/working/20211111-hg38-viral-homology/test/${a}.${score}.masked.split.25.sam
bowtie2 --no-unal -f --threads 8 --very-sensitive-local -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts -U /francislab/data1/working/20211111-hg38-viral-homology/out/split/${a}.masked.split.25.fa --score-min ${score} -S ${o} 2> ${o%.sam}.summary.txt
done ; done
```

```
for b in NC_038858.1 NC_001506.1 ; do
for score in G,20,8 G,20,7 G,20,6 G,20,5 G,20,4 G,20,3 G,20,2 G,20,1 G,20,0 ; do 
echo $b $score
s=25
dir="/francislab/data1/working/20211111-hg38-viral-homology/test"
o="${dir}/${b}.${score}.masked.split.${s}.mask.bed"
i="${dir}/${b}.${score}.masked.split.${s}.sam"
samtools sort -n -O SAM -o - ${i} | awk -v s=${s} -v ref=${b%.masked} '(/^split/){ sub(/^split/,"",$1); a=1+s*$1; b=a+(length($10)-1); print ref"\t"a"\t"b }' | awk -v ext=0 'BEGIN{FS=OFS="\t"}{ if( r == "" ){ r=$1; s=(($2>ext)?$2:(ext+1))-ext; e=$3+ext } else { if( $2 <= (e+ext+1) ){ e=$3+ext }else{ print $1,s,e; s=$2-ext; e=$3+ext } } }END{ if( r != "" ) print r,s,e }' > ${o}
done ; done
```









Evaluate masked region sizes

```
cat out/raw.split.HM.vsl/*bed | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$3-$2}' > bed_files_with_region_lengths.raw.txt 

cat out/RM.split.HM.vsl/*bed | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$3-$2}' > bed_files_with_region_lengths.masked.txt 
```

```
sed 's/\t/,/g' bed_files_with_region_lengths.raw.txt > bed_files_with_region_lengths.raw.csv
sed 's/\t/,/g' bed_files_with_region_lengths.masked.txt > bed_files_with_region_lengths.masked.csv

awk 'BEGIN{FS=OFS=","}(FNR==NR){d[$1]=$2;l[$1]=$3}(FNR!=NR){print $0,l[$1],100*$4/l[$1],d[$1]}' report.csv bed_files_with_region_lengths.raw.csv > bed_files_with_region_lengths.raw.plus.csv
awk 'BEGIN{FS=OFS=","}(FNR==NR){d[$1]=$2;l[$1]=$3}(FNR!=NR){print $0,l[$1],100*$4/l[$1],d[$1]}' report.csv bed_files_with_region_lengths.masked.csv > bed_files_with_region_lengths.masked.plus.csv

sort -t, -k4nr bed_files_with_region_lengths.raw.plus.csv 
sort -t, -k4nr bed_files_with_region_lengths.masked.plus.csv 

```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211122-Homology-Paper"
curl -netrc -X MKCOL "${BOX}/"

for f in bed_files_with_region_lengths.masked.plus.csv ; do
	echo $f
	curl -netrc -T ${f} "${BOX}/"
done
```



###	20230621


A tissue level atlas of the healthy human virome

https://bmcbiol.biomedcentral.com/articles/10.1186/s12915-020-00785-5


| name | accession | description |
| --- | --- | --- |
| HHV-1 | NC_001806.2 | also known as Herpes Simplex type 1 (HSV-1) | 
| HHV-2 | NC_001798.2 | also known as Herpes Simplex type 2 (HSV-2) | 
| HHV-3 | NC_001348.1 |  | 
| HHV-4 | NC_007605.1 | also known as Epstein-Barr virus (EBV) | 
| HHV-4 type 2 | NC_009334.1 |  | 
| HHV-5 | NC_006273.2 | also known as Human Cytomegalovirus (HCMV) | 
| HHV-6A | NC_001664.4 |  | 
| HHV-6B | NC_000898.1 |  | 
| HHV-7 | NC_001716.2 |  | 
| HHV-8 | NC_009333.1 | also known as Kaposi sarcoma-associated herpesvirus (KSHV) | 




```
mkdir blastn_beds_word_size_11
blastn_to_bed_array_wrapper.bash -word_size 11 --threads 2 --out ${PWD}/blastn_beds_word_size_11 ${PWD}/Raw/{NC_001806.2,NC_001798.2,NC_001348.1,NC_007605.1,NC_009334.1,NC_006273.2,NC_001664.4,NC_000898.1,NC_001716.2,NC_009333.1}*fasta

mkdir blastn_beds_word_size_10
blastn_to_bed_array_wrapper.bash -word_size 10 --threads 2 --out ${PWD}/blastn_beds_word_size_10 ${PWD}/Raw/{NC_001806.2,NC_001798.2,NC_001348.1,NC_007605.1,NC_009334.1,NC_006273.2,NC_001664.4,NC_000898.1,NC_001716.2,NC_009333.1}*fasta

mkdir blastn_beds_word_size_09
blastn_to_bed_array_wrapper.bash -word_size 9 --threads 2 --out ${PWD}/blastn_beds_word_size_09 ${PWD}/Raw/{NC_001806.2,NC_001798.2,NC_001348.1,NC_007605.1,NC_009334.1,NC_006273.2,NC_001664.4,NC_000898.1,NC_001716.2,NC_009333.1}*fasta

mkdir blastn_beds_word_size_08
blastn_to_bed_array_wrapper.bash -word_size 8 --threads 2 --out ${PWD}/blastn_beds_word_size_08 ${PWD}/Raw/{NC_001806.2,NC_001798.2,NC_001348.1,NC_007605.1,NC_009334.1,NC_006273.2,NC_001664.4,NC_000898.1,NC_001716.2,NC_009333.1}*fasta

mkdir blastn_beds_word_size_07
blastn_to_bed_array_wrapper.bash -word_size 8 --threads 2 --out ${PWD}/blastn_beds_word_size_07 ${PWD}/Raw/{NC_001806.2,NC_001798.2,NC_001348.1,NC_007605.1,NC_009334.1,NC_006273.2,NC_001664.4,NC_000898.1,NC_001716.2,NC_009333.1}*fasta

```

