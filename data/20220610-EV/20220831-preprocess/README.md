
#	20220831

Sadly, only aligned R1s to hg38!

Redoing as 20220913



```
ln -s /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv metadata.csv



mkdir -p ${PWD}/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="${PWD}/logs/preprocess.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/array_wrapper.bash

```





```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```





UCSF VPN just sucks

```
module load samtools
samtools fasta -f4 out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.bam | gzip > out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.fa.gz 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=blastn --time=1440 --nodes=1 --ntasks=8 --mem=60G --output=/francislab/data1/working/20220610-EV/20220831-preprocess/blastn.log /francislab/data1/working/20220610-EV/20220831-preprocess/blastn.bash 

zcat out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.tsv.gz | awk 'BEGIN{FS=OFS="\t"}{print $1,$NF}' | uniq | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $NF}' | sort | uniq -c | sort -nr

zcat out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.tsv.gz | awk 'BEGIN{FS=OFS="\t"}{print $1}' | uniq | sort | uniq > out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.matched_read_names.txt


awk '(NR==FNR){matched[$0]=1}(NR!=FNR){ r=$1; sub(/^>/, "", r); if( !matched[r] ){print $1;print $2 } }' out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.matched_read_names.txt <( zcat out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.fa.gz | paste - - )





sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=kraken2 --time=10080 --nodes=1 --ntasks=32 --mem=240G --output=/francislab/data1/working/20220610-EV/20220831-preprocess/kraken2.log ~/.local/bin/kraken2.bash --threads 32 --use-names --db /francislab/data1/refs/kraken2/standard --report /francislab/data1/working/20220610-EV/20220831-preprocess/out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.unmatched.kraken2.report.txt.gz --output /francislab/data1/working/20220610-EV/20220831-preprocess/out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.unmatched.kraken2.output.txt.gz /francislab/data1/working/20220610-EV/20220831-preprocess/out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.unmatched.fa.gz



```




























---

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
for f in *.quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz ; do echo $f
if [ ! -f ${f}.read_count.txt ] ; then
zcat $f | grep -c "^>" > ${f}.read_count.txt
fi
done

for f in *.quality.umi.t1.t3.hg38.rx.marked.bam ; do echo $f
if [ ! -f ${f}.F3844.aligned_count.txt ] ; then
samtools view -F 3844 -c $f > ${f}.F3844.aligned_count.txt
fi
done


for f in *.quality.umi.t1.t3.hg38.rx.marked.bam; do echo $f
cat ${f}.F3844.aligned_count.txt
cat ${f%.bam}.reference.fasta.gz.read_count.txt
done
```


```
module load samtools
for dir in /scratch/gwendt/* ; do
b=$( basename ${dir}/SFHH*.quality.umi.t1.t3.hg38.rx.marked.bam .quality.umi.t1.t3.hg38.rx.marked.bam )
n=$( cat ${dir}/split/*fasta | grep -c "^>" )
d=$( samtools view -F3844 -c ${dir}/SFHH*.quality.umi.t1.t3.hg38.rx.marked.bam )
c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
echo "${b} : ${n} / ${d} = ${c}"
done
```






```
./pear_report.bash > pear_report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' pear_report.md > pear_report.csv
```


