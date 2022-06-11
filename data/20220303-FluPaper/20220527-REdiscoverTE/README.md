
#	REdiscoverTE

See /c4/home/gwendt/github/ucsffrancislab/genomics/data/20220303-FluPaper/20220419-REdiscoverTE








`ln -s ../20220421-SingleCell/mergedAllCells_withCellTypeIdents_CLEAN.csv`


loop over author selected / our souporcell / seurat filtered barcodes?


link them in the format `B1_c1_AAACCTGGTCGTCTTC`

This is gonna be about 220,000 or 230,000 fastq files!!!!!



Use array job to loop over batches



Run REdiscoverTE on each

Rollup

DE by ancestry, infection status, cell type



```
REdiscoverTE_array_wrapper.bash

REdiscoverTE_rollup.bash

REdiscoverTE_rollup_merge.Rscript 
```






```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220527-REdiscoverTE"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T mergedAllCells_withCellTypeIdents_CLEAN.filtered.B15.csv "${BOX}/"
curl -netrc -T /francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220527-REdiscoverTE/rollup"
curl -netrc -X MKCOL "${BOX}/"

#for d in rollup/rollup.* ; do
#BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220527-REdiscoverTE/${d}"
#curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220527-REdiscoverTE/rollup"
for f in rollup/rollup.merged/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```


