
#	REdiscoverTE


```
ls -1 /francislab/data1/working/PRJNA736483/20220310-bamtofastq/out/*_R1.fastq.gz | wc -l
89
```

```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-89%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083
```



```
./REdiscoverTE_rollup.bash 
```

















-----


From 20211208-EV/20211216-REdiscoverTE


Link raw files to replace .fqgz to .fastq.gz
```
DIR=/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi
RAW=/francislab/data1/working/20211208-EV/20211216-REdiscoverTE/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.format.t1.t3.notphiX.notviral.nothg38.1.fqgz ; do
ln -s $f ${RAW}/$( basename $f .quality.format.t1.t3.notphiX.notviral.nothg38.1.fqgz ).R1.fastq.gz
done
for f in ${DIR}/*.quality.format.t1.t3.notphiX.notviral.nothg38.2.fqgz ; do
ln -s $f ${RAW}/$( basename $f .quality.format.t1.t3.notphiX.notviral.nothg38.2.fqgz ).R2.fastq.gz
done

```

```
mkdir -p /francislab/data1/working/20211208-EV/20211216-REdiscoverTE/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="REdiscoverTE" --output="/francislab/data1/working/20211208-EV/20211216-REdiscoverTE/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20211208-EV/20211216-REdiscoverTE/REdiscoverTE_array_wrapper.bash
```


```
./REdiscoverTE_rollup.bash 
```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE"
curl -netrc -X MKCOL "${BOX}/"

for f in rollup/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done

```

```
echo "id,cc" > metadata.csv
awk 'BEGIN{FS=OFS=","}($5 ~ /(IPMN|MCN)/){print $1,$5}' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv >> metadata.csv
```



NO 7 ( RE_all_repClass_1_raw_counts.RDS ) here or in previous runs?
Removing from R script expections so now 1-9 instead of 1-10
```
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/metadata.csv ${PWD}/results id cc NA NA 6 0.5 0.2 k15
```



```
module load r

mkdir -p ${PWD}/results
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/metadata.csv ${PWD}/results id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf results/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/metadata.csv ${PWD}/results id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf results/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/results"
curl -netrc -X MKCOL "${BOX}/"

for f in results/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```



```
module load r

mkdir -p ${PWD}/high_low_1
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low.csv ${PWD}/high_low_1 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf high_low/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low.csv ${PWD}/high_low_1 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf high_low_1/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/high_low_1"
curl -netrc -X MKCOL "${BOX}/"

for f in high_low.csv high_low_1/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```





```
module load r

mkdir -p ${PWD}/high_low_plus_1
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low_plus.csv ${PWD}/high_low_plus_1 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf high_low_plus/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low_plus.csv ${PWD}/high_low_plus_1 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf high_low_plus_1/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/high_low_plus_1"
curl -netrc -X MKCOL "${BOX}/"

for f in high_low_plus.csv high_low_plus_1/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```








```
module load r

mkdir -p ${PWD}/high_low_2
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low.csv ${PWD}/high_low_2 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf high_low/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low.csv ${PWD}/high_low_2 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf high_low_2/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/high_low_2"
curl -netrc -X MKCOL "${BOX}/"

for f in high_low.csv high_low_2/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```



```
module load r

mkdir -p ${PWD}/high_low_plus_2
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low_plus.csv ${PWD}/high_low_plus_2 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf high_low_plus_2/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/high_low_plus.csv ${PWD}/high_low_plus_2 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf high_low_plus_2/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/high_low_plus_2"
curl -netrc -X MKCOL "${BOX}/"

for f in high_low_plus.csv high_low_plus_2/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```




```
module load r

mkdir -p ${PWD}/plot_1
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/plot.csv ${PWD}/plot_1 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf plot_1/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/plot.csv ${PWD}/plot_1 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf plot_1/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/plot_1"
curl -netrc -X MKCOL "${BOX}/"

for f in plot.csv plot_1/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```




```
module load r

mkdir -p ${PWD}/plot_2
for i in $( seq 9 ); do
iname=$( ls -1 rollup/*_1_raw_counts.RDS | xargs -I% basename % _1_raw_counts.RDS | sed -n ${i}p )
for k in 15 ; do
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/plot_2.csv ${PWD}/plot_2 id cc NA NA ${i} 0.9 0.5 k${k}
mv Rplots.pdf plot_2/k${k}.cc.${iname}.alpha_0.9.logFC_0.5.NoQuestion.plots.pdf
./REdiscoverTE_EdgeR.R ${PWD}/rollup ${PWD}/plot_2.csv ${PWD}/plot_2 id cc NA NA ${i} 0.5 0.2 k${k}
mv Rplots.pdf plot_2/k${k}.cc.${iname}.alpha_0.5.logFC_0.2.NoQuestion.plots.pdf
done ; done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211216-REdiscoverTE/plot_2"
curl -netrc -X MKCOL "${BOX}/"

for f in plot_2.csv plot_2/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```


