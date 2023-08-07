
#	20220610-EV/20230804-cutadapt-test


This is just to compare quality trimming



```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  -U 21 \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}" \
  -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -a CTGTCTCTTATACACATCTC \
  -A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}" \
  -A CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -A CTGTCTCTTATACACATCTC \
  /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz 

```

```
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \

```


```
grep "^Quality-trimmed:" /francislab/data1/working/20220610-EV/20230804-cutadapt-test/out/*cutadapt_summary.log | awk '{print $NF}' | sed 's/[(%)]//g' | tee >(datamash max 1 | awk '{print "Max:"$1}' ) >( datamash mean 1 | awk '{print "Mean:"$1}') >(datamash median 1  | awk '{print "Median:"$1}') >(datamash q1 1 | awk '{print "Q1:"$1}' ) >(datamash q3 1 | awk '{print "Q3:"$1}' ) >(datamash iqr 1 | awk '{print "iqr:"$1}' ) > /dev/null
iqr:1.1
Q3:5.2
Q1:4.1
Median:4.6
Mean:4.7151162790698
Max:8.6

```


```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out_quality_only \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz 

```

```

control_ids=$( grep ",SE,case control,control,control" /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv | cut -d, -f1 | paste -sd, )

files=$( eval ls -1 out/{${control_ids}}_*cutadapt_summary.log 2> /dev/null )

grep "^Quality-trimmed:" $files | awk '{print $NF}' | sed 's/[(%)]//g' | tee >(datamash max 1 | awk '{print "Max:"$1}' ) >( datamash mean 1 | awk '{print "Mean:"$1}') >(datamash median 1  | awk '{print "Median:"$1}') >(datamash q1 1 | awk '{print "Q1:"$1}' ) >(datamash q3 1 | awk '{print "Q3:"$1}' ) >(datamash iqr 1 | awk '{print "iqr:"$1}' ) > /dev/null

```






