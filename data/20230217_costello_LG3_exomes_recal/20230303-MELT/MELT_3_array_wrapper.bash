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

IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.
#sample=$( sed -n ${line}p to_run.txt )
#echo ${sample}

#bam=$( cat to_run.txt | sed -n ${line}p )
bam=$( ls -1 ${IN}/*bam | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

basename=$( basename $bam .bam )
echo ${basename}


MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"


inbase=${OUT}/${basename}


outbase=${OUT}/DISCOVERYGENO/${basename}
f=${outbase}.ALU.tsv
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

	trap "{ chmod -R +w $TMPDIR ; }" EXIT
	scratch_in=${TMPDIR}/in
	mkdir -p ${scratch_in}
	#cp ${inbase}.bam* ${scratch_in}
	ln -s ${inbase}.bam ${scratch_in}
	ln -s ${inbase}.bam.bai ${scratch_in}
	cp ${inbase}.bam.disc ${scratch_in}
	cp ${inbase}.bam.disc.bai ${scratch_in}
	cp ${inbase}.bam.fq ${scratch_in}
	cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa ${scratch_in}
	cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa.fai ${scratch_in}
	#cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa ${scratch_in}
	#cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa.fai ${scratch_in}
	scratch_bam=${scratch_in}/$( basename ${inbase}.bam )
	scratch_work=${TMPDIR}/work
	mkdir -p ${scratch_work}
	cp -r ${OUT}/DISCOVERYGROUP ${TMPDIR}/

	java -Xmx2G -jar ${MELTJAR} Genotype \
		-bamfile ${scratch_bam} \
		-t ~/.local/MELTv2.2.2/me_refs/1KGP_Hg19/transposon_file_list.txt \
		-h ${scratch_in}/hg19.chrXYMT_alts.fa \
		-w ${scratch_work} \
		-p ${TMPDIR}/DISCOVERYGROUP/

	mkdir -p $( dirname ${f} )
	cp ${scratch_work}/$( basename ${f} .ALU.tsv ).*.tsv $( dirname ${f} )/


#	Not sure that using scratch made this any faster.

#	java -Xmx2G -jar ${MELTJAR} Genotype \
#		-bamfile ${inbase}.bam \
#		-t ~/.local/MELTv2.2.2/me_refs/Hg38/transposon_file_list.txt \
#		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
#		-w $( dirname ${f} ) \
#		-p ${OUT}/DISCOVERYGROUP/


	chmod -w ${f%.ALU.tsv}.*.tsv

fi



date
exit




Looks like about 10 hours each? Many on n17 are at 25hours and they are only halfway!
34 hours now.



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-4%4 --job-name="MELT3" --output="${PWD}/logs/MELT3.${date}-%A_%a.out" --time=10080 --nodes=1 --ntasks=4 --mem=40G ${PWD}/MELT_3_array_wrapper.bash

scontrol update ArrayTaskThrottle=6 JobId=352083



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1564%16 --job-name="MELT3" --output="${PWD}/logs/MELT3.${date}-%A_%a.out" --time=10080 --nodes=1 --ntasks=2 --mem=15G --gres=scratch:100G ${PWD}/MELT_3_array_wrapper.bash



