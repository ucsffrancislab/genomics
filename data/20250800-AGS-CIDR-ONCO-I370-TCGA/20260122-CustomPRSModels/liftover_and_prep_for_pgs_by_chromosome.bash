#!/usr/bin/env bash

data=$1	#	cidr,tcga,i370,onco
c=$2	#	chromosome

set -x
set -e	#	exit if any command fails	#	the liftover command technically fails
set -u	#	Error on usage of unset variables
set -o pipefail


threads=${SLURM_NTASKS:-4}
memory=${SLURM_MEM_PER_NODE:-10000}

#module load bcftools 	#	don't use the module. use my install which includes the liftover plugin
module load plink2 htslib

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas


#	csi is the preferred, more modern, index and supports larger
#	tbi is more compatible, but I haven't found any issues yet

#	vcf files need indexing before concatenating


vcf=${indir}/imputed-umich-${data}/chr${c}.dose.vcf.gz

outdir=$( dirname ${vcf} )/hg38_0.8
mkdir -p ${outdir}

annotated=${outdir}/annotated.$( basename ${vcf} )
if [ -f ${annotated} ] && [ ! -w ${annotated} ] ; then
	echo "Write-protected ${annotated} exists. Skipping."
else

	bcftools filter -i 'INFO/R2 > 0.8' -O u ${vcf} \
		| bcftools annotate \
			--rename-chrs <(echo -e "${c}\tchr${c}") \
			-Oz -o ${annotated} \
			--write-index=csi
	chmod -w ${annotated}

#	bcftools annotate \
#		--rename-chrs <(echo -e "${c}\tchr${c}") \
#		-Oz -o ${annotated} \
#		--write-index=csi \
#		${vcf}
fi

lifted=${outdir}/lifted.$( basename ${vcf} )
if [ -f ${lifted} ] && [ ! -w ${lifted} ] ; then
	echo "Write-protected ${lifted} exists. Skipping."
else
	#	NEEDS A PLUGIN
	#	bcftools plugin <name> [OPTIONS] <file> [-- PLUGIN_OPTIONS]
	#	use local bcftools with plugin
	#	module unload bcftools
	bcftools +liftover --threads ${threads} -O u \
		${annotated} \
		-- \
		--src-fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz \
		--chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
		--fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
		--reject ${outdir}/rejected.$( basename ${vcf} ) \
		--reject-type z \
		| bcftools sort -Oz -o ${lifted}
	chmod -w ${lifted}
fi



norm=${outdir}/norm.$( basename ${vcf} )
if [ -f ${norm} ] && [ ! -w ${norm} ] ; then
	echo "Write-protected ${norm} exists. Skipping."
else
	#bcftools norm -Oz -o ${norm} \
	bcftools norm -Ou \
		--check-ref x -m -any \
		-f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
		${lifted} | bcftools norm -d exact -Oz -o ${norm}
	chmod -w ${norm}

#		| bcftools sort -O u \
fi

#	VERY, VERY, VERY rarely, this can result in multiple entries at the same position.
#	This will piss of plink scoring.
#		Error: --score variant ID 'chr17:34964976:G:A' appears multiple times in main
#	Need the added "bcftools norm -d exact" call



final=${outdir}/final.$( basename ${vcf} )
if [ -f ${final} ] && [ ! -w ${final} ] ; then
	echo "Write-protected ${final} exists. Skipping."
else
	bcftools annotate --threads ${threads} --set-id '%CHROM:%POS:%REF:%ALT' -O u ${norm} | \
		bcftools view -m2 -M2 -v snps -Oz --write-index=csi -o ${final}
	chmod -w ${final}
fi



pfinal=${outdir}/final.$( basename ${vcf} .vcf.gz )
if [ -f ${pfinal}.psam ] && [ ! -w ${pfinal}.psam ] ; then
	echo "Write-protected ${pfinal} exists. Skipping."
else

	#	Error: chrX is present in the input file, but no sex information was provided;
	#	rerun this import with --psam or --update-sex.  --split-par may also be
	#	appropriate.

	plink2 --memory ${memory} --threads ${threads} --make-pgen \
		--not-chr X --vcf ${final} --out ${pfinal}
	chmod -w ${pfinal}.psam

fi

#mkdir -p

model_dir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels
score_dir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/scores
for model in ${model_dir}/plink_models_with_chr_prefix/*_scoring_system.txt.gz ; do
	model_base=$( basename ${model} _scoring_system.txt.gz )
	echo ${model}

	scores_outdir=${score_dir}/$( basename $( dirname ${vcf} ) )
	mkdir -p ${scores_outdir}

	scores=${scores_outdir}/$( basename ${vcf} .vcf.gz ).${model_base}

	if [ -f ${scores}.score ] && [ ! -w ${scores}.score ] ; then
		echo "Write-protected ${pfinal} exists. Skipping."
	else

		plink2 --memory ${memory} --threads ${threads} \
			--score ${model} 1 2 3 header-read list-variants \
			--pfile ${pfinal} --out ${scores}
		chmod -w ${scores}.score

	fi

done



date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"
echo "Done"


