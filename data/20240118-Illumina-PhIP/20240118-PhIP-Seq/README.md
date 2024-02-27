
#	20240118-Illumina-PhIP/20240118-PhIP-Seq


```
mkdir fastq
cd fastq
for f in /francislab/data1/raw/20240118-Illumina-PhIP/fastq/*fastq.gz ; do
ln -s $f
done
cd ..
```


##	20240118


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




```
box_upload.bash merged.3versions.HAPLib.1.with_protein_virus_seqs_unique.with_means_and_medians.count.csv
```



##	20240124

What is everything? Align to my human+viral+bacterial reference. Will everything align?

```
module load samtools bowtie2
INDEX=/francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.viral-20230801.bacteria-20210916-NC_only
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bt2_hvb
bam=${fq%.fastq.gz}_bt2_hvb.${baseind}.bam
bowtie2.bash -x ${INDEX} --very-sensitive -U $fq --sort --output ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```

No. Surprisingly not. PhiX is really the only thing that aligns.

Rather interesting that very little aligns to viral which is part of the tile reference?








##	20240220

Investigate trimming the reference and the reads to see if more align.
I suspect that less will align.

". In “script.align.sh”, “bowtie -3 25” trims 25 nucleotides off the 3’ end of each sequencing read. This is done if sequencing reads are 75 nucleotides in length. The reference file only includes the first 50 nucleotides of each member of the library, so the sequencing reads must be trimmed down to 50 nucleotides to align correctly to the reference."


The reference sequences for HAPLIB.1 are 168bp.
Our reads are 151bp.

Most of the previous alignments occured at position 1.

Trim reference sequence to first 50bp and create appropriate indexes.
Add '-3 101' to bowtie and bowtie2 calls





```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1.50
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bwt
bam=${fq%.fastq.gz}_bwt.${baseind}.bam
bowtie -3 101 -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1.50
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bt2allloc
bam=${fq%.fastq.gz}_bt2allloc.${baseind}.bam
bowtie2.bash -3 101 -x ${INDEX} --all --very-sensitive-local -U $fq --sort --output ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

INDEX=/francislab/data1/refs/PhIP-Seq/HAPLib.1.50
baseind=$( basename $INDEX)
for fq in fastq/*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)_bt2alle2e
bam=${fq%.fastq.gz}_bt2alle2e.${baseind}.bam
bowtie2.bash -3 101 -x ${INDEX} --all --very-sensitive -U $fq --sort --output ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done

```




```
merge_all_combined_counts_files.py --output merged.3versions.HAPLib.1.50.count.csv fastq/S?_b*.*HAPLib.1.50.count.csv

join -t, fastq/S1_bwt.HAPLib.1*count.csv | awk -F, '{s2+=$2;s3+=$3}END{print s2,s3;print (s2-s3)/s3;}'
join -t, fastq/S2_bwt.HAPLib.1*count.csv | awk -F, '{s2+=$2;s3+=$3}END{print s2,s3;print (s2-s3)/s3;}'
join -t, fastq/S3_bwt.HAPLib.1*count.csv | awk -F, '{s2+=$2;s3+=$3}END{print s2,s3;print (s2-s3)/s3;}'
join -t, fastq/S4_bwt.HAPLib.1*count.csv | awk -F, '{s2+=$2;s3+=$3}END{print s2,s3;print (s2-s3)/s3;}'

```





