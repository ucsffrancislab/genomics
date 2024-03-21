
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




Their paper says that they used PEAR which is nice, but don't give details.

`Reads were quality filtered, paired-end reconciled (PEAR v0.9.8; Zhang et al., 2014) and aligned to a reference database of the full library (bowtie2 v2.3.1; Langmead and Salzberg, 2012). Sequence alignment map files were parsed using a suite of in-house analysis tools (Python/Pandas), and individual phage counts were normalized to reads per 100k (rpK) by dividing by the sum of counts and multiplying by 100,000.`




UNDO / REDO

After looking at the data and what PEAR produces, I suggest just using R1 (for the paired end) and right trimming GACTACAAGGACGACGATGAT which seems to coincide with PEAR's assembled results.

Quick look showed nearly all R1 contain GACTACAAGGACGACGATGAT. Only about 45% of single ended contain GACTACAAGGACGACGATGAT



fcaa059_supplementary_data.pdf says
primer design:
forward: CTACGAATTCCTGGAGCCATCCGCAGTTCG
reverse: CTACAAGCTTCTTATCATCGTCGTCCTTGTAGTC

ELAVL4_fwd: GAACCGATTACTGTGAAGTTTGCCAAC 
ELAVL4_rev: GTAGACAAAGATGCACCACCCAGTTC



cutadapt to quality filter and trim single ended and R1 
left trim AGCCATCCGCAGTTCGAGAAA
right trim GACTACAAGGACGACGATGAT

right trim CTACGAATTCCTGGAGCCATCCGCAGTTCG
?CTACAAGCTTCTTATCATCGTCGTCCTTGTAGTC?

AGACGGTGCTGGGCAAACGTGGCTG usually trails CTACGAATTCCTGGAGCCATCCGCAGTTCG


```
      717 AGCCATCCGCAGTTCGAGAAA.txt
182919831 GACTACAAGGACGACGATGAT.txt
      301 CTACAAGCTTCTTATCATCGTCGTCCTTGTAGTC.txt
       77 CTACGAATTCCTGGAGCCATCCGCAGTTCG.txt
        0 GAACCGATTACTGTGAAGTTTGCCAAC.txt
        0 GTAGACAAAGATGCACCACCCAGTTC.txt
```



##	20240316

316 total

```
./preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out \
  --extension .fastq.gz ${PWD}/fastq/SRR???????.fastq.gz

./preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out \
  --extension _1.fastq.gz ${PWD}/fastq/SRR*_1.fastq.gz

mkdir out-loc
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive-local --threads 8 \
 -x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
 --single --extension .trim.fastq.gz --outdir ${PWD}/out-loc \
 ${PWD}/out/SRR*.trim.fastq.gz

mkdir out-e2e
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --threads 8 \
 -x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
 --single --extension .trim.fastq.gz --outdir ${PWD}/out-e2e \
 ${PWD}/out/SRR*.trim.fastq.gz

```



individual phage counts were normalized to reads per 100k (rpK) by dividing by the sum of counts and multiplying by 100,000.

```
for f in out-{e2e,loc}/*.human_peptidome_oligo_pool.bam.aligned_count.txt ; do
echo $f
sum=$( cat $f )
awk -v sum=${sum} '{$1=100000*$1/sum;print}' ${f%%aligned_count.txt}aligned_sequence_counts.txt > ${f%%aligned_count.txt}normalized_aligned_sequence_counts.txt
done

```






##	20240318


Merge everything in a single matrix and have a looksie

```
python3 ~/.local/bin/merge_uniq-c.py -o merged.csv out-e2e/*normalized_aligned_sequence_counts.txt

cat merged.csv | datamash transpose -t, > tmp1

awk 'BEGIN{FS="\t";OFS=","}(NR>1){print $4,$10}' filereport_read_run_PRJNA507500_tsv.txt | sort | awk 'BEGIN{FS=OFS=",";print "sample","patient"}{if( $2=="Viral sample from Escherichia phage T7" ){ $2=sprintf("control_%02d", ++i ) }print $1,$2}' > tmp2

join --header -t, tmp2 tmp1 > tmp3

cut -d, -f2 tmp3 > tmp4
cut -d, -f1,3- tmp3 > tmp5
paste -d, tmp4 tmp5 > tmp6
head -n 1 tmp6 > tmp7
tail -n +2 tmp6 | sort -t, -k1,1 >> tmp7

```

