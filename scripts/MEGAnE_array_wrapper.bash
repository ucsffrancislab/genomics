#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
#if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

threads=${SLURM_NTASKS:-8}
extension=".bam"	#_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"
#strand=""

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
#		-s|--strand)
#			shift; strand=$1; shift;;
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
scratch_size=$[threads*28]

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
#if [ $( basename ${0} ) == "slurm_script" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI #samtools bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	
	#		#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
	#		OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
	#		
	#		#while [ $# -gt 0 ] ; do
	#		#	case $1 in
	#		#		-d|--dir)
	#		#			shift; OUT=$1; shift;;
	#		#		*)
	#		#			echo "Unknown params :${1}:"; exit ;;
	#		#	esac
	#		#done

	mkdir -p ${OUT}

	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	line=$( sed -n "$line_number"p ${arguments_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	base=$( basename $line ${extension} )
	bam=${line}
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	outbase=${OUT}/${base}

	#	produces many files
	#
	#		MEI_final_gaussian_genotyped.vcf
	#		breakpoint_pairs_pooled_all.txt.gz
	#		overhang_to_MEI_list.txt.gz
	#		absent_MEs_genotyped.vcf
	#		absent.txt.gz
	#
	#	but this vcf is the last
	f=${outbase}/absent_MEs_genotyped.vcf
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running MEGAnE"

		singularity exec --bind /francislab,/scratch \
			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			call_genotype_38 -p ${threads} \
			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa \
			-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk \
			-i ${bam} -sample_name ${base} -outdir ${f}


		#	The reference genome apparently NEEDS to be unzipped.
		#	
		#	2023-05-25 13:47:05,277:INFO:file=1_indiv_call_genotype.py:module=1_indiv_call_genotype:funcName=<module>:line=331:message=ME insertion search finished!
		#	2023-05-25 13:47:05,282:INFO:file=1_indiv_call_genotype.py:module=1_indiv_call_genotype:funcName=<module>:line=338:message=Absent ME search started.
		#	2023-05-25 13:47:05,282:DEBUG:file=find_absent.py:module=find_absent:funcName=find_abs:line=21:message=started
		#	2023-05-25 13:47:09,923:ERROR:file=find_absent.py:module=find_absent:funcName=find_abs:line=152:message=
		#	Traceback (most recent call last):
		#  File "/usr/local/bin/MEGAnE/scripts/find_absent.py", line 130, in find_abs
		#    fa=parse_fasta_transd(tail.seqfn)
		#  File "/usr/local/bin/MEGAnE/scripts/utils.py", line 69, in parse_fasta_transd
		#    for line in infile:
		#  File "/opt/conda/lib/python3.7/codecs.py", line 322, in decode
		#    (result, consumed) = self._buffer_decode(data, self.errors, final)
		#UnicodeDecodeError: 'utf-8' codec can't decode byte 0x9f in position 24: invalid start byte


		chmod -R a-w $( dirname ${f} )
	fi

	date


else

	ls -1 ${IN}/*${extension} > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%20 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) --out ${OUT} --extension ${extension} )

	#--gres=scratch:${scratch_size}G \


	echo "Throttle with ..."
	echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

fi

#	TEProF2_array_wrapper.bash --threads 4
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam




