
#	20200720-TCGA-GBMLGG-RNA_bam/20251211-VIRTUS2



/francislab/data1/refs/VIRTUS2/

```bash

for r1 in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/*_R1.fastq.gz ; do
 r2=${r1/R1.fastq/R2.fastq}

 base=$( basename ${r1} _R1.fastq.gz )
 mkdir -p ${PWD}/out/${base}/

 echo "cd ${PWD}/out/${base}/; \
  export CWL_SINGULARITY_CACHE=/francislab/data1/refs/VIRTUS2/; \
  cwltool --singularity ~/github/yyoshiaki/VIRTUS2/bin/VIRTUS.PE.cwl \
   --fastq1 ${r1} --fastq2 ${r2} \
   --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
   --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus \
   --outFileNamePrefix_human human \
   --nthreads 8"

done > commands

commands_array_wrapper.bash --jobname VIRTUS2 --array_file commands --time 1-0 --threads 8 --mem 60G

```

These are running about 30 minutes / sample



some failed rerun with more memory

```bash
for d in out/* ; do if [ ! -f ${d}/VIRTUS.output.tsv ]; then echo $d ; fi ; done
out/06-0745-01A-01R-1849-01+1
out/26-5134-01A-01R-1850-01+1
out/32-4213-01A-01R-1850-01+2
out/DU-5849-01A-11R-1708-07+1
out/HT-7467-01A-11R-2027-07+1
out/QH-A6CY-01A-11R-A32Q-07+1

grep -l "not enough memory for BAM" logs/commands_array_wrapper.bash.20251211192227264253636-949277_*.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_246.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_328.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_429.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_600.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_86.out.log

grep -l ERROR logs/commands_array_wrapper.bash.20251211192227264253636-949277_*.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_246.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_328.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_429.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_600.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_760.out.log
logs/commands_array_wrapper.bash.20251211192227264253636-949277_86.out.log
```

```bash

sed -i s'/nthreads 8/nthreads 16/g' commands

commands_array_wrapper.bash --jobname VIRTUS2 --array_file commands --time 1-0 --threads 16 --mem 120G --array 86,246,328,429,600,760

```





246, 328, 600 still fails


EXITING because of fatal ERROR: not enough memory for BAM sorting: 
SOLUTION: re-run STAR with at least --limitBAMsortRAM 87247902396

EXITING because of fatal ERROR: not enough memory for BAM sorting: 
SOLUTION: re-run STAR with at least --limitBAMsortRAM 55591131153

EXITING because of fatal ERROR: not enough memory for BAM sorting: 
SOLUTION: re-run STAR with at least --limitBAMsortRAM 34486036652


BAMoutput.cpp:27:BAMoutput: exiting because of *OUTPUT FILE* error: could not create output file human_STARtmp//BAMsort/56/8
SOLUTION: check that the path exists and you have write permission for this file. Also check ulimit -n and increase it to allow more open files.




```bash

sed -i s'/nthreads 16/nthreads 32/g' commands

commands_array_wrapper.bash --jobname VIRTUS2 --array_file commands --time 1-0 --threads 32 --mem 240G --array 246,328,600


sed -i s'/nthreads 32/nthreads 64/g' commands

commands_array_wrapper.bash --jobname VIRTUS2 --array_file commands --time 1-0 --threads 64 --mem 490G --array 246,328,600

```


out/26-5134-01A-01R-1850-01+1
out/32-4213-01A-01R-1850-01+2
out/HT-7467-01A-11R-2027-07+1
















Only useful if multiple groups to compare and if enough viral threshold surpassed.

Also only include VIRTUS files that have data in them.
If they are just headers, they don't get included in the summary dataframe.
And it will crash when comparing 2 groups.


```bash
\rm out/*input.csv
for r1 in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/*_R1.fastq.gz ; do
 base=$( basename ${r1} _R1.fastq.gz )
 if [[ -f out/${base}/VIRTUS.output.tsv ]] && [[ $( wc -l < out/${base}/VIRTUS.output.tsv ) -gt 1 ]] ; then
  tss=$( echo ${base} | cut -c1-2 )  
  sample_type=$( echo ${base} | cut -c9-10 )  

  if grep -q ${tss} /francislab/data1/refs/TCGA/TCGA.GBM_codes.txt ; then
   echo ${base},${base},PE,GBM >> out/gbm.input.csv
  fi
  if grep -q ${tss} /francislab/data1/refs/TCGA/TCGA.LGG_codes.txt ; then
   echo ${base},${base},PE,LGG >> out/lgg.input.csv
  fi
 fi
done
cat out/*.input.csv > out/input.csv

sed -i '1iName,Fastq,Layout,Group' out/input.csv
sed -i '1iName,Fastq,Layout,Group' out/gbm.input.csv
sed -i '1iName,Fastq,Layout,Group' out/lgg.input.csv
```

Be sure to change the scatterplot call to square=False

```bash
cd out

~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py gbm.input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human --th_rate 0.0000001 \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus
mv summary.csv gbm.summary.csv
mv scattermap.pdf gbm.scattermap.pdf

~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py lgg.input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human --th_rate 0.0000001 \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus
mv summary.csv lgg.summary.csv
mv scattermap.pdf lgg.scattermap.pdf

~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human --th_rate 0.0000001 \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus

cd ..

box_upload.bash out/*scattermap.pdf out/*summary.csv
```





