
#	Align TCGA to hg38 with bwa to check difference with MELT







---

```
#bcftools mpileup -Ou -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa tmp/${base}.chr11:16565415-16565815.bam | bcftools call -mv -Oz -o tmp/${base}.chr11:16565415-16565815.vcf.gz
#	chr11:16565415-16565815
```

```
module load samtools bcftools

mkdir tmp
for bam in out/*.bam ; do
for region in chrX:83003852-83004252 chr8:61165845-61166245 chr22:10934545-10934945	; do 
echo $bam $region
base=$(basename $bam .bam)
samtools view -q 60 -o tmp/${base}.${region}.bam $bam ${region}
samtools index tmp/${base}.${region}.bam
done
done
```



samtools view -F3840 -q 60 $bam chr11:15357698-15359698 |\

```
module load samtools bcftools
mkdir tmp

for bam in out/{02-2483,CS-4938}-*.bam ; do
echo $bam
base=$(basename $bam .bam)
samtools view -F3840 -q 60 $bam chr11:16565415-16565815 |\
 awk -F"\t" '{p=1; s=gensub(/([MIDXS=])/," \\1 ","g",$6); split(s,a," ");for(i=1;i<=length(a);i+=2){ if(a[i+1]=="S"){ print("@"$1":"$3":"$4+p-1); print(substr($10,p,a[i])); print("+"); print(substr($11,p,a[i])); } p+=a[i] }}'|\
 gzip > tmp/${base}.fastq.gz
done
```




```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}/alu-inspection"
for f in tmp/*.chr11:16565415-16565815.bam{,.idx} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```







```
bcftools_mpileup_call_array_wrapper.bash -q 30 --variants-only --skip-variants indels --ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa ${PWD}/out/*bam


```

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="bcftoolsmerge" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/bcftools_merge.$( date "+%Y%m%d%H%M%S%N" ).out.log --export=None \
--wrap="module load bcftools htslib && bcftools merge --threads 16 -Ov /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out/*.vcf.gz | sed -e '/^#CHROM/s:.bam::g' -e '/^#CHROM/s:/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out/::g' | bgzip > /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/merged.vcf.gz"
```