`filereport_read_run_PRJNA507500_tsv.txt` uses leading 0s in patient number. `sample_info` does not. correcting
(change `patient_1_CSF_rep1` to `patient_01_CSF_rep1`)

duplicated `patient_01_CSF_rep3` ??

```

cut -d, -f2- PhIP-PND-2018/experimental_data/sample_info.csv | sed '/patient_[[:digit:]]_/s/patient_/patient_0/' | uniq > tmp8

head -n 1 tmp8 > tmp9
tail -n +2 tmp8 | sort -t, -k1,1 >> tmp9

join --header -t, -a2 -oauto tmp9 tmp7 > tmp10
```



```
wc -l tmp10
317 tmp10

awk -F, '{print NF}' tmp10 | uniq
652416

```
 
How to determine Anti Yo and Anti Hu? And what does that mean?

Anti-Yo antibodies, also known as anti-Purkinje cell cytoplasmic antibody 1 (PCA-1)
Anti-Yo =? PCA1
Anti-Hu - guessing ANNA1

"the anti-Yo (n = 36 patients) and anti-Hu (n = 44 patients) syndromes."

```
grep PCA PhIP-PND-2018/experimental_data/sample_info.csv| cut -d, -f2 | cut -d_ -f2 | uniq | wc -l
37

grep ANNA PhIP-PND-2018/experimental_data/sample_info.csv| cut -d, -f2 | cut -d_ -f2 | uniq | wc -l
44
```

Not sure if that's correct, but close. Perhaps, one sample doesn't actually exist. CHECK THIS.

I'm gonna use the contents of each `PhIP-PND-2018/experimental_data/*_data` dir.


Healthy data are those that were lost during the join so need to put them back

```
ll PhIP-PND-2018/experimental_data/*_data/*v | wc -l
316

ll PhIP-PND-2018/experimental_data/YO_data/*v | wc -l
115

ll PhIP-PND-2018/experimental_data/HU_data/*v | wc -l
151

ll PhIP-PND-2018/experimental_data/healthy_data/*v | wc -l
50

ls -1 PhIP-PND-2018/experimental_data/YO_data/ | cut -d_ -f1,2 | uniq | wc -l
37

ls -1 PhIP-PND-2018/experimental_data/HU_data/ | cut -d_ -f1,2 | uniq | wc -l
44
```

The paper says anti-Yo is 36. Again I have 37?

Cool




```
mv tmp10 final_matrix.csv
chmod 400 final_matrix.csv
gzip final_matrix.csv
\rm tmp*
```



"We identified in our control IPs a set of the 100 most abundant peptides that also have a standard deviation less than their mean. This ‘internal control’ set represented the most abundant and consistent phage carried along specifically by the protein-AG beads or other reagents, in the absence of any antibody. We calculated a sample-specific scaling factor, defined as the ratio of median abundances (rpK) of these 100 peptides in our controls to their abundance in the given sample. Fold-change values were multiplied by their sample-specific scaling factor."


```
zcat final_matrix.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}(NR>9){ s=0;for(i=2;i<=NF;i++){s+=$i};print s }' | datamash min 1 q1 1 median 1 mean 1 q3 1 max 1

0.00708649	1.454915	6.73065	48.436022195343	24.48185	521264

zcat final_matrix.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}(NR>9){ s=0;for(i=2;i<=NF;i++){s+=$i};print s }' | wc -l
652407

zcat final_matrix.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}(NR>9){ s=0;for(i=2;i<=NF;i++){s+=$i};if(s>2){print s} }' | wc -l
461230
```






##	20240319

```
module load WitteLab python3/3.9.1
python3
```


```
from datetime import datetime
import pandas as pd
datetime.now().strftime("%H:%M:%S")

df=pd.read_csv('final_matrix.csv.gz',dtype={
    1:str,2:str,3:str,4:str,5:str,6:str
})

datetime.now().strftime("%H:%M:%S")

```




