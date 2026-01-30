
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

We are going to need to run 1 more PRS on these data.
Its the PRS that Taishi/Geno/Linda developed for glioma.
I’ll send the info- there is a R script that should be pretty easy to implement

Here is the link: 

https://zenodo.org/records/10790748

https://pubmed.ncbi.nlm.nih.gov/38916140/

https://academic.oup.com/neuro-oncology/article/26/10/1933/7698216?login=false

https://pmc.ncbi.nlm.nih.gov/articles/PMC11448969/




FYI. Skip to 20260130


The scores are hg38 and the imputed data are hg19.

My first goes as scoring thought that the data were hg38.

In addition, the scoring ids need to match the imputed result ids which is easily parsable for the CHR:POS:REF:ALT.

The RSID scoring models, will eventually need proper annotation.






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

NEEDS other_allele. What is other_allele? The reference allele? All of my checks say, yes, other == reference

hm_inferOtherAllele will let it run, but you will get nothing. You NEED other_allele.

Once included, create_collection will work

```
paper/idhmut_1p19qcodel_scoring_system.txt.gz
paper/idhmut_1p19qnoncodel_scoring_system.txt.gz
paper/idhmut_scoring_system.txt.gz
paper/idhwt_scoring_system.txt.gz
```

```bash
mkdir models
for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.txt.gz ; do
echo $f
zcat ${f} | tail -n +2 | sed 's/^chr//' | awk 'BEGIN{FS=" ";OFS="\t"}{split($1,a,":");other_allele=($2==a[3])?a[4]:a[3];print a[1],a[2],$2,$3,other_allele}' | sort -t $'\t' -k1n,1 -k2n,2 -k3,3 > models/$(basename $f .gz)
sed -i '1ihm_chr\thm_pos\teffect_allele\teffect_weight\tother_allele' models/$(basename $f .gz)
done
```



Need to extract both the reference and alternate alleles


/francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids 
paper/allGlioma_scoring_system.txt.gz
paper/gbm_scoring_system.txt.gz
paper/nonGbm_scoring_system.txt.gz




```bash
echo -e 'rsid\tchr\tpos\tref\talt' > rsid_translation_table.tsv
module load bcftools
bcftools view -H /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz | awk 'BEGIN{FS=OFS="\t"}{print $3,$1,$2,$4,$5}' | sort -t$'\t' -k1,1 -k2,2 | uniq >> rsid_translation_table.tsv

wc -l rsid_translation_table.tsv
#	660146175 rsid_translation_table.tsv

```



```bash
mkdir models
for f in paper/{allGlioma,gbm,nonGbm}_scoring_system.txt.gz ; do
echo $f
zcat ${f} | wc -l
zcat ${f} | tr ' ' '\t' | head -1 > ${f%.txt.gz}.sorted.txt
zcat ${f} | tr ' ' '\t' | tail -n +2 | sort -t$'\t' -k1,1 | uniq >> ${f%.txt.gz}.sorted.txt
done

#	paper/allGlioma_scoring_system.txt.gz
#	1058980
#	paper/gbm_scoring_system.txt.gz
#	1059412
#	paper/nonGbm_scoring_system.txt.gz
#	1059475
```


```bash
for f in paper/{allGlioma,gbm,nonGbm}_scoring_system.txt.gz ; do
echo -e 'hm_chr\thm_pos\teffect_allele\teffect_weight\tother_allele' > models/$(basename $f .gz)
join --header -t$'\t' rsid_translation_table.tsv ${f%.txt.gz}.sorted.txt | uniq | cut -d$'\t' -f2- | tail -n +2 | awk 'BEGIN{FS=OFS="\t"}{other_allele=($5==$3)?$4:$3;print $1,$2,$5,$6,other_allele}' | sort -t$'\t' -k1n,1 -k2n,2 -k3,3 >> models/$(basename ${f} .gz)
wc -l models/$(basename ${f} .gz)
done

#	1058942 models/allGlioma_scoring_system.txt
#	1059375 models/gbm_scoring_system.txt
#	1059437 models/nonGbm_scoring_system.txt

```


What will happen if the "other allele" is "C,T"?

```bash
join --header -t$'\t' rsid_translation_table.tsv ${f%.txt.gz}.sorted.txt | uniq | cut -d$'\t' -f2- | tail -n +2 | head
12	126406434	G	A	G	2.571696e-6
4	21617051	T	C	T	1.026691e-5
4	94812755	G	T	G	1.498636e-6
3	98624063	A	G	G	2.11919e-4
4	138678744	T	C	C	3.671438e-6
4	38922709	G	A	A	4.299083e-5
4	164700803	G	C,T	G	1.184754e-5			<-----
2	236843411	T	C	T	1.44378e-6
4	178567757	C	T	C	1.051877e-5
4	17346740	C	T	T	1.990849e-5
```




Unify and harmonize these coordinates. 3 scoring files are rsIDs "rs3766192" and 4 are like "chr1:953279:T:C".

Merge all 7 models into a single matrix?



reference 20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/ ( not sure if I reran the PGS imputation since "figuring things out" )





##	Create collection

Assuming using pgs-calc for scoring,

Download and install the latest version: https://github.com/lukfor/pgs-calc (1.6.2) Done

