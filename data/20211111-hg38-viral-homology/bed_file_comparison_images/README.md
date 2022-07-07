


```
/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.bt2/NC_001664.4.split.25.mask.bed
/francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.STAR/NC_001664.4.split.25.mask.bed
/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.bt2/NC_001664.4.masked.split.25.mask.bed
/francislab/data1/working/20211111-hg38-viral-homology/out/RM.split.HM.STAR/NC_001664.4.masked.split.25.mask.bed

pyGenomeTracks --tracks NC_001664.4.ini --region X:3130000-3140000 --trackLabelFraction 0.2 --width 38 --dpi 130 -o master_bed_arrow_zoom.png
pyGenomeTracks --tracks NC_001664.4.ini --region NC_001664.4:1-200000 --trackLabelFraction 0.2 --width 38 --dpi 130 -o master_bed_arrow_zoom.png
```



bedtools 2.30.0 apparently has a bug which limits the line size.
Use 2.29.0 with pyGenomeTracks or no bedtools at all.


Compare bowtie2 Raw HM, RM HM and RM

Compare bowtie2 and STAR Raw HM, RM HM and RM



```
./create_bed_files_for_pyGenomeTracks.bash
```


```
./create_ini_files_for_pyGenomeTracks.bash
```



```
./run_pyGenomeTracks.bash
```


