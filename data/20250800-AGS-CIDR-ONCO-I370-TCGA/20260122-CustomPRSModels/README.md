
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
mkdir plink_models_without_chr_prefix
for f in paper/{idhmut_1p19qnoncodel,idhmut_1p19qcodel,idhmut,idhwt}_scoring_system.txt.gz ; do
echo $f
zcat ${f} |sed 's/^chr//' | gzip > plink_models_without_chr_prefix/$( basename ${f} )
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


Copy the script so I don't muck it up if I edit while running.

```bash
for data in cidr i370 onco tcga; do
for c in {1..22}; do
echo cp liftover_and_prep_for_pgs_by_chromosome.bash \${TMPDIR}\; \${TMPDIR}/liftover_and_prep_for_pgs_by_chromosome.bash ${data} ${c}
done ; done > commands

commands_array_wrapper.bash --array_file commands --time 3-0 --threads 4 --mem 30G --jobcount 16 --jobname lift
```



No need to concat. pgs-calc and plink2 can score by chromosome. pgs-calc has a built-in merge. plink2 does not.

pgs-calc models are by chromosome and position. No ids are used.
The models were prepared above and are still good, but will need the chr prefix added.
Add the "chr" prefix and rename the file to include "pgs-calc" to differentiate from the plink2 models.

```bash
mkdir pgs-calc_models
for f in pgs-calc_models_without_chr_prefix/* ; do
echo $f
sed '2,$s/^/chr/' ${f} > pgs-calc_models_with_chr_prefix/$( basename $f )
done
```


plink2 needs matching ids, whether they be rsids or CHR:POS:REF:ALT, the data must match the model.

The `paper/idh*_scoring_system.txt.gz` files are appropriately formated with CHR:POS:REF:ALT ids.
`mkdir plink_models_with_chr_prefix; cp paper/idh*_scoring_system.txt.gz plink_models_with_chr_prefix/`


This takes a very long time. Mostly the sort I believe
```bash
for f in paper/{allGlioma,gbm,nonGbm}_scoring_system.sorted.txt ; do
join --header -t$'\t' rsid_translation_table.tsv ${f} | uniq | tail -n +2 | sort -t $'\t' -k1n,1 -k2n,2 -k3,3 | awk 'BEGIN{FS="\t";OFS=" "}{print "chr"$2":"$3":"$4":"$5,$6,$7}' | sed '1iID prs_allele prs_weight' | gzip > plink_models_with_chr_prefix/$(basename ${f} .sorted.txt).txt.gz
done
```

This results in some entries with multiple ALTs. Probably problem. What will be in the data?
```bash
chr4:164700803:G:C,T G 3.466689e-6
```
It is what's in the dbSNP file. Hmmm.







plink scoring incorporate into the liftover script.


Still need to aggregate.

`plink_models_with_chr_prefix` is the usable scores.

`pgs-calc_models_with*` and `plink_models_without_chr_prefix` are unnecessary.


```
grep "^Error: --score variant ID" logs/commands_array_wrapper.bash.20260202092202069416188-1020441_*
logs/commands_array_wrapper.bash.20260202092202069416188-1020441_14.out.log:Error: --score variant ID 'chr14:22163782:T:C' appears multiple times in main
logs/commands_array_wrapper.bash.20260202092202069416188-1020441_17.out.log:Error: --score variant ID 'chr17:36608541:G:A' appears multiple times in main
logs/commands_array_wrapper.bash.20260202092202069416188-1020441_1.out.log:Error: --score variant ID 'chr1:147891874:A:G' appears multiple times in main
```














##	pgs-calc


Probably not gonna use it.

