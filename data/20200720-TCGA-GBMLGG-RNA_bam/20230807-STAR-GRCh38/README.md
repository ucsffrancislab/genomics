
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38



```
ll ${PWD}/../20200803-bamtofastq/out/*_R1.fastq.gz | wc -l
895
```



```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```


```
sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --array=246%1 --exclude=c4-n3,c4-n10 --parsable --job-name=STAR_array_wrapper.bash --time=10080 --nodes=1 --ntasks=16 --mem=120000M --gres=scratch:450G --output=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38/logs/STAR_array_wrapper.bash.20230820081307292816571b-%A_%a.out.log /c4/home/gwendt/.local/bin/ucsffrancislab_genomics/STAR_array_wrapper.bash --array_file /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38/STAR_array_wrapper.bash.20230820081307292816571 --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38/out
```





```

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report.csv report.t.csv
```




