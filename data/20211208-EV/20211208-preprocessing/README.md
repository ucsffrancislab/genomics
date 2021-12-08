


```
mkdir -p /francislab/data1/working/20211208-EV/20211208-preprocessing/logs

date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="preproc" --output="/francislab/data1/working/20211208-EV/20211208-preprocessing/logs/preprocess.${date}-%A_%a.out" --time=1440 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20211208-EV/20211208-preprocessing/array_wrapper.bash
```



```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '/---/d' report.md > report.csv
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