pgs-calc DOES NOT LIKE the chr prefix. Back and forth and back and forth and back and rrrrrrrrrrr

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib openjdk ;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar create-collection --out=pgs-collection.txt.gz pgs-calc_models_without_chr_prefix/*.txt; tabix -S 5 -p vcf pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz;chmod -w pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz*"

mkdir pgs-calc_models_with_chr_prefix
chmod +w pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz*
cp pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz.info pgs-calc_models_with_chr_prefix/
zcat pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz | sed '6,$s/^/chr/' | bgzip > pgs-calc_models_with_chr_prefix/pgs-collection.txt.gz
tabix -S 5 -p vcf pgs-calc_models_with_chr_prefix/pgs-collection.txt.gz
```

I think that we are ready to score. We are just waiting for everything to finish lifting over.

```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do

  echo "module load openjdk; cp ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.vcf.gz \${TMPDIR}/; java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \${TMPDIR}/final.chr${chrnum}.dose.vcf.gz --ref pgs-calc_models_with_chr_prefix/pgs-collection.txt.gz --out \${TMPDIR}/final.chr${chrnum}.dose.scores.txt --info \${TMPDIR}/final.chr${chrnum}.dose.scores.info --report-csv \${TMPDIR}/final.chr${chrnum}.dose.scores.csv --report-html \${TMPDIR}/final.chr${chrnum}.dose.scores.html --no-ansi --threads 8; mkdir -p ${outdir}/pgs-calc-${data}/; cp \${TMPDIR}/final.chr${chrnum}.dose.scores.* ${outdir}/pgs-calc-${data}/; chmod -w ${outdir}/pgs-calc-${data}/final.chr${chrnum}.dose.scores.*"

done
done > commands2

commands_array_wrapper.bash --array_file commands2 --time 1-0 --threads 4 --mem 30G --jobcount 8 --jobname score
```

```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score-${data} \
  --export=None --output="${PWD}/pgs-merge-score-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${outdir}/pgs-calc-${data}/chr*.dose.scores.txt --out ${outdir}/pgs-calc-${data}/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info-${data} \
  --export=None --output="${PWD}/pgs-merge-info-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${outdir}/pgs-calc-${data}/chr*.dose.scores.info --out ${outdir}/pgs-calc-${data}/scores.info"

done
```

```bash

box_upload.bash pgs-calc-*0.8/scores*

```










##	20260203

https://chatgpt.com/c/69820e15-c2fc-8326-ad17-d60eeb085dde

Aggregate plink2 scoring.

plink2 only provides average. Un-average them

Assumptions (match your files)

$1 = IID
$2 = ALLELE_CT
$NF = prs_weight_AVG (last column)



New suggestion from Claude
prs[iid] += $3 * $4  # NAMED_ALLELE_DOSAGE_SUM × prs_weight_AVG



```bash
for data in cidr i370 onco tcga; do
for fullmodel in plink_models_with_chr_prefix/* ; do
model=$( basename ${fullmodel} _scoring_system.txt.gz )

awk '
  FNR==1 {next}      # skip headers
  {
    iid = $1
    snp_ct[iid] += $2            # ALLELE_CT
    prs[iid]    += $2 * $NF      # AVG × ALLELE_CT
  }
  END {
    print "IID\tPRS_raw\tSNP_CT"
    for (i in prs) {
      print i "\t" prs[i] "\t" snp_ct[i]
    }
  }
' plink-scores/imputed-umich-${data}/chr*.dose.${model}.sscore > plink-scores/imputed-umich-${data}.${model}.prs.genome_raw.txt

done
done

```



If SNP_CT varies wildly → something went wrong upstream.


Standardize (Z-score) across individuals

This is the canonical PRS normalization.

```python
import pandas as pd
import glob
from scipy.stats import zscore

for file in glob.glob('plink-scores/imputed-umich-*.*.prs.genome_raw.txt'):
	prs = pd.read_csv(file, sep="\t")
	#	prs["PRS_z"] = (prs["PRS_raw"] - prs["PRS_raw"].mean()) / prs["PRS_raw"].std()
	#	prs$PRS_z <- scale(prs$PRS_raw) same thing?
	# Defaults to ddof=0, but you can specify
	prs['PRS_z'] = zscore(prs['PRS_raw'], ddof=0)
	prs.to_csv( file.replace('prs.genome_raw.txt', 'prs.genome_z.txt'), sep="\t", index=False)

```



```bash

./prs_qc.py > prs_qc.log

box_upload.bash prs_qc.py prs_qc.log plink-scores/imputed-umich-*txt plink-scores/qc_plots/*

```


IDHwt more ancestry related?
Get ancestry PCs for these studies and test correlation

2. PRS–PC correlation per model
For each PRS:
cor(PRS_raw, PC1)
You will almost certainly see:
idhwt → strong correlation
others → weak or none
That is the smoking gun.

3. Variant frequency differentiation
If you really want to be thorough:
compute mean allele frequency difference per SNP across ancestry
weight by |beta|
idhwt will dominate

```bash
tail -q -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/pgs-*-hg19/estimated-population.txt | cut -f1,5 -d$'\t' | sed '1iIID\tPC1' > plink-scores/IID_PC1.tsv

tail -q -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/pgs-*-hg19/estimated-population.txt | cut -f1,5-9 -d$'\t' | sed '1iIID\tPC1\tPC2\tPC3\tPC4\tPC5' > plink-scores/IID_PCs.tsv

./prs_qc.py > prs_qc.log
```

Nope.


##	20260205


Try again with other variables like actual IDH status? Seems odd but we shall see.

Just need to find a good way to include all of these.

Not sure how easy this will be because they aren't as centralized.

And we don't have it all.

Start with just the TCGA
TCGA-02-0003-10A_TCGA-02-0003-10A

/francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv 

About 13% (870) of the TCGA (6700) is actually TCGA and we have metadata.

I370 is partially AGS

ONCO is partially AGS

CIDR is mostly IPS


Do survival analysis only on cases.
like ../20250724-pgs/



ChatGPT advises z-scoring and thereafter should ONLY be OUR data.

I think that I should create "select" subset files and then move on from there.


```bash

for f in plink-scores/imputed-umich-cidr.*.prs.genome_raw.txt ; do
 echo $f
 head -1 $f > ${f%.txt}.select.txt
 tail -n +2 $f | grep "_G" >> ${f%.txt}.select.txt
done

for f in plink-scores/imputed-umich-i370.*.prs.genome_raw.txt ; do
 echo $f
 head -1 $f > ${f%.txt}.select.txt
 tail -n +2 $f | grep "AGS" >> ${f%.txt}.select.txt
done

for f in plink-scores/imputed-umich-onco.*.prs.genome_raw.txt ; do
 echo $f
 head -1 $f > ${f%.txt}.select.txt
 tail -n +2 $f | grep "AGS" >> ${f%.txt}.select.txt
done

for f in plink-scores/imputed-umich-tcga.*.prs.genome_raw.txt ; do
 echo $f
 head -1 $f > ${f%.txt}.select.txt
 tail -n +2 $f | grep "^TCGA" >> ${f%.txt}.select.txt
done
```


CIDR: 447/482 are IPS cases

I370: 1268/4619 are AGS, about half that are cases

Onco: 1339/4365 are AGS cases

TCGA: 873/6716 are TCGA, mostly cases


```python
import pandas as pd
import glob
from scipy.stats import zscore

for file in glob.glob('plink-scores/imputed-umich-*.*.prs.genome_raw.select.txt'):
	prs = pd.read_csv(file, sep="\t")
	#	prs["PRS_z"] = (prs["PRS_raw"] - prs["PRS_raw"].mean()) / prs["PRS_raw"].std()
	#	prs$PRS_z <- scale(prs$PRS_raw) same thing?
	# Defaults to ddof=0, but you can specify
	prs['PRS_z'] = zscore(prs['PRS_raw'], ddof=0)
	prs.to_csv( file.replace('prs.genome_raw.select.txt', 'prs.genome_z.select.txt'), sep="\t", index=False)

```





Reinvestigating pgs-calc


```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

data=cidr
chrnum=22

module load openjdk


java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.vcf.gz --ref pgs-calc_models_with_chr_prefix/pgs-collection.txt.gz --out ${TMPDIR}/final.chr${chrnum}.dose.scores.txt --info ${TMPDIR}/final.chr${chrnum}.dose.scores.info --report-csv ${TMPDIR}/final.chr${chrnum}.dose.scores.csv --report-html ${TMPDIR}/final.chr${chrnum}.dose.scores.html --no-ansi --threads 8



chr prefix doesn't work

bcftools annotate --rename-chrs <(echo -e "chr22\t22\nchr4\t4") -r chr4,chr22 -Oz -o test22.vcf.gz --write-index=csi ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.vcf.gz 

bcftools annotate --rename-chrs <(echo -e "chr22\t22") -r chr22 -Oz -o test22.vcf.gz --write-index=csi ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.vcf.gz 

java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply test${chrnum}.vcf.gz --ref pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz --out ${TMPDIR}/final.chr${chrnum}.dose.scores.txt --info ${TMPDIR}/final.chr${chrnum}.dose.scores.info --report-csv ${TMPDIR}/final.chr${chrnum}.dose.scores.csv --report-html ${TMPDIR}/final.chr${chrnum}.dose.scores.html --no-ansi --threads 8
```


MUST ONLY BE ONE CHROMOSOME PER FILE apparently. Trickly after liftover.

Concatenate, sort, then resplit?

```bash

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

data=cidr
chrnum=22

module load openjdk


bcftools view -r chr${chrnum} -Oz -o test${chrnum}.vcf.gz --write-index=csi ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.vcf.gz 

java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply test${chrnum}.vcf.gz --ref pgs-calc_models_with_chr_prefix/pgs-collection.txt.gz --out ${TMPDIR}/final.chr${chrnum}.dose.scores.txt --info ${TMPDIR}/final.chr${chrnum}.dose.scores.info --report-csv ${TMPDIR}/final.chr${chrnum}.dose.scores.csv --report-html ${TMPDIR}/final.chr${chrnum}.dose.scores.html --no-ansi --threads 8

#	all scores are 0

bcftools annotate --rename-chrs <(echo -e "chr22\t22") -r chr22 -Oz -o noprefix_test${chrnum}.vcf.gz --write-index=csi test${chrnum}.vcf.gz

java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply noprefix_test${chrnum}.vcf.gz --ref pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz --out ${TMPDIR}/final.chr${chrnum}.dose.scores.txt --info ${TMPDIR}/final.chr${chrnum}.dose.scores.info --report-csv ${TMPDIR}/final.chr${chrnum}.dose.scores.csv --report-html ${TMPDIR}/final.chr${chrnum}.dose.scores.html --no-ansi --threads 8
```


pgs-calc seems to REQUIRE NUMERIC chromosome only regardless of model or will just report 0's

Also only 1 chromosome per file for pgs-calc or get something like this ...

```bash
[Run]     [Chr 04]...
[Error]   [Chr 04] failed: java.lang.Exception: Different chromosomes found in file.
java.lang.Exception: Different chromosomes found in file.
    at genepi.riskscore.tasks.ApplyScoreTask.processVCF(ApplyScoreTask.java:305)
    at genepi.riskscore.tasks.ApplyScoreTask.run(ApplyScoreTask.java:192)
    at lukfor.progress.tasks.Task.call(Task.java:39)
    at lukfor.progress.tasks.Task.call(Task.java:1)
    at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:317)
    at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1144)
    at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:642)
    at java.base/java.lang.Thread.run(Thread.java:1583)
```







##	20260206

Create a new collection including these new models

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar create-collection --out=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/*_scoring_system.txt.gz /francislab/data1/refs/Imputation/PGSCatalog/hg38/PGS??????.txt.gz ;tabix -S 5 -p vcf /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz;chmod -w /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz*"
```


Isolate lifted/final data into their own chromosome files.

```bash
for data in cidr i370 onco tcga; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${data}-redi --time=2-0 --export=None \
  --output="${PWD}/redistribute_snps_to_proper_chromosome_files.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  redistribute_snps_to_proper_chromosome_files.bash ${data}
done
```

creates .... `20251218-survival_gwas/imputed-umich-*/hg38_0.8/final.chr*.dose.corrected.vcf.gz`















Rerun the scoring for all 4 complete datasets for all models including these new 7.

cp ${outdir}/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz \${TMPDIR}/;  34GB

```bash
indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels
  echo "module load openjdk; cp ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.corrected.vcf.gz \${TMPDIR}/; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \${TMPDIR}/final.chr${chrnum}.dose.corrected.vcf.gz --ref ${outdir}/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz --out \${TMPDIR}/chr${chrnum}.scores.txt --info \${TMPDIR}/chr${chrnum}.scores.info --report-csv \${TMPDIR}/chr${chrnum}.scores.csv --report-html \${TMPDIR}/chr${chrnum}.scores.html --no-ansi --threads 8; mkdir -p ${outdir}/pgs-calc-scores/${data}/; cp \${TMPDIR}/chr${chrnum}.scores.* ${outdir}/pgs-calc-scores/${data}/; chmod -w ${outdir}/pgs-calc-scores/${data}/chr${chrnum}.scores.*"



