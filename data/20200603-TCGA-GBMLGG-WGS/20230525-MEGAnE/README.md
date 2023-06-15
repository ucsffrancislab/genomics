
#	20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE


/francislab/data1/refs/MEGAnE



MEGAnE doesn't seem to work with read length < 100

Check read lengths to see what completed

```
grep -l "read lenth = 51" out/*/for_debug.log | wc -l
104
```


Check for absent_MEs_genotyped.vcf to see if processing completed

```
ll -d out/* | wc -l
278

ll -d out/*/absent_MEs_genotyped.vcf | wc -l
174
```




```

MEGAnE_array_wrapper.bash --threads 8 --extension .bam \
--in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out

```



This will create an outdir called `jointcall_out`

```

MEGAnE_aggregation_steps.bash --threads 64 \
--in  /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE

```






```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"

for f in jointcall_out/*vcf.gz vcf_for_phasing/*.gz; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```







#	20230612

```
module load bcftools

for vcf in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_*.vcf.gz ; do
echo ${vcf}
bcftools view --no-header ${vcf} 2>/dev/null | wc -l
done

/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_biallelic.vcf.gz
11720
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_MEA_biallelic.vcf.gz
2212
/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_MEI_biallelic.vcf.gz
9513
```


```
for vcf in /francislab/data1/refs/MEGAnE/1000GP.GRCh38_*.vcf.gz ; do
echo ${vcf}
bcftools view --no-header ${vcf} 2>/dev/null | wc -l
done

/francislab/data1/refs/MEGAnE/1000GP.GRCh38_2504.ME_absences.ALL.vcf.gz
4028
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_2504.ME_absences.PASS.vcf.gz
2931
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_2504.ME_insertions.ALL.vcf.gz
54337
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_2504.ME_insertions.PASS.vcf.gz
45317
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_3202.ME_absences.ALL.vcf.gz
4314
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_3202.ME_absences.PASS.vcf.gz
2966
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_3202.ME_insertions.ALL.vcf.gz
56649
/francislab/data1/refs/MEGAnE/1000GP.GRCh38_3202.ME_insertions.PASS.vcf.gz
46333
```


```
[W::vcf_parse_filter] FILTER 'SD' is not defined in the header

##FILTER=<ID=M,Description="Too many missing genotypes">
##FILTER=<ID=LC,Description="Low confidence">
##FILTER=<ID=NU,Description="Not unique">
##FILTER=<ID=S,Description="Spanning read num is outlier">
##FILTER=<ID=F,Description="Shorter than 50-bp">
##FILTER=<ID=D,Description="Relative depth of breakpoint is outlier">
##FILTER=<ID=G,Description="Outliers during genotyping">
##FILTER=<ID=R,Description="No discordant read stat available">
##FILTER=<ID=Y,Description="Variants on chrY. This is only available when female">
```



```
module load htslib bcftools
for vcf in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_*.vcf.gz ; do
echo ${vcf}
bcftools view ${vcf} | awk 'BEGIN{FS=OFS="\t"}(/^#/){print}(!/^#/){sub(/SD/,"S;D",$7);print}' | bgzip > ${vcf%.vcf.gz}.SD.vcf.gz
done
```



```
for vcf in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/vcf_for_phasing/all_*.SD.vcf.gz ; do
echo ${vcf}
vcf_dir=${vcf%.vcf.gz}
mkdir -p ${vcf_dir}
for sample in $( bcftools view --header-only ${vcf} 2>/dev/null | grep "^#CHROM" | cut -f10- ) ; do
echo ${sample}
bcftools view --no-header ${vcf} --samples ${sample} 2>/dev/null | cut -f1,2,3,10 > ${vcf_dir}/${sample}.tsv
done ; done

```



```
vcf=vcf_for_phasing/all_biallelic.SD.vcf.gz 
normals=$( bcftools view --header-only ${vcf} 2>/dev/null | grep "^#CHROM" | cut -f10- | datamash transpose | grep "^..-....-10" )
tumors=$( bcftools view --header-only ${vcf} 2>/dev/null | grep "^#CHROM" | cut -f10- | datamash transpose | grep "^..-....-01" )


vcf=${PWD}/vcf_for_phasing/all_biallelic.SD.vcf.gz 
for normal in $( bcftools view --header-only ${vcf} 2>/dev/null | grep "^#CHROM" | cut -f10- | datamash transpose | grep "^..-....-10" ) ; do
echo $normal
subject=$( echo ${normal} | cut -d- -f1,2 )
for tumor in $( bcftools view --header-only ${vcf} 2>/dev/null | grep "^#CHROM" | cut -f10- | datamash transpose | grep "^..-....-01" | grep "^${subject}" ) ; do
echo ${normal} - ${tumor}
sdiff -s \
  ${PWD}/vcf_for_phasing/all_biallelic.SD/${normal}.tsv \
  ${PWD}/vcf_for_phasing/all_biallelic.SD/${tumor}.tsv \
  | sed 's/[[:space:]]\+/\t/g' | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4"->"$9}' \
  > ${PWD}/vcf_for_phasing/all_biallelic.SD/${normal}.${tumor}.tsv
done ; done

```

