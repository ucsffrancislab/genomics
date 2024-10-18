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
	echo $0 path/*.faa
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".faa"
	outdir=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI #samtools #star/2.7.7a
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

	#base=$( basename ${line} ${extension} )

	#bam=${line}

	#echo
	#echo "base : ${base}"
	#echo "bam : $bam"
	#echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x




	#	/francislab/data2/refs/PhIP-Seq/human_herpes/1226.faa
	#	/francislab/data2/refs/PhIP-Seq/human_herpes/1226/ranked_0.pdb

	f=${line%${extension}}/ranked_0.pdb
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	All that time trying to get GPU working, too limited access
		#	WITH 
		#	singularity exec --nv --writable-tmpfs \
		#  --use_gpu_relax \


		#	WITHOUT GPU
		singularity exec --writable-tmpfs \
  		--bind /francislab,/scratch \
			/francislab/data1/refs/singularity/AlphaFold.sif \
  		/app/run_alphafold.sh \
  		--use_gpu_relax=False \
  		--bfd_database_path=/francislab/data1/refs/alphafold/databases/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
  		--uniref30_database_path=/francislab/data1/refs/alphafold/databases/uniref30/UniRef30_2021_03 \
  		--pdb70_database_path=/francislab/data1/refs/alphafold/databases/pdb70/pdb70 \
  		--uniref90_database_path=/francislab/data1/refs/alphafold/databases/uniref90/uniref90.fasta \
  		--mgnify_database_path=/francislab/data1/refs/alphafold/databases/mgnify/mgy_clusters_2022_05.fa \
  		--template_mmcif_dir=/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/ \
  		--obsolete_pdbs_path=/francislab/data1/refs/alphafold/databases/pdb_mmcif/obsolete.dat \
  		--data_dir=/francislab/data1/refs/alphafold/databases/ \
  		--max_template_date=3000-01-01 \
  		--model_preset=monomer \
  		--fasta_paths=${line} \
  		--output_dir=$( dirname ${line} )

#  --output_dir=${line%.faa}


#  --max_template_date=2020-05-14 \

		chmod a-w $f
	fi



	date

	echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""
	time="1-0"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			--time)
				shift; time=$1; shift;;
			-@|--threads)
				shift; threads=$1; shift;;
			#-o|--out|--outdir|-e|--extension|-s|--strand|--arguments)
			-e|--extension)
				array_options="${array_options} $1 $2"; shift; shift;;
			-h|--help)
				usage;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks ${1} >> ${array_file}; shift ;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		mem=$[threads*7500]M
		scratch_size=$[threads*28]G

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		#--gres=scratch:${scratch_size} \

		[ -z "${array}" ] && array="1-${max}"

		set -x

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".


#  -n, --ntasks=ntasks         number of tasks to run
#      --nice[=value]          decrease scheduling priority by value
#      --no-requeue            if set, do not permit the job to be requeued
#      --ntasks-per-node=n     number of tasks to invoke on each node
#  -N, --nodes=N               number of nodes on which to run (N = min[-max])





#			--time=1-0 --nodes=1 --ntasks-per-node=1 --ntasks=1 --mem=20G --gres=gpu:1 --partition=common \

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=${time} --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

