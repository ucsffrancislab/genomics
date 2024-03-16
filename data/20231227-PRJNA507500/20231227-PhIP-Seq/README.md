
#	20231227-PRJNA507500/20231227-PhIP-Seq


```
mkdir fastq
cd fastq
for f in /francislab/data1/raw/20231227-PRJNA507500/fastq/*fastq.gz ; do
ln -s $f
done
cd ..
```



```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/HAP

for fq in fastq/SRR825941*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.HAP.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done
```




```
module load samtools bowtie
INDEX=/francislab/data1/refs/PhIP-Seq/VIR3_clean

for fq in fastq/SRR825941*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.VIR3_clean.bam
bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done
```




```
module load samtools bowtie bowtie2
INDEX=/francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome

#bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}

for fq in fastq/SRR825941*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.GRCh38.bam
bowtie2 --very-sensitive-local --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done
```




##	20231229



Prior to renaming reads to numbers ...
```
for fq in fastq/SRR825941*fastq.gz ; do echo $fq; s=$(basename $fq .fastq.gz); bam=${fq%.fastq.gz}.HPOP.bam; bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}; samtools index ${bam}; samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv; done
fastq/SRR8259411.fastq.gz
# reads processed: 4286797
# reads with at least one alignment: 1680216 (39.20%)
# reads that failed to align: 2606581 (60.80%)
Reported 1680216 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259412_1.fastq.gz
# reads processed: 146551
# reads with at least one alignment: 10447 (7.13%)
# reads that failed to align: 136104 (92.87%)
Reported 10447 alignments
fastq/SRR8259412_2.fastq.gz
# reads processed: 146551
# reads with at least one alignment: 5204 (3.55%)
# reads that failed to align: 141347 (96.45%)
Reported 5204 alignments
fastq/SRR8259413_1.fastq.gz
# reads processed: 1617080
# reads with at least one alignment: 919947 (56.89%)
# reads that failed to align: 697133 (43.11%)
Reported 919947 alignments
fastq/SRR8259413_2.fastq.gz
# reads processed: 1617080
# reads with at least one alignment: 1328 (0.08%)
# reads that failed to align: 1615752 (99.92%)
Reported 1328 alignments
fastq/SRR8259414_1.fastq.gz
# reads processed: 4230907
# reads with at least one alignment: 2530782 (59.82%)
# reads that failed to align: 1700125 (40.18%)
Reported 2530782 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259414_2.fastq.gz
# reads processed: 4230907
# reads with at least one alignment: 993 (0.02%)
# reads that failed to align: 4229914 (99.98%)
Reported 993 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259415_1.fastq.gz
# reads processed: 3233095
# reads with at least one alignment: 2263562 (70.01%)
# reads that failed to align: 969533 (29.99%)
Reported 2263562 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259415_2.fastq.gz
# reads processed: 3233095
# reads with at least one alignment: 2193 (0.07%)
# reads that failed to align: 3230902 (99.93%)
Reported 2193 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259416_1.fastq.gz
# reads processed: 1942900
# reads with at least one alignment: 1209566 (62.26%)
# reads that failed to align: 733334 (37.74%)
Reported 1209566 alignments
fastq/SRR8259416_2.fastq.gz
# reads processed: 1942900
# reads with at least one alignment: 4983 (0.26%)
# reads that failed to align: 1937917 (99.74%)
Reported 4983 alignments
fastq/SRR8259417_1.fastq.gz
# reads processed: 3542226
# reads with at least one alignment: 1971134 (55.65%)
# reads that failed to align: 1571092 (44.35%)
Reported 1971134 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259417_2.fastq.gz
# reads processed: 3542226
# reads with at least one alignment: 1870 (0.05%)
# reads that failed to align: 3540356 (99.95%)
Reported 1870 alignments
[bam_sort_core] merging from 1 files and 1 in-memory blocks...
fastq/SRR8259418_1.fastq.gz
# reads processed: 581267
# reads with at least one alignment: 399942 (68.81%)
# reads that failed to align: 181325 (31.19%)
Reported 399942 alignments
fastq/SRR8259418_2.fastq.gz
# reads processed: 581267
# reads with at least one alignment: 853 (0.15%)
# reads that failed to align: 580414 (99.85%)
Reported 853 alignments
fastq/SRR8259419_1.fastq.gz
# reads processed: 671045
# reads with at least one alignment: 414664 (61.79%)
# reads that failed to align: 256381 (38.21%)
Reported 414664 alignments
fastq/SRR8259419_2.fastq.gz
# reads processed: 671045
# reads with at least one alignment: 256 (0.04%)
# reads that failed to align: 670789 (99.96%)
Reported 256 alignments

```

The --norc will effectively stop all of R2 from aligning. Almost anyway.

Some of this data is paired so could do it that way too.

The oligos are only 147bp long. The reads are 150/151bp so really NEED to trim during alignment.


```
module load samtools bowtie bowtie2
INDEX=~/github/derisilab-ucsf/PhIP-PND-2018/library_design/oligos

for fq in fastq/SRR825941*fastq.gz ; do
echo $fq
s=$(basename $fq .fastq.gz)
bam=${fq%.fastq.gz}.HPOP.bam
bowtie -3 25 -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet -x ${INDEX} $fq | samtools sort -o ${bam}
samtools index ${bam}
samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
done
```





