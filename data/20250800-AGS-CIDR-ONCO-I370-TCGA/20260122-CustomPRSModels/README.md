
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
Actually, the REF:ALT won't necessarily match between data and reference so after SNP isolation just CHR:POSITION.

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

They also need to be sorted (Does it?)

sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos}

When I used it, I remember getting an error when hm_chr and hm_chr were not there.

I think it is using the "harmonized format" so hm_chr, hm_pos, effect_allele, effect weight. 

NEEDS other_allele. What is other_allele? The reference allele? All of my checks say, yes, other == reference

hm_inferOtherAllele will let it run, but you will get nothing. You NEED other_allele.

Once included, create_collection will work


```bash
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


```bash
/francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids 

paper/allGlioma_scoring_system.txt.gz
paper/gbm_scoring_system.txt.gz
paper/nonGbm_scoring_system.txt.gz
```




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

THIS IS WRONG DON'T DO IT THIS WAY. Pretty sure that the commas will make pgs-calc ignore it. Split the commas and create another entry

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







MOVE THIS TO ABOVE

TODO 
Sadly need to redo the pgs-calc models for the custom models
Split the commas on the other allele generating multiple entries
Won't be able to do it in this run.
Will only effect the 3 rsid models.

```bash

for f in pgs-calc_models_without_chr_prefix/{allGlioma,gbm,nonGbm}_scoring_system.txt.gz ; do
mv ${f} ${f%.txt.gz}.commas.txt.gz
model=$( basename $f .txt.gz )

zcat ${f%.txt.gz}.commas.txt.gz | awk 'BEGIN{FS=OFS="\t"}
(NR==1){ print }
(NR>1){
 split($5,a,",")
 for( i in a ){
   $5=a[i]
   print
 }
}' | gzip > pgs-calc_models_without_chr_prefix/${model}.txt.gz

done

```




##	Create collection

Assuming using pgs-calc for scoring,

Download and install the latest version: https://github.com/lukfor/pgs-calc (1.6.2) Done

openjdk is needed for the jar

htslib is needed for tabix

reference 20250700-AGS-CIDR-ONCO-I370/20250618-quick_test

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


Getting even more complicated.

Gotta liftover which seems to require chromosome name match with chr prefix.




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


The `paper/idh*_scoring_system.txt.gz` files are appropriately formated with CHR:POS:REF:ALT ids.












##	pgs-calc


pgs-calc DOES NOT LIKE the chr prefix. Back and forth and back and forth and back and rrrrrrrrrrr

The data can include the chr prefix, but the models ABSOLUTELY CANNOT.


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





Does this work on pgs-calc? or just a remnant of plink?

```bash

./prs_qc.py > prs_qc.log

