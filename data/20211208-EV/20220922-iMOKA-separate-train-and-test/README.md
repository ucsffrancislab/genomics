
#	20211208-EV/20220922-iMOKA-separate-train-and-test



Link raw files to replace .fqgz to .fastq.gz

```
DIR=/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi
RAW=${PWD}/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.format.t1.t3.notphiX.notviral.?.fqgz ; do
l=$(basename $f .fqgz)
l=${l/.quality*notphiX.notviral/}
ln -s $f ${RAW}/${l}.fastq.gz
done


ln -s /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv metadata.csv
```




sample - group - filelist

```
DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=OFS="\t"}(NR>1){print $1,$5}' /francislab/data1/raw/20211208-EV/plot_2.csv ) > source.tsv
```



Preprocess all so can predict later
```
./iMOKA_count.bash
```



WAIT UNTIL COMPLETE and then Create models

```
chmod -w ??/preprocess/*/*bin

./iMOKA_prep_create_matrices.bash
```




```
./iMOKA_actual.bash
```




Predict those not used in models


```
./predict.bash
```


```
./matrices_of_select_kmers.bash
```



```
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img iMOKA_core create -i 16/create_matrix.tsv -o 16/create_matrix.json

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA_dump.bash --dir ${PWD}/16

```
 



```
./upload.bash
```
