
#	REdiscoverTE





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


