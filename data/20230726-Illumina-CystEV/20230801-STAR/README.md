


#	20230726-Illumina-CystEV/20230801-STAR


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230801-cutadapt/out/*_R1.fastq.gz

```




```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCtranscriptgenetype" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCtranscriptgenetype.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_type \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.transcript.gene_type.tsv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCtranscriptgenename" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCtranscriptgenename.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t transcript -g gene_name \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.transcript.gene_name.tsv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCexongenename" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCexongenename.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t exon -g gene_name \
-a /francislab/data1/refs/sources/gencodegenes.org/release_43/gencode.v43.primary_assembly.annotation.gtf \
-o ${PWD}/featureCounts.exon.gene_name.tsv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAName" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA.Name.tsv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="fCmiRNAtranscriptName" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/fCmiRNAtranscriptName.$( date "+%Y%m%d%H%M%S" ).out.log \
--wrap="featureCounts.bash -T 16 -t miRNA_primary_transcript -g Name \
-a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 \
-o ${PWD}/featureCounts.miRNA_primary_transcript.Name.tsv ${PWD}/out/*.Aligned.sortedByCoord.out.bam"

```



```
awk 'BEGIN{FS=OFS=","}{print $1,$21}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.Kirkwood.csv > tmp

(head -n 1 tmp && tail -n +2 tmp | sort -t, -k1,1 ) > kirkwood.csv
\rm tmp
```



```
for f in featureCounts.*.tsv ; do
sed -e '2s/.Aligned.sortedByCoord.out.bam//g' -e '2s:/francislab/data1/working/20230726-Illumina-CystEV/20230801-STAR/out/::g' $f | tail -n +2 | cut --output-delimiter=, -f1,7- | datamash transpose -t, > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) | datamash transpose -t, > tmp2
(head -n 1 tmp2 && tail -n +2 tmp2 | sort -t, -k1,1 ) | datamash transpose -t, > tmp3
join --header -t, kirkwood.csv tmp3 > tmp4
(head -n 1 tmp4 && tail -n +2 tmp4 | sort -t, -k2,2 -k1,1 ) | datamash transpose -t, > ${f%.tsv}.grade.csv
done
\rm tmp1 tmp2 tmp3 tmp4
```




```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in featureCounts.*.grade.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```





