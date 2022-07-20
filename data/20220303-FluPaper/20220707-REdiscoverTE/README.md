
#	REdiscoverTE


```
REdiscoverTE_array_wrapper.bash

REdiscoverTE_rollup.bash

#	WAIT

REdiscoverTE_rollup_merge.Rscript 

awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"}{print $0,$1,$2,$3,$4}' > metadata.csv

awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","ancestry"}{print $0,$4}' > metadata.ancestry.csv

```


```

 
for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done






module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/results_ancestry
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.ancestry.csv ${outdir} id ancestry NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.ancestry.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.ancestry.csv ${outdir} id ancestry NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.ancestry.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done



module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/results_celltype
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id celltype NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.celltype.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id celltype NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.celltype.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done



module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/results_infection
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id infection NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.infection.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id infection NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.infection.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done
```






















```
module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/rmarkdown_results_ancestry
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.ancestry.csv ${outdir} id ancestry NA NA ${i} 0.9 0.5 k${k} 3> ${outdir}/k${k}.ancestry.${iname}.alpha_0.9.logFC_0.5.html
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.ancestry.csv ${outdir} id ancestry NA NA ${i} 0.5 0.2 k${k} 3> ${outdir}/k${k}.ancestry.${iname}.alpha_0.5.logFC_0.2.html
done

module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/rmarkdown_results_celltype
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.csv ${outdir} id celltype NA NA ${i} 0.9 0.5 k${k} 3> ${outdir}/k${k}.celltype.${iname}.alpha_0.9.logFC_0.5.html
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.csv ${outdir} id celltype NA NA ${i} 0.5 0.2 k${k} 3> ${outdir}/k${k}.celltype.${iname}.alpha_0.5.logFC_0.2.html
done

module load r
k=15
indir=${PWD}/rollup/
outdir=${PWD}/rmarkdown_results_infection
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.csv ${outdir} id infection NA NA ${i} 0.9 0.5 k${k} 3> ${outdir}/k${k}.infection.${iname}.alpha_0.9.logFC_0.5.html
~/github/ucsffrancislab/genomics/development/REdiscoverTE_EdgeR_rmarkdown_to_fd3.R ${indir} ${PWD}/metadata.csv ${outdir} id infection NA NA ${i} 0.5 0.2 k${k} 3> ${outdir}/k${k}.infection.${iname}.alpha_0.5.logFC_0.2.html
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

















