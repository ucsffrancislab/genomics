
#	SNP2HLA

```BASH
module load plink2
plink2 --pfile ../20210303-for_analysis/chr6.dose --export vcf --out chr6

module load htslib
bgzip chr6.vcf 

module load bcftools
bcftools index chr6.vcf.gz 
bcftools annotate --annotations /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz -c ID -Oz -o chr6.annotated.vcf.gz chr6.vcf.gz 

module load plink
plink --make-bed --vcf chr6.annotated.vcf.gz --out chr6.annotated --double-id



ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.bed
ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.bgl.phased
ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.bim
ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.fam
ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.FRQ.frq
ln -s /francislab/data1/refs/snp2hla/T1DGC/T1DGC_REF.markers

ln -s ~/.local/bin/plink-1.07 plink
```

SNP2HLA seems to prefer an older version of plink


```
./SNP2HLA.csh chr6.annotated REFERENCE (.bgl.phased/.markers) OUTPUT plink {optional: max_memory[mb] window_size}
```



```
./snp2hla.bash
```



Exception in thread "main" java.lang.IllegalArgumentException: AlleleCoder.code() ERROR: Allele in data file but not in marker file: TA for marker rs11965524


```
./plink --noweb --bfile ../20210304-snp2hla/chr6-t1dgc-matched --exclude snplist.txt --make-bed --out chr6-t1dgc-matched.filtered
./snp2hla.bash
```


