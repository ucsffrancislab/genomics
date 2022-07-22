
#	REdiscoverTE


```
REdiscoverTE_array_wrapper.bash

REdiscoverTE_rollup.bash

#	WAIT

REdiscoverTE_rollup_merge.bash

awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}{print $0,$1,$2,$3,$4}' > metadata.csv

awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","ancestry"}{print $0,$4}' > metadata.ancestry.csv

```


```

 
for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done

```





```
awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"} ( $3 ~ /^(B|CD4_T|CD8_T|NK|monocytes)$/ ){print $0,$1,$2,$3,$4}' > metadata.select.csv

awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}(( $3 == "NK" ) && ( $2 == "flu" )){print $0,$1,$2,$3,$4}' > metadata.NK.infected.csv
awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}(( $3 == "NK" ) && ( $2 == "NI"  )){print $0,$1,$2,$3,$4}' > metadata.NK.noninfected.csv

for celltype in B CD4_T CD8_T NK monocytes ; do echo $celltype
awk '{print $1}' rollup/REdiscoverTE.tsv | awk -v celltype=${celltype} 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}( $3 == celltype ){print $0,$1,$2,$3,$4}' > metadata.${celltype}.csv
done
awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}( $3 ~ "monocytes" ){print $0,$1,$2,$3,$4}' > metadata.all_monocytes.csv




./REdiscoverTE_EdgeR_rmarkdown.bash

```










