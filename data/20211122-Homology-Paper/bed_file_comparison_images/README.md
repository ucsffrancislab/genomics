


mkdir RM
mkdir raw.split.HM.bt2/
mkdir raw.split.HM.STAR/
mkdir RM.split.HM.bt2/
mkdir RM.split.HM.STAR/

scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.bt2/NC_001664.4.split.25.mask.bed raw.split.HM.bt2/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.STAR/NC_001664.4.split.25.mask.bed raw.split.HM.STAR/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.bt2/NC_001664.4.masked.split.25.mask.bed RM.split.HM.bt2/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.STAR/NC_001664.4.masked.split.25.mask.bed RM.split.HM.STAR/


scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.bt2/NC_001664.4.split.25.mask.fasta raw.split.HM.bt2/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.STAR/NC_001664.4.split.25.mask.fasta raw.split.HM.STAR/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.bt2/NC_001664.4.masked.split.25.mask.fasta RM.split.HM.bt2/
scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.STAR/NC_001664.4.masked.split.25.mask.fasta RM.split.HM.STAR/

scp c4:/francislab/data1/working/20211111-hg38-viral-homology/out/RM/NC_001664.4.masked.fasta RM/


More interested in the final mask than just the stages.

fasta_N_regions_to_bed_file

Check start end format

Start coordinate on the chromosome or scaffold for the sequence considered (the first base on the chromosome is numbered 0)
- so use NR-1 since the first NR is 0
End coordinate on the chromosome or scaffold for the sequence considered. This position is non-inclusive, unlike chromStart.
- again use NR-1 since in this case it is the next position which triggers the end of the region.

```
tail -n +2 RM/NC_001664.4.masked.fasta | tr -d "\n" | sed 's/\(.\)/\1\n/g' | awk 'BEGIN{true=1;false=0;n=false;start=0}
(  /N/ && !n ){n=true; start=NR-1}
( !/N/ &&  n && start ){n=false; print "REGION\t"start"\t"NR}'
```

A lot different when prepping for pyGenomeTracks
In order to get a line through the full record.

```
tail -n +2 RM/NC_001664.4.masked.fasta | tr -d "\n" | sed 's/\(.\)/\1\n/g' | awk 'BEGIN{true=1;false=0;n=false;start=0}
(  /N/ && !n ){n=true; start=NR-1}
( !/N/ &&  n && start ){n=false;blockSizes=blockSizes""NR-start",";blockStarts=blockStarts""start",";blockCount++}
END{ print "NC_001664.4\t1\t160000\t.\t0\t+\t1\t160000\t0\t"blockCount"\t"blockSizes"\t"blockStarts }' > RM/NC_001664.4.masked.bed

```

```
for f in */NC_001664.4.*.fasta ; do
tail -n +2 ${f} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | awk 'BEGIN{true=1;false=0;n=false;start=0}
(  /N/ && !n ){n=true; start=NR-1}
( !/N/ &&  n && start ){n=false;blockSizes=blockSizes""NR-start",";blockStarts=blockStarts""start",";blockCount++}
END{ print "NC_001664.4\t1\t160000\t.\t0\t+\t0\t0\t0\t"blockCount+2"\t0,"blockSizes"0,\t0,"blockStarts"159999," }' > ${f}.bed
done



pyGenomeTracks --tracks NC_001664.4.ini --region NC_001664.4:0-160000 --trackLabelFraction 0.2 --width 38 --dpi 130 -o NC_001664.4.png

```



```
rsync -avz --progress c4:/francislab/data1/working/20211122-Homology-Paper/out/ ./20211122-Homology-Paper/
```


bedtools 2.30.0 apparently has a bug which limits the line size
use 2.29.0 with pyGenomeTracks


---


Compare bowtie2 Raw HM, RM HM and RM

```
for f in 20211122-Homology-Paper/*/*fasta ; do
accession=$( basename ${f} | awk -F. '{print $1"."$2}' )
echo $f
echo $accession
chars=$( tail -n +2 ${f} | tr -d "\n" | wc --chars )
tail -n +2 ${f} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | awk -v a=${accession} -v c=${chars} 'BEGIN{true=1;false=0;n=false;start=0}
(  /N/ && !n ){n=true; start=NR-1}
( !/N/ &&  n && start ){n=false;blockSizes=blockSizes""NR-start",";blockStarts=blockStarts""start",";blockCount++}
END{ print a"\t1\t"c"\t.\t0\t+\t0\t0\t0\t"blockCount+2"\t0,"blockSizes"0,\t0,"blockStarts""c-1"," }' > ${f}.bed
done
```

```
mkdir out
for f in 20211122-Homology-Paper/raw/*fasta.bed ; do
b=$( basename ${f} .fasta.bed )
sed -e "s/RAW_HM_FASTA_BED_FILE/20211122-Homology-Paper\/split.vsl\/${b}.split.25.mask.fasta.bed/" \
-e "s/RM_FASTA_BED_FILE/20211122-Homology-Paper\/masks\/${b}.masked.fasta.bed/" \
-e "s/RM_HM_FASTA_BED_FILE/20211122-Homology-Paper\/split.vsl\/${b}.masked.split.25.mask.fasta.bed/" \
template.ini > out/${b}.ini
done
```


```
for f in 20211122-Homology-Paper/raw/*fasta ; do
b=$( basename ${f} .fasta )
chars=$( tail -n +2 ${f} | tr -d "\n" | wc --chars )
title=$( head -1 ${f} | sed -e 's/^>//' )
pyGenomeTracks --tracks out/${b}.ini --region ${b}:0-${chars} --trackLabelFraction 0.1 --width 30 --dpi 120 -o out/${b}.png --title "${title}                " --fontSize 16
done
```




