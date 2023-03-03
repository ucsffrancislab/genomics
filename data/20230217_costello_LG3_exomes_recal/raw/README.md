

copy_vcfs.bash



upload_vcfs_to_box.bash



```
module load samtools
for bam in /costellolab/data3/jocostello/LG3/exomes_recal/*/*bam ; do
echo $bam
base=$( basename $bam .bam )
dir=$( basename $( dirname $bam ) )
mkdir -p bams/$dir
samtools view -h -b -o bams/${dir}/${base}.chr13.bam $bam chr13:108863591-108863609
done


for bam in bams/*/*bam ; do
echo $bam
samtools index $bam
done


echo "bam,chr13:108863591:A,chr13:108863591:C,chr13:108863591:G,chr13:108863591:T,chr13:108863609:A,chr13:108863609:C,chr13:108863609:G,chr13:108863609:T" > chr13.csv
for bam in bams/*/*bam ; do
aa=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="A"){print $1}' )
ac=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="C"){print $1}' )
ag=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="G"){print $1}' )
at=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="T"){print $1}' )
ba=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="A"){print $1}' )
bc=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="C"){print $1}' )
bg=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="G"){print $1}' )
bt=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="T"){print $1}' )
echo "${bam#bams/},${aa},${ac},${ag},${at},${ba},${bc},${bg},${bt}"
done >> chr13.csv &

```

upload_bams_to_box.bash




MAPQ 60


```
module load samtools
mkdir bams60
for bam in /costellolab/data3/jocostello/LG3/exomes_recal/*/*bam ; do
echo $bam
base=$( basename $bam .bam )
dir=$( basename $( dirname $bam ) )
mkdir -p bams60/$dir
samtools view -h -q 60 -b -o bams60/${dir}/${base}.chr13.bam $bam chr13:108863591-108863609
samtools index bams60/${dir}/${base}.chr13.bam
done


echo "bam,chr13:108863591:A,chr13:108863591:C,chr13:108863591:G,chr13:108863591:T,chr13:108863609:A,chr13:108863609:C,chr13:108863609:G,chr13:108863609:T" > chr13.MAPQ60.csv
for bam in bams60/*/*bam ; do
aa=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="A"){print $1}' )
ac=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="C"){print $1}' )
ag=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="G"){print $1}' )
at=$( samtools_bases_at_position.bash -c chr13 -p 108863591 -b $bam | sort | uniq -c | awk '($2=="T"){print $1}' )
ba=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="A"){print $1}' )
bc=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="C"){print $1}' )
bg=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="G"){print $1}' )
bt=$( samtools_bases_at_position.bash -c chr13 -p 108863609 -b $bam | sort | uniq -c | awk '($2=="T"){print $1}' )
echo "${bam#bams60/},${aa},${ac},${ag},${at},${ba},${bc},${bg},${bt}"
done >> chr13.MAPQ60.csv &

```

upload_bams60_to_box.bash





are these sommatic? or just not recal?

```
module load samtools
mkdir sommaticbams60
for bam in /costellolab/data3/jocostello/LG3/exomes/*/*bam ; do
echo $bam
base=$( basename $bam .bam )
dir=$( basename $( dirname $bam ) )
mkdir -p sommaticbams60/$dir
samtools view -h -q 60 -b -o sommaticbams60/${dir}/${base}.chr13.bam $bam chr13:108863591-108863609
samtools index sommaticbams60/${dir}/${base}.chr13.bam
done





