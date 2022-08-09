
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
DIR=/francislab/data1/working/20220610-EV/20220610-preprocessing/out
RAW=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw-10
mkdir -p $RAW
for f in ${DIR}/*.quality.t1-10.t3-10.notphiX.?.fqgz ; do
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

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw-10
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( /SFHH/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.all-10.tsv
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
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) | sed -E 's/Primary|Recurrent/tumor/' > source.tumorcontrol.tsv
```

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) | sed -E 's/Primary|control/nonRecurrent/' > source.recurrentnonrecurrent.tsv
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

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw-10
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrentcontrol-10.tsv
```

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw-10
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) | sed -E 's/Primary|Recurrent/tumor/' > source.tumorcontrol-10.tsv
```

```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw-10
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.primaryrecurrent-10.tsv
```


Preprocess all so can predict later

```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/16 --k 16 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/21 --k 21 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/31 --k 31 --source_file ${PWD}/source.all.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=360 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/10 --k 10 --source_file ${PWD}/source.all-10.tsv
```




WAIT UNTIL COMPLETE

```
chmod -w ??/preprocess/*/*bin
```

Create models


```
mkdir -p PrimaryRecurrent/10
mkdir -p PrimaryRecurrent/16
mkdir -p PrimaryRecurrent/21
mkdir -p PrimaryRecurrent/31
ln -s ../../10/preprocess PrimaryRecurrent/10/preprocess
ln -s ../../16/preprocess PrimaryRecurrent/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrent/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrent/31/preprocess
cat 10/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrent/10/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrent/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrent/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrent/31/create_matrix.tsv
```




```
mkdir -p PrimaryRecurrentControl/10
mkdir -p PrimaryRecurrentControl/16
mkdir -p PrimaryRecurrentControl/21
mkdir -p PrimaryRecurrentControl/31
ln -s ../../10/preprocess PrimaryRecurrentControl/10/preprocess
ln -s ../../16/preprocess PrimaryRecurrentControl/16/preprocess
ln -s ../../21/preprocess PrimaryRecurrentControl/21/preprocess
ln -s ../../31/preprocess PrimaryRecurrentControl/31/preprocess
cat 10/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrentControl/10/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrentControl/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrentControl/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > PrimaryRecurrentControl/31/create_matrix.tsv
```




```
mkdir -p TumorControl/10
mkdir -p TumorControl/16
mkdir -p TumorControl/21
mkdir -p TumorControl/31
ln -s ../../10/preprocess TumorControl/10/preprocess
ln -s ../../16/preprocess TumorControl/16/preprocess
ln -s ../../21/preprocess TumorControl/21/preprocess
ln -s ../../31/preprocess TumorControl/31/preprocess
cat 10/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/10/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/31/create_matrix.tsv
```




```
mkdir -p RecurrentNonrecurrent/10
mkdir -p RecurrentNonrecurrent/16
mkdir -p RecurrentNonrecurrent/21
mkdir -p RecurrentNonrecurrent/31
ln -s ../../10/preprocess RecurrentNonrecurrent/10/preprocess
ln -s ../../16/preprocess RecurrentNonrecurrent/16/preprocess
ln -s ../../21/preprocess RecurrentNonrecurrent/21/preprocess
ln -s ../../31/preprocess RecurrentNonrecurrent/31/preprocess
cat 10/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|control/Nonrecurrent/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > RecurrentNonrecurrent/10/create_matrix.tsv
cat 16/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|control/Nonrecurrent/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > RecurrentNonrecurrent/16/create_matrix.tsv
cat 21/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|control/Nonrecurrent/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > RecurrentNonrecurrent/21/create_matrix.tsv
cat 31/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | sed -E 's/Primary|control/Nonrecurrent/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > RecurrentNonrecurrent/31/create_matrix.tsv
```




```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/10 --k 10 --step create --source_file ${PWD}/source.primaryrecurrent-10.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrent/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrent.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent_control.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/10 --k 10 --step create --source_file ${PWD}/source.primaryrecurrentcontrol-10.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrent_control.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/16 --k 16 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrentcontrol.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/21 --k 21 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.primary_recurrentcontrol.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/PrimaryRecurrentControl/31 --k 31 --step create --source_file ${PWD}/source.primaryrecurrentcontrol.tsv


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/TumorControl/10 --k 10 --step create --source_file ${PWD}/source.tumorcontrol-10.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/TumorControl/16 --k 16 --step create --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/TumorControl/21 --k 21 --step create --source_file ${PWD}/source.tumorcontrol.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/TumorControl/31 --k 31 --step create --source_file ${PWD}/source.tumorcontrol.tsv




date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.recurrent_nonrecurrent.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/RecurrentNonrecurrent/16 --k 16 --step create --source_file ${PWD}/source.recurrentnonrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.recurrent_nonrecurrent.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/RecurrentNonrecurrent/21 --k 21 --step create --source_file ${PWD}/source.recurrentnonrecurrent.tsv

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.recurrent_nonrecurrent.${date}.out" --time=720 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/RecurrentNonrecurrent/31 --k 31 --step create --source_file ${PWD}/source.recurrentnonrecurrent.tsv
```















Upload results




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrentControl"
curl -netrc -X MKCOL "${BOX}/"
for d in 10 16 21 31 ; do
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
for d in 10 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-PrimaryRecurrent/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T PrimaryRecurrent/${d}/aggregated.json "${BOX}/"
curl -netrc -T PrimaryRecurrent/${d}/output.json "${BOX}/"
done
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-TumorControl"
curl -netrc -X MKCOL "${BOX}/"
for d in 10 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-TumorControl/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T TumorControl/${d}/aggregated.json "${BOX}/"
curl -netrc -T TumorControl/${d}/output.json "${BOX}/"
done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-RecurrentNonrecurrent"
curl -netrc -X MKCOL "${BOX}/"
for d in 10 16 21 31 ; do
echo $d
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220610-iMOKA-RecurrentNonrecurrent/${d}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T RecurrentNonrecurrent/${d}/aggregated.json "${BOX}/"
curl -netrc -T RecurrentNonrecurrent/${d}/output.json "${BOX}/"
done
```





Predict those not used in models


```
predict.bash
```





SFHH011CD, SFHH011CE, SFHH011CF, SFHH011CG
Run Panattoni samples through the GBMWT vs nonGBMWT models from 
/francislab/data2/working/20210428-EV/20210706-iMoka


```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $7 == "Panattoni" ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.panattoni.tsv
```

```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/15 --k 15 --source_file ${PWD}/source.panattoni.tsv
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/20 --k 20 --source_file ${PWD}/source.panattoni.tsv
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/25 --k 25 --source_file ${PWD}/source.panattoni.tsv
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/30 --k 30 --source_file ${PWD}/source.panattoni.tsv
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/35 --k 35 --source_file ${PWD}/source.panattoni.tsv
```

```
predict_panattoni_20210706.bash
```







[gwendt@c4-dev2 /francislab/data1/working/20220610-EV/20220610-iMOKA]$ tail -20 ../20220802-iMOKA/README.md 









```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G /francislab/data1/working/20220610-EV/20220610-iMOKA/iMOKA_just_preprocess.bash --dir /francislab/data1/working/20220610-EV/20220610-iMOKA/16 --k 16 --source_file ${PWD}/source.testse.tsv



export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img iMOKA_core create -i 16/create_matrix.tsv -o 16/create_matrix.json

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.dump.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA_dump.bash 
```