```
zcat final_matrix.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}
(NR>9){ 
sum=0;for(i=2;i<=NF;i++){sum+=$i}
mean=sum/(NF-1)
sigma=0;for(i=2;i<=NF;i++){sigma+=($i-mean)^2}
stddev=(sigma/(NF-1))^0.5
if(stddev<mean)print($1,mean,stddev,stddev<mean)
}'
```


```
gi|112382237|ref|NP_663780.2|_synemin_isoform_A_[Homo_sapiens]_fragment_2,3.90175,3.82067,1
gi|115292438|ref|NP_001041677.1|_cementoblastoma-derived_protein_1_[Homo_sapiens]_fragment_8,3.70168,3.65174,1
gi|28872814|ref|NP_060363.2|_semaphorin-4G_isoform_1_precursor_[Homo_sapiens]_fragment_24,5.58683,5.09348,1
gi|767961880|ref|XP_011537699.1|_PREDICTED:_deleted_in_malignant_brain_tumors_1_protein_isoform_X11_[Homo_sapiens]_fragment_73,1.46114,1.44627,1
```

Only 4?  That was for all samples and IS NOT what they did. They did controls ONLY.


"We identified in our control IPs a set of the 100 most abundant peptides that also have a standard deviation less than their mean."

```
zcat final_matrix.csv.gz | datamash transpose -t, | head -100 | cut -c1-150
file_id,control_01,control_02,control_03,control_04,control_05,control_06,control_07,control_08,control_09,control_10,control_11,control_12,control_13
GROUP,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,PCA1,PCA1,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,ANNA1,
TYPE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,CSF,CSF,CSF,CSF,SERUM,SERUM,CSF,CSF,CSF,CSF,CSF,CSF,SERUM,SERUM,SERUM,SERUM,CSF,CSF,SERUM,SERUM
DRAW DATE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,7/6/16,7/6/16,unk,unk,7/6/16,7/6/16,unk,unk,unk,unk,10/28/14,10/28/14,2/26/15,2/26/15,10/5
SEX,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,F,F,F,F,F,F,unk,unk,unk,unk,M,M,M,M,F,F,F,F,F,F,M,M,M,M,M,M,M,M,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
CANCER,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
AGE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,18,18,18,18,18,18,unk,unk,unk,unk,11,11,11,11,60,60,53,53,53,53,64,64,64,64,73,73,73,73,63,63,63
TITER,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,1024.0,1024.0,,,30720.0,30720.0,,,,,256.0,256.0,7680.0,7680.0,61440.0,61440.0,256.0,256.0,6144
sample,SRR8425734,SRR8425735,SRR8425736,SRR8425737,SRR8425738,SRR8425739,SRR8425740,SRR8425741,SRR8425742,SRR8425743,SRR8425744,SRR8425745,SRR8425746,
gi|10047090|ref|NP_055147.1|_small_muscular_protein_[Homo_sapiens]_fragment_0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
gi|10047090|ref|NP_055147.1|_small_muscular_protein_[Homo_sapiens]_fragment_1,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
gi|10047090|ref|NP_055147.1|_small_muscular_protein_[Homo_sapiens]_fragment_2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
gi|10047100|ref|NP_057387.1|_WW_domain-binding_protein_5_[Homo_sapiens]_fragment_0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.120145,0.0,0.0,0.0,0.0,0.0,0.0,0.
gi|10047100|ref|NP_057387.1|_WW_domain-binding_protein_5_[Homo_sapiens]_fragment_2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
gi|10047100|ref|NP_057387.1|_WW_domain-binding_protein_5_[Homo_sapiens]_fragment_3,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
```


```
zcat final_matrix.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}
(NR>9){ 
sum=0;for(i=2;i<=51;i++){sum+=$i}
mean=sum/(51-1)
sigma=0;for(i=2;i<=51;i++){sigma+=($i-mean)^2}
stddev=(sigma/(51-1))^0.5
if(stddev<mean)print($1,mean,stddev,stddev<mean)
}'
```

Hmm. Just one? Something's wrong.

