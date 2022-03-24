#	SQuIRE

https://github.com/wyang17/SQuIRE


```
singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire 

singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Fetch
```

##	Fetch 

It is important to make the outdirs first

```
mkdir ${PWD}/fetched

singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Fetch \
  --build hg38 --fetch_folder ${PWD}/fetched --fasta --rmsk  --chrom_info  --index  --gene --pthreads 32 --verbosity | tee fetched.out 
```


##	Clean

```
chmod -R 500 ${PWD}/fetched
mkdir ${PWD}/cleaned

singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Clean \
  --rmsk ${PWD}/fetched/hg38_rmsk.txt --fetch_folder ${PWD}/fetched --clean_folder ${PWD}/cleaned --verbosity | tee cleaned.out
```

##	Map


```
chmod -R 500 ${PWD}/cleaned
mkdir ${PWD}/mapped

for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUB*R1.fastq.gz ; do
r2=${r1/_R1./_R2.}
base=$( basename $r1 _R1.fastq.gz )
read_length=$( zcat $r1 | head -2 | tail -1 | wc -c )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=s${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/mapped/${base}.txt \
  --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Map \
  --name $base --read1 $r1 --read2 $r2 \
  --map_folder ${PWD}/mapped --read_length $read_length --fetch_folder ${PWD}/fetched --pthreads 16 --build hg38 --verbosity"
done
```


##	Count

strandedness = '0' if unstranded, 1 if first-strand eg Illumina Truseq, dUTP, NSR, NNSR, 2 if second-strand, eg Ligation, Standard

EM = desired number of EM iterations other than auto

First complete run took just shy of 24 hours on 16 cores. Up that limit

`for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUBCB*R1.fastq.gz ; do`

```
chmod -R 500 ${PWD}/mapped
mkdir ${PWD}/counted

for r1 in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out/10-PAUB*R1.fastq.gz ; do
base=$( basename $r1 _R1.fastq.gz )
mkdir ${PWD}/${base}-temp
read_length=$( zcat $r1 | head -2 | tail -1 | wc -c )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=s${base} --time=2880 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/counted/${base}.txt \
  --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Count \
  --map_folder ${PWD}/mapped --clean_folder ${PWD}/cleaned --count_folder ${PWD}/counted --temp_folder ${PWD}/${base}-temp \
  --read_length $read_length --fetch_folder ${PWD}/fetched \
  --name ${base} --build hg38 --strandedness 2 --EM auto --verbosity"
done
```





##	Call


```
chmod -R 500 ${PWD}/counted
mkdir ${PWD}/called

projectname=FakeProject

#Location or variable (such as $TMPDIR) to store intermediate files
group1=10-PAUBCB-09A-01R,10-PAUBCT-09A-01R,10-PAUBLL-09A-01R,10-PAUBPY-09A-01R
#Name of basenames of samples in group 1
group2=10-PAUBRD-09A-01R,10-PAUBTC-09A-01R,10-PAUBXP-09A-01R
#Name of basenames of samples in group 2
condition1=treated
#Name of condition for group 1 in squire Call
condition2=control
#Name of condition for group 2 in squire Call
output_format=pdf
#Desired output of figures as html or pdf
#  --env R_LIBS=/usr/local/lib/R/library/ \

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=sqCall --time=1440 --nodes=1 --ntasks=64 --mem=495G \
  --output=${PWD}/called/${base}.txt \
  --wrap "singularity exec --bind /francislab,/scratch --no-home \
  /francislab/data1/refs/singularity/SQuIRE.img squire Call \
  --map_folder ${PWD}/mapped --clean_folder ${PWD}/cleaned --count_folder ${PWD}/counted --temp_folder ${PWD}/${base}-temp \
  --group1 $group1 --group2 $group2 --condition1 $condition1 --condition2 $condition2 --projectname $projectname \
  --pthreads 64 --output_format $output_format --call_folder ${PWD}/called --verbosity"
```

Other options to note.

```
--cleanenv
--contain
--containall
--no-home
--no-mount ...
```


##	Draw


```
chmod -R 500 ${PWD}/called
mkdir ${PWD}/drawed

threads=8
mem=60G

for file in ${PWD}/mapped/*.bam ; do
basefile=$(basename $file)
base=${basefile//.bam/}
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=s${base} --time=1440 --nodes=1 --ntasks=${threads} --mem=${mem} \
  --output=${PWD}/drawed/${base}.txt \
  --wrap "singularity exec --bind /francislab,/scratch --no-home \
  /francislab/data1/refs/singularity/SQuIRE.img squire Draw \
  --map_folder ${PWD}/mapped --clean_folder ${PWD}/cleaned --count_folder ${PWD}/counted --temp_folder ${PWD}/${base}-temp \
  --fetch_folder ${PWD}/fetched \
  --draw_folder ${PWD}/drawed --name $base --build hg38 --pthreads ${threads} --strandedness 2 --verbosity"
done

```

After ...

```
chmod -R 500 ${PWD}/drawed
```

##	Seek


Need to filter input bed file by existing fasta chromosomes otherwise it will fail.

```
Opening chr10_KN196480v1_fixfile

Traceback (most recent call last):
  File "/usr/local/bin/squire", line 11, in <module>
    load_entry_point('SQuIRE', 'console_scripts', 'squire')()
  File "/SQuIRE/squire/cli.py", line 156, in main
    subargs.func(args = subargs)
  File "/SQuIRE/squire/Seek.py", line 155, in main
    chromosome_infile = Fasta(chrom_infile)
  File "/usr/local/lib/python2.7/dist-packages/pyfaidx/__init__.py", line 1017, in __init__
    build_index=build_index)
  File "/usr/local/lib/python2.7/dist-packages/pyfaidx/__init__.py", line 384, in __init__
    "Cannot read FASTA file %s" % filename)
pyfaidx.FastaNotFoundError: Cannot read FASTA file /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220309-SQuIRE-test/fetched/hg38.chromFa/chr10_KN196480v1_fix.fa

```


while read -r chr therest; do
if [ -f ${PWD}/fetched/hg38.chromFa/${chr}.fa ] ; then
echo -e "${chr}\t${therest}"
fi
done < ${PWD}/cleaned/hg38_all.bed > hg38_filtered.bed



```
chmod +w fetched/hg38.chromFa

singularity exec --no-home --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE.img squire Seek \
  --infile hg38_filtered.bed --outfile seek.fa --genome ${PWD}/fetched/hg38.chromFa --verbosity | tee seek.out
```

After ...

```
chmod -R 500 ${PWD}/fetched
```

