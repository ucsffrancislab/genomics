
#	MiXCR test


```
~/.local/mixcr-3.0.13/mixcr align --species human /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz 02-0047-01A.vdjca

~/.local/mixcr-3.0.13/mixcr align --species human /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R2.fastq.gz 02-0055-01A.vdjca

mkdir out

~/.local/mixcr-3.0.13/mixcr align --species human /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/06-5411-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/06-5411-01A-01R-1849-01+1_R2.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/out/06-5411-01A.vdjca &


#~/.local/mixcr-3.0.13/mixcr mergeAlignments 02-0047-01A.vdjca 02-0055-01A.vdjca output.vdjca

~/.local/mixcr-3.0.13/mixcr assemble 02-0047-01A.vdjca 02-0047-01A.clns
~/.local/mixcr-3.0.13/mixcr assemble 02-0055-01A.vdjca 02-0055-01A.clns

~/.local/mixcr-3.0.13/mixcr exportClones 02-0047-01A.clns 02-0047-01A.txt
~/.local/mixcr-3.0.13/mixcr exportClones 02-0055-01A.clns 02-0055-01A.txt
```





```
./process.bash


mkdir data
cp out/??-????-???.txt data/
./make_metadata.bash > data/metadata.txt
cd ..
```


#	immunarch test

```
module load r
R

library(immunarch)
immdata <- repLoad("data")

repExplore(immdata$data, "lens") %>% vis()
repClonality(immdata$data, "homeo") %>% vis()
repOverlap(immdata$data) %>% vis()
geneUsage(immdata$data[[1]]) %>% vis()
repDiversity(immdata$data) %>% vis(.by = "IDH", .meta = immdata$meta)
```




