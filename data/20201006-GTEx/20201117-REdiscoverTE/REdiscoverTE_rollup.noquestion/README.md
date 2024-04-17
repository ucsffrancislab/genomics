




Plotting a huge correlation table as a heatmap is proving impossible


Filtering rows and cols with at least one 0.8 or 0.9. Assuming there are no 1s



```BASH
zcat GENE_x_RE_all.correlation.tsv.gz | head -1 > GENE_x_RE_all.correlation.gt08.tsv
zgrep "0\.[89]" GENE_x_RE_all.correlation.tsv.gz >> GENE_x_RE_all.correlation.gt08.tsv 

cat GENE_x_RE_all.correlation.gt08.tsv | datamash transpose  | head -1 > GENE_x_RE_all.correlation.gt08.gt08.tsv
cat GENE_x_RE_all.correlation.gt08.tsv | datamash transpose  | grep "0\.[89]" >> GENE_x_RE_all.correlation.gt08.gt08.tsv

zcat GENE_x_RE_all.correlation.tsv.gz | head -1 > GENE_x_RE_all.correlation.gt09.tsv
zgrep "0\.9" GENE_x_RE_all.correlation.tsv.gz >> GENE_x_RE_all.correlation.gt09.tsv 

cat GENE_x_RE_all.correlation.gt09.tsv | datamash transpose  | head -1 > GENE_x_RE_all.correlation.gt09.gt09.tsv
cat GENE_x_RE_all.correlation.gt09.tsv | datamash transpose  | grep "0\.9" >> GENE_x_RE_all.correlation.gt09.gt09.tsv

R
```


```R

c=read.table('GENE_x_RE_all.correlation.gt08.gt08.tsv',sep="\t",row.names=1,header=TRUE)

dim(c)
#[1] 1061 7668


c=read.table('GENE_x_RE_all.correlation.gt09.gt09.tsv',sep="\t",row.names=1,header=TRUE)

dim(c)
#[1]  396 1774





library(ggcorrplot)

plt = ggcorrplot(c, outline.color = "white", lab=TRUE)


```



