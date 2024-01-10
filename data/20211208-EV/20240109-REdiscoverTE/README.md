
#	20211208-EV/20240109-REdiscoverTE


13 samples


ONLY DEDUPED READS THAT ALIGNED TO HUMAN



```
mkdir in
for f in ../20230815-preprocess/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R?.fastq.gz ; do
echo $f
l=$( basename ${f} .fastq.gz )
r=${l#*.deduped.}
l=${l%.format.*}
ln -s ../${f} in/${l}_${r}.fastq.gz
done

```



```

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/in/*_R1.fastq.gz

```


