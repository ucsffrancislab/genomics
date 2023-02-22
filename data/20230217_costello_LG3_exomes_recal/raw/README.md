

copy_vcfs.bash



upload_vcfs_to_box.bash



```
module load samtools
for bam in /costellolab/data3/jocostello/LG3/exomes_recal/GBM*/*bam ; do
echo $bam
base=$( basename $bam .bam )
dir=$( basename $( dirname $bam ) )
mkdir -p bams/$dir
samtools view -h -b -o bams/${dir}/${base}.chr13.bam $bam chr13:108863591-108863609
done


for bam in bams/*/*bam ; do
samtools index $bam
done

```

upload_bams_to_box.bash

