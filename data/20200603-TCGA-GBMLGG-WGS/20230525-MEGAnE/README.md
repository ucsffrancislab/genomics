
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

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T merged_normal_tumor_megane.csv "${BOX}/"

```







