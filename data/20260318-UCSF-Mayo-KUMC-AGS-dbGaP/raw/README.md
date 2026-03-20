
#	20260318-UCSF-Mayo-KUMC-AGS-dbGaP

Downloading control data for use with the CIDR cases.


```bash

~/.local/sratoolkit.3.4.0-ubuntu64/bin/vdb-config -i

\rm ~/.ncbi/objid.mapping

cat ~/.ncbi/user-settings.mkfg

~/.local/sratoolkit.3.4.0-ubuntu64/bin/prefetch --ngc prj_8276_D16637.ngc cart_prj8276_202603181124.krt



#	not encrypted
#	~/.local/sratoolkit.3.4.0-ubuntu64/bin/vdb-decrypt --ngc prj_8276_D16637.ngc ./


tar xvfz download/phg001860.v1.MDS_AML_Minnesota.genotype-calls-matrixfmt.c1.GRU-PUB.tar.gz
#drwxr-xr-x guptan11/gwas     0 2023-03-02 09:14 Genotype_files_new/
#-rw-r--r-- guptan11/gwas 819592183 2023-03-02 09:14 Genotype_files_new/plink.bed
#-rw-r--r-- guptan11/gwas  60891517 2023-03-02 09:14 Genotype_files_new/plink.bim
#-rw-r--r-- guptan11/gwas     42763 2023-03-02 09:14 Genotype_files_new/plink.fam

mv Genotype_files_new/* ./
rmdir Genotype_files_new


tar xvfz download/phg001860.v1.MDS_AML_Minnesota.sample-info.MULTI.tar.gz 
#drwxr-xr-x guptan11/gwas     0 2023-03-06 10:05 Sample/
#-rw-r--r-- guptan11/gwas 164715 2023-03-06 07:25 Sample/sample-info.csv
#-rw-r--r-- guptan11/gwas   1260 2023-03-06 08:41 Sample/phg001860.v1.MDS_AML_Minnesota.file.desc
#-rw-r--r-- guptan11/gwas 152300 2023-03-06 08:58 Sample/sample-file.txt

cat Sample/sample-info.csv | grep -vs "^#" | cut -d, -f1,2 | sed '1isubject,sample' > subject_sample.csv
/bin/rm -rf Sample/


zcat download/phs002962.v2.pht012600.v2.p1.c1.MDS_AML_Minnesota_Subject_Phenotypes.GRU-PUB.txt.gz| grep -vs "^#" | grep -vs "^$" > metadata.tsv

```


```bash
grep rs429358 plink.bim /francislab/data1/raw/20250813-CIDR/CIDR.bim
#	nothing

cut -f1 plink.bim | uniq | sort | uniq > plink.bim.1.txt
cut -f1 /francislab/data1/raw/20250813-CIDR/CIDR.bim | uniq | sort | uniq > CIDR.bim.1.txt

wc -l plink.bim.1.txt CIDR.bim.1.txt
 27 plink.bim.1.txt
 27 CIDR.bim.1.txt
 54 total

sdiff -sd plink.bim.1.txt CIDR.bim.1.txt | wc -l
0


cut -f2 plink.bim | uniq | sort | uniq > plink.bim.2.txt
cut -f2 /francislab/data1/raw/20250813-CIDR/CIDR.bim | uniq | sort | uniq > CIDR.bim.2.txt

wc -l plink.bim.2.txt CIDR.bim.2.txt
 1914935 plink.bim.2.txt
 1904599 CIDR.bim.2.txt
 3819534 total

sdiff -sd plink.bim.2.txt CIDR.bim.2.txt | wc -l
10336


cut -f1,2 plink.bim | uniq | sort | uniq > plink.bim.1,2.txt &
cut -f1,2 /francislab/data1/raw/20250813-CIDR/CIDR.bim | uniq | sort | uniq > CIDR.bim.1,2.txt &

wc -l plink.bim.1,2.txt CIDR.bim.1,2.txt
 1914935 plink.bim.1,2.txt
 1904599 CIDR.bim.1,2.txt
 3819534 total

sdiff -sd plink.bim.1,2.txt CIDR.bim.1,2.txt | wc -l
16936



cut -f1,2,4 plink.bim | uniq | sort | uniq > plink.bim.1,2,4.txt &
cut -f1,2,4 /francislab/data1/raw/20250813-CIDR/CIDR.bim | uniq | sort | uniq > CIDR.bim.1,2,4.txt &

wc -l plink.bim.1,2,4.txt CIDR.bim.1,2,4.txt
 1914935 plink.bim.1,2,4.txt
 1904599 CIDR.bim.1,2,4.txt
 3819534 total

sdiff -sd plink.bim.1,2,4.txt CIDR.bim.1,2,4.txt | wc -l

#	Taking way too long
#	most are going to be different




grep rs12248560 *sorted.bim

#	CIDR.sorted.bim:10	DUP-seq-rs12248560	0	94761900	A	G
#	CIDR.sorted.bim:10	ilmnseq_rs12248560.2_F2BT	0	94761900	A	G
#	CIDR.sorted.bim:10	rs12248560.2	0	94761900	A	G
#	plink.sorted.bim:10	DUP-seq-rs12248560	0	96521657	T	C
#	plink.sorted.bim:10	ilmnseq_rs12248560.2_F2BT	0	96521657	T	C
#	plink.sorted.bim:10	rs12248560.2	0	96521657	T	C

grep rs12248560 /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/*/VCF/common_rsids
#	/francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids:10:96521657:rs12248560
#	/francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids:10:94761900:rs12248560

```

