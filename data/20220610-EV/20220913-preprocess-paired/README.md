

#	20220913

Aligning PAIRED to hg38
Missed this in the last run.



```
ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv

ln -s /c4/home/gwendt/github/ucsffrancislab/genomics/data/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/bowtie2_nonrandomized.bash



mkdir -p ${PWD}/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="${PWD}/logs/preprocess.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/array_wrapper.bash



for f in out/*format.umi.t1.t2.t3.notphiX.readname.R1.fastq.gz ; do
echo $f
b=${f%.R1.fastq.gz}
echo $b
if [ -f ${b}.hg38.bam ] ; then
echo "exists"
else
echo "Missing"
chmod -w ${b}.hg38.*
/bin/rm -rf ${b}.hg38.*
fi
done
```





```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```



