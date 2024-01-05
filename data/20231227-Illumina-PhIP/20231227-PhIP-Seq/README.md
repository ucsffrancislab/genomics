
#	20231227-Illumina-PhIP/20231227-PhIP-Seq


```
mkdir fastq
cd fastq
for f in /francislab/data1/raw/20231227-Illumina-PhIP/fastq/*fastq.gz ; do
ln -s $f
done
cd ..
```




```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/vir3

for fq in fastq/*fastq.gz ; do s=$( basename $fq .fastq.gz ); bowtie -3 50 -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet   -x ${INDEX} $fq   | samtools sort -o ${fq%.fastq.gz}.bam; done

for f in fastq/*bam ; do samtools index $f; done

for bam in fastq/*bam ; do SAMPLE_ID=$(basename $bam .bam); samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${SAMPLE_ID}" | tr "\\t" "," > ${bam%.bam}.count.csv; done
```

##	20231228


```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAP

for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```




```
merge_all_combined_counts_files.py --output fastq/merged.combined.count.csv fastq/*count.csv

join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_virus.csv fastq/merged.combined.count.csv > merged.combined.with_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus.csv fastq/merged.combined.count.csv > merged.combined.with_protein_virus.count.csv

```


```
awk 'BEGIN{FS=OFS=","}(NR>1){c[$2]+=$4+$5+$6+$7}END{for(i in c){print c[i],i}}' merged.combined.with_virus.count.csv | sort -t, -k1nr,1 

awk 'BEGIN{FS=OFS=","}(NR>1){c[$3" "$2]+=$5+$6+$7+$8}END{for(i in c){print c[i],i}}' merged.combined.with_protein_virus.count.csv | sort -t, -k1nr,1 
```


what are the reads that didn't align?
```
for bam in fastq/*bam ; do
echo $bam
samtools fastq -f4 $bam | gzip > ${bam%.bam}.unmapped.fastq.gz
done

module load samtools bowtie2
for fastq in fastq/*.unmapped.fastq.gz ; do
echo $fastq
bowtie2.bash -x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --very-sensitive-local -U $fastq --sort --output ${fastq%.fastq.gz}.local.bam
done
```
Virtually no reads align to hg38, end-to-end or local



```
module load samtools bowtie2
for fastq in fastq/*.unmapped.fastq.gz ; do
echo $fastq
bowtie2.bash -x /francislab/data1/refs/bowtie2/phiX \
  --very-sensitive-local -U $fastq --sort --output ${fastq%.fastq.gz}.phiX.local.bam
done
```








##	20240102


```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.${baseind}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```

```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.2
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.${baseind}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```

Definitely HAPLib.1. The alignments of S1-S4 are 87-89%. HAPLib.2 are about 3.5%.


```
merge_all_combined_counts_files.py --output fastq/merged.HAPLib.1.count.csv fastq/S?.HAPLib.1.count.csv

join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_virus.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_protein_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus_seqs_unique.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_protein_virus_seqs_unique.count.csv

```


```
awk 'BEGIN{FS=OFS=","}(NR>1){c[$2]+=$4+$5+$6+$7}END{for(i in c){print c[i],i}}' merged.combined.with_virus.count.csv | sort -t, -k1nr,1 

awk 'BEGIN{FS=OFS=","}(NR>1){c[$3" "$2]+=$5+$6+$7+$8}END{for(i in c){print c[i],i}}' merged.combined.with_protein_virus.count.csv | sort -t, -k1nr,1 
```





##	20240104


```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/LExPELib.1
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.${baseind}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```

```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/LExPELib.2
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.${baseind}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```














Definitely HAPLib.1. The alignments of S1-S4 are 87-89%. HAPLib.2 are about 3.5%.


```
merge_all_combined_counts_files.py --output fastq/merged.HAPLib.1.count.csv fastq/S?.HAPLib.1.count.csv

join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_virus.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_protein_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus_seqs_unique.csv fastq/merged.HAPLib.1.count.csv > merged.HAPLib.1.with_protein_virus_seqs_unique.count.csv

```


```
awk 'BEGIN{FS=OFS=","}(NR>1){c[$2]+=$4+$5+$6+$7}END{for(i in c){print c[i],i}}' merged.combined.with_virus.count.csv | sort -t, -k1nr,1 

awk 'BEGIN{FS=OFS=","}(NR>1){c[$3" "$2]+=$5+$6+$7+$8}END{for(i in c){print c[i],i}}' merged.combined.with_protein_virus.count.csv | sort -t, -k1nr,1 
```

