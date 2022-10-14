

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





BEWARE


hg38_refGene.gtf contains absolute paths so if this is moved it MUST BE EDITED to reflect the new location



