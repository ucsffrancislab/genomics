
#	20220610-EV/20220915-iMOKA

Quality 15 filtered, paired-end R1 alignment



Link raw files as fasta.gz
```
DIR=/francislab/data1/working/20220610-EV/20220831-preprocess/out
RAW=${PWD}/raw
mkdir -p $RAW
for f in ${DIR}/*.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.rx.marked.deduped.fa.gz ; do
l=$( basename $f .quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.rx.marked.deduped.fa.gz )
ln -s $f ${RAW}/${l}.fasta.gz
done



ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv
```
Link metadata for uploading.


Prepare runs

```
DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( /SFHH/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.all.tsv



#	DIR=${PWD}/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrentcontrol.tsv
#	
#	
#	DIR=${PWD}/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrent.tsv
#	
#	
#	DIR=${PWD}/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=",";OFS="\t"}( $7 == "Panattoni" ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.panattoni.tsv
#	
#	
#	DIR=${PWD}/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) | sed -E 's/Primary|Recurrent/tumor/' > source.tumorcontrol.tsv

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



#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.11.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/11 --k 11 --step create --source_file ${PWD}/source.primaryrecurrent.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.16.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrent.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.21.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrent.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.31.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrent.tsv
#	
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.11.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/11 --k 11 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.16.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.21.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.31.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv
#	
#	
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.11.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/TumorControl/11 --k 11 --step create --source_file ${PWD}/source.tumorcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.16.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/TumorControl/16 --k 16 --step create --source_file ${PWD}/source.tumorcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.21.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/TumorControl/21 --k 21 --step create --source_file ${PWD}/source.tumorcontrol.tsv
#	
#	date=$( date "+%Y%m%d%H%M%S%N" )
#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.31.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/TumorControl/31 --k 31 --step create --source_file ${PWD}/source.tumorcontrol.tsv
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
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA_dump.bash --k 16 --dir ${PWD}/16
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA_dump.bash --dir ${PWD}/16

```
 



```
./upload.bash
```
