

#	20200603-TCGA-GBMLGG-WGS/20230804-bowtie2-HumanViral



```
bowtie2_array_wrapper.bash --threads 8 --very-sensitive \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230803-cutadapt/out/*_R1.fastq.gz

```


```
echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv
```






##	20230905


```
module load samtools
for bam in out/{02,06-0157,06-0190-10B,06-0210-10A}*bam ; do 
echo $bam
samtools view -F14 ${bam} | awk -v bam=${bam} '{OFS=","}(($3~/(chr|KI|GL)/&&$7~/(AC|NC)/)||($3~/(AC|NC)/&&$7~/(chr|KI|GL)/)){ read=(and(64,$2))?"1":"2"; pos=($3~/_/)?$4:int($4/1000)*1000;print $1,read,$5,$3,pos,length($10),$10 > bam".discordant_matrix."read".csv"}'
sort -k1,1 ${bam}.discordant_matrix.1.csv > ${bam}.discordant_matrix.sorted.1.csv
sort -k1,1 ${bam}.discordant_matrix.2.csv > ${bam}.discordant_matrix.sorted.2.csv
join -t, ${bam}.discordant_matrix.sorted.1.csv ${bam}.discordant_matrix.sorted.2.csv > ${bam}.discordant_matrix.joined.csv
done

for f in out/*.discordant_matrix.joined.csv ; do
echo $f
awk -F, '($3>40)&&($9>40)&&($6>50)&&($12>50){print $10,$4,$5;print $4,$10,$11}' $f | grep "^.C_" | sort -k1,1 -k2,2 -k3n,3 | uniq -c | awk 'BEGIN{OFS=","}{print $2,$3,$4,$1}' > tmp
join -t, tmp accession_description.csv
done
```