box_upload.bash prs_qc.py prs_qc.log plink-scores/imputed-umich-*txt plink-scores/qc_plots/*

```



CIDR: 447/482 are IPS cases

I370: 1268/4619 are AGS, about half that are cases

Onco: 1339/4365 are AGS cases

TCGA: 873/6716 are TCGA, mostly cases

MUST ONLY BE ONE CHROMOSOME PER FILE apparently. Tricky after liftover.

Concatenate, sort, then resplit?

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

```bash
for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do
echo "pgs-calc.bash ${data} ${chrnum}"
done
done > commands

commands_array_wrapper.bash --array_file commands --time 2-0 --threads 8 --mem 60G --jobcount 8 --jobname pgs-calc
```


Merge after completes

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





Create Collection of just the new models, including both version of the RSID models (with and without commas)

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib openjdk; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar create-collection --out=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.new_models.txt.gz /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/*_scoring_system*.txt.gz; tabix -S 5 -p vcf /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.new_models.txt.gz;chmod -w /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix/pgs-collection.new_models.txt.gz*"
```


Just the new models

```bash

for data in cidr i370 onco tcga; do
for chrnum in {1..22} ; do
echo "pgs-calc.dev.bash ${data} ${chrnum} ${PWD}/pgs-calc_models_without_chr_prefix/pgs-collection.new_models.txt.gz"
done
done > commands2

commands_array_wrapper.bash --array_file commands2 --time 1-0 --threads 4 --mem 30G --jobcount 4 --jobname pgs-calc.dev
```


Merge

```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score-${data} \
  --export=None --output="${PWD}/pgs-merge-score-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --wrap="module load openjdk;java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${outdir}/${data}/chr*.scores.txt --out ${outdir}/${data}/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info-${data} \
  --export=None --output="${PWD}/pgs-merge-info-${data}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --wrap="module load openjdk;java -Xmx25G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${outdir}/${data}/chr*.scores.info --out ${outdir}/${data}/scores.info"

done
```


```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models

for data in cidr i370 onco tcga; do

scale_raw_pgs_scores_to_z-scores.py -i ${outdir}/${data}/scores.txt -o ${outdir}/${data}/scores.z-scores.txt 

done

```


Scale the new raw scores matrix.

```bash

for data in cidr i370 onco tcga; do

scale_raw_pgs_scores_to_z-scores.py -i pgs-calc-scores/${data}/scores.txt -o pgs-calc-scores/${data}/scores.z-scores.txt 

done

```





##	PGS Survival Analysis (just the new models for the moment)

```bash

ln -s ../20250724-pgs/lists

```


Extract just cases from PGS matrix. Not sure why. Not used.

```bash
#for b in cidr onco i370 tcga ; do
#
#  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_pgs-${b} \
#    --output="${PWD}/pull_pgs-${b}.%j.$( date "+%Y%m%d%H%M%S%N" ).out" \
#    --time=1-0 --nodes=1 --ntasks=4 --mem=30G pull_case_pgs.bash \
#    --IDfile ${PWD}/lists/${b}-cases.txt \
#    --pgsfile ${PWD}/pgs-calc-scores-new_models/${b}/scores.z-scores.txt \
#    --outbase ${PWD}/pgs-calc-scores-new_models/${b}
#
#done
```






What am I doing here? Trimming the PCs (PC1-PC20) are the last 20 columns of all but CIDR



```bash
for b in onco i370 tcga ; do
  cov_in=lists/${b}_covariates.tsv
  cols=$( head -1 $cov_in | tr '\t' '\n' | wc -l )
  cat ${cov_in} | cut -d$'\t' -f1-$((cols-20)) | tr -d , | tr '\t' , > $TMPDIR/tmp.csv

  head -1 ${TMPDIR}/tmp.csv > pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv
  tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv
  cat ../20250724-pgs/pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
  join --header -t, pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > pgs-calc-scores-new_models/${b}/${b}-covariates.tsv
done


mv lists/cidr_covariates.tsv lists/cidr_covariates.tsv.old
ln -s /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.20260212.tsv lists/cidr_covariates.tsv

for b in cidr ; do
  cov_in=lists/${b}_covariates.tsv
  cat ${cov_in} | tr -d , | tr '\t' , > $TMPDIR/tmp.csv

  head -1 ${TMPDIR}/tmp.csv > pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv
  tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv
  cat ../20250724-pgs/pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
  join --header -t, pgs-calc-scores-new_models/${b}/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > pgs-calc-scores-new_models/${b}/${b}-covariates.tsv
done
```


```bash
for b in cidr onco i370 tcga ; do
for id in lists/${b}*meta_cases.txt ; do

echo pgscox.claude.bash --dataset ${b} --pgsscores ${PWD}/pgs-calc-scores-new_models/${b}/scores.z-scores.txt \
 --outbase ${PWD}/pgs-calc-scores-new_models-claude/${b}/ \
 --idfile ${id} --covfile ${PWD}/pgs-calc-scores-new_models/${b}/${b}-covariates.tsv

done; done > claude_cox_commands

commands_array_wrapper.bash --array_file claude_cox_commands --time 1-0 --threads 4 --mem 30G --jobcount 4 --jobname pgscox
```


Use METAL to analyze all 4 datasets together.

```bash
for id in lists/onco*meta_cases.txt ; do

echo survival_metal_wrapper_all4.bash $id

done > metal_commands

commands_array_wrapper.bash --array_file metal_commands --time 1-0 --threads 4 --mem 30G
```


```bash
for b in cidr onco i370 tcga ; do
 cp pgs-calc-scores-new_models/${b}/scores.* pgs-calc-scores-new_models-claude/${b}/
done
```

```bash
module load r

./prs_survival_analysis_report_v4.Rmd
mv prs_survival_analysis_report_v4.Rmd.html pgs-calc-scores-new_models-claude/
```

```bash
box_upload.bash pgs-calc-scores-new_models-claude/prs_survival_analysis_report_v4.Rmd.html pgs-calc-scores-new_models-claude/metal* pgs-calc-scores-new_models-claude/*/scores* pgs-calc-scores-new_models-claude/*/*/*
```




##	20260213

All models

Replace the "bad" RSID model scores with the "good" ones.

```bash
./merge_prs_scores.py --all --catalog-base /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores
./merge_prs_scores_info.py --all --catalog-base /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores
```

```bash
for b in onco i370 tcga ; do
  cov_in=lists/${b}_covariates.tsv
  cols=$( head -1 $cov_in | tr '\t' '\n' | wc -l )
  cat ${cov_in} | cut -d$'\t' -f1-$((cols-20)) | tr -d , | tr '\t' , > $TMPDIR/tmp.csv

  head -1 ${TMPDIR}/tmp.csv > pgs-calc-scores-merged/${b}/${b}-covariates_base.csv
  tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> pgs-calc-scores-merged/${b}/${b}-covariates_base.csv
  cat ../20250724-pgs/pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
  join --header -t, pgs-calc-scores-merged/${b}/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > pgs-calc-scores-merged/${b}/${b}-covariates.tsv
