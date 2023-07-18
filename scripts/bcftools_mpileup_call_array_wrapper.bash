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
	echo $0 --ref /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/genome-lib/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa 
	echo /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/trimmed/*bam
	echo
	exit
}

if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".bam"

	mpileup_options=""
	call_options=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-t|--threads)
				shift; threads=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			-r|--ref)
				shift; ref=$1; shift;;
			-q)
				mpileup_options="${mpileup_options} $1 $2"; shift; shift;;
			-v|--variants-only)
				#	Output variant sites only
				call_options="${call_options} $1"; shift;;
			-V|--skip-variants)
				# TYPE        Skip indels/snps
				call_options="${call_options} $1 $2"; shift; shift;;
			-*)
				echo
				echo "Unknown param :${1}:"
				echo
				usage;;
			*)
				echo
				echo "Unknown param :${1}:"
				echo
				usage;;
		esac
	done

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI bcftools
	fi
	
	date
	
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

	#base=$( basename $line ${extension} )
	base=${line%${extension}}
	bam=${line}
	vcf=${base}.vcf.gz
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	echo "bam : $bam"
	echo "vcf : $vcf"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	f="${vcf}"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running bcftools"

		#	not sure if -q 60 is always appropriate here
		# STAR The mapping quality MAPQ (column 5) is 255 for uniquely mapping reads, and int(-10*log10(1-. 1/Nmap)) for multi-mapping reads.
		#	Bowtie 2 generates MAPQ scores between 0–42. BWA generates MAPQ scores between 0–37. 
		#	Actually, BWA-MEM produces MAPQ as high as 60. Not sure where the line is though.

		#	this calls for all positions with data, not just variants.

		bcftools mpileup ${mpileup_options} -Ou -f ${ref} ${bam} | bcftools call ${call_options} -m -Oz -o ${vcf}
		bcftools index ${f}
		chmod -w ${f} ${f}.csi
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
			-o|--out|--outdir|-e|--extension|-x|-r|--ref|-V|--skip-variants|-q)
				array_options="${array_options} $1 $2"; shift; shift;;
			-v|--variants-only)
				array_options="${array_options} $1"; shift;;
			-h|--help)
				usage;;
			-*)
				array_options="${array_options} $1"; shift;;
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
		date=$( date "+%Y%m%d%H%M%S%N" )

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi


