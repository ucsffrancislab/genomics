
#	First run of TEProF2

/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/




Running this 3 different ways: unstranded, rf and fr for comparison


Running RseQC returns all like ...

Fraction of reads explained by "1+-,1-+,2++,2--": 0.9568

https://chipster.csc.fi/manual/library-type-summary.html

This suggests fr-firststrand

Stringtie
--rf	Assumes a stranded library fr-firststrand.
--fr	Assumes a stranded library fr-secondstrand.





```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-rf \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-rf

```


---


```

TEProF2_array_wrapper.bash --threads 4 --strand --fr \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-fr \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --fr --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-fr

```

---


```

TEProF2_array_wrapper.bash --threads 4 \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out

```





fr and unstranded failed quite early


```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out-rf/Step10.RData ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```