for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do
echo "pgs-calc.bash ${data} ${chrnum}"
done
done > commands

commands_array_wrapper.bash --array_file commands --time 2-0 --threads 8 --mem 60G --jobcount 8 --jobname pgs-calc
```


Merge

```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score-${data} \
  --export=None --output="${PWD}/pgs-merge-score-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${outdir}/pgs-calc-scores/${data}/chr*.scores.txt --out ${outdir}/pgs-calc-scores/${data}/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info-${data} \
  --export=None --output="${PWD}/pgs-merge-info-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${outdir}/pgs-calc-scores/${data}/chr*.scores.info --out ${outdir}/pgs-calc-scores/${data}/scores.info"

done
```










TODO  ---  Compare plink's scores to pgs-calc's.

hc ../20250724-pgs/pgs-cidr-hg19/scores.txt 
"sample","PGS000008","PGS000006","PGS000005","PGS000002","PGS000003","PGS000007","PGS000004","PGS000
"CSR01_CSR01-1-0427561327","-0.4388784013230804","-0.06674872281382704","-0.020987556001273333","-0.
"CSR02_CSR02-1-0427561328","-0.9576076738206964","0.4412269867980285","-0.8594468682276784","-1.2089
"CSR03_CSR03-1-0427561329","-0.6334767574885873","0.11415971475071274","-0.4800121966745792","-0.616
"CSR04_CSR04-1-0427561330","0.3822147069489432","0.0914940228976775","0.5728907364637053","-0.275078
"CSR05_CSR05-1-0427561331","0.2391618190879612","0.749791647094753","0.022534124080266338","-0.27876
"CSR06_CSR06-1-0427561332","0.015366533532215954","0.04200979381812431","0.34372751272530877","-0.23
"CSR07_CSR07-1-0427561333","-0.21197748491279356","0.07706609346519144","0.09969380693382845","-0.73
"CSR08_CSR08-1-0427561334","0.4141717159144491","0.7379417194752023","0.785677000855685","0.45584937
"CSR09_CSR09-1-0427561335","-0.3031906518672116","0.6785183288570806","-0.13026687371711887","-1.888



head pgs-calc-scores/cidr/scores.txt | cut -c1-100
"sample","allGlioma_scoring_system","gbm_scoring_system","idhmut_1p19qcodel_scoring_system","idhmut_
"CSR01_CSR01-1-0427561327","1.83864491521851","1.7252670221948374","0.497667242799566","0.2153982278
"CSR02_CSR02-1-0427561328","1.8050973857159829","1.9425654358390896","0.5880943116838441","0.3673133
"CSR03_CSR03-1-0427561329","1.9994589021232372","2.1365019901441524","0.24853711805148768","0.323879
"CSR04_CSR04-1-0427561330","1.662360993019792","1.821884169339171","-0.1562705770049962","0.06573025
"CSR05_CSR05-1-0427561331","1.9441509593460022","2.17114302554223","0.3669397330659182","0.192403005
"CSR06_CSR06-1-0427561332","1.6707050786918844","1.7692876681132437","-0.06520721070520039","-0.0077
"CSR07_CSR07-1-0427561333","1.4176768872016032","1.582557853353312","-0.1040461853098565","0.6141375
"CSR08_CSR08-1-0427561334","1.7530317684494536","1.8823051727841775","0.2702653415488848","0.2385189
"CSR09_CSR09-1-0427561335","2.0014791607180857","1.938807533630856","0.23648606846047387","0.8399118

wc -l pgs-calc-scores/cidr/scores.txt
483 pgs-calc-scores/cidr/scores.txt

awk -F, '{print NF}'  pgs-calc-scores/cidr/scores.txt | uniq
5111

ls -1 plink-scores/imputed-umich-cidr*.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.allGlioma.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.gbm.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.idhmut_1p19qcodel.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.idhmut_1p19qnoncodel.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.idhmut.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.idhwt.prs.genome_raw.txt
plink-scores/imputed-umich-cidr.nonGbm.prs.genome_raw.txt

head plink-scores/imputed-umich-cidr.allGlioma.prs.genome_raw.txt
IID	PRS_raw	SNP_CT
147_G146-1-0427562915	20.9992	1648348
136_G135-1-0427562904	20.955	1648348
369_G369-1-0427563047	21.0402	1648348
27_G025-1-0427562792	20.959	1648348
16_G014-1-0427562781	21.0807	1648348
396_G397-1-0427561155	20.8406	1648348
385_G386-1-0427561144	20.9683	1648348
45_G043-1-0427562810	20.8441	1648348
56_G054-1-0427562822	20.9621	1648348















Scale the new raw scores matrix.

```bash

