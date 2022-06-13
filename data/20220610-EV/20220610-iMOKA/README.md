
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



```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.tsv
```


```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/16 --k 16

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/21 --k 21

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/31 --k 31
```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrentControl"
curl -netrc -X MKCOL "${BOX}/"
for d in 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrentControl/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${d}/aggregated.json "${BOX}/"
curl -netrc -T ${d}/output.json "${BOX}/"
done
```





```
mkdir PrimaryRecurrentControl
mv source.tsv iMOKA.20220610205* 16 21 31 PrimaryRecurrentControl/
cat PrimaryRecurrentControl/source.tsv | grep -vs control > source.tsv
mkdir 16 21 31
ln -s ../PrimaryRecurrentControl/16/preprocess 16/preprocess
ln -s ../PrimaryRecurrentControl/21/preprocess 21/preprocess
ln -s ../PrimaryRecurrentControl/31/preprocess 31/preprocess
cat PrimaryRecurrentControl/16/create_matrix.tsv | grep -vs control > 16/create_matrix.tsv
cat PrimaryRecurrentControl/21/create_matrix.tsv | grep -vs control > 21/create_matrix.tsv
cat PrimaryRecurrentControl/31/create_matrix.tsv | grep -vs control > 31/create_matrix.tsv
```



```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/16 --k 16 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/21 --k 21 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/31 --k 31 --step create
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrent"
curl -netrc -X MKCOL "${BOX}/"
for d in 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrent/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${d}/aggregated.json "${BOX}/"
curl -netrc -T ${d}/output.json "${BOX}/"
done
```

