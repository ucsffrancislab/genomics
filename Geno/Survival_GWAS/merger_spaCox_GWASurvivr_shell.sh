#!/usr/bin/env bash

#SBATCH --account=francislab
#SBATCH --partition=francislab
#SBATCH --job-name=TCGA_survival_merger
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geno.guerra@ucsf.edu
#SBATCH --ntasks=1
#SBATCH --mem=35gb
#SBATCH --time=100:00:00
#SBATCH --export=NONE
#SBATCH --output=/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210310-logfiles/pharma_surv_merger_%A.log


pwd; hostname; date

module load CBI WitteLab
module load plink2 bcftools 

array="20210223-TCGA-GBMLGG-WTCCC-Affy6"
vcffile="TCGA_glioma_cases.dosage"


datpath="/francislab/data1/working/$array/20220425-Pharma/data"
#subsetpath="/home/gguerra/Pharma_TMZ_glioma/Data"
subsetpath="/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data"
#IDfile="$subset.txt"
#scriptpath="/francislab/data1/working/$array/20210315-scripts/Pharma/Survival_GWAS"
scriptpath=/c4/home/gwendt/Survival_GWAS
covpath="/francislab/data1/working/$array/20210305-covariates/20230223-covariates/TCGA_WTCCC_EUR_covariates.txt"
scratchpath=${TMPDIR}/$$		#	<----- should add process id to make directory unique
#outdate=20220427

echo $scratchpath
mkdir -p $scratchpath

cp $datpath/$vcffile  $scratchpath/
cp $covpath $scratchpath/covariates.txt


#cd /home/gguerra/Pharma_TMZ_glioma/Data
#subsets=$(echo TCGA*meta*cases.txt | sed 's/.txt//g')
#for subset in $subsets;


#for s in ${subsetpath}/TCGA*meta*cases.txt ; do
for s in $( ls -1 ${subsetpath}/TCGA*meta*cases.txt | tail -n 1 ); do
	echo "Looping ..."

	subset=$( basename ${s} .txt )
	echo "Subset:$subset:"
	IDfile="$subset.txt"

	cp $subsetpath/$IDfile $scratchpath/


	#outpath="/francislab/data1/working/$array/20220425-Pharma/results/survival/$subset"
	outpath=${scriptpath}/testing
	mkdir -p $outpath

	#outdate=20220815

	cp $outpath/$subset.coxph  $scratchpath/srv.txt
	cp $outpath/SPACox_$subset.txt $scratchpath/spa.txt

	$scriptpath/SPACox_GWASurvivr_merger.R $scratchpath/srv.txt \
		$scratchpath/spa.txt \
		$scratchpath/$subset.out > $scratchpath/$subset.log

	mv $scratchpath/$subset.out $outpath//merged_$subset.txt

	echo
done

#/bin/rm -rf $scratchpath


