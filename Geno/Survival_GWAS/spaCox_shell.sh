#!/usr/bin/env bash

#SBATCH --account=francislab
#SBATCH --partition=francislab
#SBATCH --job-name=TCGA_spacox
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geno.guerra@ucsf.edu
#SBATCH --ntasks=3
#SBATCH --mem=35gb
#SBATCH --time=100:00:00
#SBATCH --export=NONE
#SBATCH --output=/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210310-logfiles/pharma_spacox_%A.log


pwd; hostname; date

module load CBI WitteLab
module load plink2 bcftools 

array="20210223-TCGA-GBMLGG-WTCCC-Affy6"
vcffile="TCGA_glioma_cases.dosage"		# <-- this doesn't appear to be an actual vcf file and not index file


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
#cp $datpath/${vcffile}.tbi  $scratchpath/
#cp: cannot stat '/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20220425-Pharma/data/TCGA_glioma_cases.dosage.tbi': No such file or directory

cp $covpath $scratchpath/covariates.txt

#cd /home/gguerra/Pharma_TMZ_glioma/Data
#subsets=$(echo TCGA*meta*cases.txt | sed 's/.txt//g')
#for subset in $subsets; do


#for s in ${subsetpath}/TCGA*meta*cases.txt ; do
for s in $( ls -1 ${subsetpath}/TCGA*meta*cases.txt | tail -n 1 ); do
	echo "Looping ..."
 
	subset=$( basename ${s} .txt )
	echo "Subset:$subset:"
	IDfile="$subset.txt"

	cp $subsetpath/$IDfile $scratchpath/

	#	Normal install of SPACox fails as incompatible
	#install_github("WenjianBi/SPACox")
	#	BiocManager::install(c('survival'))

	$scriptpath/SPAcox.R $scratchpath/$vcffile \
		$scratchpath/covariates.txt \
		$scratchpath/$IDfile \
		$scratchpath/$subset.out > $scratchpath/$subset.log

	#	/scratch/gwendt/601036
	#	Looping ...
	#	Subset:TCGA_HGG_IDHmut_meta_cases:
	#	Loading required package: seqminer
	#	Loading required package: data.table
	#	There were 21 warnings (use warnings() to see them)
	#	There were 50 or more warnings (use warnings() to see the first 50)
	#	Warning message:
	#	In coxph.fit(X, Y, istrat, offset, init, control, weights = weights,  :
	#	  Ran out of iterations and did not converge
	#	Error in uniroot(K1_adj, c(-20, 20), extendInt = "upX", G2NB = G2NB, G2NA = G2NA,  : 
	#	  no sign change found in 1000 iterations
	#	Calls: SPACox -> SPACox.one.SNP -> GetProb_SPA -> uniroot
	#	Execution halted

	#	Ah yeah HGG IDHmut is a very small group, so wouldn’t converge

	#rm $scratchpath/$IDfile
	#outpath="/francislab/data1/working/$array/20220425-Pharma/results/survival/$subset"
	outpath=${scriptpath}/testing
	mkdir -p $outpath
	mv $scratchpath/$subset.out $outpath/SPACox_$subset.txt

	echo
done

#/bin/rm -rf $scratchpath


