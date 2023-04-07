#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	#set -e  #       exit if any command fails
	set -u  #       Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools/1.13 bowtie2/2.4.4 htslib bedtools2/2.30.0
	fi
	#set -x  #       print expanded command before executing it
#	
#	#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
#	OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
#	
#	#while [ $# -gt 0 ] ; do
#	#	case $1 in
#	#		-d|--dir)
#	#			shift; OUT=$1; shift;;
#	#		*)
#	#			echo "Unknown params :${1}:"; exit ;;
#	#	esac
#	#done
#	
#	mkdir -p ${OUT}
#	
#	MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"
#	
#	
#	outbase=${OUT}/DISCOVERYVCF
#	f=${outbase}/ALU.final_comp.vcf.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		java -Xmx4G -jar ${MELTJAR} MakeVCF \
#			-genotypingdir ${OUT}/DISCOVERYGENO/ \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa \
#			-t ~/.local/MELTv2.2.2/me_refs/1KGP_Hg19/transposon_file_list.txt \
#			-p ${OUT}/DISCOVERYGROUP/	\
#			-w $( dirname ${f} ) \
#			-o $( dirname ${f} )
#		#bgzip $( dirname ${f} )/*.final_comp.vcf
#		#chmod -w $( dirname ${f} )/*.final_comp.vcf.gz
#		for vcf in $( dirname ${f} )/*.final_comp.vcf ; do
#			bgzip $vcf
#			chmod -w ${vcf}.gz
#		done
#	fi
#	
#	
#	date




	date

	#/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/merge_genotype_diffs.py -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/merged_genotype_diffs.csv.gz /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/vcfallq60/*.regions.genotype_snp_diffs.tsv

	#	ls -1 *interval_list
	#	Agilent_SureSelect_Human_All_Exon_50MB.interval_list
	#	Agilent_SureSelect_Human_All_Exon_V4.interval_list
	#	Agilent_SureSelect_Human_All_Exon_v5.interval_list
	#	SeqCap_EZ_Exome_v3_capture.interval_list
	#	xgen-exome-research-panel-targets_6bpexpanded.interval_list
	
	/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/bed_intersection.py -a /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/Agilent_SureSelect_Human_All_Exon_50MB.interval_list -b /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/Agilent_SureSelect_Human_All_Exon_V4.interval_list -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/12.bed

	/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/bed_intersection.py -a /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/12.bed -b /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/Agilent_SureSelect_Human_All_Exon_v5.interval_list -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/123.bed

	/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/bed_intersection.py -a /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/123.bed -b /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/SeqCap_EZ_Exome_v3_capture.interval_list -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/1234.bed

	/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/bed_intersection.py -a /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/1234.bed -b /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/xgen-exome-research-panel-targets_6bpexpanded.interval_list -o /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/12345.bed

	date


else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${script}" \
		--output="${PWD}/logs/${script}.${date}.out" --time=14400 --nodes=1 --ntasks=16 --mem=120G \
		$( realpath ${0} )

fi

