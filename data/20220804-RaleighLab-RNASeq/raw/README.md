
#	20220804-RaleighLab-RNASeq


Meningioma? HKU? Hong Kong University


Raw Raw

ll /raleighlab/data1/wcc/portal-us.medgenome.com/FASTQ/



Trimmed

```
ll /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*trimmed.1.fastq.gz
```

I don't quite get why the bam file is SO MUCH BIGGER

FASTQs are 10GB each. BAM should be just a bit more than 20GB. Its 130GB?

```
ll /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91Aligned.sortedByCoord.out.bam
-rw-r--r-- 1 naomizakimi raleighlab 129246902751 Dec 22 14:27 /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91Aligned.sortedByCoord.out.bam

ll /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91_trimmed.1.fastq.gz
-rw-r--r-- 1 naomizakimi raleighlab 9232833855 Sep  8  2022 /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91_trimmed.1.fastq.gz

samtools view -c /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91Aligned.sortedByCoord.out.bam  
404070801

zcat /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM91_trimmed.1.fastq.gz | sed -n '1~4p' | wc -l
135675293
```



```
cp /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM138_trimmed.?.fastq.gz ./
cp /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM138Aligned.sortedByCoord.out.bam ./
samtools view -h QM138Aligned.sortedByCoord.out.bam > QM138Aligned.sortedByCoord.out.sam
samtools view -h -o QM138Aligned.sortedByCoord.out.new.bam QM138Aligned.sortedByCoord.out.bam


samtools view -c QM138Aligned.sortedByCoord.out.sam 
218339710
samtools view -c QM138Aligned.sortedByCoord.out.bam
218339710
samtools view -c QM138Aligned.sortedByCoord.out.new.bam
218339710

ll QM*
-rw-r----- 1 gwendt francislab  6445113719 May 10 20:35 QM138_trimmed.1.fastq.gz
-rw-r----- 1 gwendt francislab  6600284076 May 10 20:37 QM138_trimmed.2.fastq.gz
-rw-r----- 1 gwendt francislab 69496664758 May 10 20:43 QM138Aligned.sortedByCoord.out.bam
-rw-r----- 1 gwendt francislab 89127593261 May 10 21:03 QM138Aligned.sortedByCoord.out.sam
-rw-r----- 1 gwendt francislab  6994161534 May 10 21:51 QM138Aligned.sortedByCoord.out.new.bam


zcat QM138_trimmed.1.fastq.gz > QM138_trimmed.1.fastq
cat QM138_trimmed.1.fastq | bgzip > QM138_trimmed.bgzip.1.fastq
cat QM138_trimmed.1.fastq | gzip > QM138_trimmed.gzip.1.fastq


```












```
ssh d1
cd /francislab/data1/raw/20220804-RaleighLab-RNASeq
mkdir strand_check

for bai in /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*Aligned.sortedByCoord.out.bam.bai; do
bam=${bai%%.bai}
echo $bam
f=strand_check/$(basename ${bai} .bam.bai).strand_check.txt
if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f}
fi
done
```



```
for f in strand_check/*.strand_check.txt ; do
awk -F: '($1=="Fraction of reads explained by \"1+-,1-+,2++,2--\""){if($2<0.1){print "--fr"}else if($2>0.9){print "--rf"}else{print "none"}}' ${f}
done | sort | uniq -c


     10 none
    292 --rf

```


Strand check shows that these data are ( --rf / fr-firststrand )





```
mkdir trimmed
for f in /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*Aligned.sortedByCoord.out.bam* ; do
l=$(basename $f)
l=${l/Aligned.sortedByCoord.out.bam/.Aligned.sortedByCoord.out.bam}
ln -s ${f} trimmed/${l}
done
```


```
for f in /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*_trimmed.?.fastq.gz ; do
l=$(basename $f)
l=${l/_trimmed/}
ln -s ${f} trimmed/${l}
done
```


```
awk 'BEGIN{OFS=FS=","}(NR>1){print $1,$12}' HKU_AllFusions/Integrated_data_working-Table\ 1.csv | sort > ids_DNA_methylation_group.csv

```


```
for bai in trimmed/QM*.Aligned.sortedByCoord.out.bam.bai ; do
echo $bai
f=${bai}.read_count.txt
if [ ! -f ${f} ] ; then
cat $bai | bamReadDepther | awk '(/^[#*]/){s+=$2+$3}END{print s}' > ${f}
chmod -w ${f}
fi
done
```



```
for f in trimmed/QM*.Aligned.sortedByCoord.out.bam.bai.read_count.txt ; do
b=$( basename $f .Aligned.sortedByCoord.out.bam.bai.read_count.txt )
c=$( cat $f )
echo ${b},${c}
done | sort -t, -k2nr

```

Why are some odd? Multiple alignments! ERRRR
```
QM315,226044724
QM136,223145285
QM304,221835393
QM74,219763372
QM138,218339710
```

No way to filter read count from index file so ...


```
samtools_count_array_wrapper.bash trimmed/QM*bam
```

Still not always even?

```
fast_count_array_wrapper.bash trimmed/QM*.1.fastq.gz 
```







20230531
```
grep -E 'gene_name "GAPDH"|gene_name "TP53"' /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/genome-lib/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_annot.gff3 > select.gff3

grep -E 'gene_name "GAPDH"|gene_name "TP53"' /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/genome-lib/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_annot.gtf > select.gtf


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCtranscript" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCtranscript.${date}.out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_name -a ${PWD}/select.gtf -o ${PWD}/QM.TP53.GAPDH.transcript.tsv ${PWD}/trimmed/Q*bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCexon" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCexon.${date}.out.log \
--wrap="featureCounts.bash -T 16 -t exon -g gene_name -a ${PWD}/select.gtf -o ${PWD}/QM.TP53.GAPDH.exon.tsv ${PWD}/trimmed/Q*bam"

```
