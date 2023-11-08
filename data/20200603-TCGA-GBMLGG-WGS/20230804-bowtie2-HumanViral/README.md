

#	20200603-TCGA-GBMLGG-WGS/20230804-bowtie2-HumanViral


Why didn't I sort!

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



##	20230906


Look at the sequences
```
awk -F, -v accession=NC_053004.1 -v score=30 '(($10==accession)&&($9>score)){print $13}(($4==accession)&&($3>score)){print $7}' out/*discordant_matrix.joined.csv
```




```
ln -s /francislab/data1/working/20211111-hg38-viral-homology/RMHM/NC_053004.1.fasta 

ln -s /francislab/data1/working/20211111-hg38-viral-homology/RMHM/NC_037053.1.fasta 

box_upload.bash NC_0*fasta
```


Extrac

```
module load samtools

samtools view -h -q 40 -F14 out/02-2485-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam |  awk '(/^@/||$3=="NC_053004.1")' > 02-2485-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.F14.q40.NC_053004.1.viral.sam &

samtools view -h -q 40 -F14 out/02-2485-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam |  awk '(/^@/||$7=="NC_053004.1")' > 02-2485-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.F14.q40.NC_053004.1.human.sam &


samtools view -h -q 40 -F14 out/02-2485-10A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam |  awk '(/^@/||$3=="NC_037053.1")' > 02-2485-10A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.F14.q40.NC_037053.1.viral.sam &

samtools view -h -q 40 -F14 out/02-2485-10A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam |  awk '(/^@/||$7=="NC_037053.1")' > 02-2485-10A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.F14.q40.NC_037053.1.human.sam &


for sam in *.sam ; do
samtools sort -o ${sam%.sam}.bam ${sam}
samtools index ${sam%.sam}.bam
done

box_upload.bash *bam *bam.bai

```





##	20230926


```
bowtie2-build NC_037053.1.fasta NC_037053.1


bowtie2_array_wrapper.bash --threads 8 --very-sensitive --no-unal \
  --ref ${PWD}/NC_037053.1 \
  --out ${PWD}/out_NC_037053.1 \
  ${PWD}/../20230803-cutadapt/out/02-2485-10A-01D-1494*_R1.fastq.gz

bowtie2_array_wrapper.bash --threads 8 --very-sensitive --all --no-unal \
  --ref ${PWD}/NC_037053.1 \
  --out ${PWD}/out_NC_037053.1_all \
  ${PWD}/../20230803-cutadapt/out/02-2485-10A-01D-1494*_R1.fastq.gz

```


```

samtools sort -O SAM -o - out_NC_037053.1_all/02-2485-10A-01D-1494.NC_037053.1.bam | awk '{$5="XXX";print}' > out_NC_037053.1_all/02-2485-10A-01D-1494.NC_037053.1.sam
samtools sort -O SAM -o - out_NC_037053.1/02-2485-10A-01D-1494.NC_037053.1.bam | awk '{$5="XXX";print}' > out_NC_037053.1/02-2485-10A-01D-1494.NC_037053.1.sam

sdiff out_NC_037053.1*/02-2485-10A-01D-1494.NC_037053.1.sam | head

```


##	20230928


```
module load samtools
for bam in out/[0-9]*bam ; do 
echo $bam
o=${bam}.discordant_matrix.joined.csv
if [ -f ${o} ] ; then
echo "${o} exists. Skipping"
else
samtools view -F14 ${bam} | awk -v bam=${bam} '{OFS=","}(($3~/(chr|KI|GL)/&&$7~/(AC|NC)/)||($3~/(AC|NC)/&&$7~/(chr|KI|GL)/)){ read=(and(64,$2))?"1":"2"; pos=($3~/_/)?$4:int($4/1000)*1000;print $1,read,$5,$3,pos,length($10),$10 > bam".discordant_matrix."read".csv"}'
sort -k1,1 ${bam}.discordant_matrix.1.csv > ${bam}.discordant_matrix.sorted.1.csv
sort -k1,1 ${bam}.discordant_matrix.2.csv > ${bam}.discordant_matrix.sorted.2.csv
join -t, ${bam}.discordant_matrix.sorted.1.csv ${bam}.discordant_matrix.sorted.2.csv > ${o}
fi
done

for f in out/*.discordant_matrix.joined.csv ; do
echo $f
awk -F, '($3>40)&&($9>40)&&($6>50)&&($12>50){print $10,$4,$5;print $4,$10,$11}' $f | grep "^.C_" | sort -k1,1 -k2,2 -k3n,3 | uniq -c | awk 'BEGIN{OFS=","}{print $2,$3,$4,$1}' > tmp
join -t, tmp accession_description.csv
done
```



##	20231027


```
sbatch --job-name="featureCounts" --ntasks=64 --mem=495G --time=14-0 --export=NONE --wrap="~/.local/bin/featureCounts.bash -T 64 -a /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.gtf -t protein -g protein_id -o ${PWD}/featureCounts.HHV3_proteins.csv ${PWD}/out/*.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam"

```

##	20231031
```
cat featureCounts.HHV3_proteins.csv | awk -F"\t" '{s=0;for(i=7;i<=NF;i++)s+=$i; print $1,s}'
```








##	20231107

Redo featureCounting on all the samples


```
sbatch --job-name="featureCounts" --ntasks=64 --mem=495G --time=14-0 --export=NONE --wrap="~/.local/bin/featureCounts.bash -T 64 -a /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3_proteins_in_Human_herpesvirus_3_genome.gtf -t protein -g protein_id -o ${PWD}/featureCounts.HHV3_proteins.csv ${PWD}/out/*.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam"

```

```
cat featureCounts.HHV3_proteins.csv | awk -F"\t" '{s=0;for(i=7;i<=NF;i++)s+=$i; print $1,s}'
```



