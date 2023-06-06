
#	20210428-EV/20230606-iMOKA


```
mkdir -p in
for f in /francislab/data1/working/20210428-EV/20230605-preprocessing/out/SFHH00*.fastq.gz ; do
echo $f
base=$( basename $f )
ln -s $f in/${base}
done
```





Remove control data

```
awk -F, '($1~/_11$/){print "rm -f in/"$2".fastq.gz";print "rm -f in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv


rm -f in/SFHH005k.fastq.gz
rm -f in/SFHH006k.fastq.gz
rm -f in/SFHH005v.fastq.gz
rm -f in/SFHH006v.fastq.gz
rm -f in/SFHH005ag.fastq.gz
rm -f in/SFHH006ag.fastq.gz
rm -f in/SFHH005ar.fastq.gz
rm -f in/SFHH006ar.fastq.gz
```



```
awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}( NR>1 && $1 !~ /_11/){print $2,"test",pwd"/in/"$2".fastq.gz";print $3,"test",pwd"/in/"$3".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.all.tsv
```



```
iMOKA_count.bash -k 16 --threads 64 --mem 490

```




CATS = D-Plex

metadata contains columns with commas so need FPAT

Do we really need these source files?
```
awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( $4 ~ /GBM/){print $2,"GBM",pwd"/in/"$2".fastq.gz"}
( NR>1 && $1 !~ /_11/ && $4 !~ /GBM/){print $2,"nonGBM",pwd"/in/"$2".fastq.gz"}
' /francislab/data1/raw/20210428-EV/metadata.csv > source.CATS.GBM.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( $4 ~ /GBM/){print $3,"GBM",pwd"/in/"$3".fastq.gz"}
( NR>1 && $1 !~ /_11/ && $4 !~ /GBM/){print $3,"nonGBM",pwd"/in/"$3".fastq.gz"}
' /francislab/data1/raw/20210428-EV/metadata.csv > source.Lexogen.GBM.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( $4 ~ /IDH-mutant/){print $2,"IDHmt",pwd"/in/"$2".fastq.gz"}
( NR>1 && $1 !~ /_11/ && $4 !~ /IDH-mutant/){print $2,"IDHWT",pwd"/in/"$2".fastq.gz"}
' /francislab/data1/raw/20210428-EV/metadata.csv > source.CATS.IDH.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( $4 ~ /IDH-mutant/){print $3,"IDHmt",pwd"/in/"$3".fastq.gz"}
( NR>1 && $1 !~ /_11/ && $4 !~ /IDH-mutant/){print $3,"IDHWT",pwd"/in/"$3".fastq.gz"}
' /francislab/data1/raw/20210428-EV/metadata.csv > source.Lexogen.IDH.tsv

```




```
chmod -w out/16/preprocess/*/*bin
```





../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/iMOKA_prep_create_matrices.bash

```
mkdir -p out/GBM-CATS-16
mkdir -p out/GBM-Lexogen-16
mkdir -p out/IDH-CATS-16
mkdir -p out/IDH-Lexogen-16

ln -s ../16/preprocess out/GBM-CATS-16/preprocess
ln -s ../16/preprocess out/GBM-Lexogen-16/preprocess
ln -s ../16/preprocess out/IDH-CATS-16/preprocess
ln -s ../16/preprocess out/IDH-Lexogen-16/preprocess


awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $1 !~ /_11/ ){f=pwd"/out/16/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /GBM/){print f,$2,"GBM"}else{print f,$2,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/GBM-CATS-16/create_matrix.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $1 !~ /_11/ ){f=pwd"/out/16/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /GBM/){print f,$3,"GBM"}else{print f,$3,"nonGBM"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/GBM-Lexogen-16/create_matrix.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $1 !~ /_11/ ){f=pwd"/out/16/preprocess/"$2"/"$2".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /IDH-mutant/){print f,$2,"IDHmt"}else{print f,$2,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/IDH-CATS-16/create_matrix.tsv

awk -F, -v pwd=$PWD 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}
( NR>1  && $1 !~ /_11/ ){f=pwd"/out/16/preprocess/"$3"/"$3".tsv"
if(system("test -f " f".sorted.bin")==0){
if( $4 ~ /IDH-mutant/){print f,$3,"IDHmt"}else{print f,$3,"IDHWT"}
}}' /francislab/data1/raw/20210428-EV/metadata.csv > out/IDH-Lexogen-16/create_matrix.tsv

```




../../20220610-EV/20221025-iMOKA-trim-R1-nr-14/iMOKA_actual.bash


```

for s in GBM-CATS-16 GBM-Lexogen-16 IDH-CATS-16 IDH-Lexogen-16 ; do

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
--output="${PWD}/logs/iMOKA.${s}.${date}.out" \
--time=720 --nodes=1 --ntasks=32 --mem=240G \
~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k 16 --step create 

done

```





Predict those not in the models

```
#./predict.bash
```


```
#./matrices_of_select_kmers.bash
```



```
for s in GBM-CATS-16 GBM-Lexogen-16 IDH-CATS-16 IDH-Lexogen-16 ; do
iMOKA_upload.bash out/${s}
done

```






