


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


Something is wonky. Awful consolidation

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



featureCounts -a mirna.gff -t miRNA_primary_transcript -g Name -o feature_counts.mirna.tsv out_noumi/*.quality.format.t1.t3.notphiX.notviral.hg38.bam

featureCounts -a genes.gff -t transcript -g gene_name -o feature_counts.genes.tsv out_noumi/*.quality.format.t1.t3.notphiX.notviral.hg38.bam
```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211208-preprocessing"
curl -netrc -X MKCOL "${BOX}/"


curl -netrc -T feature_counts.genes.tsv "${BOX}/"
curl -netrc -T feature_counts.genes.tsv.summary.tsv "${BOX}/"

curl -netrc -T feature_counts.mirna.tsv "${BOX}/"
curl -netrc -T feature_counts.mirna.tsv.summary.tsv "${BOX}/"

for f in out/*fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```









```
for gtf in /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/*gtf ; do
echo $gtf
g=$( basename $gtf .gtf )
featureCounts -a ${gtf} -t feature -g feature_name -o feature_counts.${g}.tsv out_noumi/*.quality.format.t1.t3.notphiX.notviral.hg38.bam

mv feature_counts.${g}.tsv.summary feature_counts.${g}.summary.tsv
sed -i -e "1s'out_noumi/''g" -e "1s'.quality.format.t1.t3.notphiX.notviral.hg38.bam''g" feature_counts.${g}.summary.tsv
sed -i -e "1,2s'out_noumi/''g" -e "1,2s'.quality.format.t1.t3.notphiX.notviral.hg38.bam''g" feature_counts.${g}.tsv
tail -n +3 feature_counts.${g}.tsv | awk 'BEGIN{FS=OFS="\t"}{s=0;for(i=7;i<=NF;i++)s+=$i;print s"\t"$0}' | sort -k1nr | cut -f2- >> feature_counts.${g}.sorted.tsv 
done
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/20211208-preprocessing"

for gtf in /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/*gtf ; do
g=$( basename $gtf .gtf )
echo $g
curl -netrc -T feature_counts.${g}.tsv "${BOX}/"
curl -netrc -T feature_counts.${g}.sorted.tsv "${BOX}/"
curl -netrc -T feature_counts.${g}.summary.tsv "${BOX}/"
done
```



KWIP/KHMER test

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=1440 --nodes=1 --ntasks=16 --mem=120G --job-name="SFHH009H" --output="${PWD}/SFHH009H.khmer.log" load-into-counting.py --max-memory-usage 100G --ksize 13 --threads 16 ${PWD}/out_noumi/SFHH009H.quality.format.t1.t3.notphiX.notviral.1.ct.gz ${PWD}/out_noumi/SFHH009H.quality.format.t1.t3.notphiX.notviral.1.fqgz


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=1440 --nodes=1 --ntasks=16 --mem=120G --job-name="SFHH009M" --output="${PWD}/SFHH009M.khmer.log" load-into-counting.py --max-memory-usage 100G --ksize 13 --threads 16 ${PWD}/out_noumi/SFHH009M.quality.format.t1.t3.notphiX.notviral.1.ct.gz ${PWD}/out_noumi/SFHH009M.quality.format.t1.t3.notphiX.notviral.1.fqgz


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=1440 --nodes=1 --ntasks=16 --mem=120G --job-name="SFHH009N" --output="${PWD}/SFHH009N.khmer.log" load-into-counting.py --max-memory-usage 100G --ksize 13 --threads 16 ${PWD}/out_noumi/SFHH009N.quality.format.t1.t3.notphiX.notviral.1.ct.gz ${PWD}/out_noumi/SFHH009N.quality.format.t1.t3.notphiX.notviral.1.fqgz

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time=1440 --nodes=1 --ntasks=64 --mem=499G --job-name="kwip" --output="${PWD}/kwip.log" --wrap="kwip -t 64 -k ${PWD}/test.kern -d ${PWD}/test.dist ${PWD}/out_noumi/SFHH009*.1.ct.gz"

```





```
featureCounts -T 16 -a genes.gff -t transcript -g gene_name -o feature_counts.genes.noumi.tsv out_noumi/*.quality.format.t1.t3.notphiX.notviral.hg38.bam
featureCounts -T 16 -a genes.gff -t transcript -g gene_name -o feature_counts.genes.umi.tsv out/*.quality.format.consolidate.t1.t2.t3.notphiX.hg38.bam

```
