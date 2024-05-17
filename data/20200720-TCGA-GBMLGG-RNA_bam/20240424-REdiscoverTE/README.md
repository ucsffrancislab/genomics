
#	20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE

895 total files


##	Quick Run

Quick run of just select


```BASH

ls -1 ${PWD}/../../20230807-cutadapt/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz | awk '( $1 ~ /^..-....-01/ ){print $1}' > AllTumors
chmod 400 AllTumors
ls -1 ${PWD}/../../20230807-cutadapt/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz | awk '( $1 ~ /^..-....-01/ ){split($1,a,"-");k[a[1]a[2]]++;if(k[a[1]a[2]]==1){print $1}}' > FirstTumors
chmod 400 FirstTumors

```

```BASH

tail -q -n +2 /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240401-REdiscoverTE-TensorFlow/{gbm_train,gbm_test}.tsv | cut -f1 | sort | uniq | tr -d \" > EduardoGBMSubjects
awk 'BEGIN{OFS="\t"}{split($1,a,"-");print a[1]"-"a[2],$0}' FirstTumors > tmp
join tmp EduardoGBMSubjects | cut -d" " -f2 > EduardoGBMFirstTumors
\rm tmp

```

```BASH

awk -F"\t" '($2=="TCGA-GBM" && $8=="WT"){split($1,a,"-");print a[2]"-"a[3]}' /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/TCGA.Glioma.metadata.tsv > GBMWTSubjects
awk 'BEGIN{OFS="\t"}{split($1,a,"-");print a[1]"-"a[2],$0}' FirstTumors > tmp
join tmp GBMWTSubjects | cut -d" " -f2 > GBMWTFirstTumors
\rm tmp

```

```BASH

wc -l *
  846 AllTumors
  116 EduardoGBMFirstTumors
  118 EduardoGBMSubjects
  688 FirstTumors
  155 GBMWTFirstTumors
  441 GBMWTSubjects

```



```BASH

mkdir GBMWTFirstTumors_in
for f in $( cat GBMWTFirstTumors ) ; do
if [ -f /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/${f}_R1.fastq.gz ] ; then
ln -s /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/${f}_R1.fastq.gz GBMWTFirstTumors_in/
ln -s /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/${f}_R2.fastq.gz GBMWTFirstTumors_in/
fi
done

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/GBMWTFirstTumors_out \
  --extension _R1.fastq.gz \
  ${PWD}/GBMWTFirstTumors_in/*_R1.fastq.gz

```





```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/GBMWTFirstTumors_out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion \
--outbase ${PWD}/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion

```






```BASH

awk 'BEGIN{FS=OFS="\t"}(NR>1){print $4,$5}' /francislab/data1/refs/REdiscoverTE/rollup_annotation/GENCODE.V26.Basic_Gene_Annotation_md5.tsv | sort -k1,1 | uniq > ENSG_Symbol.tsv

```




Initially this process was done on the `2_counts_normalized.RDS` files. We have/are redone/redoing it on the `3_TPM.RDS` files.





```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=correlate --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/correlate_select.GBMWTFirstTumors.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/correlate_select.Rscript --indir ${PWD}/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion --select ${PWD}/GBMWTFirstTumors"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=correlate --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/correlate_select.EduardoGBMFirstTumors.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/correlate_select.Rscript --indir ${PWD}/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion --select ${PWD}/EduardoGBMFirstTumors"

```


Filter greater than 0.8, 0.9, 0.95, 0.99

```BASH

\rm commands
for tsv in GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_*.correlation.tsv ; do
echo "${PWD}/select_gt.bash ${tsv}"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```


```BASH

tail -n +2 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs.GBMWTFirstTumors
head -1 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all.GBMWTFirstTumors

tail -n +2 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.EduardoGBMFirstTumors.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs.EduardoGBMFirstTumors
head -1 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.EduardoGBMFirstTumors.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all.EduardoGBMFirstTumors

```


```BASH

wc -l GENEs.*Tumors RE_all.*Tumors
  52441 GENEs.EduardoGBMFirstTumors
  52441 GENEs.GBMWTFirstTumors
   4634 RE_all.EduardoGBMFirstTumors
   4634 RE_all.GBMWTFirstTumors

```


```BASH

box_upload.bash GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/*tsv

```


