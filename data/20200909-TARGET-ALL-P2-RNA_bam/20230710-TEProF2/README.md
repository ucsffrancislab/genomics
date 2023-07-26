
#	20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2



```
/francislab/data1/refs/RseQC/README.md 
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
mkdir ${dir}
for bai in ${base}/*.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi
done
```

```
base=/francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam
dir=${base}/strand_check
for f in ${dir}/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c

 
      5 --fr
     51 none
    476 --rf

```



This data is predominantly stranded.





```

TEProF2_array_wrapper.bash --threads 4 \
  --out ${PWD}/in \
  --extension .bam \
  /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/*bam

```



```
TEProF2_aggregation_steps.bash --threads 64 \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  ${PWD}/in --out ${PWD}/out
```


Prepping to view final R data
```R
R

load("out/Step13.RData")
colnames(tpmexpressiontable)[1] = "ids"
write.table(tpmexpressiontable,file='tpmexpressiontable.csv',sep=",",row.names=FALSE,quote=FALSE)
```


```
chmod a-w tpmexpressiontable.csv
```






```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in tpmexpressiontable* ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```




##	20230724















Create a translation table to convert TCONS to Viral

```
awk 'BEGIN{FS=OFS=","}(NR>1){print $(NF-1),$NF}' /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.005.trimandsort.species.csv | sort | uniq > TCONS_species.e0.005.csv

cat tpmexpressiontable.csv | datamash transpose -t, | head -1 > tpmexpressiontable.sorted.csv
cat tpmexpressiontable.csv | datamash transpose -t, | tail -n +2 >> tpmexpressiontable.sorted.csv

join -t, TCONS_species.e0.005.csv \
  <( tail -n +2 tpmexpressiontable.sorted.csv ) \
  > tpmexpressiontable.sorted.species.csv

awk 'BEGIN{FS=OFS=","}{ for(i=3;i<=NF;i++){s[$2][i]+=$i}}END{for(k in s){t=k;for(i=3;i<=NF;i++){t=t","s[k][i]};print t}}' tpmexpressiontable.sorted.species.csv | sort | awk 'BEGIN{FS=OFS=","}{s=0;for(i=2;i<=NF;i++){if($i>0.01)s++};print $1,s}' > tpmexpressiontable.sorted.species.agg.csv


```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in TCONS_species.e0.005.csv tpmexpressiontable.sorted.csv tpmexpressiontable.sorted.species.csv tpmexpressiontable.sorted.species.agg.csv; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```