for data in cidr i370 onco tcga; do

scale_raw_pgs_scores_to_z-scores.py -i pgs-calc-scores/${data}/scores.txt -o pgs-calc-scores/${data}/scores.z-scores.txt 

done

```









Run survival gwas (I feel like I'm procratinating)







EDIT
EDIT
EDIT
EDIT
EDIT
EDIT




These take 4 to 26 hours. Really wish that the michiganCoxSurv was parallelizable.

May need to rerun the cidr_LrGG_IDHmut_1p19qintact_meta_cases.txt if I redefine it.

```BASH
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo gwasurvivr.bash --dataset ${b} --vcffile imputed-umich-${b}/${b}-cases/${b}-cases.vcf.gz \
 --outbase ${PWD}/gwas-${b}/ \
 --idfile ${id} --covfile imputed-umich-${b}/${b}-cases/${b}-covariates.tsv

done ; done > gwas_commands

commands_array_wrapper.bash --jobname gwasurvivr --array_file gwas_commands --time 2-0 --threads 2 --mem 15G
```




###	spacox.bash

Occassional failures. Dataset is too small is the usual cause.


SPA cox read in entire dosage file which can be large (30GB for topmed onco)
Will need memory to support this
umich i370 is only 3GB

For some reason, reading the transposed crashes so no need to do this. Too many columns?

```BASH
#for f in imputed-*/*/*dosage ; do
#echo "sed '1s/^/ /' $f | datamash transpose -t' ' | sed '1s/^ //' > ${f}.transposed; chmod -w ${f}.transposed"
#done > transpose_commands