```BASH

for f in GENEs RE_all ; do
echo ${f}
comm -23 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.GTEx_only
comm -13 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.TCGA_only
comm -12 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.shared
done

```


```BASH

join GENEs.Cerebellum.GBMWTFirstTumors.GTEx_only ENSG_Symbol.tsv > GENEs.Cerebellum.GBMWTFirstTumors.GTEx_only.Symbol
join GENEs.Cerebellum.GBMWTFirstTumors.TCGA_only ENSG_Symbol.tsv > GENEs.Cerebellum.GBMWTFirstTumors.TCGA_only.Symbol
join GENEs.Cerebellum.GBMWTFirstTumors.shared ENSG_Symbol.tsv > GENEs.Cerebellum.GBMWTFirstTumors.shared.Symbol

```


```BASH

box_upload.bash *.Cerebellum.GBMWTFirstTumors.*

```


```BASH

module load WitteLab python3/3.9.1
python3

```

```python3

import pandas as pd

TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv',sep='\t',index_col=0)
GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv',sep='\t',index_col=0)

#GTEx.shape
#(55670, 4788)
#TCGA.shape
#(55662, 6515)

GTEx.shape
(47024, 3583)
TCGA.shape
(52441, 4634)

d=TCGA-GTEx
d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv',sep='\t')

```

```BASH

box_upload.bash GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv

```



```BASH
#
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#  --job-name=cocor --time=14-0 --nodes=1 --ntasks=8 --mem=60G \
#  --output=${PWD}/logs/cocor.$( date "+%Y%m%d%H%M%S%N" ).out.log \
#  --wrap "module load r; ${PWD}/cocor.Rscript --tcga=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv --gtex=/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv --shared_genes=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENEs.Cerebellum.GBMWTFirstTumors.shared --shared_res=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/RE_all.Cerebellum.GBMWTFirstTumors.shared"
#
```


So this is gonna take about 5 days.

Probably a good idea to prefilter shared genes and REs and break up the input and process in several different jobs and then concatenate results.

Looks like the whole script is using about 20GB of memory.

The smaller jobs probably will not need this much as the matrix will be smaller.

Could break this up into 16 different jobs and process with just 4CPU/30GB or possibly even 32 on 2CPU/15GB.







Not sure yet, but I think that the Rscript is gonna drop the NA "gene"

```
echo "Gene" > shared_genes
cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENEs.Cerebellum.GBMWTFirstTumors.shared >> shared_genes
echo "RE" > shared_res
cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/RE_all.Cerebellum.GBMWTFirstTumors.shared >> shared_res

for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv ; do
echo $f
echo "substituting"
cat $f | tr -d \" | tr "\t" \; > tmp1
echo "sorting"
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t\; -k1,1 >> tmp2
echo "joining"
join --header -t\; shared_genes tmp2 > tmp3
echo "transposing"
cat tmp3 | datamash transpose -t \; > tmp4
echo "sorting"
head -1 tmp4 > tmp5
tail -n +2 tmp4 | sort -t\; -k1,1 >> tmp5
echo "joining"
join --header -t\; shared_res tmp5 > tmp6
echo "transposing to output"
cat tmp6 | datamash transpose -t \; | tr \; "\t" > $( basename $f .tsv ).shared.tsv
done

\rm tmp*

wc -l *.shared.tsv
     46034 GENE_x_RE_all.Cerebellum.correlation.shared.tsv
     46034 GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv


awk -F"\t" '{print NF}' GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv | uniq
3170
awk -F"\t" '{print NF}' GENE_x_RE_all.Cerebellum.correlation.shared.tsv | uniq
3170



for f in GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv GENE_x_RE_all.Cerebellum.correlation.shared.tsv ; do
echo $f
awk -F"\t" '(NR==1){header=$0;c=0;i=1;n=sprintf("%03d",i);print header > FILENAME"."n}(NR>1){
if( c >= 1000 ){
c=0;i++;n=sprintf("%03d",i);
print header > FILENAME"."n
}
c++;print >> FILENAME"."n
}' $f
done
```





Split things up. Each takes about an hour.
```

\rm commands
for i in $( seq -w 001 047 ) ; do
echo "module load r; ${PWD}/cocor.Rscript --tcga=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv.${i} --gtex=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENE_x_RE_all.Cerebellum.correlation.shared.tsv.${i} --output=cocor.${i}.tsv"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```


