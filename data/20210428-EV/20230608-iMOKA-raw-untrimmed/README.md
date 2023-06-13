
#	20210428-EV/20230608-iMOKA



run iMOKA on THE RAW, UNTRIMMED DATA




```
mkdir -p in

for f in /francislab/data1/raw/20210428-EV/Hansen/SFHH00*_R1_001.fastq.gz ; do
echo $f
l=$( basename ${f} _R1_001.fastq.gz )
echo $l
l=${l%_S*}
echo ${l}
ln -s ${f} in/${l}.fastq.gz
done
```






Remove control data

```
#awk -F, '($1~/_11$/){print "rm -f in/"$2".fastq.gz";print "rm -f in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv
#
#rm -f in/SFHH005k.fastq.gz
#rm -f in/SFHH006k.fastq.gz
#rm -f in/SFHH005v.fastq.gz
#rm -f in/SFHH006v.fastq.gz
#rm -f in/SFHH005ag.fastq.gz
#rm -f in/SFHH006ag.fastq.gz
#rm -f in/SFHH005ar.fastq.gz
#rm -f in/SFHH006ar.fastq.gz
```

Remove blank data

```
awk -F, '($4~/blank/){print "rm -f in/"$2".fastq.gz";print "rm -f in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv

rm -f in/SFHH005v.fastq.gz
rm -f in/SFHH006v.fastq.gz
rm -f in/SFHH005ar.fastq.gz
rm -f in/SFHH006ar.fastq.gz
```








```
#awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}( NR>1 && $1 !~ /_11/){print $2,"test",pwd"/in/"$2".fastq.gz";print $3,"test",pwd"/in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.all.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}( NR>1 && $4 !~ /blank/){print $2,"test",pwd"/in/"$2".fastq.gz";print $3,"test",pwd"/in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.all.tsv
```




With control

```
iMOKA_count.bash -k 16 --threads 64 --mem 490
iMOKA_count.bash -k 21 --threads 64 --mem 490
iMOKA_count.bash -k 31 --threads 64 --mem 490
```




```
chmod -w out/*/preprocess/*/*bin
```





../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/iMOKA_prep_create_matrices.bash

```
for k in 16 21 31 ; do
mkdir -p out/GBM-CATS-${k}
mkdir -p out/GBM-Lexogen-${k}
mkdir -p out/IDH-CATS-${k}
mkdir -p out/IDH-Lexogen-${k}

ln -s ../${k}/preprocess out/GBM-CATS-${k}/preprocess
ln -s ../${k}/preprocess out/GBM-Lexogen-${k}/preprocess
ln -s ../${k}/preprocess out/IDH-CATS-${k}/preprocess
ln -s ../${k}/preprocess out/IDH-Lexogen-${k}/preprocess


awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$2,"Control"}else if( $4 ~ /GBM/){print f,$2,"GBM"}else{print f,$2,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv | grep -vs "Control" > out/GBM-CATS-${k}/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$3,"Control"}else if( $4 ~ /GBM/){print f,$3,"GBM"}else{print f,$3,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv | grep -vs "Control" > out/GBM-Lexogen-${k}/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$2,"Control"}else if( $4 ~ /IDH-mutant/){print f,$2,"IDHmt"}else{print f,$2,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv | grep -vs "Control" > out/IDH-CATS-${k}/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$3,"Control"}else if( $4 ~ /IDH-mutant/){print f,$3,"IDHmt"}else{print f,$3,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv | grep -vs "Control" > out/IDH-Lexogen-${k}/create_matrix.tsv


mkdir -p out/GBM-CATS-${k}-withControl
mkdir -p out/GBM-Lexogen-${k}-withControl
mkdir -p out/IDH-CATS-${k}-withControl
mkdir -p out/IDH-Lexogen-${k}-withControl

ln -s ../${k}/preprocess out/GBM-CATS-${k}-withControl/preprocess
ln -s ../${k}/preprocess out/GBM-Lexogen-${k}-withControl/preprocess
ln -s ../${k}/preprocess out/IDH-CATS-${k}-withControl/preprocess
ln -s ../${k}/preprocess out/IDH-Lexogen-${k}-withControl/preprocess


awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$2,"Control"}else if( $4 ~ /GBM/){print f,$2,"GBM"}else{print f,$2,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/GBM-CATS-${k}-withControl/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$3,"Control"}else if( $4 ~ /GBM/){print f,$3,"GBM"}else{print f,$3,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/GBM-Lexogen-${k}-withControl/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$2,"Control"}else if( $4 ~ /IDH-mutant/){print f,$2,"IDHmt"}else{print f,$2,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/IDH-CATS-${k}-withControl/create_matrix.tsv

awk -F, -v k=${k} -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $4 !~ /blank/ ){f=pwd"/out/"k"/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /control/){print f,$3,"Control"}else if( $4 ~ /IDH-mutant/){print f,$3,"IDHmt"}else{print f,$3,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/IDH-Lexogen-${k}-withControl/create_matrix.tsv

done
```





../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/iMOKA_actual.bash


```

for k in 16 21 31 ; do
for s in GBM-CATS-${k} GBM-Lexogen-${k} IDH-CATS-${k} IDH-Lexogen-${k} GBM-CATS-${k}-withControl GBM-Lexogen-${k}-withControl IDH-CATS-${k}-withControl IDH-Lexogen-${k}-withControl ; do

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
--output="${PWD}/logs/iMOKA.${s}.${date}.out" \
--time=720 --nodes=1 --ntasks=32 --mem=240G \
~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step create 

done ; done

```




Predict those not in the models

```
#../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/predict.bash
```

```
#../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/matrices_of_select_kmers.bash
```