done


ln -s /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.20260212.tsv lists/cidr_covariates.tsv

for b in cidr ; do
  cov_in=lists/${b}_covariates.tsv
  cat ${cov_in} | tr -d , | tr '\t' , > $TMPDIR/tmp.csv

  head -1 ${TMPDIR}/tmp.csv > pgs-calc-scores-merged/${b}/${b}-covariates_base.csv
  tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> pgs-calc-scores-merged/${b}/${b}-covariates_base.csv
  cat ../20250724-pgs/pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
  join --header -t, pgs-calc-scores-merged/${b}/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > pgs-calc-scores-merged/${b}/${b}-covariates.tsv
done
```


```bash
for b in cidr onco i370 tcga ; do
for id in lists/${b}*meta_cases.txt ; do

echo pgscox.claude.bash --dataset ${b} --pgsscores ${PWD}/pgs-calc-scores-merged/${b}/scores.z-scores.txt \
 --outbase ${PWD}/pgs-calc-scores-merged/${b}/ \
 --idfile ${id} --covfile ${PWD}/pgs-calc-scores-merged/${b}/${b}-covariates.tsv

done; done > claude_cox_commands

commands_array_wrapper.bash --array_file claude_cox_commands --time 1-0 --threads 4 --mem 30G --jobcount 4 --jobname pgscox
```


```bash
for b in cidr onco i370 tcga ; do
 cp pgs-calc-scores/${b}/scores.info pgs-calc-scores-merged/${b}/
done
```





Use METAL to analyze all 4 datasets together.

```bash
for id in lists/onco*meta_cases.txt ; do

echo survival_metal_wrapper.bash $id /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-merged

done > metal_commands

commands_array_wrapper.bash --array_file metal_commands --time 1-0 --threads 4 --mem 30G --jobname metal --jobcount 9
```



```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=prs_survival_analysis \
  --export=None --output="${PWD}/pgs_survival_analysis.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=32 --mem=240G \
  --wrap="module load pandoc r; ${PWD}/prs_survival_analysis_catalog_report.Rmd"

