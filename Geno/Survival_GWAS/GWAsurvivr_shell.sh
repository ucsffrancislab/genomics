#!/usr/bin/env bash

#SBATCH --account=francislab
#SBATCH --partition=francislab
#SBATCH --job-name=TCGA_gwasurvivr
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geno.guerra@ucsf.edu
#SBATCH --ntasks=3
#SBATCH --mem=35gb
#SBATCH --time=100:00:00
#SBATCH --export=NONE
#SBATCH --output=/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210310-logfiles/pharma_gwasurvivr_%A.log


pwd; hostname; date

module load CBI WitteLab
module load plink2 bcftools 

array="20210223-TCGA-GBMLGG-WTCCC-Affy6"
vcffile="TCGA_WTCCC_pharma_merged.vcf.gz"


datpath="/francislab/data1/working/$array/20220425-Pharma/data"
#subsetpath="/home/gguerra/Pharma_TMZ_glioma/Data"
subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"
#IDfile="$subset.txt"
#scriptpath="/francislab/data1/working/$array/20210315-scripts/Pharma/Survival_GWAS"
scriptpath=/c4/home/gwendt/Survival_GWAS
covpath="/francislab/data1/working/$array/20210305-covariates/20230223-covariates/TCGA_WTCCC_EUR_covariates.txt"
scratchpath=${TMPDIR}/$$		#	<----- should add process id to make directory unique
#outdate=20220427

mkdir -p ${scratchpath}
cp $datpath/$vcffile  $scratchpath/
cp $datpath/$vcffile.tbi $scratchpath/
cp $covpath $scratchpath/covariates.txt


#for s in ${subsetpath}/TCGA*meta*cases.txt ; do
for s in $( ls -1 ${subsetpath}/TCGA*meta*cases.txt | tail -n 1 ); do
	echo "Looping ..."
 
	subset=$( basename ${s} .txt )
	echo "Subset:$subset:"
	IDfile="$subset.txt"

	cp $subsetpath/$IDfile $scratchpath/

	#	BiocManager::install(c('gwasurvivr','ncdf4','matrixStats','parallel','survival',
	#		'GWASTools','VariantAnnotation','SummarizedExperiment','SNPRelate'))

	$scriptpath/gwasurvivr.R $scratchpath/$vcffile \
		$scratchpath/covariates.txt \
		$scratchpath/$IDfile \
		$scratchpath/$subset > $scratchpath/${subset}.log


	#	TCGA_HGG_IDHwt_meta_cases
	#	Loading required package: Biobase
	#	Loading required package: BiocGenerics
	#	...
	#	SNPRelate -- supported by Streaming SIMD Extensions 2 (SSE2)
	#	[1] "TCGA-02-0001-10A_TCGA-02-0001-10A" "TCGA-02-0003-10A_TCGA-02-0003-10A"
	#	[3] "TCGA-02-0006-10A_TCGA-02-0006-10A" "TCGA-02-0007-10A_TCGA-02-0007-10A"
	#	[5] "TCGA-02-0009-10A_TCGA-02-0009-10A" "TCGA-02-0011-10A_TCGA-02-0011-10A"
	#	[1] "FAM_BLOOD293294;71056_C08" "FAM_BLOOD293296;71056_B08"
	#	[3] "FAM_BLOOD293417;71056_C01" "FAM_BLOOD293319;71056_A07"
	#	[5] "FAM_BLOOD293317;71056_B07" "FAM_BLOOD293372;71056_A04"
	#	[1] "TCGA-02-0003-10A_TCGA-02-0003-10A" "TCGA-02-0006-10A_TCGA-02-0006-10A"
	#	[3] "TCGA-02-0009-10A_TCGA-02-0009-10A" "TCGA-02-0011-10A_TCGA-02-0011-10A"
	#	[5] "TCGA-02-0027-10A_TCGA-02-0027-10A" "TCGA-02-0033-10A_TCGA-02-0033-10A"
	#	Analysis started on 2025-01-08 at 19:06:17
	#	Covariates included in the models are: age, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10, SexFemale
	#	279 samples are included in the analysis
	#	Analyzing chunk 0-100
	#	Analyzing chunk 100-200
	#	...
	#	Analyzing chunk 298500-298600
	#	Analysis completed on 2025-01-08 at 19:40:18
	#	176 SNPs were removed from the analysis for not meeting the threshold criteria.
	#	List of removed SNPs can be found in /scratch/gwendt/411642/TCGA_HGG_IDHwt_meta_cases.snps_removed
	#	298271 SNPs were analyzed in total
	#	The survival output can be found at /scratch/gwendt/411642/TCGA_HGG_IDHwt_meta_cases.coxph
	#	There were 50 or more warnings (use warnings() to see the first 50)


	#rm $scratchpath/$IDfile
	#outpath="/francislab/data1/working/$array/20220425-Pharma/results/survival/$subset"
	outpath=${scriptpath}/testing
	mkdir -p $outpath
	mv $scratchpath/$subset* $outpath/

	echo
done

/bin/rm -rf $scratchpath


