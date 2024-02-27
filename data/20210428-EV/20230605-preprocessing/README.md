
#	20210428-EV/20230605-preprocessing





```
mkdir -p in

for f in /francislab/data1/raw/20210428-EV/Hansen/SFHH00*_R1_001.fastq.gz ; do
echo $f
l=$( basename ${f} _R1_001.fastq.gz )
echo $l
l=${l%_S*}
echo ${l}
ln -s ${f} in/${l}.fastq.gz
done
```



```
EV_preprocessing_array_wrapper.bash \
--threads 8 \
--extension .fastq.gz \
--out ${PWD}/out \
${PWD}/in/SFHH00*.fastq.gz
```



##	20230614




/francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3


```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCgenetranscript" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCgenetranscript.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_name \
-a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
-o ${PWD}/featureCounts.transcript.gene_name.tsv ${PWD}/out/SFHH005*.umi_tag.dups.deduped.bam"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCgeneexon" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCgeneexon.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t exon -g gene_name \
-a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
-o ${PWD}/featureCounts.exon.gene_name.tsv ${PWD}/out/SFHH005*.umi_tag.dups.deduped.bam"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAName" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA.Name.tsv ${PWD}/out/SFHH005*.umi_tag.dups.deduped.bam"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAtranscriptName" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAtranscriptName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA_primary_transcript -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA_primary_transcript.Name.tsv ${PWD}/out/SFHH005*.umi_tag.dups.deduped.bam"

```


```
for f in featureCounts.*.tsv ; do
sed -i -e '2s/.umi_tag.dups.deduped.bam//g' -e '2s:/francislab/data1/working/20210428-EV/20230605-preprocessing/out/::g' $f
done

for f in featureCounts.*e.tsv ; do
awk 'BEGIN{FS=OFS="\t"}(NR>2){sum=0;for(i=7;i<=NF;i++){sum+=$i}if(sum>0){print $1,$2,$3,$4,$5,$6,sum}}' ${f} | sort -k7nr > ${f%.tsv}.total_count.tsv
done

for f in featureCounts.*e.tsv ; do
awk 'BEGIN{FS=OFS="\t"}(NR>2){sum=0;for(i=7;i<=NF;i++){if($i>0){sum+=1}}if(sum>0){print $1,$2,$3,$4,$5,$6,sum}}' ${f} | sort -k7nr > ${f%.tsv}.sample_count.tsv
done


for f in featureCounts.*.tsv ; do
awk 'BEGIN{FS=OFS="\t"}(NR==2){print}(NR>2){sum=0;for(i=7;i<=NF;i++){sum+=$i}if(sum>0){print}}' ${f} > ${f%.tsv}.nonzero.tsv
done

```



```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in featureCounts.*.tsv featureCounts*_count.tsv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```






##	20240129 - blank content investigation


/francislab/data1/working/20210428-EV/20230605-preprocessing

/francislab/data1/working/20230726-Illumina-CystEV/20230809-preprocess

```
SFHH005v	blank
SFHH005ar	blank
1_11	blank
4_10	blank
7_7	blank
8_4	blank
```

```
bowtie2_array_wrapper.bash --sort --extension .fastq.gz --very-sensitive --threads 32 \
-x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome+viral+bacteria+protozoa \
--outdir ${PWD}/GRCh38.primary_assembly.genome+viral+bacteria+protozoa \
${PWD}/out/SFHH005{v,ar}.umi_tag.dups.deduped.fastq.gz
```




