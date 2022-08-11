


```
mkdir -p /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="/francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/logs/preprocess.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/array_wrapper.bash

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



```
for f in out/*.quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.bam.unaligned_count.txt ; do b=$( basename $f .quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.bam.unaligned_count.txt ) ; u=$( cat $f ) ; a=$( cat ${f/unalign/align} ); c=$( echo "scale=2; 100 * ${a} / ( ${a} + ${u} )" | bc -l 2> /dev/null) ; echo ${b} - ${c}; done

```

```
date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=transcript --time=360 --nodes=1 --ntasks=32 --mem=240G --output=${PWD}/logs/featureCounts.transcript.${date}.txt ~/.local/bin/featureCounts.bash -T 32 -a hg38.ncbiRefSeq.gtf -g gene_name -t transcript -o ${PWD}/featureCounts.rmsk.un.hg38.ncbiRefSeq.transcript.gene_name.csv ${PWD}/pear_out/*.quality.t1.t3.rmsk.un.hg38.bam
```

awk -F"\t" '{s=0;for(i=7;i<=NF;i++)s+=$i;if(s>100)print}'  featureCounts.rmsk.un.hg38.ncbiRefSeq.transcript.gene_name.csv | wc -l



```
zcat SFHH011Z.quality.umi.R1.fastq.gz | sed -n '1~4p' | awk -F- '{print $NF}' | sort | uniq -c | sort -n > SFHH011Z.quality.umi.R1.fastq.gz.umi_counts.txt &

zcat SFHH011Z.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011Z.quality.R2.fastq.gz.umi_counts.txt &
zcat SFHH011S.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011S.quality.R2.fastq.gz.umi_counts.txt &
zcat SFHH011CH.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011CH.quality.R2.fastq.gz.umi_counts.txt &
zcat SFHH011A.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011A.quality.R2.fastq.gz.umi_counts.txt &
zcat SFHH011BB.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011BB.quality.R2.fastq.gz.umi_counts.txt &
zcat SFHH011CC.quality.R2.fastq.gz | sed -n '2~4p' | awk '{print substr($0,0,18)}' | sort | uniq -c | sort -n > SFHH011CC.quality.R2.fastq.gz.umi_counts.txt &
```










Count already trimmed reads. 
Count the UMIs.


```
for f in *.quality.umi.t1.t3.R1.fastq.gz ; do echo $f
if [ ! -f ${f}.umi_counts.txt ] ; then
zcat $f | sed -n '1~4p' | awk -F- '{print $NF}' | sort | uniq -c | sort -n > ${f}.umi_counts.txt
fi
done 
```

Filter out UMIs with too much homogeneity


cat SFHH011AA.quality.umi.t1.t3.R1.fastq.gz.umi_counts.txt | awk '{s=$0;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");max=16;if(a<=max && c<=max && g<=max && t<=max) print s, a, c, g, t}'

```
for f in *.quality.umi.t1.t3.R1.fastq.gz.umi_counts.txt ; do echo $f
if [ ! -f ${f%.txt}.14.txt ] ; then
cat ${f} | awk 'BEGIN{OFS="\t"}{s=$2;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");x=14;if(a<x && c<x && g<x && t<x) print $1, s, a, c, g, t}' > ${f%.txt}.14.txt
fi
if [ ! -f ${f%.txt}.15.txt ] ; then
cat ${f} | awk 'BEGIN{OFS="\t"}{s=$2;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");x=15;if(a<x && c<x && g<x && t<x) print $1, s, a, c, g, t}' > ${f%.txt}.15.txt
fi
if [ ! -f ${f%.txt}.16.txt ] ; then
cat ${f} | awk 'BEGIN{OFS="\t"}{s=$2;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");x=16;if(a<x && c<x && g<x && t<x) print $1, s, a, c, g, t}' > ${f%.txt}.16.txt
fi
if [ ! -f ${f%.txt}.17.txt ] ; then
cat ${f} | awk 'BEGIN{OFS="\t"}{s=$2;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");x=17;if(a<x && c<x && g<x && t<x) print $1, s, a, c, g, t}' > ${f%.txt}.17.txt
fi
if [ ! -f ${f%.txt}.18.txt ] ; then
cat ${f} | awk 'BEGIN{OFS="\t"}{s=$2;a=gsub(/[aA]/,"");c=gsub(/[cC]/,"");g=gsub(/[gG]/,"");t=gsub(/[tT]/,"");x=18;if(a<x && c<x && g<x && t<x) print $1, s, a, c, g, t}' > ${f%.txt}.18.txt
fi
done
```

```
for f in *.quality.umi.t1.t3.R1.fastq.gz.umi_counts{.,.??.}txt ; do echo $f
if [ ! -f ${f%.txt}.sum.txt ] ; then
cat ${f} | awk '{sum+=$1}END{print sum}' > ${f%.txt}.sum.txt
fi
done
```


```
./umi_report.bash > umi_report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' umi_report.md > umi_report.csv
```

