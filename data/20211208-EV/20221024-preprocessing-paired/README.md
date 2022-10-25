

#	20211208-EV/20221024-preprocessing-paired

New preprocessing based on 20220610 / 20221019 preprocessing paired


Quality TRIMMING rather than FILTERING



```
ln -s "/francislab/data1/raw/20211208-EV/adapter and indexes for QB3_NovaSeq SP 150PE_SFHH009 S Francis_11-16-2021.csv" metadata.csv





mkdir -p ${PWD}/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="preproc" --output="${PWD}/logs/preprocess.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/array_wrapper.bash




scontrol update ArrayTaskThrottle=4 JobId=874115
```



```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

```




