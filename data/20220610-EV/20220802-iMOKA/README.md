
#	20220610-EV/20220802-iMOKA



Link raw files to replace .fagz to .fasta.gz
```
DIR=/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out
RAW=${PWD}/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz ; do
l=$( basename $f .quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz )
ln -s $f ${RAW}/${l}.fasta.gz
done
```

```
ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv
```


Prepare runs

```
DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( /SFHH/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.all.tsv


DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrentcontrol.tsv


DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrent.tsv


DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $7 == "Panattoni" ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.panattoni.tsv


DIR=${PWD}/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.fasta.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) | sed -E 's/Primary|Recurrent/tumor/' > source.tumorcontrol.tsv
```











Preprocess all so can predict later

```
mkdir -p ${PWD}/logs

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA_just_preprocess.${date}.out" --time=60 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA_just_preprocess.bash --dir ${PWD}/11 --k 11 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA_just_preprocess.${date}.out" --time=60 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA_just_preprocess.bash --dir ${PWD}/16 --k 16 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA_just_preprocess.${date}.out" --time=60 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA_just_preprocess.bash --dir ${PWD}/21 --k 21 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA_just_preprocess.${date}.out" --time=60 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA_just_preprocess.bash --dir ${PWD}/31 --k 31 --source_file ${PWD}/source.all.tsv
```











WAIT UNTIL COMPLETE

```
chmod -w ??/preprocess/*/*bin
```

Create models


```
mkdir -p PrimaryRecurrent/11
mkdir -p PrimaryRecurrent/16
mkdir -p PrimaryRecurrent/21
mkdir -p PrimaryRecurrent/31
ln -s ../../11/preprocess PrimaryRecurrent/11/preprocess
ln -s ../../16/preprocess PrimaryRecurrent/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrent/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrent/31/preprocess
cat 11/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrent/11/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrent/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrent/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrent/31/create_matrix.tsv


mkdir -p PrimaryRecurrentControl/11
mkdir -p PrimaryRecurrentControl/16
mkdir -p PrimaryRecurrentControl/21
mkdir -p PrimaryRecurrentControl/31
ln -s ../../11/preprocess PrimaryRecurrentControl/11/preprocess
ln -s ../../16/preprocess PrimaryRecurrentControl/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrentControl/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrentControl/31/preprocess
cat 11/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrentControl/11/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrentControl/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrentControl/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrentControl/31/create_matrix.tsv


mkdir -p TumorControl/11
mkdir -p TumorControl/16
mkdir -p TumorControl/21
mkdir -p TumorControl/31
ln -s ../../11/preprocess TumorControl/11/preprocess
ln -s ../../16/preprocess TumorControl/16/preprocess
ln -s ../../21/preprocess TumorControl/21/preprocess
ln -s ../../31/preprocess TumorControl/31/preprocess
cat 11/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/11/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/31/create_matrix.tsv
```




```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/11 --k 11 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrent.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/11 --k 11 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv



date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/11 --k 11 --step create --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/16 --k 16 --step create --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/21 --k 21 --step create --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/31 --k 31 --step create --source_file ${PWD}/source.tumorcontrol.tsv
```






















```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/11 --k 11 --step reduce --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/16 --k 16 --step reduce --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/21 --k 21 --step reduce --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/31 --k 31 --step reduce --source_file ${PWD}/source.primaryrecurrent.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/11 --k 11 --step reduce --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/16 --k 16 --step reduce --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/21 --k 21 --step reduce --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/31 --k 31 --step reduce --source_file ${PWD}/source.primaryrecurrentcontrol.tsv



date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/11 --k 11 --step reduce --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/16 --k 16 --step reduce --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/21 --k 21 --step reduce --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/TumorControl/31 --k 31 --step reduce --source_file ${PWD}/source.tumorcontrol.tsv
```



































Predict those not used in models


```
predict.bash
```


```
matrices_of_select_kmers.bash
```


```
upload.bash
```










```
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img iMOKA_core create -i 11/create_matrix.tsv -o 11/create_matrix.json

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA_dump.bash 
```













```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA_just_preprocess.${date}.out" --time=60 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA_just_preprocess.bash --dir ${PWD}/16 --k 16 --source_file ${PWD}/source.testse.tsv






export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img iMOKA_core create -i 16/create_matrix.tsv -o 16/create_matrix.json





date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA_dump.bash 
```




