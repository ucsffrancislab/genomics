
#	20211208-EV/20221026-iMOKA-paired ( 20221024-preprocessing-paired )

Quality 15 TRIMMED, paired-end, non-random


Link raw files as fasta.gz
```
DIR=/francislab/data1/working/20211208-EV/20221024-preprocessing-paired/out
RAW=${PWD}/raw
suffix=format.umi.quality15.t1.t2.t3.readname.hg38.tags.mated.marked.deduped.fa.gz
mkdir -p $RAW
for f in ${DIR}/*.${suffix} ; do
l=$( basename $f .${suffix} )
ln -s $f ${RAW}/${l}.fasta.gz
done


ln -s /francislab/data1/raw/20211208-EV/plot_2.csv metadata.csv


DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS="\t";OFS="\t"}( /SFHH/ ){print $1,$5}' metadata.csv ) > source.all.tsv

```






Preprocess all so can predict later
```
iMOKA_count.bash -k 11 -k 16 -k 21 -k 31
```






WAIT UNTIL COMPLETE and then Create models

```
chmod -w out/??/preprocess/*/*bin

./iMOKA_prep_create_matrices.bash
```







```
./iMOKA_actual.bash

```








Predict those not used in models


```
ssh d1

#./predict.bash
```


```
./matrices_of_select_kmers.bash
```



```
export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img iMOKA_core create -i out/16/create_matrix.tsv -o out/16/create_matrix.json



date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA_dump.bash --dir ${PWD}/out/16

```
 



```
nohup ./upload.bash > upload.out.txt 2>&1 &
```