##	20240315

```
fastx_count_array_wrapper.bash ${PWD}/fastq/SRR???????.fastq.gz
fastx_count_array_wrapper.bash ${PWD}/fastq/SRR*_1.fastq.gz
```

I just noticed that the provided fasta reference file contains 21bp prefix and suffixes. Odd. I don't expect them in the data.

AGCCATCCGCAGTTCGAGAAA 

GACTACAAGGACGACGATGAT

Need to recreate from PhIP-PND-2018/library_design/human_peptidome_oligo_pool.csv.

```
mv PhIP-PND-2018/library_design/human_peptidome_oligo_pool.fasta PhIP-PND-2018/library_design/human_peptidome_oligo_pool.fasta.bad

awk -F, '{ print ">"$1; print $3 }' PhIP-PND-2018/library_design/human_peptidome_oligo_pool.csv > PhIP-PND-2018/library_design/human_peptidome_oligo_pool.fasta

bowtie2-build PhIP-PND-2018/library_design/human_peptidome_oligo_pool.fasta PhIP-PND-2018/library_design/human_peptidome_oligo_pool

```


Looks like the prefixes and suffixes exist in the data but not the reference. Not sure what that means.
```
grep AGCCATCCGCAGTTCGAGAAA /francislab/data1/working/20231227-PRJNA507500/20231227-PhIP-Seq/PhIP-PND-2018/library_design/human_peptidome_oligo_pool.csv 

grep GACTACAAGGACGACGATGAT /francislab/data1/working/20231227-PRJNA507500/20231227-PhIP-Seq/PhIP-PND-2018/library_design/human_peptidome_oligo_pool.csv 
```

```
zgrep AGCCATCCGCAGTTCGAGAAA fastq/SRR8*q.gz > AGCCATCCGCAGTTCGAGAAA.txt &

fastq/SRR8259414_1.fastq.gz:AGCAGGGCGCGCATGGCGATGCGGTGATTCTGGGCATGAGCAGCCTGGAACAGCTGGAACAGAACCTGGCGGCGGCGGAAGAAGGCCCACTGGAACCGGCGGATGGCTCCAGGAATTCCTGGAGCCATCCGCAGTTCGAGAAAAAAATGCT
fastq/SRR8259414_1.fastq.gz:AGCAGGGCGCGCATGGCGATGCGGTGATTCTGGGCATGAGCAGCCTGGAACAGCTGGAACAGAACCTGGCGGCGGCGGAAGAAGGCCCACTGGAACCGGCGGATGGCTCCAGGAATTCCTGGAGCCATCCGCAGTTCGAGAAAAAAATGCT
fastq/SRR8259414_1.fastq.gz:AGCAGGGCGCGCATGGCGATGCGGTGATTCTGGGCATGAGCAGCCTGGAACAGCTGGAACAGAACCTGGCGGCGGCGGAAGAAGGCCCACTGGAACCGGCGGATGGCTCCAGGAATTCCTGGAGCCATCCGCAGTTCGAGAAAAAAATGCT
fastq/SRR8259414_1.fastq.gz:AGCAGGGCGCGCATGGCGATGCGGTGATTCTGGGCATGAGCAGCCTGGAACAGCTGGAACAGAACCTGGCGGCGGCGGAAGAAGGCCCACTGGAACCGGCGGATGGCTCCAGGAATTCCTGGAGCCATCCGCAGTTCGAGAAAAAAATGCT

zgrep GACTACAAGGACGACGATGAT fastq/SRR8*q.gz > GACTACAAGGACGACGATGAT.txt &


[1]-  Exit 1                  zgrep AGCCATCCGCAGTTCGAGAAA fastq/SRR8*q.gz > AGCCATCCGCAGTTCGAGAAA.txt
[2]+  Exit 1                  zgrep GACTACAAGGACGACGATGAT fastq/SRR8*q.gz > GACTACAAGGACGACGATGAT.txt


wc -l AGCCATCCGCAGTTCGAGAAA.txt GACTACAAGGACGACGATGAT.txt
        717 AGCCATCCGCAGTTCGAGAAA.txt
  182919831 GACTACAAGGACGACGATGAT.txt
  182920548 total

```





```
mkdir out-loc

bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive-local --threads 8 \
-x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
--single --extension .fastq.gz --outdir ${PWD}/out-loc \
${PWD}/fastq/SRR???????.fastq.gz


bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive-local --threads 8 \
-x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
--extension _1.fastq.gz --outdir ${PWD}/out-loc \
${PWD}/fastq/SRR*_1.fastq.gz

```




```
mkdir out-e2e

bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --threads 8 \
-x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
--single --extension .fastq.gz --outdir ${PWD}/out-e2e \
${PWD}/fastq/SRR???????.fastq.gz


bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --threads 8 \
-x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
--extension _1.fastq.gz --outdir ${PWD}/out-e2e \
${PWD}/fastq/SRR*_1.fastq.gz

```



