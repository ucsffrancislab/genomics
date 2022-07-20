#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date


if [ $# -gt 0 ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r
	fi
	set -x	#	print expanded command before executing it

	${PWD}/REdiscoverTE_EdgeR_rmarkdown.R $*

else

	date=$( date "+%Y%m%d%H%M%S" )
	k=15
	indir=${PWD}/rollup/

	for celltype in B CD4_T CD8_T NK monocytes all_monocytes ; do
		echo ${celltype}
		outdir=${PWD}/rmarkdown_results_${celltype}_infection
		mkdir -p ${outdir}

		for i in $( seq 9 ); do
			echo $i

			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
				--job-name="Rmd1${d}" \
				--output="${PWD}/logs/Rmd1.${celltype}.${i}.${date}.out" \
				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.05 0.5 k${k} 

			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
				--job-name="Rmd2${d}" \
				--output="${PWD}/logs/Rmd2.${celltype}.${i}.${date}.out" \
				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.1 0.2 k${k} 

		done

	done

	for celltype in NK.infected NK.nonfected ; do
		echo ${celltype}
		outdir=${PWD}/rmarkdown_results_${celltype}_ancestry
		mkdir -p ${outdir}

		for i in $( seq 9 ); do
			echo $i

			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
				--job-name="Rmd3${d}" \
				--output="${PWD}/logs/Rmd3.${celltype}.${i}.${date}.out" \
				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.05 0.5 k${k} 

			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
				--job-name="Rmd4${d}" \
				--output="${PWD}/logs/Rmd4.${celltype}.${i}.${date}.out" \
				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.1 0.2 k${k} 

		done

	done

fi



