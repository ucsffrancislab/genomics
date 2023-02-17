#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI samtools
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230202-bwa-MELT-2.1.5-SPLIT/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"


outbase=${OUT}/DISCOVERYVCF
f=${outbase}/ALU.final_comp.vcf.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	java -Xmx4G -jar ${MELTJAR} MakeVCF \
		-genotypingdir ${OUT}/DISCOVERYGENO/ \
		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
		-t ~/.local/MELTv2.2.2/me_refs/Hg38/transposon_file_list.txt \
		-p ${OUT}/DISCOVERYGROUP/	\
		-w $( dirname ${f} ) \
		-o $( dirname ${f} )
	gzip $( dirname ${f} )/*.final_comp.vcf
	chmod -w $( dirname ${f} )/*.final_comp.vcf.gz
fi



#for mei in ALU HERVK LINE1 SVA ; do
#
#	outbase=${OUT}/${mei}DISCOVERYVCF/${mei}
#	f=${outbase}.final_comp.vcf.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		java -Xmx4G -jar ${MELTJAR} MakeVCF \
#			-genotypingdir ${OUT}/${mei}DISCOVERYGENO/ \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-w $( dirname ${f} ) \
#			-p ${OUT}/${mei}DISCOVERYGROUP/	\
#			-o $( dirname ${f} )
#		gzip ${f%.gz}
#		chmod -w ${f}
#	fi
#
#done


date
exit







ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/*bam | wc -l
278


mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MELT4" --output="${PWD}/logs/MELT4.${date}.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G ${PWD}/MELT_4.bash