```

cp cocor.001.tsv cocor.tsv
for i in $( seq -w 002 047 ) ; do
tail -n +2 cocor.${i}.tsv >> cocor.tsv
done

```










##	Complete Run


```BASH

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```

```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation_noquestion \
--outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

```BASH

#	REdiscoverTE_EdgeR_rmarkdown.bash

```















##	cocor distribution



```BASH

module load WitteLab python3/3.9.1
python3

```



```python


import pandas as pd
df=pd.read_csv('cocor.tsv',sep='\t',index_col=0)
df.head()
df.describe().T.to_csv('cocor.RE.describe.tsv',sep='\t')
df.T.describe().T.to_csv('cocor.GENE.describe.tsv',sep='\t')

```

What produces 0 in the cocor matrix?

Where are they 0?

```BASH

( head -1 cocor.tsv && grep -m1 -P '\t0\t' cocor.tsv ) | awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){print $1;for(i=2;i<=NF;i++){if($i==0){print h[i],i}}}'
ENSG00000000971
(AAGGGA)n 51
(CCACCCG)n 573
(CCCGA)n 662
(CCCTGCT)n 704
(GCAC)n 1222
(TCCTCTT)n 2602
(TCTCGC)n 2634
tRNA-Leu-CTG 2868
(TTGTTTG)n 2974
(TTTATCT)n 2984
(TTTATTC)n 2987
(TTTTTGT)n 3049

```

Find the values in the source matrices that are being compared.



```BASH
for f in GENE_x_RE_all.*.correlation.shared.tsv; do
echo $f
( head -1 $f && grep -m1 "^ENSG00000000971" $f ) | awk -F"\t" '{print $2868}'
done


GENE_x_RE_all.Cerebellum.correlation.shared.tsv
tRNA-Leu-CTG
0.968945933355241  # 0.968869096164028
GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv
tRNA-Leu-CTG
0.00395619460372738 # 0.0241762547961101

```

```R
library('cocor')
GTEx_count=37
TCGA_count=155

pvalue = cocor.indep.groups( 0.968869096164028, 0.0241762547961101,  GTEx_count, TCGA_count, 
     alternative = "two.sided", test = "fisher1925", alpha = 0.05, null.value = 0, return.htest = TRUE)$fisher1925$p.value

print( pvalue )

[1] 0



unk = cocor.indep.groups( 0.968869096164028, 0.0241762547961101,  GTEx_count, TCGA_count, 
     alternative = "two.sided", test = "fisher1925", alpha = 0.05, null.value = 0, return.htest = TRUE)

print( unk )


$fisher1925

	Fisher's z (1925)

data:  
z = 10.802, p-value < 2.2e-16
alternative hypothesis: true difference in correlations is not equal to 0
sample estimates:
     r1.jk      r2.hm 
0.96886910 0.02417625 


$zou2007

	Zou's (2007) confidence interval

data:  

alternative hypothesis: true difference in correlations is not equal to 0
sample estimates:
     r1.jk      r2.hm 
0.96886910 0.02417625 
```







Can you pull the co expression row for that RE, i.e. which genes come up as correlated in the GTEX data?



```

cat GENE_x_RE_all.Cerebellum.correlation.shared.tsv | datamash transpose > GENE_x_RE_all.Cerebellum.correlation.shared.T.tsv
( head -1 GENE_x_RE_all.Cerebellum.correlation.shared.T.tsv && grep -m1 "^HERVS71-int" GENE_x_RE_all.Cerebellum.correlation.shared.T.tsv ) | awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if(sqrt($i^2)<=0.0005){print h[i]" "$i > "GENE_x_RE_all.Cerebellum.correlation.shared.T."$1".csv"}}}'
join ENSG_Symbol.tsv GENE_x_RE_all.Cerebellum.correlation.shared.T.HERVS71-int.csv

cat GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv | datamash transpose > GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.T.tsv
( head -1 GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.T.tsv && grep -m1 "^HERVS71-int" GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.T.tsv ) | awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if(sqrt($i^2)<=0.0005){print h[i]" "$i > "GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.T."$1".csv"}}}'
join ENSG_Symbol.tsv GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.T.HERVS71-int.csv 

