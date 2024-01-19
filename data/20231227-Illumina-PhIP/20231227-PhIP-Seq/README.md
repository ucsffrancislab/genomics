
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




##	20240116


Median alignment count per tile?

Multiple alignments instead of just best?

Bowtie2 local instead of just bowtie?




```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bwt
bam=${fq%.fastq.gz}_bwt.${baseind}.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bt2allloc
bam=${fq%.fastq.gz}_bt2allloc.${baseind}.bam
bowtie2.bash -x ${INDEX} --all --very-sensitive-local -U $fq --sort --output ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bt2alle2e
bam=${fq%.fastq.gz}_bt2alle2e.${baseind}.bam
bowtie2.bash -x ${INDEX} --all --very-sensitive -U $fq --sort --output ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```





```
merge_all_combined_counts_files.py --output merged.3versions.HAPLib.1.count.csv fastq/S?_b*.*HAPLib.1.count.csv

join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_virus.csv merged.3versions.HAPLib.1.count.csv > merged.3versions.HAPLib.1.with_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus.csv merged.3versions.HAPLib.1.count.csv > merged.3versions.HAPLib.1.with_protein_virus.count.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/HAP_id_protein_virus_seqs_unique.csv merged.3versions.HAPLib.1.count.csv > merged.3versions.HAPLib.1.with_protein_virus_seqs_unique.count.csv

```

Add average columns
id,Protein names,Organism,peptide,UniProt_Seq_Identical,S0_bt2alle2e,S0_bt2allloc,S0_bwt,S1_bt2alle2e,S1_bt2allloc,S1_bwt,S2_bt2alle2e,S2_bt2allloc,S2_bwt,S3_bt2alle2e,S3_bt2allloc,S3_bwt,S4_bt2alle2e,S4_bt2allloc,S4_bwt

```
awk 'function median(nums)
{ asort(nums);
l=length(nums);
return ((l % 2 == 0) ? ( nums[l/2] + nums[(l/2) + 1] ) / 2 : nums[int(l/2) + 1])
}
BEGIN{OFS=FS=","}(NR==1){print $0,"bt2e2emean","bt2locmean","bwtmean","bt2e2emed","bt2locmed","bwtmed"}(NR>1){
meanbwt=($NF+$(NF-3)+$(NF-6)+$(NF-9))/4
meanbt2loc=($(NF-1)+$(NF-4)+$(NF-7)+$(NF-10))/4
meanbt2e2e=($(NF-2)+$(NF-5)+$(NF-8)+$(NF-11))/4
split($NF","$(NF-3)","$(NF-6)","$(NF-9),a,",")
medbwt=median(a)
split($(NF-1)","$(NF-4)","$(NF-7)","$(NF-10),a,",")
medbt2loc=median(a)
split($(NF-2)","$(NF-5)","$(NF-8)","$(NF-11),a,",")
medbt2e2e=median(a)
print $0,meanbt2e2e,meanbt2loc,meanbwt,medbt2e2e,medbt2loc,medbwt
}' merged.3versions.HAPLib.1.with_protein_virus_seqs_unique.count.csv > merged.3versions.HAPLib.1.with_protein_virus_seqs_unique.with_means_and_medians.count.csv

```




