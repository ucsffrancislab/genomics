
#	20230726-Illumina-CystEV/20230801-cutadapt



```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}" \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
  -A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}" \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
  /francislab/data1/raw/20230726-Illumina-CystEV/fastq/*R1.fastq.gz

```




```
grep "^Quality-trimmed:" /francislab/data1/working/20230726-Illumina-CystEV/20230801-cutadapt/out/*cutadapt_summary.log | awk '{print $NF}' | sed 's/[(%)]//g' | tee >(datamash max 1 | awk '{print "Max:"$1}' ) >( datamash mean 1 | awk '{print "Mean:"$1}') >(datamash median 1  | awk '{print "Median:"$1}') >(datamash q1 1 | awk '{print "Q1:"$1}' ) >(datamash q3 1 | awk '{print "Q3:"$1}' ) >(datamash iqr 1 | awk '{print "iqr:"$1}' ) > /dev/null
iqr:2.3
Q3:6.8
Q1:4.5
Median:5.2
Mean:5.64
Max:9.7
```


```
kirkwood_ids=$(tail -n +2 /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.Kirkwood.csv  | cut -d, -f1 | paste -sd, )
files=$( eval ls -1 out/{${kirkwood_ids}}*cutadapt_summary.log 2> /dev/null )

grep "^Quality-trimmed:" $files | awk '{print $NF}' | sed 's/[(%)]//g' | tee >(datamash max 1 | awk '{print "Max:"$1}' ) >( datamash mean 1 | awk '{print "Mean:"$1}') >(datamash median 1  | awk '{print "Median:"$1}') >(datamash q1 1 | awk '{print "Q1:"$1}' ) >(datamash q3 1 | awk '{print "Q3:"$1}' ) >(datamash iqr 1 | awk '{print "iqr:"$1}' ) > /dev/null

```


```
se_control_ids=$( awk -F, '($8=="SE control"){print $1}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.csv | paste -sd, )

files=$( eval ls -1 out/{${se_control_ids}}*cutadapt_summary.log 2> /dev/null )

grep "^Quality-trimmed:" $files | awk '{print $NF}' | sed 's/[(%)]//g' | tee >(datamash max 1 | awk '{print "Max:"$1}' ) >( datamash mean 1 | awk '{print "Mean:"$1}') >(datamash median 1  | awk '{print "Median:"$1}') >(datamash q1 1 | awk '{print "Q1:"$1}' ) >(datamash q3 1 | awk '{print "Q3:"$1}' ) >(datamash iqr 1 | awk '{print "iqr:"$1}' ) > /dev/null


```



