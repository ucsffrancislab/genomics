

#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-test


pgs-calc getting out of hand. Need some straight test answers.



VCF data 
* chr prefix
  * with
  * without


This vcf ONLY has chr22 in it.

```bash
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr22.dose.corrected.vcf.gz chr22.vcf.gz
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr22.dose.corrected.vcf.gz.csi chr22.vcf.gz.csi
bcftools annotate --rename-chrs <(echo -e "chr22\t22") -Oz -o 22.vcf.gz --write-index=csi chr22.vcf.gz

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr5.dose.corrected.vcf.gz chr5.vcf.gz
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr5.dose.corrected.vcf.gz.csi chr5.vcf.gz.csi
bcftools annotate --rename-chrs <(echo -e "chr5\t5") -Oz -o 5.vcf.gz --write-index=csi chr5.vcf.gz

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr17.dose.corrected.vcf.gz chr17.vcf.gz
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-cidr/hg38_0.8/final.chr17.dose.corrected.vcf.gz.csi chr17.vcf.gz.csi
bcftools annotate --rename-chrs <(echo -e "chr17\t17") -Oz -o 17.vcf.gz --write-index=csi chr17.vcf.gz

```



pgs-calc models
* chr prefix
  * with
  * without
* other allele
  * hm_inferOtherAllele column instead of other_allele - will let it run, but you will get nothing. You NEED other_allele.
  * including commas
  * split into separate entry commas

```bash


for f in ../pgs-calc_models_without_chr_prefix/*_scoring_system.txt.gz ; do
model=$( basename $f )
for chrom in chr num ; do
echo $chrom
for other in split comma infer ; do
mkdir -p models/${chrom}/${other}
echo $other

zcat ${f} | awk -v chrom=$chrom -v other=$other 'BEGIN{FS=OFS="\t"}
(NR==1){
if(other=="infer"){ $5="hm_inferOtherAllele" }
print
}
{
if( chrom=="chr"){ $1="chr"$1 }

if( other=="split"){
 split($5,a,",")
 for( i in a ){
   $5=a[i]
   print
 }
}else if(other=="comma"){
 print
}else if(other=="infer"){ 
 $5=""
 print
}

}' | gzip > models/${chrom}/${other}/${model}

done; done ; done

```

```bash

module load htslib openjdk
for set in $( ls -d models/*/* ) ; do
echo $set
java -Xmx10G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar create-collection --out=${set}/pgs-collection.txt.gz ${set}/*_scoring_system.txt.gz
tabix -S 5 -p vcf ${set}/pgs-collection.txt.gz
done

```


So create-collection with chr prefix is useless and create no variants. Just empty models.


```bash

models/chr/comma

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 0 unique variants and 7 scores.
models/chr/infer

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 0 unique variants and 7 scores.
models/chr/split

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 0 unique variants and 7 scores.
models/num/comma

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 1276691 unique variants and 7 scores.
```

Whilst "hm_inferOtherAllele" let's it run, it doesn't seem to actually infer anything.

And split creates more variants than leaving the command

```bash
models/num/infer

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 0 unique variants and 7 scores.
models/num/split

pgs-calc 1.6.2
https://github.com/lukfor/pgs-calc
(c) 2020 - 2025 Lukas Forer

Wrote 1327213 unique variants and 7 scores.


```

```bash
for vcf in 5 chr5 17 chr17 22 chr22 ; do
echo $vcf
for dir in models/num/comma models/num/split ; do
echo $dir
java -Xmx20G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply ${vcf}.vcf.gz \
--ref ${dir}/pgs-collection.txt.gz \
--out ${dir}/${vcf}.scores.txt \
--info ${dir}/${vcf}.scores.info \
--no-ansi --threads 4
done ; done
```


Whilst create-collection doesn't like the chr prefix, apply doesn't care

```bash
ll pgs-calc-test/models/*/*/*scores*
-rw-r----- 1 gwendt francislab  3080 Feb 10 14:21 pgs-calc-test/models/num/comma/22.scores.info
-rw-r----- 1 gwendt francislab 90869 Feb 10 14:21 pgs-calc-test/models/num/comma/22.scores.txt
-rw-r----- 1 gwendt francislab  3080 Feb 10 14:22 pgs-calc-test/models/num/comma/chr22.scores.info
-rw-r----- 1 gwendt francislab 90869 Feb 10 14:22 pgs-calc-test/models/num/comma/chr22.scores.txt
-rw-r----- 1 gwendt francislab  3077 Feb 10 14:21 pgs-calc-test/models/num/split/22.scores.info
-rw-r----- 1 gwendt francislab 91119 Feb 10 14:21 pgs-calc-test/models/num/split/22.scores.txt
-rw-r----- 1 gwendt francislab  3077 Feb 10 14:22 pgs-calc-test/models/num/split/chr22.scores.info
-rw-r----- 1 gwendt francislab 91119 Feb 10 14:22 pgs-calc-test/models/num/split/chr22.scores.txt
```

split does use more variants. Is that correct, though?




Redo plink

```bash

for vcf in 5 chr5 ; do
echo $vcf
bcftools annotate --set-id '%CHROM:%POS' -Oz -o ${vcf}.chr.pos.vcf.gz ${vcf}.vcf.gz
done

for vcf in chr17 ; do
echo $vcf
bcftools annotate --set-id '%CHROM:%POS' -Oz -o ${vcf}.chr.pos.vcf.gz ${vcf}.vcf.gz
done

for vcf in 22 chr22 ; do
echo $vcf
bcftools annotate --set-id '%CHROM:%POS' -Oz -o ${vcf}.chr.pos.vcf.gz ${vcf}.vcf.gz
done

```


```bash
mkdir plink_models_with_chr_prefix
for f in ../plink_models_with_chr_prefix/*_scoring_system.txt.gz ; do
echo $f
zcat $f | awk '(NR==1){print}(NR>1){split($1,a,":");print a[1]":"a[2],$2,$3}' | gzip > plink_models_with_chr_prefix/$(basename $f)
done
```


```bash
module load plink2

#--geno 0.05 

vcf_base=chr22.chr.pos
vcf=${vcf_base}.vcf.gz
plink2 --make-pgen --not-chr X --vcf ${vcf} --out ${vcf_base}
for model in plink_models_with_chr_prefix/*_scoring_system.txt.gz ; do
  model_base=$( basename ${model} _scoring_system.txt.gz )
  plink2 --score ${model} 1 2 3 header-read list-variants \
    --pfile ${vcf_base} --out $( basename ${vcf} .vcf.gz ).${model_base}
done

vcf_base=chr17.chr.pos
vcf=${vcf_base}.vcf.gz
plink2 --make-pgen --not-chr X --vcf ${vcf} --out ${vcf_base}
for model in plink_models_with_chr_prefix/*_scoring_system.txt.gz ; do
  model_base=$( basename ${model} _scoring_system.txt.gz )
  plink2 --score ${model} 1 2 3 header-read list-variants \
    --pfile ${vcf_base} --out $( basename ${vcf} .vcf.gz ).${model_base}
done

vcf_base=chr5.chr.pos
vcf=${vcf_base}.vcf.gz
plink2 --make-pgen --not-chr X --vcf ${vcf} --out ${vcf_base}
for model in plink_models_with_chr_prefix/*_scoring_system.txt.gz ; do
  model_base=$( basename ${model} _scoring_system.txt.gz )
  plink2 --score ${model} 1 2 3 header-read list-variants \
    --pfile ${vcf_base} --out $( basename ${vcf} .vcf.gz ).${model_base}
done
```