```










```BASH

module load r

```


```R

r=readRDS(paste('GBMWTFirstTumors_REdiscoverTE_rollup_noquestion','RE_all_3_TPM.RDS',sep="/"))
r=r$counts
write.table(r, file=paste('GBMWTFirstTumors_REdiscoverTE_rollup_noquestion','RE_all_3_TPM.tsv',sep="/"),
  row.names=TRUE, sep="\t", col.names = NA)

```

```BASH

REdiscoverTE_median_plotter.Rmd GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/RE_all_repFamily_3_TPM.RDS

```





for the TCGA and GTEX ‘only’ files. Can we come up with a way to cull that list by genes that are expressed in a majority of subjects?

So you are looking to find those that are in a majority of subjects in TCGA or GTEx?

Yep- no big rush, but Im still curious if there are extreme examples where its completely absent in one or the other… but real not just noise


```

for RE in $( grep -v ")n\$" RE_all.Cerebellum.GBMWTFirstTumors.GTEx_only ) ; do
echo $RE
grep \"${RE}\" /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/RE_all_3_TPM.tsv | datamash transpose | datamash -H mean 1 q1 1 median 1 q3 1 iqr 1 sstdev 1 jarque 1 
done


for RE in $( grep -v ")n\$" RE_all.Cerebellum.GBMWTFirstTumors.TCGA_only ) ; do
echo $RE
grep \"${RE}\" /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/RE_all_3_TPM.tsv | datamash transpose | datamash -H mean 1 q1 1 median 1 q3 1 iqr 1 sstdev 1 jarque 1 
done

```




##	20240502


Filter out Simple Repeats and those with medians == 0

```R

r=readRDS("/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/RE_all_3_TPM.RDS")
r=r$counts
r=r[!grepl(")n$", row.names(r)),]
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('TCGA_Good_RE.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/RE_all_3_TPM.RDS")
r=r$counts
r=r[!grepl(")n$", row.names(r)),]
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('GTEx_Good_RE.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_3_TPM.RDS")
r=r$counts
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('TCGA_Good_GENE.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_3_TPM.RDS")
r=r$counts
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('GTEx_Good_GENE.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

```




```BASH
cat <( tail -n +2 GTEx_Good_RE.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_RE.tsv | cut -f1 ) | sort | uniq > Good_RE.one
cat <( tail -n +2 GTEx_Good_GENE.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_GENE.tsv | cut -f1 ) | sort | uniq > Good_GENE.one

cat <( tail -n +2 GTEx_Good_RE.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_RE.tsv | cut -f1 ) | sort | uniq -d > Good_RE.both
cat <( tail -n +2 GTEx_Good_GENE.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_GENE.tsv | cut -f1 ) | sort | uniq -d > Good_GENE.both

sed -i '1iGENE' Good_GENE.one
sed -i '1iGENE' Good_GENE.both
sed -i '1iRE' Good_RE.one
sed -i '1iRE' Good_RE.both
```


```BASH
sed 's/\t/;/g' cocor.tsv > tmp

for s in one both ; do
echo $s
join --header -t\; Good_GENE.${s} tmp | datamash transpose -t\; > tmp1
join --header -t\; Good_RE.${s} tmp1 | datamash transpose -t\; > tmp2
sed 's/;/\t/g' tmp2 > cocor.${s}.tsv
done
```





Each take about 2 hours

```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=Rmd.one --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/cocor.one.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/REdiscoverTE_cocor_heatmap.Rmd ${PWD}/cocor.one.tsv"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=Rmd.both --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/cocor.both.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/REdiscoverTE_cocor_heatmap.Rmd ${PWD}/cocor.both.tsv"

```



##	20240506


```

awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i==0)print $1"\t"h[i]}}'  cocor.both.tsv > cocor.both.0.tsv

awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i==0)print $1"\t"h[i]}}'  cocor.one.tsv > cocor.one.0.tsv


join ENSG_Symbol.tsv cocor.both.0.tsv | sed 's/ /\t/g' > cocor.both.0.symbol.tsv

join ENSG_Symbol.tsv cocor.one.0.tsv | sed 's/ /\t/g' > cocor.one.0.symbol.tsv

```




```BASH

