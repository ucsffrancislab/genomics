#	RepEnrich2

https://github.com/nerettilab/RepEnrich2


##	Step 1) Attain repetitive element annotation
```
wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAD8FJm28zWy6kVy0WIcpz77a/hg38_repeatmasker_clean.txt.gz

gunzip hg38_repeatmasker_clean.txt.gz

wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAAovLTYE93PjBIlRRToO59la/Repenrich2_setup_hg38.tar.gz
```

##	Step 2) Run the setup for RepEnrich2

This took about a day.
```
singularity exec --bind /francislab /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2_setup.py ${PWD}/hg38_repeatmasker_clean.txt /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${PWD}/setup_folder_hg38 --threads 32
```


##	Step 3) Map the data to the genome

hg38 was link to hg38.chrXYM_alts.fa which already has a bowtie2 index built.

```
mkdir ${PWD}/out
for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUB*R1.fastq.gz ; do
r2=${r1/_R1./_R2.}
base=$( basename $r1 _R1.fastq.gz )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/${base}.txt \
bowtie2.bash --threads 16 --output ${PWD}/out/${base}.bam -1 ${r1} -2 ${r2} --nocount \
-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts
done
```





python RepEnrich2_subset.py /path/to/sample.bam 30 Sample_Name --pairedend TRUE
```


##	Step 4) Run RepEnrich2 on the data

```
python RepEnrich2.py /data/mm9_repeatmasker.txt /data/Sample_Output_Folder/ Sample_Name /data/RepEnrich2_setup_mm9 /data/sample_name_multimap_R1.fastq --fastqfile2 /data/sample_name_multimap_R2.fastq /data/sample_name_unique.bam --cpus 16 --pairedend TRUE
```