mv prs_survival_analysis_catalog_report.Rmd.html pgs-calc-scores-merged/
```



```bash
box_upload.bash pgs-calc-scores-merged/prs_survival_analysis_catalog_report.Rmd.html pgs-calc-scores-merged/metal* pgs-calc-scores-merged/*/scores* pgs-calc-scores-merged/*/*/*
```


















https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6





* pgs-calc-scores/ - entire catalog scores PLUS 7 new models HOWEVER the 3 RSID models are a bit wrong as the other_allele can contain commas
* pgs-calc-scores-new_models/ - scoring of just the 7 new models. The 3 RSID models are included in 2 versions: split and commas.
* pgs-calc-scores-new_models-claude/ - merge with above.
* pgs-calc-scores-merged/ - full catalog analysis





##	Edison Analysis prompt 1:

Creating a prompt to  pass to Edison Analysis to perform all that I've done above.

The PGS calculation is time consuming so skipping to the Cox model, METAL merging, and analysis.

Merge select covariate fields or just provide then separately with explanation?

pgs-calc-scores-merged/*/*-covariates.tsv



pgs-calc-scores-merged/*/scores.{info,txt}

tar gz files?



4 datasets ( CIDR, ONCO, I370 and TCGA ) were genotyped on different SNP arrays.
Each of these datasets was then prepared / checked with the HRC-1000G-check-bim.pl using the 1000GP_Phase3_combined.legend reference file.
Imputation on the UMich server was initiated via the command line which used the following options:
* -F "refpanel=1000g-phase-3-v5"
* -F "build=hg19"
* -F "r2Filter=0.3"
* -F "phasing=eagle"
* -F "population=off"

Using bcftools, the imputed results were lifted over to hg38, selecting only those with INFO/R2 > 0.8, normalized twice, 

first with "--check-ref x -m -any"
    -c, --check-ref e|w|x|s         Check REF alleles and exit (e), warn (w), exclude (x), or set (s) bad sites [e]
    -m, --multiallelics -|+TYPE     Split multiallelics (-) or join biallelics (+), type: snps|indels|both|any [both]
then with "-d exact"
    -d, --rm-dup TYPE               Remove duplicate snps|indels|both|all|exact

Then only SNPs were selected using 
bcftools view -m2 -M2 -v snps -Oz -

    -m/M, --min-alleles/--max-alleles INT  Minimum/maximum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)
    -v/V, --types/--exclude-types LIST     Select/exclude comma-separated list of variant types: snps,indels,mnps,ref,bnd,other [null]


Then any SNPs that were lifted over to a different chromosomes (~1235 SNPs) were redistributed to the correct chromosome.


Using https://github.com/lukfor/pgs-calc, scores were calculated for a large subset of the PGS catalog plus 7 additional custom models by chromosome and then merged for each dataset.

Each dataset has then generated a large matrix of scores (DATASET.scores.txt) and json file containing information regarding the scoring process (DATASET.scores.info).


For each dataset we have N-1 samples (includes header line) with scores 

wc -l pgs-calc-scores-merged/*/scores.txt
       483 pgs-calc-scores-merged/cidr/scores.txt
      4620 pgs-calc-scores-merged/i370/scores.txt
      4366 pgs-calc-scores-merged/onco/scores.txt
      6717 pgs-calc-scores-merged/tcga/scores.txt

We don't have covariates for all.

For each dataset we have N-1 samples (includes header line) with some covariates 