module load WitteLab python3/3.9.1

```


```BASH
./matrix_select_and_diff.py \
 -n /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv \
 -t /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv \
 -s cocor.both.0.symbol.tsv -o GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.cocor.both.0.tsv
```








##	20240507 - Change from RE_all to RE_all_repFamily



```BASH

tail -n +2 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs_x_RE_all_repFamily.GBMWTFirstTumors
head -1 GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all_repFamily.GBMWTFirstTumors

```


```BASH

module load WitteLab python3/3.9.1
python3

```

```python3

import pandas as pd

TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv',sep='\t',index_col=0)
GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv',sep='\t',index_col=0)

GTEx.shape
(47024, 49)
TCGA.shape
(52441, 48)

d=TCGA-GTEx
d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv',sep='\t')

```


```BASH

for f in RE_all_repFamily ; do
echo ${f}
comm -23 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.GTEx_only
comm -13 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.TCGA_only
comm -12 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/${f}.Cerebellum ${f}.GBMWTFirstTumors > ${f}.Cerebellum.GBMWTFirstTumors.shared
done

```



```

echo "RE" > shared_res_repFamily
cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/RE_all_repFamily.Cerebellum.GBMWTFirstTumors.shared >> shared_res_repFamily

for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv ; do
echo $f
echo "substituting"
cat $f | tr -d \" | tr "\t" \; > tmp1
echo "sorting"
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t\; -k1,1 >> tmp2
echo "joining"
join --header -t\; shared_genes tmp2 > tmp3
echo "transposing"
cat tmp3 | datamash transpose -t \; > tmp4
echo "sorting"
head -1 tmp4 > tmp5
tail -n +2 tmp4 | sort -t\; -k1,1 >> tmp5
echo "joining"
join --header -t\; shared_res_repFamily tmp5 > tmp6
echo "transposing to output"
cat tmp6 | datamash transpose -t \; | tr \; "\t" > $( basename $f .tsv ).shared.tsv
done

\rm tmp*

wc -l *.shared.tsv
     46034 GENE_x_RE_all.Cerebellum.correlation.shared.tsv
     46034 GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv
     46034 GENE_x_RE_all_repFamily.Cerebellum.correlation.shared.tsv
     46034 GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.shared.tsv


awk -F"\t" '{print NF}' GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.shared.tsv | uniq
49
awk -F"\t" '{print NF}' GENE_x_RE_all_repFamily.Cerebellum.correlation.shared.tsv | uniq
49



for f in GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.shared.tsv GENE_x_RE_all_repFamily.Cerebellum.correlation.shared.tsv ; do
echo $f
awk -F"\t" '(NR==1){header=$0;c=0;i=1;n=sprintf("%03d",i);print header > FILENAME"."n}(NR>1){
if( c >= 1000 ){
c=0;i++;n=sprintf("%03d",i);
print header > FILENAME"."n
}
c++;print >> FILENAME"."n
}' $f
done
```




Split things up. Each takes about a minute!
```

\rm commands
for i in $( seq -w 001 047 ) ; do
echo "module load r; ${PWD}/cocor.Rscript --tcga=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.shared.tsv.${i} --gtex=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENE_x_RE_all_repFamily.Cerebellum.correlation.shared.tsv.${i} --output=cocor.repFamily.${i}.tsv"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 2 --mem 15G 

```


```

cp cocor.repFamily.001.tsv cocor.repFamily.tsv
for i in $( seq -w 002 047 ) ; do
tail -n +2 cocor.repFamily.${i}.tsv >> cocor.repFamily.tsv
done

```



Filter out Simple Repeats and those with medians == 0

```R

