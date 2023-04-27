

#	STAR alignment with strand (testing for use with TEProF2)


```

STAR_array_wrapper.bash --threads 8 \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200612-prepare/trimmed/length \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out




```


```

for bai in *bai; do bam=$( basename $bai .bai); echo $bam ; f=${bam}.strand_check.txt; if [ ! -f ${f} ] ; then infer_experiment.py -r hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi ; done

```


```
grep "1+-,1-+,2++,2--" out/*bam.strand_check.txt | awk '{print $NF}' | sort -nr | tail
0.9179
0.9178
0.9104
0.9098
0.9094
0.9069
0.9069
0.9064
0.8980
0.8843
```