```

./merge_megane_genotype_diffs.py -o merged_normal_tumor_megane.csv ${PWD}/vcf_for_phasing/all_biallelic.SD/*.*.tsv


awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=4;i<=NF;i++){if($i~/->/){c+=1}}print $1,$2,$3,c}' merged_normal_tumor_megane.csv > merged_normal_tumor_megane.mutation_counts.csv

awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=4;i<=NF;i++){if(($i~/->/)&&($i!~/\./)){c+=1}}print $1,$2,$3,c}' merged_normal_tumor_megane.csv > merged_normal_tumor_megane.nondot_mutation_counts.csv

sort -k4nr merged_normal_tumor_megane.nondot_mutation_counts.csv | head -20

chr4	68171189	all_abs_1160	33
chr2	31336814	all_ins_5289	32
chr4	190179651	all_ins_7223	31
chr1	102630524	all_abs_70	28
chr22	20075431	all_ins_6104	28
chr7	36212532	all_ins_8243	28
chr8	16245288	all_ins_8695	28
chr1	102582131	all_abs_69	27
chr11	106173837	all_ins_3052	26
chr21	42965753	all_ins_6075	26
chr2	64872853	all_ins_5383	26
chr13	21614340	all_ins_3549	25
chr15	39399389	all_ins_4117	25
chr19	53194248	all_ins_5191	25
chr20	29640907	all_ins_5862	25
chr3	99936522	all_ins_6443	25
chr5	134427215	all_ins_7577	25
chr10	133689566	all_ins_2785	24
chr11	16576031	all_abs_229	24
chr12	10081572	all_ins_3165	24

```


```
awk -F, '($5=="Brain Lower Grade Glioma"){print $1}' \
	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv | uniq > LGG.txt

awk -F, '($5=="Glioblastoma Multiforme"){print $1}' \
	/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv | uniq > GBM.txt
```



```
for subtype in LGG GBM ; do
echo ${subtype}

( ( cat merged_normal_tumor_megane.csv | datamash transpose | head -3 ) && ( cat merged_normal_tumor_megane.csv | datamash transpose | grep -f ${subtype}.txt ) ) | datamash transpose > merged_normal_tumor_megane.${subtype}.csv

awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=4;i<=NF;i++){if($i~/->/){c+=1}}print $1,$2,$3,c}' merged_normal_tumor_megane.${subtype}.csv > merged_normal_tumor_megane.${subtype}.mutation_counts.csv

awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=4;i<=NF;i++){if(($i~/->/)&&($i!~/\./)){c+=1}}print $1,$2,$3,c}' merged_normal_tumor_megane.${subtype}.csv > merged_normal_tumor_megane.${subtype}.nondot_mutation_counts.csv

sort -k4nr merged_normal_tumor_megane.${subtype}.nondot_mutation_counts.csv | head -20

done
```



```
LGG
chr15	39399389	all_ins_4117	18
chr22	20075431	all_ins_6104	18
chr2	31336814	all_ins_5289	18
chr4	190179651	all_ins_7223	17
chr2	169785008	all_abs_2114	16
chr11	16576031	all_abs_229	15
chr19	6987454	all_abs_733	15
chr4	68171189	all_abs_1160	15
chr11	76619300	all_ins_1397	14
chr12	53354543	all_ins_3300	14
chr18	49621033	all_ins_4939	14
chr19	53194248	all_ins_5191	14
chr2	64872853	all_ins_5383	14
chr6	38954423	all_abs_1438	14
chrX	76034035	all_abs_1857	14
chr12	10081572	all_ins_3165	13
chr14	62759565	all_ins_3980	13
chr15	26627364	all_ins_4091	13
chr20	29640907	all_ins_5862	13
chr3	68821337	all_abs_1049	13

GBM
chr11	106173837	all_ins_3052	19
chr1	102582131	all_abs_69	18
chr4	68171189	all_abs_1160	18
chr1	102630524	all_abs_70	17
chr13	21614340	all_ins_3549	17
chr6	120247085	all_ins_8024	17
chr16	81085872	all_abs_621	16
chr21	5313393	all_ins_5946	16
chr7	36212532	all_ins_8243	15
chr7	47511446	all_ins_8277	15
chr8	124877682	all_ins_8963	15
chr8	16245288	all_ins_8695	15
chr11	61377720	all_ins_2942	14
chr15	77618526	all_abs_567	14
chr21	42965753	all_ins_6075	14
chr2	31336814	all_ins_5289	14
chr4	190179651	all_ins_7223	14
chr5	134427215	all_ins_7577	14
chr11	38779510	all_ins_2887	13
chr12	90452611	all_abs_348	13

```






