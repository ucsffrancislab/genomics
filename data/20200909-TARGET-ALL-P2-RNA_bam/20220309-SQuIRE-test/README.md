



https://github.com/wyang17/SQuIRE



```
singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire 

singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Fetch

mkdir ${PWD}/fetched       # IMPORTANT

singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Fetch --build hg38 --fetch_folder ${PWD}/fetched --fasta --rmsk  --chrom_info  --index  --gene --threads 32 --verbosity | tee fetched.out 


mkdir ${PWD}/cleaned
singularity exec --bind /francislab /francislab/data1/refs/singularity/SQuIRE.img squire Clean --rmsk ${PWD}/fetched/hg38_rmsk.txt --fetch_folder ${PWD}/fetched --clean_folder ${PWD}/cleaned --threads 32 --verbosity | tee cleaned.out
```




loop map

```
samplenames=SRR4016864,SRR4016865,SRR4016861,SRR4016860


# Loop through read 1 fastq files
for samplename in ${samplenames//,/ }
do
for fastq in $fastq_folder/${samplename}*$r1suffix

do
  read1+=${fastq}
done


  # Check if the data is paired or unpaired
  if [ $r2suffix != 'False' ]
  then
  for fastq in $fastq_folder/${samplename}*$r2suffix
    do
    read2+=${fastq}
    done

    # Check if map has already been comleted
    if [[ `stat -c %s $map_folder/${samplename}.bam` < 1000 ]]
    then
      # Send paired map.sh job
      qsub -cwd -V map.sh $read1 $samplename $argument_file $read2
    fi

  else
    # Check if map has already been comleted
    if [[ `stat -c %s $map_folder/$base.bam` < 1000 ]]
    then
      # Send unpaired map.sh job
      read2=False
      qsub -cwd -V map.sh $read1 $samplename $argument_file $read2
    fi
  fi
done
```






qsub -cwd loop_count.sh arguments.sh
qsub -cwd call.sh arguments.sh
qsub -cwd loop_draw.sh arguments.sh


 sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=sqFetch --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/sqFetch.txt --wrap "

















```
for bam in /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/10-PAUB*bam ; do
  base=$( basename $bam .bam )


  sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img TEcount --sortByPos --format BAM --mode multi -b ${bam} --project ${base} --GTF /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf --TE ${PWD}/TEtranscripts_TE_GTF/hg38_rmsk_TE.gtf"


done
```