create a collection with 

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib openjdk ;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar create-collection --out=pgs-collection.txt.gz models/*.txt; tabix -S 5 -p vcf pgs-collection.txt.gz;chmod -w pgs-collection.txt.gz*"
```





Test

```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels
data=cidr
chrnum=22

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=test_apply --time=2-0 --export=None \
  --output="${PWD}/test_apply.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk; cp ${indir}/imputed-umich-${data}/chr${chrnum}.dose.vcf.gz \${TMPDIR}/; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \${TMPDIR}/chr${chrnum}.dose.vcf.gz --ref models/allGlioma_scoring_system.txt --out \${TMPDIR}/chr${chrnum}.dose.scores.txt --info \${TMPDIR}/chr${chrnum}.dose.scores.info --report-csv \${TMPDIR}/chr${chrnum}.dose.scores.csv --report-html \${TMPDIR}/chr${chrnum}.dose.scores.html --min-r2 0.8 --no-ansi --threads 8; mkdir -p ${outdir}/pgs-${data}-0.8/; cp \${TMPDIR}/chr${chrnum}.dose.scores.* ${outdir}/pgs-${data}-0.8/; chmod -w ${outdir}/pgs-${data}-0.8/chr${chrnum}.dose.scores.*"

```



##	Apply dataset and chromosome


openjdk is needed for the jar

htslib is needed for tabix




reference 20250700-AGS-CIDR-ONCO-I370/20250618-quick_test

What data? All 4 sets?

These PGS scores were developed using I370 and ONCO and then tested on TCGA.
This isn't really a good idea.


```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do

  echo "module load openjdk; cp ${indir}/imputed-umich-${data}/chr${chrnum}.dose.vcf.gz \${TMPDIR}/; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \${TMPDIR}/chr${chrnum}.dose.vcf.gz --ref pgs-collection.txt.gz --out \${TMPDIR}/chr${chrnum}.dose.scores.txt --info \${TMPDIR}/chr${chrnum}.dose.scores.info --report-csv \${TMPDIR}/chr${chrnum}.dose.scores.csv --report-html \${TMPDIR}/chr${chrnum}.dose.scores.html --min-r2 0.8 --no-ansi --threads 8; mkdir -p ${outdir}/pgs-${data}-0.8/; cp \${TMPDIR}/chr${chrnum}.dose.scores.* ${outdir}/pgs-${data}-0.8/; chmod -w ${outdir}/pgs-${data}-0.8/chr${chrnum}.dose.scores.*"

done
done > commands

commands_array_wrapper.bash --array_file commands --time 1-0 --threads 8 --mem 60G --jobcount 8
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


```bash

box_upload.bash pgs-*0.8/scores*

```









##	Plink

```bash
mkdir plink_models
for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.txt.gz ; do
echo $f
zcat ${f} |sed 's/^chr//' | gzip > plink_models/$( basename ${f} )
done
```




```bash
for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=plink2_${data} --time=1-0 --export=None \
  --output="${PWD}/plink2.${data}.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=16 --mem=120G plink_score.bash ${data}

done

```


Need to find add the rsids to the other 3 models.




Plink only finds about 11,000 variants? Dump all the ids from both of these and compare.

/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/dose.pvar
/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/plink_models/idhmut_1p19qcodel_scoring_system.txt.gz 


grep -vs "^#" /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/dose.pvar| awk '{print $3}' | sort > cidr.dose.pvar.ids &
grep -vs "^#" /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/dose.pvar| cut -d$'\t' -f3 | sort > cidr.dose.pvar.ids2 &

zcat /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/plink_models/idhmut_1p19qcodel_scoring_system.txt.gz | tail -n +2 | cut -d' ' -f1 | sort > model.idhmut_1p19qcodel_scoring_system.ids &

join cidr.dose.pvar.ids model.idhmut_1p19qcodel_scoring_system.ids | wc -l
11107


Hmm. Does pgs-calc note this as well?
Yes. Even less actually, but that was filtered on 0.8.
idhmut_1p19qcodel_scoring_system","variants":1071074,"variantsUsed":10935




After, run on just the R2>0.8






##	20260129

```bash
bcftools view -H /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/dose.vcf.gz | awk '{print $3":"$4}' | sort | sed 's/^/chr/' > cidr.dose.chr.pos.ref &

f=cidr.dose.chr.pos.ref
join ${f} hg19.All_20180423.positions.csv | uniq | wc -l
21967832
join ${f} hg38.All_20180418.positions.csv | uniq | wc -l
1326380
```

So the imputed results are hg19 and the models are hg38. Something need lifted over.


Eventually add the pgs-calc scoring to the scripts as well.

Eventually convert the RSID scoring to CHR:POS:REF:ALT


```bash
for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=plink2_${data} --time=14-0 --export=None \
  --output="${PWD}/plink2.${data}.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=16 --mem=120G plink_score.bash ${data}

done

```

Getting even more complicated.

Gotta liftover which seems to require chromosome name match with chr prefix.

```bash
data=cidr
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=plink2_${data} --time=14-0 --export=None   --output="${PWD}/plink2.${data}.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=64 --mem=490G plink_score.dev.bash ${data}
```



##	20260130

Chat'ed with ChatGPT 


```bash
for data in cidr i370 onco tcga; do
for c in {1..22}; do
echo liftover_and_prep_for_pgs_by_chromosome.bash ${data} ${c}
done ; done > commands


commands_array_wrapper.bash --array_file commands --time 2-0 --threads 2 --mem 15G --jobcount 30 --jobname lift

```



