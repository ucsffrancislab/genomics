#!/usr/bin/env bash

#	/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/GWAS/20210318-GWAS-glioma-script.sh

#SBATCH --account=francislab
#SBATCH --partition=francislab
#SBATCH --job-name=AGS_illumina_GWAS
#SBATCH --mail-type=END,FAIL		
#SBATCH --mail-user=geno.guerra@ucsf.edu	
#SBATCH --ntasks=8 
#SBATCH --mem=35gb	
#SBATCH --array=1-22
#SBATCH --time=300:00:00
#SBATCH --export=NONE
#SBATCH --output=/francislab/data1/working/20210302-AGS-illumina/20210310-logfiles/GWAS_%A_%a.log		

pwd; hostname; date

module load CBI WitteLab
module load plink2

genpath="/francislab/data1/working/20210302-AGS-illumina/20210303-for_analysis"
logpath="/francislab/data1/working/20210302-AGS-illumina/20210310-logfiles"
phenpath="/francislab/data1/working/20210302-AGS-illumina/20210305-covariates"
ppath="/francislab/data1/working/20210302-AGS-illumina/20210310-GWAS"
outpath="$ppath/results"

chr=$SLURM_ARRAY_TASK_ID	# <-- nice use for an array job
chr=22	#	<--- test using the smallest

scratchpath=$TMPDIR/$$
mkdir -p $scratchpath

# will automatically remove scratch job on exit, regardless of if job succeeds/fails:
#trap "{ cd /scratch/ ; rm -r -f $scratchpath/ ; }" EXIT

outdate="20210318"
#gendate="03292018"

mkdir -p $logpath
mkdir -p $outpath
opath="$outpath/chr$chr"
mkdir -p $opath

# copy data to scratch space:

cp $genpath/chr$chr.dose.* $scratchpath/
cp $phenpath/AGS_illumina_GWAS.phen $scratchpath/
cp $phenpath/AGS_illumina_covariates.txt $scratchpath/
cp $phenpath/AGS_illumina_EUR_ids.txt $scratchpath/


#--pheno-name case,idhmut_gwas,idhmut_1p19qnoncodel_gwas,trippos_gwas,idhwt_gwas,idhmut_1p19qcodel_gwas,idhwt_1p19qnoncodel_TERTmut_gwas \

plink2 \
	--pfile $scratchpath/chr$chr.dose \
	--keep $scratchpath/AGS_illumina_EUR_ids.txt \
	--pheno iid-only $scratchpath/AGS_illumina_GWAS.phen \
	--pheno-name idhmut_only_gwas,tripneg_gwas,idhwt_1p19qnoncodel_gwas \
	--1 \
	--covar iid-only $scratchpath/AGS_illumina_covariates.txt \
	--covar-name Age,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
	--covar-variance-standardize \
	--glm firth-fallback hide-covar cols=chrom,pos,ref,alt1,a1freq,firth,test,nobs,beta,orbeta,se,ci,tz,p,err \--maf 0.01 \
	--memory 15000 \
	--threads 8 \
	--out $scratchpath/chr$chr.$outdate

#	this seems wrong. the \--maf 0.01 - checking
#	--glm firth-fallback hide-covar cols=chrom,pos,ref,alt1,a1freq,firth,test,nobs,beta,orbeta,se,ci,tz,p,err \--maf 0.01 \

echo ""
echo "plink jobs completed, moving results"
start=`date +%s`
#mv $scratchpath/chr$chr.$outdate.* $opath/									#	<---- testing . don't mv
echo "Duration: $((($(date +%s)-$start)/60)) minutes"

echo ""
echo "cleaning up..."
start=`date +%s`
#rm -r -f $scratchpath						#	<---- testing. don't remove
echo "Duration: $((($(date +%s)-$start)/60)) minutes"

exit 0

#[[ -n "$SLURM_JOB_ID" ]] && sstat -j "$SLURM_JOB_ID" --format="JobID,Elapsed,MaxRSS"

