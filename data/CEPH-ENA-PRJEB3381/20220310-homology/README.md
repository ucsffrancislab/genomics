


Align CEPH samples to each viral version

```
ls -1 /francislab/data1/raw/CEPH-ENA-PRJEB3381/*_1.fastq.gz
/francislab/data1/raw/CEPH-ENA-PRJEB3381/ERR194146_1.fastq.gz
/francislab/data1/raw/CEPH-ENA-PRJEB3381/ERR194147_1.fastq.gz
/francislab/data1/raw/CEPH-ENA-PRJEB3381/ERR194158_1.fastq.gz
/francislab/data1/raw/CEPH-ENA-PRJEB3381/ERR194159_1.fastq.gz
/francislab/data1/raw/CEPH-ENA-PRJEB3381/ERR194161_1.fastq.gz

ls -1 /francislab/data1/working/20211111-hg38-viral-homology/R*.rev.1.bt2
/francislab/data1/working/20211111-hg38-viral-homology/RawHM.rev.1.bt2
/francislab/data1/working/20211111-hg38-viral-homology/Raw.rev.1.bt2
/francislab/data1/working/20211111-hg38-viral-homology/RMHM.rev.1.bt2
/francislab/data1/working/20211111-hg38-viral-homology/RM.rev.1.bt2
```

```
date=$( date "+%Y%m%d%H%M%S" )
mkdir ${PWD}/out/
for r1 in /francislab/data1/raw/CEPH-ENA-PRJEB3381/*_1.fastq.gz ; do
for r in /francislab/data1/working/20211111-hg38-viral-homology/R*.rev.1.bt2 ; do
r2=${r1/_1/_2}
ref=${r%%.rev.1.bt2}
baseref=$( basename ${ref} )
sample=$( basename ${r1} _1.fastq.gz )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${sample}.${baseref}" --output="${PWD}/out/${sample}.${baseref}.${date}.%j.out" --time=1440 --nodes=1 --ntasks=16 --mem=120G ~/.local/bin/bowtie2.bash -x ${ref} -1 ${r1} -2 ${r2} --very-sensitive --no-unal --threads 16 --sort --output ${PWD}/out/${sample}.${baseref}.bam
done ; done
```


BAM to BED for pyGenomeTracks

```
./pyGenomeTracks.bash
```


