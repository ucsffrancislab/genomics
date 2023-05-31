
#	20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE


/francislab/data1/refs/MEGAnE



MEGAnE doesn't seem to work with read length < 100

Check read lengths to see what completed

```
grep -l "read lenth = 51" out/*/for_debug.log | wc -l
104
```


Check for absent_MEs_genotyped.vcf to see if processing completed

```
ll -d out/* | wc -l
278

ll -d out/*/absent_MEs_genotyped.vcf | wc -l
174
```




```

MEGAnE_array_wrapper.bash --threads 8 --extension .bam \
--in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out

```



This will create an outdir called `jointcall_out`

```

MEGAnE_aggregation_steps.bash --threads 64 \
--in  /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE

```






```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"

for f in jointcall_out/*vcf.gz vcf_for_phasing/*.gz; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```