```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_normal_tumor_megane* ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```






##	20230614



```
bcftools +fill-tags -l

GTisec
GTsubset
ad-bias
add-variantkey
af-dist
allele-length
check-ploidy
check-sparsity
color-chrs
contrast
counts
dosage
fill-AN-AC
fill-from-fasta
fill-tags
fixploidy
fixref
frameshifts
guess-ploidy
gvcfz
impute-info
indel-stats
isecGT
mendelian
mendelian2
missing2ref
parental-origin
prune
remove-overlaps
scatter
setGT
smpl-stats
split
split-vep
tag2tag
trio-dnm2
trio-stats
trio-switch-rate
variant-distance
variantkey-hex


bcftools +fill-tags -- -l

INFO/AC        Number:A  Type:Integer  ..  Allele count in genotypes
INFO/AC_Hom    Number:A  Type:Integer  ..  Allele counts in homozygous genotypes
INFO/AC_Het    Number:A  Type:Integer  ..  Allele counts in heterozygous genotypes
INFO/AC_Hemi   Number:A  Type:Integer  ..  Allele counts in hemizygous genotypes
INFO/AF        Number:A  Type:Float    ..  Allele frequency from FMT/GT or AC,AN if FMT/GT is not present
INFO/AN        Number:1  Type:Integer  ..  Total number of alleles in called genotypes
INFO/ExcHet    Number:A  Type:Float    ..  Test excess heterozygosity; 1=good, 0=bad
INFO/END       Number:1  Type:Integer  ..  End position of the variant
INFO/F_MISSING Number:1  Type:Float    ..  Fraction of missing genotypes (all samples, experimental)
INFO/HWE       Number:A  Type:Float    ..  HWE test (PMID:15789306); 1=good, 0=bad
INFO/MAF       Number:1  Type:Float    ..  Frequency of the second most common allele
INFO/NS        Number:1  Type:Integer  ..  Number of samples with data
INFO/TYPE      Number:.  Type:String   ..  The record type (REF,SNP,MNP,INDEL,etc)
FORMAT/VAF     Number:A  Type:Float    ..  The fraction of reads with the alternate allele, requires FORMAT/AD or ADF+ADR
FORMAT/VAF1    Number:1  Type:Float    ..  The same as FORMAT/VAF but for all alternate alleles cumulatively
TAG:Number=Type(EXPR)                  ..  Experimental support for user expressions such as DP:1=int(sum(DP))
               If Number and Type are not given (e.g. DP=sum(DP)), variable number (Number=.) of floating point
               values (Type=Float) will be used.
```



```
bcftools view --apply-filters PASS --samples-file ${f} --force-samples ${vcf} \
 | bcftools +fill-tags -o ${f}.${basevcf} -Oz -- -t AF
```


```
vcf=${PWD}/vcf_for_phasing/all_biallelic.SD.vcf.gz

zgrep -m1 "^#CHROM" ${vcf} | cut -f10- | datamash transpose > ${vcf%.vcf.gz}.samples.txt
grep "^..-....-10" ${vcf%.vcf.gz}.samples.txt > ${vcf%.vcf.gz}.samples.normal.txt
grep "^..-....-01" ${vcf%.vcf.gz}.samples.txt > ${vcf%.vcf.gz}.samples.tumor.txt
grep -f GBM.txt ${vcf%.vcf.gz}.samples.normal.txt > ${vcf%.vcf.gz}.samples.GBM.normal.txt
grep -f LGG.txt ${vcf%.vcf.gz}.samples.normal.txt > ${vcf%.vcf.gz}.samples.LGG.normal.txt
grep -f GBM.txt ${vcf%.vcf.gz}.samples.tumor.txt > ${vcf%.vcf.gz}.samples.GBM.tumor.txt
grep -f LGG.txt ${vcf%.vcf.gz}.samples.tumor.txt > ${vcf%.vcf.gz}.samples.LGG.tumor.txt


for sf in ${PWD}/vcf_for_phasing/all_biallelic.SD.samples.* ; do
 echo $sf
 subset=${sf#*all_biallelic.SD.samples}
 subset=${subset%txt}
 echo ${subset}

 bcftools view --samples-file ${sf} -Oz --force-samples ${vcf} \
  | bcftools +fill-tags -Oz -o ${vcf%.vcf.gz}${subset}AF.vcf.gz -- -t AF

 bcftools view --apply-filters PASS --samples-file ${sf} -Oz --force-samples ${vcf} \
  | bcftools +fill-tags -Oz -o ${vcf%.vcf.gz}${subset}PASS.AF.vcf.gz -- -t AF

done

```










