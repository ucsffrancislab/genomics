

See /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera





```
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed -e "s/'//g" -e "s/,//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort > viral.csv



nohup ./report.bash > report.md &
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv



```