#commands_array_wrapper.bash --array_file transpose_commands --time 1-0 --threads 16 --mem 120G
```

2/6 worked with 60G

3/6 needed 120G

1 needed 240G



This can take 15-60 mins

```BASH
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo spacox.bash --dataset ${b} --dosage imputed-umich-${b}/${b}-cases/${b}-cases.dosage \
 --outbase ${PWD}/gwas-${b}/ \
 --idfile ${id} --covfile imputed-umich-${b}/${b}-cases/${b}-covariates.tsv

done ; done > spa_commands

#	lists/${b}_covariates.tsv

commands_array_wrapper.bash --jobname spacox --array_file spa_commands --time 1-0 --threads 64 --mem 490G
```

60G isn't enough for many

490G is overkill but works for all





###	Merge

then merge those results

```BASH
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo merge_gwasurvivr_spacox.bash --dataset ${b} --outbase ${PWD}/gwas-${b}/ --idfile ${id}

done ; done > merge_commands

commands_array_wrapper.bash --jobname mergegwasspa --array_file merge_commands --time 1-0 --threads 2 --mem 15G
```






### METAL



I use the software METAL, which I downloaded to C4, its a very lightweight script, but does not seem to like being called in a shell script, .sh, I have always had to create .bash files and run those from the command line to get metal to loop over multiple analyses (e.g. multiple subtypes). 

You can find a very straightforward guide here: https://genome.sph.umich.edu/wiki/METAL_Documentation

Depending on which estimates are available, like the beta (effect size) or just p-values (like survival analysis using SPAcox would give), you must specify which mode to use. 

Easy examples of these differences are in the Script_Repository/metal folder of this Box container. 

I've built wrapper files which loop through all subtypes and call this script, see Pharma_surv_meta_wrapper_spa_all4.txt as an example. 

Using Beta estimates look at: script_Pharma_survival_metal_all4.txt


```BASH
for id in lists/onco*meta_cases.txt ; do

echo Pharma_surv_meta_wrapper_all4.bash umich $id

done > metal_commands

commands_array_wrapper.bash --jobname metal --array_file metal_commands --time 1-0 --threads 4 --mem 30G
```





Using just P-values look at: script_Pharma_survival_metal_spa_all4.txt


```BASH
for id in lists/onco*meta_cases.txt ; do

echo Pharma_surv_meta_wrapper_spa_all4.bash umich $id

done ; done > metalspa_commands

commands_array_wrapper.bash --jobname metalspa --array_file metalspa_commands --time 1-0 --threads 4 --mem 30G
```














Add exit to r scripts when the sample count drops below a certain number?

Geno : I’d say anything running less than 30 individuals is very unreliable for survival models. Possibly the saddle point approximation in SPACox needs even more.



allGlioma
paper
rs9660710 A 2.689802e-5

pgs-calc 
1	1163962	A	2.689802e-5	C,T

plink
chr1:1163962:A:C,T A 2.689802e-5




