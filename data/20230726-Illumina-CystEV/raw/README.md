
#	20230726-Illumina-CystEV


Numbers exported these and they still have ...
```
ASCII text, with CRLF line terminators
```

Can do with 
```
dos2unix /francislab/data1/raw/20230726-Illumina-CystEV/cyst_flu*
```
or
```
tr -d '\r'
```


```
mkdir fastq
for f in *_071323_L1_ds*/*.fastq.gz ; do
b=$( basename ${f} )
l=${b%_071323*}
r=${b%_001.fastq.gz}
r=${r#*_L001_}
echo $f ${l}_${r}.fastq.gz
ln -s ../${f} fastq/${l}_${r}.fastq.gz
done
```



```
awk 'BEGIN{FS=OFS=","}(NR==1){print;next}($6 ~/Kirkwood Cyst Study_cyst/){if(system("test -f fastq/"$1"_R1.fastq.gz")==0){print}}' cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv > cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv
```


```
mkdir KirkwoodCystFASTQ

for id in \
  $( tail -n +2 cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv | cut -d, -f1 | paste -s ) ; do
  #echo $id
  for f in $( ls ${id}_071323_L1_ds*/*.fastq.gz 2> /dev/null ) ; do
    echo $f
    b=$( basename ${f} )
    l=${b%_071323*}
    r=${b%_001.fastq.gz}
    r=${r#*_L001_}
    echo $f ${l}_${r}.fastq.gz
    ln -s ../${f} KirkwoodCystFASTQ/${l}_${r}.fastq.gz
  done
done
```


