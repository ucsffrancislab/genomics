#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0 *bam
	echo
	echo $0 --threads 8 --extension .bam 
	echo --out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out 
	echo /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out/*bam
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".bam"	#_R1.fastq.gz"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done
	
	#mem=$[threads*7500]M
	#scratch_size=$[threads*28]


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI #samtools bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	

	mkdir -p ${OUT}

	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	echo "Using array_file :${array_file}:"

	line=$( sed -n "$line_number"p ${array_file} )
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

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=4

	while [ $# -gt 0 ] ; do
		case $1 in
			-t|--threads)
				shift; threads=$1; shift;;
			#-o|--out|--outdir|-e|--extension|-x|-r|--ref)
			-o|--out|-e|--extension)
				array_options="${array_options} $1 $2"; shift; shift;;
			-h|--help)
				usage;;
			#-*)
			#	array_options="${array_options} $1"
			#	shift;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks $1 >> ${array_file}; shift;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		# using M so can be more precise-ish
		mem=$[threads*7500]M
		scratch_size=$[threads*28]G	#	not always necessary

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%20 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		#--gres=scratch:${scratch_size}G \


		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

