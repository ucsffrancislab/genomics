

#	20220928

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING




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
```


