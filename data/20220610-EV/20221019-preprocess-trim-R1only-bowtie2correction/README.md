

#	20221019

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing


My modifications to bowtie2 to return the first match rather than a random selection isn't working as expected.
Trying to fix.




```
ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv

ln -s /c4/home/gwendt/github/ucsffrancislab/genomics/data/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/bowtie2_nonrandomized.bash



mkdir -p ${PWD}/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="${PWD}/logs/preprocess.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/array_wrapper.bash




scontrol update ArrayTaskThrottle=4 JobId=874115
```





```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

./umi_dedup_report.bash > umi_dedup_report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' umi_dedup_report.md > umi_dedup_report.csv
```




```
dir1=/francislab/data1/working/20220610-EV/20221010-preprocess-trim-R1only-correction/out
dir2=/francislab/data1/working/20220610-EV/20221019-preprocess-trim-R1only-bowtie2correction/out
c1=$( cat ${dir1}/*.format.umi.quality15.t2.t3.hg38.name.marked.bam.f1024.aligned_count.txt | awk '{s+=$1}END{print s}' )
c2=$( cat ${dir2}/*.format.umi.quality15.t2.t3.hg38.name.marked.bam.f1024.aligned_count.txt | awk '{s+=$1}END{print s}' )
diff=$((c2-c1))
echo $((100*diff/c1))
```





