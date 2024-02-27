
#	20230726-Illumina-CystEV/20230809-preprocess


So wrong adapters in 20230801-cutadapt
And we have a UMI which I didn't deal with



Continue Format filter? Yes. 18+GTT - keep a count
Where is the UMI? Beginning of R2?
Use UMI and deduplicate or just trim and ignore? dedup
Deup and preserve unaligned? Ignore unaligned for now.
Viral discover on cyst fluid samples only?
Create model for old and new cyst fluid only and test on serum.
Trim precede TTTTTTT on R2?
Create report



```

EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension _R1.fastq.gz \
  /francislab/data1/raw/20230726-Illumina-CystEV/fastq/*R1.fastq.gz


```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
box_upload.bash report.csv
```






```
```



```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCtranscriptgenetype" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCtranscriptgenetype.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_type \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.transcript.gene_type.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCtranscriptgenename" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCtranscriptgenename.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_name \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.transcript.gene_name.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCexongenename" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCexongenename.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t exon -g gene_name \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.exon.gene_name.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAName" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA.Name.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAtranscriptName" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAtranscriptName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA_primary_transcript -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA_primary_transcript.Name.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fC2waytranscriptgene_id" \
--time=1-0 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fC2waytranscriptgene_id.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_id \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.2wayconspseudos.gtf.gz \
-o ${PWD}/featureCounts.2way.transcript.gene_id.tsv \
${PWD}/out/*.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam"

```






post process like ... /francislab/data1/working/20230726-Illumina-CystEV/20230801-STAR-GRCh38/README.md

```
awk 'BEGIN{FS=OFS=","}{print $1,$6"-"$7}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.csv > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) > metadata.csv
\rm tmp1
```

```
for f in featureCounts.*.tsv ; do 
echo $f
sed -e '2s/.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam//g' \
  -e '2s:/francislab/data1/working/20230726-Illumina-CystEV/20230809-preprocess/out/::g' \
  $f | tail -n +2 | cut --output-delimiter=, -f1,7- > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) | datamash transpose -t, > tmp2
(head -n 1 tmp2 && tail -n +2 tmp2 | sort -t, -k1,1 ) > tmp3
join --header -t, metadata.csv tmp3 | datamash transpose -t, > ${f%.tsv}.clean.csv
done
\rm tmp?

```


```
box_upload.bash featureCounts*.clean.csv
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
bowtie2_array_wrapper.bash --sort --extension .R1.fastq.gz --very-sensitive --threads 32 \
-x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome+viral+bacteria+protozoa \
--outdir ${PWD}/GRCh38.primary_assembly.genome+viral+bacteria+protozoa \
${PWD}/out/{1_11,4_10,7_7,8_4}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R1.fastq.gz
```



