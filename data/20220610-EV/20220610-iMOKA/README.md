
#	20220610-EV/20220610-iMOKA

/francislab/data1/working/20210428-EV/20211014-iMOKA/
/francislab/data1/working/20211208-EV/20211214-iMOKA


/c4/home/gwendt/github/ucsffrancislab/genomics/data/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/iMOKA_scratch.bash




Link raw files to replace .fqgz to .fastq.gz
```
DIR=/francislab/data1/working/20220610-EV/20220610-preprocessing/out
RAW=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.t1.t3.notphiX.?.fqgz ; do
l=$( basename $f .fqgz )
l=${l/.quality.t1.t3.notphiX/}
ln -s $f ${RAW}/${l}.fastq.gz
done
```


Prepare runs

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( /SFHH/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.all.tsv
```


WARNING MANUAL EDIT NEEDED TO RAW FILE
CHANGE "post recurrence" to "post-recurrence"





```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrentcontrol.tsv
```

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrent.tsv
```


Preprocess all so can predict later

```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/16 --k 16 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/21 --k 21 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/31 --k 31 --source_file ${PWD}/source.all.tsv
```




WAIT UNTIL COMPLETE

```
chmod -w ??/preprocess/*/*bin
```

Create models


```
mkdir -p PrimaryRecurrent/16
mkdir -p PrimaryRecurrent/21
mkdir -p PrimaryRecurrent/31
ln -s ../../16/preprocess PrimaryRecurrent/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrent/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrent/31/preprocess
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent" > PrimaryRecurrent/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent" > PrimaryRecurrent/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent" > PrimaryRecurrent/31/create_matrix.tsv
```




```
mkdir -p PrimaryRecurrentControl/16
mkdir -p PrimaryRecurrentControl/21
mkdir -p PrimaryRecurrentControl/31
ln -s ../../16/preprocess PrimaryRecurrentControl/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrentControl/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrentControl/31/preprocess
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" > PrimaryRecurrentControl/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" > PrimaryRecurrentControl/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" > PrimaryRecurrentControl/31/create_matrix.tsv
```




```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrent.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent_control.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrentcontrol.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrentcontrol.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv
```















Upload results




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrentControl"
curl -netrc -X MKCOL "${BOX}/"
for d in 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrentControl/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T PrimaryRecurrentControl/${d}/aggregated.json "${BOX}/"
curl -netrc -T PrimaryRecurrentControl/${d}/output.json "${BOX}/"
done
```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrent"
curl -netrc -X MKCOL "${BOX}/"
for d in 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrent/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T PrimaryRecurrent/${d}/aggregated.json "${BOX}/"
curl -netrc -T PrimaryRecurrent/${d}/output.json "${BOX}/"
done
```





Predict those not used in models


```
predict.bash
```
