#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails			#	can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail
set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
#arguments_file=${PWD}/${script}.arguments

CPC2=/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py
TEPROF2=/c4/home/gwendt/github/twlab/TEProf2Paper/bin
ARGUMENTS=/francislab/data1/refs/TEProf2/TEProF2.arguments.txt
threads=${SLURM_NTASKS:-32}
#extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"
strand=""
using_reference=false

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
#		-r|--reference_merged_candidates_gtf)
#			using_reference=true
#			shift; reference_merged_candidates_gtf=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
#		-e|--extension)
#			shift; extension=$1; shift;;
		-s|--strand)
			shift; strand=$1; shift;;
			#	I really don't know which is correct
			# --rf assume stranded library fr-firststrand
			# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
			#	5' ------------------------------> 3'
			#	   /2 ----->            <----- /1 - fr-firststrand
			#	   /1 ----->            <----- /2 - fr-secondstrand
			#	unstranded
			#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
			#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
		-h|--help)
			echo
			echo "Good question"
			echo
			exit;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mem=$[threads*7500]M
scratch_size=$[threads*28]G

if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r/4.2.3 samtools cufflinks bedtools2
			# bwa bedtools2 star/2.7.7a

		#	http://ccb.jhu.edu/software/stringtie/dl/		gffread / stringtie / gffcompare 
		#	http://ccb.jhu.edu/software/stringtie/dl/gffread-0.12.7.Linux_x86_64.tar.gz
		#	http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz
	fi
	
	date
	echo "IN:${IN}"
	echo "OUT:${OUT}"

	echo "IN and OUT should NOT be the same"

	mkdir -p ${OUT}
	cd ${OUT}

#	echo ${TEPROF2}/translationPart2.R
#	f=${OUT}/Step13.RData
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#			--job-name="translationPart2" \
#			--time=20160 --nodes=1 --ntasks=4 --mem=30G \
#			--output=${OUT}/translationPart2.${date}.out.log \
#			--parsable --dependency=${dependency_id} \
#			--chdir=${OUT} \
#			--wrap="${TEPROF2}/translationPart2.R;chmod -w ${f}" )
#	fi


	sif=/path/to/MEGAnE.sif

	date

	f=${OUT}/dirlist.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		echo "Creating dirlist ${f}"

		## first, list up samples (output directories from Step 1) you are going to merge
		#ls -d /path/to/[all_output_directories] > dirlist.txt
		ls -d ${IN}/* > ${f}
		chmod a-w ${f}

	fi

	date

	ls -l

		echo "merge non-reference ME insertions"
		singularity exec --bind /francislab,/scratch \
			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			joint_calling_hs \
			-p ${threads} \
			-merge_mei \
			-f ${OUT}/dirlist.txt \
			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa

			#-cohort_name test

			#-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk \
			#-i ${bam} -sample_name ${base} -outdir ${f}
			#-fa /path/to/reference_human_genome.fa \

	date

	ls -l

		echo "merge reference ME polymorphisms"
		singularity exec --bind /francislab,/scratch \
			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			joint_calling_hs \
			-p ${threads} \
			-merge_absent_me \
			-f ${OUT}/dirlist.txt \
			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa

			#-cohort_name test


#[gwendt@c4-log1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE]$ ll aggregation/jointcall_out/
#total 1836
#-rw-r----- 1 gwendt francislab 617620 May 27 20:29 2023-5-27-201946_MEI_jointcall.vcf.gz
#-rw-r----- 1 gwendt francislab 591084 May 27 20:21 2023-5-27-201946_MEI_scaffold.vcf.gz
#-rw-r----- 1 gwendt francislab 249680 May 27 20:30 2023-5-27-202933_MEA_jointcall.vcf.gz
#-rw-r----- 1 gwendt francislab 243049 May 27 20:29 2023-5-27-202933_MEA_scaffold.vcf.gz
#-rw-r----- 1 gwendt francislab  66858 May 27 20:30 for_debug_jointcall_abs.log
#-rw-r----- 1 gwendt francislab  99610 May 27 20:29 for_debug_jointcall_ins.log

  
	date

	ls -l

else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

#	reference_merged_candidates_gtf_option=""
#	[ -n "${reference_merged_candidates_gtf}" ] && \
#		reference_merged_candidates_gtf_option="--reference_merged_candidates_gtf ${reference_merged_candidates_gtf}"
#	strand_option=""
#	[ -n "${strand}" ] && strand_option="--strand ${strand}"
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="$(basename $0)" \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}.out.log \
			$( realpath ${0} ) --in ${IN} --out ${OUT} 
#${strand_option} ${reference_merged_candidates_gtf_option}

fi





#	TEProF2_array_wrapper.bash
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam
#	--threads 8

