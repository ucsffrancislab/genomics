


```
awk 'BEGIN{FS=OFS="\t"}(( $1 ~ /^TCGA-06/)&&($3=="Glioblastoma") && ( $4 == "black or african american" ) && ( $6 == "male" ) && ( $13 == "IDH-WT:1p19q-non-codel:TERT-NA") )' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/TCGA.Glioma.metadata.tsv > subset.csv



awk 'BEGIN{FS=OFS="\t"}(($3=="Glioblastoma") && ( $4 == "black or african american" ))' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/TCGA.Glioma.metadata.tsv > subset.csv

grep 02-2485 subset.csv 
TCGA-02-2485	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	male	02-2485-01A-01R-1849-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	MD Anderson Cancer Center	Unmethylated	515.441803	0

grep 06-2557 subset.csv 
TCGA-06-2557	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	male	06-2557-01A-01R-1849-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	Henry Ford Hospital	Unmethylated	76	1.0842117	1

grep 41-5651 subset.csv 
TCGA-41-5651	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	female	41-5651-01A-01R-1850-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	Christiana Healthcare	Methylated	59	11.5320699	0
```



```
mkdir -p out.no_alts/
date=$( date "+%Y%m%d%H%M%S" )
threads=16
mem=120G
while read -r subject other ; do
#echo $subject
subject=${subject#TCGA-}
#echo $subject
for r1 in $( ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${subject}-*R1.fastq.gz 2> /dev/null ); do
r2=${r1/_R1./_R2.}
basename=$( basename $r1 _R1.fastq.gz )
outbase=${PWD}/out.no_alts/${basename}
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${basename} --time=2880 \
  --nodes=1 --ntasks=${threads} --mem=${mem} \
  --gres=scratch:500G \
  --output=${outbase}.${date}.%j.txt \
  ~/.local/bin/bowtie2_scratch.bash \
   --very-sensitive --threads ${threads} \
   -1 ${r1} -2 ${r2} --sort --output ${outbase}.bam \
   -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts
done
done < subset.csv
```


```

grep -E '02-2485-|06-2557-|41-5651-' /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_*
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:02-2485-01A-01D-1494,575060540
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:02-2485-10A-01D-1494,478851061
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:06-2557-01A-01D-1494,504066570
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:06-2557-10A-01D-1494,600988206
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:41-5651-01A-01D-1696,516135827
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_counts.csv:41-5651-10A-01D-1696,579574120
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:02-2485-01A-01D-1494,101
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:02-2485-10A-01D-1494,101
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:06-2557-01A-01D-1494,101
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:06-2557-10A-01D-1494,101
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:41-5651-01A-01D-1696,101
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_lengths.csv:41-5651-10A-01D-1696,101

grep -E '02-2485-|06-2557-|41-5651-' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv 
02-2485,02-2485-01A-01D-1494-08,,male,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3
02-2485,02-2485-10A-01D-1494-08,,male,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3
06-2557,06-2557-01A-01D-1494-08,33,male,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3
06-2557,06-2557-10A-01D-1494-08,33,male,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3
41-5651,41-5651-01A-01D-1696-08,460,female,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3
41-5651,41-5651-10A-01D-1696-08,460,female,Glioblastoma Multiforme,Broad Institute of MIT and Harvard,9440/3

grep -E '02-2485-|06-2557-|41-5651-' subset.csv
TCGA-02-2485	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	male	02-2485-01A-01R-1849-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	MD Anderson Cancer Center	Unmethylated	515.441803	0
TCGA-06-2557	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	male	06-2557-01A-01R-1849-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	Henry Ford Hospital	Unmethylated	76	1.0842117	1
TCGA-41-5651	TCGA-GBM	Glioblastoma	black or african american	not hispanic or latino	female	41-5651-01A-01R-1850-01+1	WT	non-codelMutant	IDH-WT:1p19q-non-codel	glioblastoma:IDH-WT:1p19q-non-codel	IDH-WT:1p19q-non-codel:TERT-Mutant	Christiana Healthcare	Methylated	59	11.5320699	0



Link fastq files.


Align to hg38


Use as test data for xTea and other DNA TE pipeline

Compare tumor normal? Probably not useful in TE DNA analysis.
```






