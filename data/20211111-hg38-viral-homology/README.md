



```

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-982%10 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211111-hg38-viral-homology/array_wrapper.bash

```


```

./prep_refs.bash

```


```
cat for_reference/*.fasta > for_reference.fasta


module load bowtie2

bowtie2-build --threads 16 for_reference.fasta double_masked_viral 
chmod -w double_masked*

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



