


Use RseQC to infer strandedness needed by TEProF2 / Stringtie



https://chipster.csc.fi/manual/rseqc_infer_rnaseq_experiment.html


https://rseqc.sourceforge.net/




Download gene models (update on 12/14/2021)

https://sourceforge.net/projects/rseqc/files/BED/Human_Homo_sapiens/
https://sourceforge.net/projects/rseqc/files/BED/Human_Homo_sapiens/hg38_GENCODE_V42_Basic.bed.gz/download




I think that the last line makes it "stranded", "--fr" or "fr-firststrand". NOPE.




Running RseQC returns all like ...

Fraction of reads explained by "1+-,1-+,2++,2--": 0.9568

https://chipster.csc.fi/manual/library-type-summary.html

This suggests fr-firststrand

Stringtie
--rf	Assumes a stranded library fr-firststrand.



```
For non strand specific experiment the ratio of explanations should be close to 50:50

Fraction of reads failed to determine: 0.0000
Fraction of reads explained by "1++,1--,2+-,2-+": 0.5074
Fraction of reads explained by "1+-,1-+,2++,2--": 0.4926
For strand specific experiments there are two scenarios:

Reads in file 1 are always on the same strand as the gene: ( --fr / fr-secondstrand )

Fraction of reads failed to determine: 0.0072
Fraction of reads explained by "1++,1--,2+-,2-+": 0.9441
Fraction of reads explained by "1+-,1-+,2++,2--": 0.0487
 
Reads in file 2 are always on the same strand as the gene: ( --rf / fr-firststrand )

Fraction of reads failed to determine: 0.0011
Fraction of reads explained by "1++,1--,2+-,2-+": 0.0053
Fraction of reads explained by "1+-,1-+,2++,2--": 0.9936
```






```
mkdir strand_check
for bai in /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*Aligned.sortedByCoord.out.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=strand_check/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f}
fi
done
```

```
for f in strand_check/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c
```





