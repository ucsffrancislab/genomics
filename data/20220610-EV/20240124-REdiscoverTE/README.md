
#	20220610-EV/20240124-REdiscoverTE




```
mkdir -p in
for f in /francislab/data1/working/20210428-EV/20230605-preprocessing/out/SFHH005*.deduped.bam \
  /francislab/data1/working/20220610-EV/20230814-preprocess/out/SFHH011*.deduped.bam ; do
l=$( basename $f )
l=${l/.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped/}
l=${l/.umi_tag.dups.deduped/}
ln -s $f in/${l}
done
```




fasta or fastq NOT BAM FILES



```
REdiscoverTE_array_wrapper.bash --threads 4 \
--out /francislab/data1/working/20220610-EV/20240124-REdiscoverTE/out \
--extension .bam \
/francislab/data1/working/20220610-EV/20240124-REdiscoverTE/in/*.bam

```




