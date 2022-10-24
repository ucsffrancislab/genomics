#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

arguments_file=${PWD}/REdiscoverTE_EdgeR_rmarkdown.arguments

#	SLURM_ARRAY_TASK_ID
#if [ $# -gt 0 ] ; then
if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r
	fi
	set -x	#	print expanded command before executing it

	line=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line :${line}:"

	#	Use a 1 based index since there is no line 0.

	args=$( sed -n "$line"p ${arguments_file} )
	echo $args

	if [ -z "${args}" ] ; then
		echo "No line at :${line}:"
		exit
	fi

	echo $args


	#${PWD}/REdiscoverTE_EdgeR_rmarkdown.R $*

	cat <<- EOF | R --no-save --no-echo --args $args

		args = commandArgs(trailingOnly=TRUE)

		out_dir = args[3]
		prefix = args[11]
		column = args[5]

		i = args[8]
		filetypes <- c("GENE", "RE_intron", "RE_exon", "RE_intergenic", "RE_all", "RE_all_repFamily", 
			"RE_intron_repFamily", "RE_exon_repFamily", "RE_intergenic_repFamily", "")
		iname=filetypes[strtoi(i)]

		alpha_thresh = args[9]
		logFC_thresh = args[10]

		output_dir = out_dir
		output_file = paste(prefix,column,iname,"alpha",alpha_thresh,"logFC",logFC_thresh,"html", sep=".")

		#rmarkdown::render("REdiscoverTE_EdgeR_rmarkdown.Rmd", output_dir = output_dir, output_file = output_file )

		file.copy("~/.local/bin/REdiscoverTE_EdgeR_rmarkdown.Rmd",tempdir())
		rmarkdown::render(paste(tempdir(),"REdiscoverTE_EdgeR_rmarkdown.Rmd",sep="/"), output_dir = output_dir, output_file = output_file )
		Sys.chmod(out, ( file.info(out)\$mode - as.octmode("200") ) )

	EOF



else

	date=$( date "+%Y%m%d%H%M%S" )
	k=15
	indir=${PWD}/rollup/

	echo -n > ${arguments_file}

	for column in ancestry celltype infection ; do
		echo ${celltype}
		outdir=${PWD}/rmarkdown_results_${column}
		mkdir -p ${outdir}

		for i in $( seq 9 ); do
			echo $i

#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd1${d}" \
#				--output="${PWD}/logs/Rmd1.${column}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} 
#
#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd2${d}" \
#				--output="${PWD}/logs/Rmd2.${column}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} 

			echo ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
			echo ${indir} ${PWD}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		done

	done

	for celltype in B CD4_T CD8_T NK monocytes all_monocytes ; do
		echo ${celltype}
		outdir=${PWD}/rmarkdown_results_${celltype}_infection
		mkdir -p ${outdir}

		for i in $( seq 9 ); do
			echo $i

#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd3${d}" \
#				--output="${PWD}/logs/Rmd3.${celltype}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.05 0.5 k${k} 
#
#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd4${d}" \
#				--output="${PWD}/logs/Rmd4.${celltype}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.1 0.2 k${k} 

			echo ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
			echo ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id infection NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		done

	done

	for celltype in NK.infected NK.noninfected ; do
		echo ${celltype}
		outdir=${PWD}/rmarkdown_results_${celltype}_ancestry
		mkdir -p ${outdir}

		for i in $( seq 9 ); do
			echo $i

#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd5${d}" \
#				--output="${PWD}/logs/Rmd5.${celltype}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.05 0.5 k${k} 
#
#			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#				--job-name="Rmd6${d}" \
#				--output="${PWD}/logs/Rmd6.${celltype}.${i}.${date}.out" \
#				--time=4320 --nodes=1 --ntasks=8 --mem=60G \
#				${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.1 0.2 k${k} 

			echo ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
			echo ${indir} ${PWD}/metadata.${celltype}.csv ${outdir} id ancestry NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		done

	done



	max=$( cat ${arguments_file} | wc -l )

	mkdir ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%1 --job-name="rmarkdown" \
		--output="${PWD}/logs/REdiscoverTE.${date}.rmarkdown.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=8 --mem=60G \
		${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash

fi



