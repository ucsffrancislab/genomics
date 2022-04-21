
#	REdiscoverTE





```
ll /francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out/HMN*z | wc -l
178
```

```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-178%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083
```



Rollup all samples or just flu or just NI
```
./REdiscoverTE_rollup.bash 
./REdiscoverTE_rollup_NI.bash 
./REdiscoverTE_rollup_flu.bash 
```



`/francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt`


These csvs have a header line with 1 less column header. Inserting it as "id"
```
sed '1s/^/id,/' /francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt | awk 'BEGIN{FS=OFS=","}{print $1,$2,$6,$12}' > metadata.csv
```

Looks like ...

```
id,indiv_ID,infection_status,ethnicity
HMN83551_NI,HMN83551,NI,EUR
HMN83552_NI,HMN83552,NI,EUR
HMN83553_flu,HMN83553,flu,EUR
HMN83554_flu,HMN83554,flu,EUR
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T metadata.csv "${BOX}/"

for d in rollup* ; do
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE/${d}"
curl -netrc -X MKCOL "${BOX}/"
for f in ${d}/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done ; done
```





```
module load r

indir=${PWD}/rollup
for column in infection_status ethnicity ; do
outdir=${PWD}/results_${column}
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.${column}.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.${column}.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done ; done










for infection_status in NI flu ; do
indir=${PWD}/rollup_${infection_status}
for column in ethnicity ; do
outdir=${PWD}/results_${infection_status}_${column}
mkdir -p ${outdir}
for i in $( seq 9 ); do
iname=$( ls -1 rollup_${infection_status}/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.${column}.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.${column}.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done ; done ; done

```






TESTING

```
module load r

indir=${PWD}/rollup

for ethnicity in AFR EUR ; do
for infection_status in flu NI ; do
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
k=15

outdir=${PWD}/test/results_${infection_status}_ethnicity
mkdir -p ${outdir}
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata_${infection_status}.csv ${outdir} id ethnicity NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.ethnicity.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata_${infection_status}.csv ${outdir} id ethnicity NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.ethnicity.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf

outdir=${PWD}/test/results_${ethnicity}_infection_status
mkdir -p ${outdir}
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata_${ethnicity}.csv ${outdir} id infection_status NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf ${outdir}/k${k}.infection_status.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${indir} ${PWD}/metadata_${ethnicity}.csv ${outdir} id infection_status NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf ${outdir}/k${k}.infection_status.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf


done ; done ; done

```



















```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE"
curl -netrc -X MKCOL "${BOX}/"


for dir in test/* ; do
dir=$( basename $dir )
echo $dir
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE/${dir}"
curl -netrc -X MKCOL "${BOX}/"
for f in test/${dir}/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done ; done



for column in infection_status ethnicity ; do
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE/results_${column}"
curl -netrc -X MKCOL "${BOX}/"
for f in results_${column}/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done ; done

for infection_status in NI flu ; do
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220303-FluPaper/20220419-REdiscoverTE/results_${infection_status}_ethnicity"
curl -netrc -X MKCOL "${BOX}/"
for f in results_${infection_status}_ethnicity/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done ; done





```




