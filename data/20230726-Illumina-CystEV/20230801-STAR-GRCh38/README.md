


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

(head -n 1 tmp && tail -n +2 tmp | sort -t, -k1,1 ) | sed 's/ /_/g' > kirkwood.csv
\rm tmp
```



```
for f in featureCounts.*.tsv ; do
sed -e '2s/.Aligned.sortedByCoord.out.bam//g' -e '2s:/francislab/data1/working/20230726-Illumina-CystEV/20230801-STAR/out/::g' $f | tail -n +2 | cut --output-delimiter=, -f1,7- | datamash transpose -t, > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) | datamash transpose -t, > tmp2
(head -n 1 tmp2 && tail -n +2 tmp2 | sort -t, -k1,1 ) | datamash transpose -t, > tmp3
join --header -t, kirkwood.csv tmp3 > tmp4
(head -n 1 tmp4 && tail -n +2 tmp4 | sort -t, -k2,2 -k1,1 ) | datamash transpose -t, > kirkwood_featurecounts/${f%.tsv}.grade.csv
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


##	20230803 - normalize featurecounts by aligned count


```
echo "Sequencing_ID,Aligned_Counts" > aligned_counts.csv
for f in out/*.Aligned.sortedByCoord.out.bam.aligned_count.txt ; do
b=$( basename $f .Aligned.sortedByCoord.out.bam.aligned_count.txt )
c=$( cat $f )
echo "${b},${c}"
done | sort -t, -k1,1 >> aligned_counts.csv
```


```
for f in featureCounts.*.tsv ; do
sed -e '2s/.Aligned.sortedByCoord.out.bam//g' -e '2s:/francislab/data1/working/20230726-Illumina-CystEV/20230801-STAR/out/::g' $f | tail -n +2 | cut --output-delimiter=, -f1,7- | datamash transpose -t, > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) | datamash transpose -t, > tmp2
(head -n 1 tmp2 && tail -n +2 tmp2 | sort -t, -k1,1 ) | datamash transpose -t, > tmp3
join --header -t, kirkwood.csv tmp3 > tmp4
(head -n 1 tmp4 && tail -n +2 tmp4 | sort -t, -k2,2 -k1,1 ) | datamash transpose -t, > kirkwood_featurecounts/${f%.tsv}.grade.csv
join --header -t, aligned_counts.csv tmp4 | awk 'BEGIN{FS=OFS=","}(NR==1){print;next}{for(i=4;i<=NF;i++){$i=1000000*$i/$2}print}' > tmp5
(head -n 1 tmp5 && tail -n +2 tmp5 | sort -t, -k3,3 -k1,1 ) | datamash transpose -t, > kirkwood_featurecounts/${f%.tsv}.grade.normalized.csv
done
\rm tmp1 tmp2 tmp3 tmp4 tmp5
```


```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in featureCounts.*.grade.normalized.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```


##	20230804 - feature count for all




```
for f in featureCounts.*.tsv ; do
echo $f
sed -e '2s/.Aligned.sortedByCoord.out.bam//g' -e '2s:/francislab/data1/working/20230726-Illumina-CystEV/20230801-STAR/out/::g' $f | tail -n +2 | cut --output-delimiter=, -f1,7- > tmp1
(head -n 1 tmp1 && tail -n +2 tmp1 | sort -t, -k1,1 ) | datamash transpose -t, > tmp2
(head -n 1 tmp2 && tail -n +2 tmp2 | sort -t, -k1,1 ) > tmp3
cat tmp3 | datamash transpose -t, > ${f%.tsv}.csv
join --header -t, aligned_counts.csv tmp3 | awk 'BEGIN{FS=OFS=","}(NR==1){print;next}{for(i=3;i<=NF;i++){$i=1000000*$i/$2}print}' | datamash transpose -t, > ${f%.tsv}.normalized.csv
done
\rm tmp1 tmp2 tmp3



(head -n 1 tmp5 && tail -n +2 tmp5 | sort -t, -k3,3 -k1,1 ) | datamash transpose -t, > kirkwood_featurecounts/${f%.tsv}.grade.normalized.csv
join --header -t, kirkwood.csv tmp3 > tmp4
(head -n 1 tmp4 && tail -n +2 tmp4 | sort -t, -k2,2 -k1,1 ) | datamash transpose -t, > kirkwood_featurecounts/${f%.tsv}.grade.csv
```


```
box_upload.bash featureCounts*.csv
```




