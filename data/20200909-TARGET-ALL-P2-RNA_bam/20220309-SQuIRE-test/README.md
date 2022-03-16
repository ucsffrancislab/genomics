#	SQuIRE

https://github.com/wyang17/SQuIRE


```
singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire 

singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Fetch
```

##	Fetch 

It is important to make the outdirs first

```
mkdir ${PWD}/fetched

singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Fetch \
  --build hg38 --fetch_folder ${PWD}/fetched --fasta --rmsk  --chrom_info  --index  --gene --pthreads 32 --verbosity | tee fetched.out 
```


##	Clean

```
mkdir ${PWD}/cleaned

singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Clean \
  --rmsk ${PWD}/fetched/hg38_rmsk.txt --fetch_folder ${PWD}/fetched --clean_folder ${PWD}/cleaned --verbosity | tee cleaned.out
```

##	Map


```
mkdir ${PWD}/mapped

for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUB*R1.fastq.gz ; do
r2=${r1/_R1./_R2.}
base=$( basename $r1 _R1.fastq.gz )
read_length=$( zcat $r1 | head -2 | tail -1 | wc -c )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/${base}.txt \
  --wrap "singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Map \
  --name $base --read1 $r1 --read2 $r2 \
  --map_folder ${PWD}/mapped --read_length $read_length --fetch_folder ${PWD}/fetched --pthreads 16 --build hg38 --verbosity"
done
```
















##	Count

qsub -cwd loop_count.sh arguments.sh


##	Call

qsub -cwd call.sh arguments.sh


##	Draw

qsub -cwd loop_draw.sh arguments.sh


