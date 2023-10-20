
#	20201006-GTEx/20231002-STAR-HumanViral

1438 samples


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR*_R1.fastq.gz
```


```
module load samtools
for b in out/*bam ; do s=$( basename $b .Aligned.sortedByCoord.out.bam ); c=$( samtools view -f66 $b NC_007605.1 | wc -l ) ; echo $s,$c; done
```



##	20231011


Checking for any chimeric aligned pairs.

```
for bam in out/SRR*bam ; do 
echo $bam
samtools view -c -F14 ${bam}
done
```

NOTHING!



Several failed due to memory

```
grep -l "not enough mem" logs/STAR_array_wrapper.bash.* | awk -F_ '{print $NF}' | awk -F. '{print $1}' | sort -n | paste -sd,
288,723,761,1049,1050,1051,1052,1053,1054
```

```
STAR_array_wrapper.bash --threads 16 \
  --array 288,723,761,1049,1050,1051,1052,1053,1054 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR*_R1.fastq.gz
```



##	20231017

```
module load samtools
for bam in out/SRR*.Aligned.sortedByCoord.out.bam ; do
echo ${bam}
base=$( basename ${bam} .Aligned.sortedByCoord.out.bam )
o=${bam}.proper_pair_viral_counts.csv
if [ ! -f ${o} ] ; then
for virus in $( awk '($2~/^.C_/){print $2}' ${bam}.aligned_sequence_counts.txt ) ; do
c=$( samtools view -c -q40 -f66 ${bam} ${virus} )
if [ ${c} -gt 0 ] ; then
echo ${virus},${c} >> ${o}
fi
done ; fi ; done

```





##	20231018



```

echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv

awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Brain.NoResequencing.csv

awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$8}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > BioSample.NoResequencing.csv

awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$10}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > biospecimen_repository_sample_id.NoResequencing.csv

awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$11}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > body_site.NoResequencing.csv

cut -d, -f2 body_site.NoResequencing.csv | sort -u



```

python3 ./merge_proper_pair_viral_counts.py --int -o merged.csv out/*.proper_pair_viral_counts.csv

cat merged.csv | datamash transpose -t, > tmp2
join -t, --header body_site.NoResequencing.csv tmp2 > tmp3
join -t, --header BioSample.NoResequencing.csv tmp3 > tmp4
join -t, --header biospecimen_repository_sample_id.NoResequencing.csv tmp4 > tmp5
cat tmp5 | datamash transpose -t, > tmp6

head -3 tmp6 | sed 's/,/,description,/' > merged_raw_proper_pair_viral_counts.csv
join -t, --header accession_description.csv <( tail -n +4 tmp6 ) >> merged_raw_proper_pair_viral_counts.csv

cat merged_raw_proper_pair_viral_counts.csv | datamash transpose -t, > merged_raw_proper_pair_viral_counts.t.csv

box_upload.bash merged_raw_proper_pair_viral_counts*csv
\rm tmp?

```




