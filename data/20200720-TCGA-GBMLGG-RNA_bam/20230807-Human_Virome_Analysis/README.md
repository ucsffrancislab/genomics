
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-Human_Virome_Analysis



```
Human_Virome_Analysis_array_wrapper.bash --threads 4 --extension .Aligned.sortedByCoord.out.bam \
--out ${PWD}/out ${PWD}/../20230807-STAR-GRCh38/out/02-0047*.Aligned.sortedByCoord.out.bam 




```



##	20230816


```
for f in out/*.count.txt ; do
echo $f
id=$( basename ${f} .count.txt )
rc=$( cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/${id}_R1.fastq.gz.read_count.txt )
awk -v rc=${rc} 'BEGIN{FS=OFS="\t"}(NR==1){print;next}(/^ID_/){print $1,(1000*$2/rc)}' ${f} > ${f%.txt}.normalized.txt
done
```



```
( ( head -1 merged.csv ) && ( tail -n +2 merged.csv | sort -t, -k1,1 ) ) > merged.sorted.csv
( ( head -2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | tail -n 1 | sed 's/Refseq ID/Refseq_ID/' | sed $'s/\t/,/g' ) && ( tail -n +3 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | sed 's/[,"]//g' | sed $'s/\t/,/g' | sort -t, -k3 ) ) | awk 'BEGIN{FS=OFS=","}{print $1,$2,$3}' > 12915_2020_785_MOESM11_ESM.sorted.csv

join -t, --header -1 3 -2 1 12915_2020_785_MOESM11_ESM.sorted.csv merged.sorted.csv | datamash transpose -t, | tail -n +3 > transposed.csv



#join -t, --header transposed.csv <( tail -n +2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM3_ESM.csv | sed -e 's/ /_/g' -e '1s/,/,ppr /g' )  > compared.csv
#join -t, --header body_site.csv compared.csv > compared_with_body_site.csv




box_upload.bash transposed.csv
```









