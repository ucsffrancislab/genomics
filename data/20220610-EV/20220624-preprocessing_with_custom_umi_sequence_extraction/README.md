


```
mkdir -p /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs/preprocess.${date}-%A_%a.out" --time=2880 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/array_wrapper.bash

```


```
ln -s /francislab/data1/refs/sources/gencodegenes.org/gencode.v36lift37.annotation.gtf.gz
zcat gencode.v36lift37.annotation.gtf.gz > gencode.v36lift37.annotation.gtf
ln -s /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf



date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=transcript --time=360 --nodes=1 --ntasks=32 --mem=240G --output=${PWD}/logs/featureCounts.transcript.${date}.txt ~/.local/bin/featureCounts.bash -T 64 -a hg38.ncbiRefSeq.gtf -g gene_name -t transcript -o ${PWD}/featureCounts.ncbiRefSeq.transcript.gene_name.csv ${PWD}/out/*umi.t1.t3.hg38.bam

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=exon --time=360 --nodes=1 --ntasks=32 --mem=240G --output=${PWD}/logs/featureCounts.B${i}.19.exon.${date}.txt ~/.local/bin/featureCounts.bash -T 32 -a hg38.ncbiRefSeq.gtf -g gene_name -t exon -o ${PWD}/featureCounts.ncbiRefSeq.exon.gene_name.csv ${PWD}/out/*umi.t1.t3.hg38.bam

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=transcript --time=360 --nodes=1 --ntasks=32 --mem=240G --output=${PWD}/logs/featureCounts.transcript.${date}.txt ~/.local/bin/featureCounts.bash -T 64 -a gencode.v36lift37.annotation.gtf.gz -g gene_name -t transcript -o ${PWD}/featureCounts.gencode.transcript.gene_name.csv ${PWD}/out/*umi.t1.t3.hg38.bam

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=exon --time=360 --nodes=1 --ntasks=32 --mem=240G --output=${PWD}/logs/featureCounts.B${i}.19.exon.${date}.txt ~/.local/bin/featureCounts.bash -T 32 -a gencode.v36lift37.annotation.gtf.gz -g gene_name -t exon -o ${PWD}/featureCounts.gencode.exon.gene_name.csv ${PWD}/out/*umi.t1.t3.hg38.bam

#sed 's/^chr//' /francislab/data1/refs/sources/igv.broadinstitute.org/annotations/hg19/variations/LTR.gtf > LTR.gtf
#sed 's/^chr//' /francislab/data1/refs/sources/igv.broadinstitute.org/annotations/hg19/variations/Other.gtf > Other.gtf
```




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction"
curl -netrc -X MKCOL "${BOX}/"

for f in featureC*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```


```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```
