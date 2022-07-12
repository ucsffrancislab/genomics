
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


```






---


`ln -s ../20220421-SingleCell/mergedAllCells_withCellTypeIdents_CLEAN.csv`


loop over author selected / our souporcell / seurat filtered barcodes?


link them in the format `B1_c1_AAACCTGGTCGTCTTC`

This is gonna be about 220,000 or 230,000 fastq files!!!!!



Use array job to loop over batches



Run REdiscoverTE on each

Rollup

DE by ancestry, infection status, cell type






```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220707-REdiscoverTE"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T mergedAllCells_withCellTypeIdents_CLEAN.filtered.B15.csv "${BOX}/"
curl -netrc -T /francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220707-REdiscoverTE/rollup"
curl -netrc -X MKCOL "${BOX}/"

#for d in rollup/rollup.* ; do
#BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220707-REdiscoverTE/${d}"
#curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220707-REdiscoverTE/rollup"
for f in rollup/rollup.merged/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```