```
for k in 16 21 31 ; do
for s in GBM-CATS-${k} GBM-Lexogen-${k} IDH-CATS-${k} IDH-Lexogen-${k} GBM-CATS-${k}-withControl GBM-Lexogen-${k}-withControl IDH-CATS-${k}-withControl IDH-Lexogen-${k}-withControl ; do
if [ -f out/${s}/output.json ] ; then
iMOKA_upload.bash out/${s}
fi
done ; done

```






##	20230613


```
awk '(NR>1){print ">"$1;print $1}' /francislab/data1/working/20210428-EV/20230608-iMOKA-raw-untrimmed/out/IDH-CATS-31/output_fi.tsv > /francislab/data1/working/20210428-EV/20230608-iMOKA-raw-untrimmed/out/IDH-CATS-31/output_fi.fa

makeblastdb -in adapter.fa -input_type fasta -dbtype nucl -title adapter -out adapter -parse_seqids

blastn -db adapter -query /francislab/data1/working/20210428-EV/20230608-iMOKA-raw-untrimmed/out/IDH-CATS-31/output_fi.fa -out test.blastn
```





```
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC

AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG

ATCTCGTATGCCGTCTTCTGCTTG


TATGCCGTCTTCTGCATGTAAAAAGCGGGGG
TATGCCGTCTTCTGCTTG
CTCGTATTCAGTCTTCAGCATGAAAAAAAGG
ATCTCGTATGCCGTCTTCTGCTTG
TATGCCGAATAAAGATTAAAAAAAAGGGGGG
ATCTCGTATGCCGTCTTCTGCTTG
   TCGGATGCCGTCTTCTGCGTGATAAACGGGG
ATCTCGTATGCCGTCTTCTGCTTG
TCTCGTATTCCGTCATCAGCTAGAAAAAAGG
ATCTCGTATGCCGTCTTCTGCTTG
AAAAGATCGGAAGAGACACGTCGAACTCCAG
ATCTCGTATGCCGTCTTCTGCTTG
TTGTAGATGTGGGGGGGGGGGGGGGGGGGGG
ATCTCGTATGCCGTCTTCTGCTTG
ATCTCGTATGCCGTCGTCTGCTTGGAAAATG
ATCTCGTATGCCGTCTTCTGCTTG
GATCTCGTATGCCGTCGTGTGGGTGAAAAAG
ATCTCGTATGCCGTCTTCTGCTTG
AAAAAAAAAAAAAAACAAAAACAACACAAAA
ATCTCGTATGCCGTCTTCTGCTTG
TCTGCTTGTAAAACAGGGTGGGGGGGGGGGG
TCTGCTTG
AAAAAAAAAAGATACGAACAGCACACGTCTG
ATCTCGTATGCCGTCTTCTGCTTG
GATTCCGTCGGCTGCGTGAAAAAAGGGGGGG
TATGCCGTCTTCTGCTTG
GCCGTCTTCTGCTTTAAAATAAGAGGGGGGG
GCCGTCTTCTGCTTG
GGATGCCGTCTTCTGCTTGTACAAATGGGGG
GTATGCCGTCTTCTGCTTG
CGTCTTCTGCTTGTAATCCGGGGGGGGGGGG
CGTCTTCTGCTTG
AAAAAAGCAAAAAAAAAAAAAAAAAAAGGGG
ATCTCGTATGCCGTCTTCTGCTTG
CGTATGCCCTCTTCTGCTTGTGAAAAGGGGG
CGTATGCCGTCTTCTGCTTG
CGTCGTCTGCGTGCTAAAGGGGGGGGGGGGG
CGTCTTCTGCTTG
GATCTCGTATGCCCTCTTCTTCATGAAAAAG
ATCTCGTATGCCGTCTTCTGCTTG
GGGCTGGAGTAAAAAAAAAACAAAAAAAAAA
ATCTCGTATGCCGTCTTCTGCTTG
CTCGTATGCCGTCTTCTGCGTGTACAATCGG
CTCGTATGCCGTCTTCTGCTTG
TCTCGTCTGCCGTCTTCTTCTTGTAAAAGGG
CGTCTTCTGCTTG
ACCTCCTTGAAGGAAAAAAAAAACAAAAAAA
ATCTCGTATGCCGTCTTCTGCTTG
TATGACGTCGTCTGCTTGTAAAGAGGGGGGG
TATGCCGTCTTCTGCTTG
CGGATTCCGTCGTCTGCTTGTAGAGGGGGGG
CGTATGCCGTCTTCTGCTTG
AGATCGGAAGATCACACTACTGAACTCCAGT
ATCTCGTATGCCGTCTTCTGCTTG
AAAAGATCGGAAGAGCACCCGTCTTAACACC
ATCTCGTATGCCGTCTTCTGCTTG
GGTCTATTAAAAGAAAAAAAAAACAAAAAAA
ATCTCGTATGCCGTCTTCTGCTTG
TTCCGTCTTCTGCGTGTAAACGTGGGGGGGG
TGCCGTCTTCTGCTTG
CGGATGCCGTCTTCGGCTAGAAAAAAAGGGG
ATCTCGTATGCCGTCTTCTGCTTG
AGTCCACGCCCTAAACGATATCAACAAAAAA
ATCTCGTATGCCGTCTTCTGCTTG
TCTCGGATTCCGTCTTCTGCTTGTACAAGGG
TCTCGTATGCCGTCTTCTGCTTG
GCGTGTAAAGCTCGGGGGGGGGGGGGGGGGG
ATCTCGTATGCCGTCTTCTGCTTG
CTGCCGTCTTCTGCTAGAAAAAAAAGGGGGG
ATGCCGTCTTCTGCTTG
TCTCGGATGACGTCTTCTGCTTGTAAACAGG
TCTCGTATGCCGTCTTCTGCTTG
```







