


```
mkdir -p /francislab/data1/working/20211208-EV/20211208-preprocessing/logs

date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="preproc" --output="/francislab/data1/working/20211208-EV/20211208-preprocessing/logs/preprocess.${date}-%A_%a.out" --time=1440 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20211208-EV/20211208-preprocessing/array_wrapper.bash
```



```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

./noumi_report.bash > noumi_report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' noumi_report.md > noumi_report.csv
```


Something is wonky

```

~/.local/bin/bowtie2.bash --no-unal --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -1 out/SFHH009A_R1.fastq.gz -2 out/SFHH009A_R2.fastq.gz -o SFHH009A.phiX.bam &

~/.local/bin/bowtie2.bash --no-unal --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -1 out/SFHH009A.quality.R1.fastq.gz -2 out/SFHH009A.quality.R2.fastq.gz -o SFHH009A.quality.phiX.bam &

~/.local/bin/bowtie2.bash --no-unal --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -1 out/SFHH009A.quality.format.R1.fastq.gz -2 out/SFHH009A.quality.format.R2.fastq.gz -o SFHH009A.quality.format.phiX.bam &

~/.local/bin/bowtie2.bash --no-unal --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -1 out/SFHH009A.quality.format.consolidate.R1.fastq.gz -2 out/SFHH009A.quality.format.consolidate.R2.fastq.gz -o SFHH009A.quality.format.consolidate.phiX.bam &

```
















```
for f in out/SFHH008?.quality.format.consolidate.R1.fastq.gz ; do
echo $f
b=$( basename $f .quality.format.consolidate.R1.fastq.gz )
zcat $f | paste - - - - | cut -f1 | cut -d' ' -f1 | cut -d'_' -f2 | sort -n > ${b}.umi_counts
done
```



```
ln -s /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf genes.gff 

ln -s /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 mirna.gff



featureCounts -a mirna.gff -t miRNA_primary_transcript -g Name -o feature_counts.mirna.tsv out/*hg38.bam

featureCounts -a genes.gff -t transcript -g gene_name -o feature_counts.genes.tsv out/*hg38.bam
```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211208-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in out/*fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```




