
#	20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE

895 files

```BASH

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```


---

Quick run of just select


```BASH

mkdir REdiscoverTE_rollup_noquestion
cd REdiscoverTE_rollup_noquestion

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
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation_noquestion \
--outbase ${PWD}/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion

```



```BASH

REdiscoverTE_EdgeR_rmarkdown.bash

```




```BASH

awk 'BEGIN{FS=OFS="\t"}(NR>1){print $4,$5}' /francislab/data1/refs/REdiscoverTE/rollup_annotation/GENCODE.V26.Basic_Gene_Annotation_md5.tsv | sort -k1,1 | uniq > ENSG_Symbol.tsv

```





```BASH

module load r
../correlate_select.Rscript --select AllTumors
../correlate_select.Rscript --select FirstTumors
../correlate_select.Rscript --select GBMWTFirstTumors
../correlate_select.Rscript --select EduardoGBMFirstTumors

```




```BASH

tail -n +2 GENE_x_RE_all.tumor_ids.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs
head -1 GENE_x_RE_all.tumor_ids.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all

```

```BASH

wc -l GENEs RE_all
  55662 GENEs
   6515 RE_all

```



```BASH

for f in GENEs RE_all ; do
echo ${f}
comm -23 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/${f} ${f} > ${f}.GTEx_only
comm -13 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/${f} ${f} > ${f}.TCGA_only
comm -12 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/${f} ${f} > ${f}.shared
done

```


```BASH

join GENEs.GTEx_only ENSG_Symbol.tsv > GENEs.GTEx_only.Symbol
join GENEs.TCGA_only ENSG_Symbol.tsv > GENEs.TCGA_only.Symbol
join GENEs.shared ENSG_Symbol.tsv > GENEs.shared.Symbol

```



```BASH

box_upload.bash *_only *.tumor_ids.correlation.tsv

```




```BASH

\rm commands
for tsv in GENE_x_RE_*.correlation.tsv ; do
echo "$( realpath ${PWD}/select_gt.bash ) $( realpath ${tsv} )"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```

```BASH

box_upload.bash GENE_x_RE*.tumor_ids.correlation.gt*.tsv

```





```BASH

module load WitteLab python3/3.9.1
python3

```

```python3

import pandas as pd

TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_x_RE_all.tumor_ids.correlation.tsv',sep='\t',index_col=0)
GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_x_RE_all.correlation.tsv',sep='\t',index_col=0)

GTEx.shape
(55670, 4788)
TCGA.shape
(55662, 6515)

d=TCGA-GTEx
d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_x_RE_all.tumor_ids.correlation.DIFF.tsv',sep='\t')

```





For now, comparing ALL TCGA TUMORs to ONLY GTEx CEREBELLUM

```BASH

wc -l /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/Cerebellum
231 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/Cerebellum

```



May want to redo TCGA with UNIQUE subjects
May want to redo TCGA with GBM OR LGG
May want to redo GTEx with different tissue








```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=cocor --time=14-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/cocor.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/cocor.Rscript"

```






