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


SUFFIX="quality.format.t1.t3.notphiX.notviral.hg38.bam"
IN="/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi"
OUT="/francislab/data1/working/20211208-EV/20221013-TEtranscripts/out"


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

	#	singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img TEcount -h
	#	usage: TEcount [-h] -b RNAseq.bam --GTF genic-GTF-file --TE TE-GTF-file [--format input file format] [--stranded option] [--mode TE counting mode]
	#	               [--project name] [--sortByPos] [-i iteration] [--maxL maxL] [--minL minL] [-L fragLength] [--verbose [verbose]] [--version]
	#	
	#	Measuring TE expression per-sample.
	#	
	#	optional arguments:
	#	  -h, --help            show this help message and exit
	#	  -b RNAseq.bam, --BAM RNAseq.bam
	#	                        An RNAseq BAM file.
	#	  --GTF genic-GTF-file  GTF file for gene annotations
	#	  --TE TE-GTF-file      GTF file for transposable element annotations
	#	  --format input file format
	#	                        Input file format: BAM or SAM. DEFAULT: BAM
	#	  --stranded option     Is this a stranded library? (no, forward, or reverse). For "first-strand" cDNA libraries (e.g. TruSeq stranded), choose reverse. For
	#	                        "second-strand" cDNA libraries (e.g. QIAseq stranded), choose forward. DEFAULT: no.
	#	  --mode TE counting mode
	#	                        How to count TE: uniq (unique mappers only), or multi (distribute among all alignments). DEFAULT: multi
	#	  --project name        Name of this project. DEFAULT: TEcount_out
	#	  --sortByPos           Alignment file is sorted by chromosome position.
	#	  -i iteration, --iteration iteration
	#	                        number of iteration to run the optimization. DEFAULT: 100
	#	  --maxL maxL           maximum fragment length. DEFAULT:500
	#	  --minL minL           minimum fragment length. DEFAULT:0
	#	  -L fragLength, --fragmentLength fragLength
	#	                        average fragment length for single end reads. For paired-end, estimated from the input alignment file. DEFAULT: for paired-end, estimate
	#	                        from the input alignment file; for single-end, ignored by default.
	#	  --verbose [verbose]   Set verbose level. 0: only show critical message, 1: show additional warning message, 2: show process information, 3: show debug
	#	                        messages. DEFAULT:2
	#	  --version             show program's version number and exit
	#	
	#	Example: TEcount -b RNAseq.bam --GTF gene_annotation.gtf --TE TE_annotation.gtf --sortByPos --mode multi

	singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img \
		TEcount --sortByPos --format BAM --mode multi -b ${bam} --project ${out_base} \
		--GTF /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
		--TE /francislab/data1/refs/TEtranscripts/TEtranscripts_TE_GTF/hg38_rmsk_TE.gtf
	
	chmod -w ${f}
	
fi







echo "Done"
date

exit



ll /francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi/*quality.format.t1.t3.notphiX.notviral.hg38.bam | wc -l
13



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%1 --job-name="TEtranscripts" --output="${PWD}/logs/TEtranscripts.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/TEtranscripts_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

