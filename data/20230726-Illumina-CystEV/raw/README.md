
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




```
python3 -m pip install --user --upgrade fastq-statistic
```



```
for r1 in fastq/*_R1.fastq.gz; do
echo $r1 
r2=${r1/_R1./_R2.}
base=${r1%_R1*}
fastq-statistic --sampleid ${base} --no-plot ${r1} ${r2}
done
```

```
head -1q fastq/*_statistic.csv | head -1 > fastq-statistics.csv
tail -n 1 -q fastq/*_statistic.csv | sed 's/^fastq\///' >> fastq-statistics.csv

box_upload.bash fastq-statistics.csv 
```



##	20240122

```
zcat fastq/{1_11,4_10,7_7,8_4}_R?.fastq.gz | sed -n -e '1~4s/^@/>/p' -e '2~4p' | gzip > blanks.fa.gz &
```

lots of duplicate sequences

```
zcat fastq/{1_11,4_10,7_7,8_4}_R?.fastq.gz | sed -n -e '2~4p' | uniq | sort | uniq | awk '{print ">"NR;print $0}' | gzip > blanks.fa.gz &

```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build.log --export=None \
 --wrap="module load bowtie2; bowtie2-build --threads 64 ${PWD}/blanks.fa.gz ${PWD}/blanks"
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-blanks.log --export=None \
 ~/.local/bin/bowtie2.bash --very-sensitive --threads 64 -x ${PWD}/blanks -1 ${PWD}/fastq/1_1_R1.fastq.gz -2 ${PWD}/fastq/1_1_R2.fastq.gz --output ${PWD}/1_1.blanks.bam
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="bowtie2.hg38-viral-bacteria" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2.hg38-viral-bacteria.log --export=None \
 ~/.local/bin/bowtie2.bash --very-sensitive --threads 64 -x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.viral-20230801.bacteria-20210916-NC_only -1 ${PWD}/fastq/1_1_R1.fastq.gz -2 ${PWD}/fastq/1_1_R2.fastq.gz --output ${PWD}/1_1.hg38-viral-bacteria.bam
```