```
gi|768007069|ref|XP_011524869.1|_PREDICTED:_zinc_finger_protein_550_isoform_X1_[Homo_sapiens]_fragment_8,0.0740172,0.0666633,1
```




```
grep --no-filename 'gi|578830991|ref|XP_006721985.1|_PREDICTED:_neurofibromin_isoform_X1_\[Homo_sapiens\]_fragment_21' out-e2e/{SRR8425734,SRR8425735,SRR8425736,SRR8425737,SRR8425738,SRR8425739,SRR8425740,SRR8425741,SRR8425742,SRR8425743,SRR8425744,SRR8425745,SRR8425746,SRR8425747,SRR8425748,SRR8425749,SRR8425750,SRR8425751,SRR8425752,SRR8425753,SRR8425754,SRR8425755,SRR8425756,SRR8425757,SRR8425758,SRR8425759,SRR8425760,SRR8425761,SRR8425762,SRR8425763,SRR8425764,SRR8425765,SRR8425766,SRR8425767,SRR8425768,SRR8425769,SRR8425770,SRR8425771,SRR8425772,SRR8425773,SRR8425774,SRR8425775,SRR8425776,SRR8425777,SRR8425778,SRR8425779,SRR8425780,SRR8425781,SRR8425782,SRR8425783}*normal* | cut -d" " -f1

0.0376349
0.0328823
0.0179941
0.289012
1.98618
0.201266
0.0236633
0.014173
0.0388862
0.0496311
0.213082


grep --no-filename '^gi|578830991|ref|XP_006721985.1|_PREDICTED:_neurofibromin_isoform_X1_\[Homo_sapiens\]_fragment_21' PhIP-PND-2018/experimental_data/healthy_data/healthy_serum_*_peptide_counts.csv | cut -d, -f2

0.39876992769599995
0.080263070239
0.0665182422954
0.0639192469801
0.215086604621
0.0545329417141
0.059114127508
0.163829503728
0.788341653258
4.17341065635
0.140564634079
0.06030439245130001

```

My counts are smaller and fewer than theirs. Hmm.

Did I overfilter on quality?
Did I align too tightly?
Did I normalize incorrectly?
Should I try local rather than end-to-end?
Perhaps --all?

They didn't provide the parameters that they used for filtering and alignment







Testing


```
mkdir outtest
for s in SRR8425734 SRR8425735 SRR8425736 SRR8425737 SRR8425738 SRR8425739 SRR8425740 SRR8425741 SRR8425742 SRR8425743 SRR8425744 SRR8425745 SRR8425746 SRR8425747 SRR8425748 SRR8425749 SRR8425750 SRR8425751 SRR8425752 SRR8425753 SRR8425754 SRR8425755 SRR8425756 SRR8425757 SRR8425758 SRR8425759 SRR8425760 SRR8425761 SRR8425762 SRR8425763 SRR8425764 SRR8425765 SRR8425766 SRR8425767 SRR8425768 SRR8425769 SRR8425770 SRR8425771 SRR8425772 SRR8425773 SRR8425774 SRR8425775 SRR8425776 SRR8425777 SRR8425778 SRR8425779 SRR8425780 SRR8425781 SRR8425782 SRR8425783 ; do
echo $s
if [ -f fastq/${s}.fastq.gz ] ;then
ln -s ../fastq/${s}.fastq.gz outtest/${s}.fastq.gz
else
ln -s ../fastq/${s}_1.fastq.gz outtest/${s}.fastq.gz
fi
done
```


```
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive-local --threads 8 \
 -x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
 --single --extension .fastq.gz --outdir ${PWD}/outtest \
 ${PWD}/outtest/SRR*.fastq.gz
```

