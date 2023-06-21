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
	echo $0 *fasta
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	db=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts
	extension=".fasta"	#_R1.fastq.gz"
	word_size=10
	evalue=0.001

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			-word_size)
				shift; word_size=$1; shift;;
			-evalue)
				shift; evalue=$1; shift;;
			-db)
				shift; db=$1; shift;;
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
	#bam=${line}
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	#echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	outbase=${OUT}/${base}

	f=${outbase}.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running blast"

#		singularity exec --bind /francislab,/scratch,/costellolab \
#			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
#			call_genotype_38 -p ${threads} \
#			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa \
#			-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk \
#			-i ${bam} -sample_name ${base} -outdir ${f}

		blastn \
			-db ${db} \
			-query ${line} \
			-evalue ${evalue} \
			-word_size ${word_size} \
			-outfmt '6 qaccver qstart qend' | sort -k2n,3 | uniq \
			| awk 'BEGIN{FS=OFS="\t"}
				{ 
					if( r == "" ){
						r=$1;s=$2;e=$3 
					} else { 
						if( $2 <= (e+1) ){ 
							if(e>$3){e=$3} }else{ print $1,s-1,e; s=$2; e=$3 } 
					} 
				}END{ if( r != "" ) print r,s-1,e }' > ${f}

		chmod -R a-w ${f}	#	$( dirname ${f} )
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
			-o|--out|-e|--extension|-word_size|-evalue|-db)
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

