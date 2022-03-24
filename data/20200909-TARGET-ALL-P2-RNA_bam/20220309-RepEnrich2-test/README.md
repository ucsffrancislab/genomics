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
singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2_setup.py ${PWD}/hg38_repeatmasker_clean.txt /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${PWD}/setup_folder_hg38 --threads 32
```



I'm not sure that that was needed. I think that contents of the one download contain the same files.

```
tar tvfz Repenrich2_setup_hg38.tar.gz | wc -l
8872
ll setup_folder_hg38/ | wc -l
8872
```





##	Step 3) Map the data to the genome

hg38 was link to hg38.chrXYM_alts.fa which already has a bowtie2 index built.

```
mkdir ${PWD}/out
for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUB*R1.fastq.gz ; do
r2=${r1/_R1./_R2.}
base=$( basename $r1 _R1.fastq.gz )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=r${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/out/${base}.bowtie2.txt \
   bowtie2.bash --threads 16 --output ${PWD}/out/${base}.bam -1 ${r1} -2 ${r2} --nocount \
   -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts
done
```


No threads specifiable in command?

```
chmod -w out/*
for bam in ${PWD}/out/*bam ; do
 base=$( basename $bam .bam )
 sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=r${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/out/${base}.subset.txt \
  --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img \
   python /RepEnrich2/RepEnrich2_subset.py ${bam} 30 ${PWD}/out/${base} --pairedend TRUE"
done
```


##	Step 4) Run RepEnrich2 on the data

Output needs to go in a subdir as they produce a bunch of files with the same name. (`pair1_`, `pair2_`, `sorted_`)

Slurm Job_id=452446 Name=r10-PAUBCT-09A-01R Failed, Run time 20:49:37, OUT_OF_MEMORY


```
chmod -w out/*
for bam in ${PWD}/out/*_unique.bam ; do
 base=$( basename $bam _unique.bam )
 sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=r${base} --time=2880 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/out/${base}.repenrich2.txt \
  --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img \
  python /RepEnrich2/RepEnrich2.py ${PWD}/hg38_repeatmasker_clean.txt \
   ${PWD}/out/${base} ${base} ${PWD}/setup_folder_hg38 \
   ${PWD}/out/${base}_multimap_R1.fastq \
   --fastqfile2 ${PWD}/out/${base}_multimap_R2.fastq \
   ${bam} --cpus 16 --pairedend TRUE"
done
```

