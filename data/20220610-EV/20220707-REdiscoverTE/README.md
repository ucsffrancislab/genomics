
#	REdiscoverTE


```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv

REdiscoverTE_array_wrapper.bash

REdiscoverTE_rollup.bash

#REdiscoverTE_rollup_merge.Rscript #	<-- unneeded here

ln -s rollup.00 rollup/rollup.merged 
for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done

upload.bash
```


```
ID,Well,LabID1,Agilent Sample Number,LabID2,
Source,Analysis,case/control status,timepoint,Study,
Gender ,Age,run type:,Index5,Index 5 seq,"i5 full sequence (3' adapter, i5 index, 5' adapter)",Index7,idex 7 seq,"i7 full sequence (3' adapter, i7 index, 5' adapter)",oligo dt structure
```


```
awk -F, '( NR==1 || $7 =="case control")' metadata.csv > metadata.case_control.csv

module load r
k=15
indir=${PWD}/rollup
outdir=${PWD}/results_case_control_timepoint
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.csv ${outdir} ID timepoint NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.timepoint.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.csv ${outdir} ID timepoint NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.timepoint.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done


"case/control status" likely a problem column name. using "status"

awk 'BEGIN{FS=OFS=","}( NR==1 ){print $1,"status"}( $7 == "case control"){print $1,$8}' metadata.csv > metadata.case_control.status.csv

module load r
k=15
indir=${PWD}/rollup
outdir=${PWD}/results_case_control_status
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.status.csv ${outdir} ID status NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.status.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.status.csv ${outdir} ID status NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.status.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done



awk -F, '( NR==1 || ( $7 == "case control" && $8 =="GBM" ) )' metadata.csv > metadata.case_control.GBM.csv

module load r
k=15
indir=${PWD}/rollup
outdir=${PWD}/results_case_control_GBM
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 ${indir}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.GBM.csv ${outdir} ID timepoint NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.GBM.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.case_control.GBM.csv ${outdir} ID timepoint NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.GBM.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done



```




















---

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


