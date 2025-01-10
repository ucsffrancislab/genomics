#!/usr/bin/env bash

#SBATCH --account=francislab
#SBATCH --partition=francislab
#SBATCH --job-name=AGS_Convert_to_vcf
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geno.guerra@ucsf.edu
#SBATCH --ntasks=8
#SBATCH --mem=35gb
#SBATCH --time=100:00:00
#SBATCH --export=NONE
#SBATCH --output=/francislab/data1/working/20210302-AGS-illumina/20210310-logfiles/pharma_plink_to_vcf_%A_%a.log

pwd; hostname; date

module load CBI WitteLab
module load plink2 bcftools vcftools

imppath="/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/imputation"
genpath="/francislab/data1/working/20210302-AGS-illumina/20210303-for_analysis"

#outpath="/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data"
outpath="/c4/home/gwendt/github/ucsffrancislab/genomics/Geno/Survival_GWAS/testing"

#subsetpath="/home/gguerra/Pharma_TMZ_glioma/Data"
subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"

snpfile="Pharma_chrpos.txt"
outfile="AGS_i370_pharma_merged.vcf.gz"
IDfile="AGS_i370_glioma_cases.txt"

mkdir -p $outpath

scratchpath=$TMPDIR/$$
mkdir -p $scratchpath

#outdate="20220427"

#cp $genpath/chr* $scratchpath/
cp $subsetpath/$snpfile $scratchpath/$snpfile
cp $subsetpath/$IDfile $scratchpath/$IDfile

chrs=$(awk -F ":" '{print $1}' $scratchpath/$snpfile | sed -e 's/chr//g' |sort |uniq)


for chr in $chrs; do
#for chr in 22; do																	#			<-----testing

	cp $imppath/chr$chr.dose.vcf.gz $scratchpath/
	vcftools --gzvcf $scratchpath/chr$chr.dose.vcf.gz \
		--snps $scratchpath/$snpfile \
		--keep $scratchpath/$IDfile \
		--recode --recode-INFO-all \
		--out $scratchpath/chr$chr
   #if test -f "$scratchpath/snps_chr$chr.vcf"; then 
   #bcftools view -S $scratchpath/$IDfile $scratchpath/snp_chr$chr.vcf > $scratchpath/chr$chr.vcf
	echo $scratchpath/chr$chr.recode.vcf >> $scratchpath/tomerge.txt
	#scp $scratchpath/chr$chr.recode.vcf $outpath/
	cp $scratchpath/chr$chr.recode.vcf $outpath/
   #fi

done

vcf-concat -f $scratchpath/tomerge.txt > $scratchpath/$outfile

bcftools view -Oz -o $outpath/$outfile $scratchpath/$outfile
#bcftools sort -Oz $scratchpath/$outfile -o $outpath/$outfile
bcftools index --tbi $outpath/$outfile

rm -r -f $scratchpath


