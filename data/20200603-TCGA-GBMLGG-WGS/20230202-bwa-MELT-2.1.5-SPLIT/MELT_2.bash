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


discoverydir=${OUT}/DISCOVERYIND/

outbase=${OUT}/DISCOVERYGROUP/
f=${outbase}.pre_geno.tsv
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	java -Xmx4G -jar ${MELTJAR} GroupAnalysis \
		-discoverydir ${discoverydir}/ \
		-w $( dirname ${f} ) \
		-t ~/.local/MELTv2.2.2/me_refs/Hg38/transposon_file_list.txt \
		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
		-n ~/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed

	chmod -w ${f}	#${OUT}/${mei}DISCOVERYGROUP/${mei}.pre_geno.tsv
fi



#for mei in ALU HERVK LINE1 SVA ; do
#
#	discoverydir=${OUT}/${mei}DISCOVERYIND/
#	#mkdir ${discoverydir}
#
#	outbase=${OUT}/${mei}DISCOVERYGROUP/${mei}
#	f=${outbase}.pre_geno.tsv
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		java -Xmx4G -jar ${MELTJAR} GroupAnalysis \
#			-discoverydir ${discoverydir}/ \
#			-w $( dirname ${f} ) \
#			-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
#			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
#			-n ~/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed
#
#		chmod -w ${f}	#${OUT}/${mei}DISCOVERYGROUP/${mei}.pre_geno.tsv
#	fi
#
#done

date
exit







ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/*bam | wc -l
278


mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MELT2" --output="${PWD}/logs/MELT2.${date}.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G ${PWD}/MELT_2.bash


