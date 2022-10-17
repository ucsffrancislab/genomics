
#	#	SQuIRE

https://github.com/wyang17/SQuIRE


First actually try

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing





```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv
```




```

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%1 --job-name="SQuIRE" --output="${PWD}/logs/SQuIRE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/SQuIRE_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

```


```
singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Call -h
usage: squire Call [-h] -1 <str1,str2> or <*str*> -2 <str1,str2> or <*str*> -A
                   <str> -B <str> [-i <folder>] [-o <folder>] [-s] [-p <int>]
                   [-N <str>] [-f <str>] [-t] [-v]

Arguments:
  -h, --help            show this help message and exit
  -1 <str1,str2> or <*str*>, --group1 <str1,str2> or <*str*>
                        List of basenames for group1 (Treatment) samples, can
                        also provide string pattern common to all group1
                        basenames
  -2 <str1,str2> or <*str*>, --group2 <str1,str2> or <*str*>
                        List of basenames for group2 (Control) samples, can
                        also provide string pattern common to all group2
                        basenames
  -A <str>, --condition1 <str>
                        Name of condition for group1
  -B <str>, --condition2 <str>
                        Name of condition for group2
  -i <folder>, --count_folder <folder>
                        Folder location of outputs from SQuIRE Count
                        (optional, default = 'squire_count')
  -o <folder>, --call_folder <folder>
                        Destination folder for output files (optional;
                        default='squire_call')
  -s, --subfamily       Compare TE counts by subfamily. Otherwise, compares
                        TEs at locus level (optional; default=False)
  -p <int>, --pthreads <int>
                        Launch <int> parallel threads(optional; default='1')
  -N <str>, --projectname <str>
                        Basename for project, default='SQuIRE'
  -f <str>, --output_format <str>
                        Output figures as html or pdf
  -t, --table_only      Output count table only, don't want to perform
                        differential expression with DESeq2
  -v, --verbosity       Want messages and runtime printed to stderr (optional;
                        default=False)
```






```
awk 'BEGIN{FS=",";OFS="\t"}( ( $9 == "Test-SE" ) || ( $9 == "Primary" && $11 == "M" ) ){print $1,$9}' metadata.csv
```


```

date=$( date "+%Y%m%d%H%M%S%N" )
projectname=PrimaryvTest
group1=$( awk 'BEGIN{FS=",";OFS="\t"}( $9 == "Primary" && $11 == "M" ){print $1}' metadata.csv | paste -sd, )
condition1=Primary
group2=$( awk 'BEGIN{FS=",";OFS="\t"}( $9 == "Test-SE" ){print $1}' metadata.csv | paste -sd, )
condition2=Test
output_format=pdf
mkdir -p ${PWD}/out/called/${projectname}
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=sqCall --time=20160 --nodes=1 --ntasks=64 --mem=495G \
  --output=${PWD}/logs/SQuIRE.Call.${projectname}.${date}.out \
  --wrap "singularity exec --bind /francislab,/scratch --no-home \
  /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Call \
    --count_folder ${PWD}/out/counted \
    --call_folder ${PWD}/out/called/${projectname} \
    --group1 $group1 --group2 $group2 --condition1 $condition1 --condition2 $condition2 --projectname $projectname \
    --pthreads 64 --output_format $output_format --verbosity"


```





