
#	20200720-TCGA-GBMLGG-RNA_bam/20200808-REdiscoverTE/REdiscoverTE_rollup_noquestion



```
awk '( $1 ~ /^..-....-01/ ){print $1}' ../REdiscoverTE.tsv > tumor_ids
chmod 400 tumor_ids
```


```
module load r
../correlate_select.Rscript --select tumor_ids
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
comm -23 /francislab/data1/working/20201006-GTEx/20201117-REdiscoverTE/REdiscoverTE_rollup.noquestion/${f}.sorted ${f}.sorted > ${f}.GTEx_only
comm -13 /francislab/data1/working/20201006-GTEx/20201117-REdiscoverTE/REdiscoverTE_rollup.noquestion/${f}.sorted ${f}.sorted > ${f}.TCGA_only
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