```
awk 'BEGIN{FS=OFS="\t"}( $4 == "black or african american" )' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/TCGA.Glioma.metadata.tsv > black.csv
while read -r subject other ; do
subject=${subject#TCGA-}
ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${subject}-*R1.fastq.gz 2> /dev/null 
done < black.csv

while read -r subject other ; do subject=${subject#TCGA-}; ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${subject}-01*R1.fastq.gz 2> /dev/null ; done < black.csv | xargs -I% basename % _R1.fastq.gz | cut -c1-7


grep -E '02-2485|06-2557|41-5651|CS-5395|DU-5872|DU-5872|FG-6688|HT-7604' /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/sequencing_paired_read_* /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv black.csv
```

There just aren't enough black subject's samples to use.





```
nohup featureCounts.bash -a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf -t transcript -g gene_name -T 8 -o transcript_counts.csv *bam > featureCounts.transcripts.bash
```


1: Actin, beta	                   ACTB   ENSG00000075624   Chromosome 7: 5,526,409-5,563,902 reverse strand
2: Beta2-microglobulin    β2M     ENSG00000166710   Chromosome 15: 44,711,487-44,718,851 forward strand
3: Albumin                         ALB      ENSG00000163631   Chromosome 4: 73,397,114-73,421,482 forward strand

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T out/transcript_counts.csv.gz "${BOX}/"
```


```
nohup featureCounts.bash -a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf -t transcript -g gene_name -T 8 -o 02-2485-10A.alts-to-no-alts.csv out.no_alts/02-2485-10A-01D-1494.bam /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/02-2485-10A-01D-1494.bam &
vi 02-2485-10A.alts-to-no-alts.csv

#awk 'BEGIN{FS=OFS="\t"}(NR==2){print $1,$(NF-1),$NF,"diff"}(NR>2){d=$(NF)-$(NF-1);d=sqrt(d*d);print $1,$(NF-1),$NF,d}' 02-2485-10A.alts-to-no-alts.csv | sort -k2nr,2 > 02-2485-10A.alts-to-no-alts.abs.diffs.csv
#awk 'BEGIN{FS=OFS="\t"}(NR==2){print $1,$(NF-1),$NF,"diff"}(NR>2){d=$(NF)-$(NF-1);print $1,$(NF-1),$NF,d}' 02-2485-10A.alts-to-no-alts.csv | sort -k2nr,2 > 02-2485-10A.alts-to-no-alts.signed.diffs.csv

awk 'BEGIN{FS=OFS="\t"}(NR==2){print $1,$(NF-1),$NF,"diff"}' 02-2485-10A.alts-to-no-alts.csv > 02-2485-10A.alts-to-no-alts.abs.diffs.csv
awk 'BEGIN{FS=OFS="\t"}(NR>2){d=$(NF)-$(NF-1);d=sqrt(d*d);print $1,$(NF-1),$NF,d}' 02-2485-10A.alts-to-no-alts.csv | sort -k4nr,4 >> 02-2485-10A.alts-to-no-alts.abs.diffs.csv

awk 'BEGIN{FS=OFS="\t"}(NR==2){print $1,$(NF-1),$NF,"diff"}' 02-2485-10A.alts-to-no-alts.csv > 02-2485-10A.alts-to-no-alts.signed.diffs.csv
awk 'BEGIN{FS=OFS="\t"}(NR>2){d=$(NF)-$(NF-1);print $1,$(NF-1),$NF,d}' 02-2485-10A.alts-to-no-alts.csv | sort -k4nr,4 >> 02-2485-10A.alts-to-no-alts.signed.diffs.csv
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS/20220328-test-subset"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T 02-2485-10A.alts-to-no-alts.csv "${BOX}/"
curl -netrc -T 02-2485-10A.alts-to-no-alts.abs.diffs.csv "${BOX}/"
curl -netrc -T 02-2485-10A.alts-to-no-alts.signed.diffs.csv "${BOX}/"
```




```
nohup featureCounts.bash -a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf -t transcript -g gene_name -T 8 -o alts-vs-no-alts.csv out.*alts/*bam
```

