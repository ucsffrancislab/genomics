
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

We are going to need to run 1 more PRS on these data.
Its the PRS that Taishi/Geno/Linda developed for glioma.
I’ll send the info- there is a R script that should be pretty easy to implement

Here is the link: 

https://zenodo.org/records/10790748

https://pubmed.ncbi.nlm.nih.gov/38916140/

https://academic.oup.com/neuro-oncology/article/26/10/1933/7698216?login=false

https://pmc.ncbi.nlm.nih.gov/articles/PMC11448969/








##	Identify the reference

hg19 or hg38? betting on hg19



Data files and scoring files must by in sync. 

Sort by whole thing: chr:position:allele NOT just by a field

Extract the chromosome, positions and allele in prep to compare to scoring positions.

```bash
module load bcftools

bcftools view -H /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz | cut -f1,2,4 | tr "\t" ":" | sed 's/^/chr/' | sort | uniq > hg38.All_20180418.positions.csv &
bcftools view -H /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_20180423.vcf.gz | cut -f1,2,4 | tr "\t" ":" | sed 's/^/chr/' | sort | uniq > hg19.All_20180423.positions.csv &

for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.txt.gz ; do
echo $f
zcat $f | tail -n +2 | cut -d: -f1-3 | sort | uniq > ${f%.txt.gz}.positions.csv
done
```





```bash

wc -l hg19.All_20180423.positions.csv hg38.All_20180418.positions.csv 
#	630291607 hg19.All_20180423.positions.csv
#	651885936 hg38.All_20180418.positions.csv

for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.positions.csv ; do
echo $f
wc -l $f
join ${f} hg38.All_20180418.positions.csv | uniq | wc -l
done

#	paper/idhmut_1p19qnoncodel_scoring_system.positions.csv
#	1071077 paper/idhmut_1p19qnoncodel_scoring_system.positions.csv
#	1071077
#	paper/idhmut_1p19qcodel_scoring_system.positions.csv
#	1071074 paper/idhmut_1p19qcodel_scoring_system.positions.csv
#	1071074
#	paper/idhmut_scoring_system.positions.csv
#	1071077 paper/idhmut_scoring_system.positions.csv
#	1071077
#	paper/idhwt_scoring_system.positions.csv
#	1071077 paper/idhwt_scoring_system.positions.csv
#	1071077


for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.positions.csv ; do
echo $f
wc -l $f
join ${f} hg19.All_20180423.positions.csv | uniq | wc -l
done

#	paper/idhmut_1p19qnoncodel_scoring_system.positions.csv
#	1071077 paper/idhmut_1p19qnoncodel_scoring_system.positions.csv
#	  66087
#	paper/idhmut_1p19qcodel_scoring_system.positions.csv
#	1071074 paper/idhmut_1p19qcodel_scoring_system.positions.csv
#	  66087
#	paper/idhmut_scoring_system.positions.csv
#	1071077 paper/idhmut_scoring_system.positions.csv
#	  66087
#	paper/idhwt_scoring_system.positions.csv
#	1071077 paper/idhwt_scoring_system.positions.csv
#	  66087

```

The positions all appear to be the same. The only thing that seems to change are the weights.

I'm gonna call these weights as hg38.




##	Create usable scoring files

What is pgs-calc expecting?

I think it is using the "harmonized format" so hm_chr, hm_pos, effect_allele, effect weight. 
Maybe other_allele but don't know what to use there and I don't see it in all of the PGSCatalog files.

Chromosomes and positions are integers. Not "chr" prefix.

They also need to be sorted

sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos}

When I used it, I remember getting an error when hm_chr and hm_chr were not there.

I think it is using the "harmonized format" so hm_chr, hm_pos, effect_allele, effect weight. 


```bash
mkdir models
for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.txt.gz ; do
zcat ${f} | tail -n +2 | sed 's/^chr//' | awk 'BEGIN{FS=" ";OFS="\t"}{split($1,a,":");print a[1],a[2],$2,$3}' | sort -t $'\t' -k1n,1 -k2n,2 -k3,3 > models/$(basename $f .gz)
sed -i '1ihm_chr\thm_pos\teffect_allele\teffect_weight' models/$(basename $f .gz)
done
```





/francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids 
paper/allGlioma_scoring_system.txt.gz
paper/gbm_scoring_system.txt.gz
paper/nonGbm_scoring_system.txt.gz



```bash
echo -e 'rsid\tchr\tpos' > rsid_translation_table.tsv
awk 'BEGIN{FS=":";OFS="\t"}{print $3,$1,$2}' /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids | sort -t$'\t' -k1,1 | uniq >> rsid_translation_table.tsv
wc -l rsid_translation_table.tsv

#	660146175 rsid_translation_table

mkdir models
for f in paper/{allGlioma,gbm,nonGbm}_scoring_system.txt.gz ; do
echo $f
zcat ${f} | wc -l
zcat ${f} | head -1 > ${f%.txt.gz}.sorted.txt
zcat ${f} | tail -n +2 | sort -t$'\t' -k1,1 | uniq >> ${f%.txt.gz}.sorted.txt
echo -e '1ihm_chr\thm_pos\teffect_allele\teffect_weight' > models/$(basename $f .gz)
join --header -t$'\t' rsid_translation_table ${f%.txt.gz}.sorted.txt | uniq | cut -d$'\t' -f2- | tail -n +2 | sort -t$'\t' -k1n,1 -k2n,2 -k3,3 >> models/$(basename ${f} .gz)
wc -l ${f%.txt.gz}.sorted.txt
wc -l models/$(basename ${f} .gz)
done

```




Unify and harmonize these coordinates. 3 scoring files are rsIDs "rs3766192" and 4 are like "chr1:953279:T:C".

Merge all 7 models into a single matrix?



reference 20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/ ( not sure if I reran the PGS imputation since "figuring things out" )





##	Create collection

Assuming using pgs-calc for scoring,
Download and install the latest version: https://github.com/lukfor/pgs-calc (1.6.2) Done

refs/Imputation/PGSCatalog/README.md

create a colleciton something like ...
```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib openjdk ;pgs-calc create-collection --out=pgs-GLIO-IBD.txt.gz {PGS000155,PGS000781,PGS002302,PGS003384,PGS000017,PGS001288,PGS003981,PGS003997,PGS004013,PGS004023,PGS004038,PGS004051,PGS004067,PGS004081,PGS004097,PGS004105,PGS004121,PGS004135,PGS004151,PGS004270,PGS004271,PGS004272,PGS004273,PGS004274}.txt.gz; tabix -S 5 -p vcf pgs-GLIO-IBD.txt.gz;chmod -w pgs-GLIO-IBD.txt.gz*"
```




##	Apply dataset and chromosome


openjdk is needed for the jar

htslib is needed for tabix




reference 20250700-AGS-CIDR-ONCO-I370/20250618-quick_test

What data? All 4 sets?


```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do

  echo "module load openjdk; cp ${indir}/imputed-umich-${data}/chr${chrnum}.dose.vcf.gz \${TMPDIR}/; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \${TMPDIR}/chr${chrnum}.dose.vcf.gz 

--ref /francislab/data1/refs/Imputation/PGSCatalog/hg38/pgs-collection.txt.gz 

--out \${TMPDIR}/chr${chrnum}.dose.scores.txt --info \${TMPDIR}/chr${chrnum}.dose.scores.info --report-csv \${TMPDIR}/chr${chrnum}.dose.scores.csv --report-html \${TMPDIR}/chr${chrnum}.dose.scores.html --min-r2 0.8 --no-ansi --threads 8; mkdir -p ${outdir}/pgs-${data}-0.8/; cp \${TMPDIR}/chr${chrnum}.dose.scores.* ${outdir}/pgs-${data}-0.8/; chmod -w ${outdir}/pgs-${data}-0.8/chr${chrnum}.dose.scores.*"

done
done > commands

commands_array_wrapper.bash --array_file commands --time 4-0 --threads 8 --mem 60G
```


##	Merge


```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score-${data} \
  --export=None --output="${PWD}/pgs-merge-score-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${outdir}/pgs-${data}-0.8/chr*.dose.scores.txt --out ${outdir}/pgs-${data}-0.8/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info-${data} \
  --export=None --output="${PWD}/pgs-merge-info-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${outdir}/pgs-${data}-0.8/chr*.dose.scores.info --out ${outdir}/pgs-${data}-0.8/scores.info"

done
```


