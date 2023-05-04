
#	Test run of TEProF2 on STRANDED data

/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/

```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out \
  --extension .Aligned.sortedByCoord.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out

```








```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```




