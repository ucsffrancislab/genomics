
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





##	20240312



```
mkdir tf

cd tf
for b in ../out/*bam ../out/*.bam.bai ; do
ln -s $b
done
cd ..

bcftools_mpileup_call_array_wrapper.bash -q 40 --skip-variants indels \
 --ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
 ${PWD}/tf/*bam
```

No. WAY TOO BIG. Stick with existing merged vcf and see what happens.


```
zcat merged.vcf.gz | tail -n +624 | cut -f1,2,10- | sed -e 's/^#//' -e 's/:[^\t]*//g' -e 's/\.\/\./0/g' -e 's/0\/1/1/g' -e 's/1\/0/1/g' -e 's/1\/1/2/g' -e 's/0\/2/3/g' -e 's/2\/0/3/g' -e 's/1\/2/4/g' -e 's/2\/1/4/g' -e 's/2\/2/5/g' -e 's/0\/3/6/g' -e 's/3\/0/6/g' -e 's/1\/3/7/g' -e 's/3\/1/7/g' -e 's/2\/3/8/g' -e 's/3\/2/8/g' -e 's/3\/3/9/g' > merged.tsv
```




```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="tftest" --output="${PWD}/tf_nn.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.py"

```




