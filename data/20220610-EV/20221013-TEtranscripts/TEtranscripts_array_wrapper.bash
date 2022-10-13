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
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
set -x  #       print expanded command before executing it

#SALMON="/francislab/data1/refs/salmon"
#index=${SALMON}/REdiscoverTE.k15
#cp -r ${index} ${TMPDIR}/
#scratch_index=${TMPDIR}/$( basename ${index} )

SUFFIX="format.umi.quality15.t2.t3.hg38.name.marked.deduped.hg38.bam"
IN="/francislab/data1/working/20220610-EV/20221010-preprocess-trim-R1only-correction/out"
OUT="/francislab/data1/working/20220610-EV/20221013-TEtranscripts/out"

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

#fasta=$( ls -tr1d ${IN}/*fa.gz | sed -n "$line"p )
#fasta=$( ls -1 ${IN}/*fa.gz | sed -n "$line"p )
bam=$( ls -1 ${IN}/*.${SUFFIX} | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

base=$( basename ${bam} .${SUFFIX} )




out_base=${OUT}/${base}


f=${out_base}.cntTable

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
#if [ -d $f ] ; then
#	echo "$f exists. Skipping."
else
	echo "Running TEcount"
	#	Not sure if hg38.ncbiRefSeq.gtf is the correct GTF file.

	#	singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img \
	#		TEcount --sortByPos --format BAM --mode multi -b ${bam} --project ${out_base} \
	#		--GTF /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
	#		--TE /francislab/data1/refs/TEtranscripts/TEtranscripts_TE_GTF/hg38_rmsk_TE.gtf
	
	#	chmod -w ${f}
	
fi







f=${out_base}.cntTable

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
#if [ -d $f ] ; then
#	echo "$f exists. Skipping."
else
	echo "Running TEcount"
	#	Not sure if hg38.ncbiRefSeq.gtf is the correct GTF file.

	singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img \
		TEcount --sortByPos --format BAM --mode multi -b ${bam} --project ${out_base} \
		--GTF /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
		--TE /francislab/data1/refs/TEtranscripts/TEtranscripts_TE_GTF/hg38_rmsk_TE.gtf
	
	chmod -w ${f}
	
fi







echo "Done"
date

exit



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="TEtranscripts" --output="${PWD}/logs/TEtranscripts.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/TEtranscripts_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

