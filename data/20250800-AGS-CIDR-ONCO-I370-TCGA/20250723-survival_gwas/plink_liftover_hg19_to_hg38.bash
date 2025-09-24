#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load plink plink2 bcftools	#	openjdk
fi
set -x	#	print expanded command before executing it



#export TMPDIR=${PWD}/scratch/${SLURM_JOBID}
#mkdir -p ${TMPDIR}



b=$( basename $1 )
#d=$( dirname $1 )

mkdir -p ${2}


for chr in {1..22} ; do

	plink2 --threads ${SLURM_NTASKS} --chr $chr --bfile ${1} --out ${TMPDIR}/chr${chr} --export vcf bgz

done

mkdir ${TMPDIR}/maf-output/
mkdir ${TMPDIR}/chunksDir/
mkdir ${2}/statisticsDir/
mkdir ${2}/metaFilesDir/


#	SLURM_TASKS_PER_NODE=16
#	SLURM_NTASKS=16
#	SLURM_JOB_CPUS_PER_NODE=16
#	SLURM_CPUS_ON_NODE=16
#	SLURM_NPROCS=16
#	SLURM_MEM_PER_NODE=122880



java -Xmx$((9 * SLURM_MEM_PER_NODE / 10))M -jar /francislab/data1/refs/Imputation/imputationserver-utils.jar \
	run-qc \
	--population off \
	--reference /francislab/data1/refs/Imputation/1kgp3.FAKE-HG38.reference-panel.json \
	--build hg19 \
	--maf-output ${TMPDIR}/maf-output/ \
	--phasing-window 5000000 \
	--chunksize 20000000 \
	--chunks-out ${TMPDIR}/chunksDir/ \
	--statistics-out ${2}/statisticsDir/ \
	--metafiles-out ${2}/metaFilesDir/ \
	--report ${2}/qc_report.txt \
	--no-index \
	--chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
	${TMPDIR}/chr{?,??}.vcf.gz

#	There doesn't seem to be an error, but this usually returns 1

echo "Return code :$?:"



#	The lifted vcfs contain the "chr" prefix, but not in the header

#	I want it, but not yet so need to remove it when I convert to bed


echo "Liftover Complete"


for vcf in ${TMPDIR}/chunksDir/*.lifted.vcf.gz ; do
	echo "Indexing $vcf"
	bcftools index --tbi ${vcf}
done


#	Concatenating /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas/scratch/758864//chunksDir/chr10.vcf.gz.lifted.vcf.gz
#	The sequence "chr10" not defined in the header: /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas/scratch/758864//chunksDir/chr10.vcf.gz.lifted.vcf.gz
#	(Quick workaround: index the file.)



#	reconcat chromosomes

echo "Concatting"

bcftools concat --output ${TMPDIR}/concated.vcf.gz ${TMPDIR}/chunksDir/*.lifted.vcf.gz

echo "Indexing"

bcftools index --tbi ${TMPDIR}/concated.vcf.gz

chmod -w ${TMPDIR}/concated.vcf.gz ${TMPDIR}/concated.vcf.gz.tbi


echo "Plink creating bed files ${2}/${b}"

plink --output-chr 26 --threads ${SLURM_NTASKS} --vcf ${TMPDIR}/concated.vcf.gz --make-bed --out ${2}/${b}

plink --freq --bfile ${2}/${b} --out ${2}/${b}

chmod -w ${2}/${b}.*


#  --output-chr <MT code> : Set chromosome coding scheme in output files by
#                           providing the desired human mitochondrial code.
#                           (Options are '26', 'M', 'MT', '0M', 'chr26', 'chrM',
#                           and 'chrMT'.)


#	the HRC 1000G check bim script requires the chromosome be numeric
#	Add prefix AFTER so not here.



echo "Done"

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"


