
#	20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS


Prior STAR alignment did not include the XS tag which may be needed by TEProF2 (stringtie)

```

STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*_R1.fastq.gz

```




This sample requires much more memory to sort so rerunning it separately.

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=246 --job-name=STAR246 --time=10080 --nodes=1 --ntasks=32 --mem=240G --gres=scratch:1000G --output=${PWD}/logs/STAR_array_wrapper.$( date "+%Y%m%d%H%M%S%N" )-%A_%a.out.log ~/.local/bin/STAR_array_wrapper.bash --ref /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a   --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out --array $PWD/STAR_array_wrapper.bash.20230704180236990021713


Jul 04 20:12:54 ..... started mapping

BAMoutput.cpp:27:BAMoutput: exiting because of *OUTPUT FILE* error: could not create output file /scratch/gwendt/1473795/outdir/26-5134-01A-01R-1850-01+1._STARtmp//BAMsort/20/16
SOLUTION: check that the path exists and you have write permission for this file. Also check ulimit -n and increase it to allow more open files.

Jul 04 20:12:55 ...... FATAL ERROR, exiting
+ chmod -R a+w /scratch/gwendt/1473795


```



