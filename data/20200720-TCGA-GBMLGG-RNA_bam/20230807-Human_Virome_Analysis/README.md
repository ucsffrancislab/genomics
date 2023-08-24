
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-Human_Virome_Analysis



```
Human_Virome_Analysis_array_wrapper.bash --threads 4 --extension .Aligned.sortedByCoord.out.bam \
--out ${PWD}/out ${PWD}/../20230807-STAR-GRCh38/out/02-0047*.Aligned.sortedByCoord.out.bam 




```



##	20230821

```
awk 'BEGIN{FS="\t";OFS=","}{$1=$1;print}' /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/TCGA.Glioma.metadata.tsv > tmp
( ( head -1 tmp ) && ( tail -n +2 tmp | sort -t, -k1,1 ) ) > TCGA.Glioma.metadata.csv
\rm tmp
```

```
for f in out/*.count.txt ; do
echo $f
id=$( basename ${f} .count.txt )
rc=$( cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/${id}_R1.fastq.gz.read_count.txt )
o=${f%.txt}.normalized.txt
if [ ! -f ${o} ] ; then
awk -v rc=${rc} 'BEGIN{FS=OFS="\t"}(NR==1){print;next}(/^ID_/){print $1,(1000*$2/rc)}' ${f} > ${o}
fi
done

python3 ./merge.py --out merged.csv out/*.count.normalized.txt

( ( head -1 merged.csv ) && ( tail -n +2 merged.csv | sort -t, -k1,1 ) ) > merged.sorted.csv
( ( head -2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | tail -n 1 | sed 's/Refseq ID/Refseq_ID/' | sed $'s/\t/,/g' ) && ( tail -n +3 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | sed 's/[,"]//g' | sed $'s/\t/,/g' | sort -t, -k3 ) ) | awk 'BEGIN{FS=OFS=","}{print $1,$2,$3}' > 12915_2020_785_MOESM11_ESM.sorted.csv

join -t, --header -1 3 -2 1 12915_2020_785_MOESM11_ESM.sorted.csv merged.sorted.csv | datamash transpose -t, | tail -n +3 > transposed.csv

awk 'BEGIN{OFS=FS=","}(NR==1){print "subject",$0;next}{split($1,a,"-");print "TCGA-"a[1]"-"a[2],$0}' transposed.csv > transposed_with_subject.csv

join -t, --header TCGA.Glioma.metadata.csv transposed_with_subject.csv > transposed_with_subject_meta.csv



box_upload.bash transposed.csv transposed_with_subject.csv transposed_with_subject_meta.csv
```


No meta data for ...
```
TCGA-06-0675
TCGA-06-0678
TCGA-06-0680
TCGA-06-0681
TCGA-06-AABW
TCGA-28-2510
TCGA-28-2510
TCGA-R8-A6YH
```