CIDR was hg38 and confirmed here.

This dataset appears to be hg19.

While the second column (variant identifier) are mostly the same, the fourth column (position) differs.

Compare to the lifted-over version of CIDR

```bash
cut -f1 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim | uniq | sort | uniq > cidr19.bim.1.txt

wc -l plink.bim.1.txt cidr19.bim.1.txt
wc -l plink.bim.1.txt cidr19.bim.1.txt
 27 plink.bim.1.txt    # <- 0-26
 22 cidr19.bim.1.txt   # <- only 1-22
 49 total

sdiff -sd plink.bim.1.txt cidr19.bim.1.txt | wc -l
5



cut -f2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim | uniq | sort | uniq > cidr19.bim.2.txt

wc -l plink.bim.2.txt cidr19.bim.2.txt
 1914935 plink.bim.2.txt
 1824987 cidr19.bim.2.txt
 3739922 total

sdiff -sd plink.bim.2.txt cidr19.bim.2.txt | wc -l
89948


cut -f1,2,4 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim | uniq | sort | uniq > cidr19.bim.1,2,4.txt &

wc -l plink.bim.1,2,4.txt cidr19.bim.1,2,4.txt
 1914935 plink.bim.1,2,4.txt
 1824987 cidr19.bim.1,2,4.txt
 3739922 total

sdiff -sd plink.bim.1,2,4.txt cidr19.bim.1,2,4.txt | wc -l
130259

grep -c : /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim
233486

grep : /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim | awk '{split($2,a,":");split(a[2],b,"-");if(b[1] != $4)print}' | wc -l
15144

grep -c : plink.bim

grep : plink.bim | awk '{split($2,a,":");split(a[2],b,"-");if(b[1] != $4)print}' | wc -l

```



```bash

wc -l \
/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg38-cidr/cidr.bim \
/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim \
/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/prep-cidr-1000g/cidr-updated.bim 

  1904599 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg38-cidr/cidr.bim
  1824987 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/hg19-cidr/cidr.bim
  1092774 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/prep-cidr-1000g/cidr-updated.bim
  6647347 total


```



Test run the preimputation script here before merging with CIDR


```bash
rename plink mdsaml plink.???

b=mdsaml
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_freq \
 --wrap="module load plink; plink --freq --bfile ${b} --out ${b}; chmod -w ${b}.frq" \
 --out=${PWD}/plink.${b}.create_frequency_file.log

b=mdsaml
mkdir testing
cd testing
ln -s ../${b}.bed
ln -s ../${b}.bim
ln -s ../${b}.fam
ln -s ../${b}.frq
cd ..


b=mdsaml
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_check-bim \
 --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose \
 --bim ${PWD}/testing/${b}.bim --frequency ${PWD}/testing/${b}.frq \
 --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" \
 --out=${PWD}/testing/HRC-1000G-check-bim.pl.log




b=mdsaml
s=1000g
#	don't need any of the individual chromosomes
sed -i -e '/--real-ref-alleles/s/^/#/' testing/Run-plink.sh

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_run-plink \
 --wrap="module load plink; sh ${PWD}/testing/Run-plink.sh;\rm ${PWD}/testing/TEMP?.*" \
 --out=${PWD}/testing/Run-plink.sh.log


wc -l testing/*bim
#  1914935 testing/mdsaml.bim
#  1471084 testing/mdsaml-updated.bim
#  3386019 total

```