r=readRDS("/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/RE_all_repFamily_3_TPM.RDS")
r=r$counts
r=r[!grepl(")n$", row.names(r)),]
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('TCGA_Good_RE.repFamily.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/RE_all_repFamily_3_TPM.RDS")
r=r$counts
r=r[!grepl(")n$", row.names(r)),]
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('GTEx_Good_RE.repFamily.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_3_TPM.RDS")
r=r$counts
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('TCGA_Good_GENE.repFamily.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

r=readRDS("/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_3_TPM.RDS")
r=r$counts
medians=apply(r,1,median)
medians=medians[which(medians>0)]
write.table(medians, file=paste('GTEx_Good_GENE.repFamily.tsv',sep="/"), row.names=TRUE, sep="\t", col.names = NA, quote=FALSE)

```







```BASH
cat <( tail -n +2 GTEx_Good_RE.repFamily.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_RE.repFamily.tsv | cut -f1 ) | sort | uniq > Good_RE.repFamily.one
cat <( tail -n +2 GTEx_Good_GENE.repFamily.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_GENE.repFamily.tsv | cut -f1 ) | sort | uniq > Good_GENE.repFamily.one

cat <( tail -n +2 GTEx_Good_RE.repFamily.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_RE.repFamily.tsv | cut -f1 ) | sort | uniq -d > Good_RE.repFamily.both
cat <( tail -n +2 GTEx_Good_GENE.repFamily.tsv | cut -f1 ) <( tail -n +2 TCGA_Good_GENE.repFamily.tsv | cut -f1 ) | sort | uniq -d > Good_GENE.repFamily.both

sed -i '1iGENE' Good_GENE.repFamily.one
sed -i '1iGENE' Good_GENE.repFamily.both
sed -i '1iRE' Good_RE.repFamily.one
sed -i '1iRE' Good_RE.repFamily.both
```


```BASH
sed 's/\t/;/g' cocor.repFamily.tsv > tmp

for s in one both ; do
echo $s
join --header -t\; Good_GENE.repFamily.${s} tmp | datamash transpose -t\; > tmp1
join --header -t\; Good_RE.repFamily.${s} tmp1 | datamash transpose -t\; > tmp2
sed 's/;/\t/g' tmp2 > cocor.repFamily.${s}.tsv
done
```





Each take about 2 hours

```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=Rmd.one --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/cocor.repFamily.one.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/REdiscoverTE_cocor_heatmap.Rmd ${PWD}/cocor.repFamily.one.tsv"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=Rmd.both --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/cocor.repFamily.both.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/REdiscoverTE_cocor_heatmap.Rmd ${PWD}/cocor.repFamily.both.tsv"

```




```

awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i==0)print $1"\t"h[i]}}'  cocor.repFamily.both.tsv > cocor.repFamily.both.0.tsv

awk -F"\t" '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i==0)print $1"\t"h[i]}}'  cocor.repFamily.one.tsv > cocor.repFamily.one.0.tsv


join ENSG_Symbol.tsv cocor.repFamily.both.0.tsv | sed 's/ /\t/g' > cocor.repFamily.both.0.symbol.tsv

join ENSG_Symbol.tsv cocor.repFamily.one.0.tsv | sed 's/ /\t/g' > cocor.repFamily.one.0.symbol.tsv

```




```BASH

module load WitteLab python3/3.9.1

```


```BASH
./matrix_select_and_diff.py \
 -n /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv \
 -t /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv \
 -s cocor.repFamily.both.0.symbol.tsv -o GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.cocor.repFamily.both.0.tsv
```



```BASH

box_upload.bash cocor.repFamily.*heatmap* GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.cocor.repFamily.both.0.tsv

```




##	20240508


Increase p-value threshold in search hoping to include L1s.

Search for L1 threshold.





```
for t in 1e-7 1e-8 1e-9 ; do
awk -F"\t" -v t=$t '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i<=t)print $1"\t"h[i]}}'  cocor.repFamily.both.tsv > cocor.repFamily.both.${t}.tsv
awk -F"\t" -v t=$t '(NR==1){for(i=2;i<=NF;i++){h[i]=$i}}(NR>1){for(i=2;i<=NF;i++){if($i<=t)print $1"\t"h[i]}}'  cocor.repFamily.one.tsv > cocor.repFamily.one.${t}.tsv
join ENSG_Symbol.tsv cocor.repFamily.both.${t}.tsv | sed 's/ /\t/g' > cocor.repFamily.both.${t}.symbol.tsv
join ENSG_Symbol.tsv cocor.repFamily.one.${t}.tsv | sed 's/ /\t/g' > cocor.repFamily.one.${t}.symbol.tsv
done
```



```BASH
./matrix_select_and_diff.py \
 -n /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv \
 -t /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv \
 -s cocor.repFamily.both.1e-7.symbol.tsv -o GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.cocor.repFamily.both.1e-7.tsv
```

