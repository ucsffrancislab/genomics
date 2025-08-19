
#	refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF

Trying to devise a way of identifying whether a bim file is hg18, hg19 or hg38

```
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz.md5
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz.tbi
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_all_20180418.vcf.gz
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_all_20180418.vcf.gz.md5
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_all_20180418.vcf.gz.tbi


zcat All_20180418.vcf.gz | grep -n -m1 "^#CHROM"
zcat All_20180418.vcf.gz | tail -n +58 | cut -f1-3 --output-delimiter : | sort > All_rsids

zcat common_all_20180418.vcf.gz | grep -n -m1 "^#CHROM"
zcat common_all_20180418.vcf.gz | tail -n +58 | cut -f1-3 --output-delimiter : | sort > common_rsids


zcat common_all_20180418.vcf.gz | wc -l 
37303035

zcat All_20180418.vcf.gz | wc -l
660146231

```