wc -l pgs-calc-scores-merged/*/*-covariates.tsv 
    447 pgs-calc-scores-merged/cidr/cidr-covariates.tsv
   1252 pgs-calc-scores-merged/i370/i370-covariates.tsv
   4139 pgs-calc-scores-merged/onco/onco-covariates.tsv
   6711 pgs-calc-scores-merged/tcga/tcga-covariates.tsv


For each dataset, a DATASET.covariates.csv has been created containing
* IID
* dataset (cidr,i370,onco,tcga so could possible combine the files)
* source (Geno added this for Onco because it has AGS and Mayo, would apply to I370 and TCGA too) Only matters as Onco includes cases from different sources that were imputed together? (i370 incudes AGS and WCC, but the WCC are only controls) CIDR is all IPS. TCGA contains FAM_BLOOD,FAM_WTCCC,FAM_WS, TCGA tumor and normal) (treat tumor and normal both as cases?)
* age (continuous int) from age or age_ucsf_surg
* sex (onco and i370 are M/F; CIDR is 1/2; TCGA is male/female)
* case ( 0=control, 1=case; add for CIDR as all are case)
* PC1-8
* rad (0=no, 1=yes?; if known. not in TCGA)
* chemo/tmz (0=no, 1=yes?; if known. not in TCGA; tmz for CIDR) temodar?
* vstatus (0=dead, 1=alive? or vice versa?; deceased in CIDR)
* survdays (continuous int)
* idh (0=wildtype, 1=mutant?) From idh or idhwt_gwas/idhmut_gwas
* pq (0=intact, 1=codel?) from either pq or pqimpute?
* tert (0=?, 1=?) (not in CIDR)
* grade (high and low thresholds?) (grade in CIDR; ngrade in Onco,I370; not in TCGA)


    344 lists/tcga_IDHmut_meta_cases.txt
    378 lists/tcga_IDHwt_meta_cases.txt

     21 lists/tcga_HGG_IDHmut_meta_cases.txt
    303 lists/tcga_HGG_IDHwt_meta_cases.txt

    320 lists/tcga_LrGG_IDHmut_meta_cases.txt
     75 lists/tcga_LrGG_IDHwt_meta_cases.txt

    131 lists/tcga_LrGG_IDHmut_1p19qcodel_meta_cases.txt
    189 lists/tcga_LrGG_IDHmut_1p19qintact_meta_cases.txt


CIDR
Var Name,Code,Description
ID,,Unique IPS identifier
rad,1,Received any radiation after IPS eligible surgery
,0,No radiation documented after IPS eligible surgery
,9,Unknown if given (could not find treatment information)
tmz,1,TMZ given at any point after IPS eligible surgery
,0,Not given (in some cases not able to determine because no information or tx was given elsewhere and we did not follow the patient)
,9,Unknown if given (could not find treatment information)
idhmut,IDH mutation status ,encoded value,1=mutated,0=wildtype, 9=unknown,,,,,,,,,,
pq,Medical record/path review confirmation that tumor was 1p19q co-deleted. Only pulled and confirmed for oligodendroglioma patients,encoded value,0= 1p/19q intact  ,1= 1p/19q codeleted,blank=not abstracted,,,,,,,,,,
deceased,Vital status at last follow-up,encoded value,0=alive as of last follow up,1= deceased,,,,,,,,,,,
sex,Biological sex,encoded value,1=Male,2=Female,,,,,,,,,,,
dxgroup,Tumor type at IPS study enrollment,encoded value,1A=newly diagnosed GBM,1B=newly diagnosed IDH mutant grade 4 astrocytoma,2=newly diagnosed lower grade glioma (lgg),"3=recurrent lgg, still lgg at enrollment","4=recurrent lgg, now grade 4 at enrollment","5=newly diagnosed glioma, uncertain type",,,,,,,
grade,Tumor grade per pathology report from study enrollment surgery,encoded value,2=tumor grade 2,3=tumor grade 3,4=tumor grade 4,blank=missing/unknown grade,,,,,,,,,

LGG = 2,3
GBM = 4

Case lists ( 20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-merged/*/*-covariates.tsv )
* CIDR is all IPS cases and no controls
* I370 contains AGS cases and AGS controls
* ONCO contains AGS and Mayo cases and AGS and Mayo controls
* TCGA cases contain both tumor and normal samples and FAM controls



For the PGS Survival analysis, we just use cases.

Does no one do case / control analysis on PGS?
Steve  [2:31 PM]
We should do both.

Cases for survival. 
Case/control for risk[2:32 PM]Instruct it to look at the pgs SNPs for any associated traits. To infer potential biological mechanism