```
grep --no-filename 'gi|578830991|ref|XP_006721985.1|_PREDICTED:_neurofibromin_isoform_X1_\[Homo_sapiens\]_fragment_21' outtest/{SRR8425734,SRR8425735,SRR8425736,SRR8425737,SRR8425738,SRR8425739,SRR8425740,SRR8425741,SRR8425742,SRR8425743,SRR8425744,SRR8425745,SRR8425746,SRR8425747,SRR8425748,SRR8425749,SRR8425750,SRR8425751,SRR8425752,SRR8425753,SRR8425754,SRR8425755,SRR8425756,SRR8425757,SRR8425758,SRR8425759,SRR8425760,SRR8425761,SRR8425762,SRR8425763,SRR8425764,SRR8425765,SRR8425766,SRR8425767,SRR8425768,SRR8425769,SRR8425770,SRR8425771,SRR8425772,SRR8425773,SRR8425774,SRR8425775,SRR8425776,SRR8425777,SRR8425778,SRR8425779,SRR8425780,SRR8425781,SRR8425782,SRR8425783}*.aligned_sequence_counts.txt | cut -f1
```

Even less.






##	20240302

Using `--all` suggested a possible increase in these numbers.

```
mkdir out-e2e-all
bowtie2_array_wrapper.bash --no-unal --sort --very-sensitive --all --threads 8 \
 -x ~/github/derisilab-ucsf/PhIP-PND-2018/library_design/human_peptidome_oligo_pool \
 --single --extension .trim.fastq.gz --outdir ${PWD}/out-e2e-all \
 ${PWD}/out/SRR*.trim.fastq.gz
```

```
for f in out-e2e-all/*.human_peptidome_oligo_pool.bam.aligned_count.txt ; do
echo $f
sum=$( cat $f )
awk -v sum=${sum} '{$1=100000*$1/sum;print}' ${f%%aligned_count.txt}aligned_sequence_counts.txt > ${f%%aligned_count.txt}normalized_aligned_sequence_counts.txt
done

```











Merge everything in a single matrix and have a looksie

```
python3 ~/.local/bin/merge_uniq-c.py -o merged.all.csv out-e2e-all/*normalized_aligned_sequence_counts.txt

chmod 400 merged.all.csv
gzip merged.all.csv


zcat merged.all.csv.gz | datamash transpose -t, > tmp1

awk 'BEGIN{FS="\t";OFS=","}(NR>1){print $4,$10}' filereport_read_run_PRJNA507500_tsv.txt | sort | awk 'BEGIN{FS=OFS=",";print "sample","patient"}{if( $2=="Viral sample from Escherichia phage T7" ){ $2=sprintf("control_%02d", ++i ) }print $1,$2}' > tmp2

join --header -t, tmp2 tmp1 > tmp3

cut -d, -f2 tmp3 > tmp4
cut -d, -f1,3- tmp3 > tmp5
paste -d, tmp4 tmp5 > tmp6
head -n 1 tmp6 > tmp7
tail -n +2 tmp6 | sort -t, -k1,1 >> tmp7

```

`filereport_read_run_PRJNA507500_tsv.txt` uses leading 0s in patient number. `sample_info` does not. correcting
(change `patient_1_CSF_rep1` to `patient_01_CSF_rep1`)

duplicated `patient_01_CSF_rep3` ?? so added uniq

```

cut -d, -f2- PhIP-PND-2018/experimental_data/sample_info.csv | sed '/patient_[[:digit:]]_/s/patient_/patient_0/' | uniq > tmp8

head -n 1 tmp8 > tmp9
tail -n +2 tmp8 | sort -t, -k1,1 >> tmp9

join --header -t, -a2 -oauto tmp9 tmp7 > tmp10
```



```
wc -l tmp10
317 

awk -F, '{print NF}' tmp10 | uniq
729880
```
 


```
mv tmp10 final_matrix.all.csv
chmod 400 final_matrix.all.csv
gzip final_matrix.all.csv
\rm tmp*
```


```
zcat final_matrix.all.csv.gz | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}
(NR>9){ 
sum=0;for(i=2;i<=51;i++){sum+=$i}
mean=sum/(51-1)
sigma=0;for(i=2;i<=51;i++){sigma+=($i-mean)^2}
stddev=(sigma/(51-1))^0.5
if(stddev<mean)print($1,mean,stddev,stddev<mean)
}'
```

```
gi|768007069|ref|XP_011524869.1|_PREDICTED:_zinc_finger_protein_550_isoform_X1_[Homo_sapiens]_fragment_8,0.0750526,0.066209,1
```


All that and still just one!




