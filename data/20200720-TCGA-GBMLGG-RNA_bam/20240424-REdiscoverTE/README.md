
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

GTEx.shape
(55670, 4788)
TCGA.shape
(55662, 6515)

d=TCGA-GTEx
d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv',sep='\t')

```

```BASH

box_upload.bash GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv

```



```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=cocor --time=14-0 --nodes=1 --ntasks=8 --mem=60G \
  --output=${PWD}/logs/cocor.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/cocor.Rscript --tcga=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv --gtex=/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv --shared_genes=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENEs.Cerebellum.GBMWTFirstTumors.shared --shared_res=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/RE_all.Cerebellum.GBMWTFirstTumors.shared"

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
--outbase ${PWD}/EdiscoverTE_rollup_noquestion

```



```BASH

#	REdiscoverTE_EdgeR_rmarkdown.bash

```

