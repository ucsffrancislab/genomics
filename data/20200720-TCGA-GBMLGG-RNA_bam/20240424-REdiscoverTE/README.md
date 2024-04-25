
#	20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE

895 files




```

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```





```

REdiscoverTE_rollup.bash --datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion/

```



```
REdiscoverTE_EdgeR_rmarkdown.bash
```


---

ll ../20200808-REdiscoverTE/REdiscoverTE_rollup_noquestion/README.md 




```
awk '( $1 ~ /^..-....-01/ ){print $1}' REdiscoverTE.tsv > tumor_ids
chmod 400 tumor_ids
```


```
module load r
correlate_select.Rscript --select tumor_ids
```




```
tail -n +2 GENE_x_RE_all.tumor_ids.correlation.tsv | cut -f1 | tr -d \" > GENEs
head -1 GENE_x_RE_all.tumor_ids.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" > RE_all
```

```
wc -l GENEs RE_all
  55662 GENEs
   6515 RE_all
```



```
for f in GENEs RE_all ; do
echo ${f}
comm -23 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/${f}.sorted ${f}.sorted > ${f}.GTEx_only
comm -13 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/${f}.sorted ${f}.sorted > ${f}.TCGA_only
comm -12 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/${f}.sorted ${f}.sorted > ${f}.shared
done
```



```
box_upload.bash *_only *.tumor_ids.correlation.tsv
```




```BASH
\rm commands
for tsv in GENE_x_RE_*.correlation.tsv ; do
echo "$( realpath ${PWD}/select_gt.bash ) $( realpath ${tsv} )"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 
```

```
box_upload.bash GENE_x_RE*.tumor_ids.correlation.gt*.tsv
```





```BASH
module load WitteLab python3/3.9.1
python3
```

```python3
import pandas as pd

TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_x_RE_all.tumor_ids.correlation.tsv',sep='\t',index_col=0)
GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/GENE_x_RE_all.correlation.tsv',sep='\t',index_col=0)

GTEx.shape
(55670, 4788)
TCGA.shape
(55662, 6515)

d=TCGA-GTEx
d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_x_RE_all.tumor_ids.correlation.DIFF.tsv',sep='\t')
```





For now, comparing ALL TCGA TUMORs to ONLY GTEx CEREBELLUM
```BASH
wc -l /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/REdiscoverTE_rollup_noquestion/tumor_ids 
846 tumor_ids

wc -l /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/Cerebellum
231 /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/REdiscoverTE_rollup.noquestion/Cerebellum
```



May want to redo TCGA with UNIQUE subjects
May want to redo TCGA with GBM OR LGG
May want to redo GTEx with different tissue








```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=cocor --time=14-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/cocor.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/cocor.Rscript"



```






