
#	20211208-EV/20220913-iMOKA



Link raw files to replace .fqgz to .fastq.gz

```
DIR=/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi
RAW=/francislab/data1/working/20211208-EV/20220913-iMOKA/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.format.t1.t3.notphiX.notviral.?.fqgz ; do
ln -s $f ${RAW}/$( basename $f .fqgz ).fastq.gz
done


ln -s /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv metadata.csv



```




sample - group - filelist

```
#DIR=/francislab/data1/working/20211208-EV/20220913-iMOKA/raw
#while read subject field; do
#f=$( ls ${DIR}/${subject}.quality.format.t1.t3.notphiX.notviral.?.fastq.gz 2> /dev/null | paste -sd";" )
#if [ -n "${f}" ] ; then
#echo -e "${subject}\t${field}\t${f}"
#fi
#done < <( awk 'BEGIN{FS=",";OFS="\t"}($5 ~ /(IPMN|MCN|PDAC)/){print $1,$5}' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv ) > source.tsv
```




```
DIR=/francislab/data1/working/20211208-EV/20220913-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.quality.format.t1.t3.notphiX.notviral.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=OFS="\t"}(NR>1){print $1,$5}' /francislab/data1/raw/20211208-EV/plot_2.csv ) > source.tsv



#	DIR=/francislab/data1/working/20211208-EV/20220913-iMOKA/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.quality.format.t1.t3.notphiX.notviral.?.fastq.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=OFS="\t"}(NR>1){if($5~/High|Low/)$5="HighLow";print $1,$5}' /francislab/data1/raw/20211208-EV/plot_2.csv ) > source.HLvA.tsv
#	
#	
#	
#	DIR=/francislab/data1/working/20211208-EV/20220913-iMOKA/raw
#	while read subject field; do
#	f=$( ls ${DIR}/${subject}.quality.format.t1.t3.notphiX.notviral.?.fastq.gz 2> /dev/null | paste -sd";" )
#	if [ -n "${f}" ] ; then
#	echo -e "${subject}\t${field}\t${f}"
#	fi
#	done < <( awk 'BEGIN{FS=OFS="\t"}(NR>1){if($5~/High|Adenocarcinoma/)$5="HighAdeno";print $1,$5}' /francislab/data1/raw/20211208-EV/plot_2.csv ) > source.HAvL.tsv
```




```
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/16 --k 16 --stopstep reduce

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/21 --k 21 --stopstep reduce

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/26 --k 26 --stopstep reduce

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/31 --k 31 --stopstep reduce








mkdir -p HAvL/16
ln -s ../../16/preprocess HAvL/16/preprocess
cat 16/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/16/create_matrix.tsv

mkdir -p HLvA/16
ln -s ../../16/preprocess HLvA/16/preprocess
cat 16/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/16/create_matrix.tsv



mkdir -p HAvL/21
ln -s ../../21/preprocess HAvL/21/preprocess
cat 21/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/21/create_matrix.tsv

mkdir -p HLvA/21
ln -s ../../21/preprocess HLvA/21/preprocess
cat 21/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/21/create_matrix.tsv



mkdir -p HAvL/26
ln -s ../../26/preprocess HAvL/26/preprocess
cat 26/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/26/create_matrix.tsv

mkdir -p HLvA/26
ln -s ../../26/preprocess HLvA/26/preprocess
cat 26/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/26/create_matrix.tsv



mkdir -p HAvL/31
ln -s ../../31/preprocess HAvL/31/preprocess
cat 31/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/31/create_matrix.tsv

mkdir -p HLvA/31
ln -s ../../31/preprocess HLvA/31/preprocess
cat 31/create_matrix.tsv | \grep -E "High|Low|Adenocarcinoma" | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/31/create_matrix.tsv



date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HAvL/16 --k 16 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HLvA/16 --k 16 --step create




date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HAvL/21 --k 21 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HLvA/21 --k 21 --step create




date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HAvL/26 --k 26 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HLvA/26 --k 26 --step create




date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HAvL/31 --k 31 --step create

date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=32 --mem=240G ${PWD}/iMOKA.bash --dir ${PWD}/HLvA/31 --k 31 --step create

```

