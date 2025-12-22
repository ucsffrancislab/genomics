
#	20220804-RaleighLab-RNASeq/20251212-VIRTUS2



/francislab/data1/refs/VIRTUS2/

```bash
#for r1 in /francislab/data1/raw/20220804-RaleighLab-RNASeq/20240723/QM*_trimmed.1.fastq.gz ; do
# r2=${r1/_trimmed.1.fastq/_trimmed.2.fastq}
# base=$( basename ${r1} _trimmed.1.fastq.gz )

for r1 in /francislab/data1/working/20220804-RaleighLab-RNASeq/20240723-cutadapt/out/*_R1.fastq.gz ; do
 r2=${r1/R1.fastq/R2.fastq}

 base=$( basename ${r1} _R1.fastq.gz )
 mkdir -p ${PWD}/out/${base}/

 echo "cd ${PWD}/out/${base}/; \
  export CWL_SINGULARITY_CACHE=/francislab/data1/refs/VIRTUS2/; \
  cwltool --singularity ~/github/yyoshiaki/VIRTUS2/bin/VIRTUS.PE.cwl \
   --fastq1 ${r1} --fastq2 ${r2} \
   --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
   --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus \
   --outFileNamePrefix_human human \
   --nthreads 8"

done > commands

commands_array_wrapper.bash --jobname M_VIRTUS2 --array_file commands --time 1-0 --threads 8 --mem 60G

```

These are running about 3 hours / sample




```
#for r1 in /francislab/data1/working/20220804-RaleighLab-RNASeq/20240723-cutadapt/out/*_R1.fastq.gz ; do
#for r1 in /francislab/data1/raw/20220804-RaleighLab-RNASeq/20240723/QM*_trimmed.1.fastq.gz ; do
```

both

trying the original. odd as this bam was created by the pipeline
I think it may be the style of read name? and not my filtering?

This is odd. The reads are paired, but one didn't align. It is in the bam file.
Unclear why it says "unrecognized mate reference name"

The duplication rate of TCGA is low, max of 10%

```
grep "Duplication rate" logs/commands_array_wrapper.bash.*.out.log 
logs/commands_array_wrapper.bash.20251212072815097245476-950533_1.out.log:Duplication rate: 41.742%
logs/commands_array_wrapper.bash.20251212072815097245476-950533_2.out.log:Duplication rate: 88.2006%
logs/commands_array_wrapper.bash.20251212072815097245476-950533_3.out.log:Duplication rate: 43.7325%

logs/commands_array_wrapper.bash.20251212090026509126646-950707_1.out.log:Duplication rate: 41.3777%
logs/commands_array_wrapper.bash.20251212090026509126646-950707_2.out.log:Duplication rate: 88.2582%
logs/commands_array_wrapper.bash.20251212090026509126646-950707_3.out.log:Duplication rate: 43.4213%






    -c \
    samtools_view_removemulti.sh  8  4 /var/lib/cwl/stg281da82a-6517-433d-bfc3-6d516f4312c8/humanAligned.sortedByCoord.out.bam > /scratch/gwendt/950534/kyz24o9h/human.unmapped.bam
[W::sam_parse1] unrecognized mate reference name "chr2"; treated as unmapped
[W::sam_parse1] unrecognized mate reference name "chr1"; treated as unmapped
[W::sam_parse1] unrecognized mate reference name "chr6"; treated as unmapped
[W::sam_parse1] unrecognized mate reference name "chr10"; treated as unmapped
[W::sam_parse1] unrecognized mate reference name "chr7"; treated as unmapped
[W::sam_parse1] unrecognized mate reference name "chr17"; treated as unmapped


*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:8847:27806 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:2519:29089 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:16360:29262 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:9914:29371 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:19397:29387 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:7328:29684 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:5068:30185 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
*****WARNING: Query A00354:827:HNMTJDSX3:4:1509:11324:30467 is marked as paired, but its mate does not occur next to it in your BAM file.  Skipping. 
```






Only useful if multiple groups to compare and if enough viral threshold surpassed.





```bash
\rm out/*input.csv
for r1 in /francislab/data1/working/20220804-RaleighLab-RNASeq/20240723-cutadapt/out/*_R1.fastq.gz ; do
 base=$( basename ${r1} _R1.fastq.gz )
 if [[ -f out/${base}/VIRTUS.output.tsv ]] && [[ $( wc -l < out/${base}/VIRTUS.output.tsv ) -gt 1 ]] ; then
   awk -v base=$base 'BEGIN{FS=OFS=","}( $1 == base ){print base,base,"PE",$2 >> "out/"$2".input.csv" }' \
     /francislab/data1/raw/20220804-RaleighLab-RNASeq/ids_DNA_methylation_group.csv
 fi
done

cat out/*.input.csv > out/input.csv

sed -i '1iName,Fastq,Layout,Group' out/input.csv
sed -i '1iName,Fastq,Layout,Group' out/Merlin-intact.input.csv
sed -i '1iName,Fastq,Layout,Group' out/Immune-enriched.input.csv
sed -i '1iName,Fastq,Layout,Group' out/Hypermitotic.input.csv
```



```bash

wc -l out/*input.csv
   83 out/Hypermitotic.input.csv
  110 out/Immune-enriched.input.csv
  295 out/input.csv
  104 out/Merlin-intact.input.csv
  592 total


wc -l out/QM*/VIRTUS.output.tsv | sort -k1n,1
     1 out/QM101/VIRTUS.output.tsv
     1 out/QM105/VIRTUS.output.tsv
     1 out/QM181/VIRTUS.output.tsv
     1 out/QM219/VIRTUS.output.tsv
     1 out/QM221/VIRTUS.output.tsv
     1 out/QM242/VIRTUS.output.tsv
     1 out/QM59/VIRTUS.output.tsv
```




Be sure to change the scatterplot call to square=False

```bash
cd out

for s in Merlin-intact Immune-enriched Hypermitotic ; do
echo ${s}
~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py ${s}.input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human --th_rate 0.0000001 \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus
mv summary.csv ${s}.summary.csv
mv scattermap.pdf ${s}.scattermap.pdf
done

~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human --th_rate 0.0000001 \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus

cd ..
box_upload.bash out/*scattermap.pdf out/*summary.csv
```



