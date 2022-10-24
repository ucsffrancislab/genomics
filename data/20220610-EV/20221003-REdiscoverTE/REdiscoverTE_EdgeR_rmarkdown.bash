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

		out=paste(output_dir,output_file,sep="/")
		print(out)

		if( file.exists(out) && file.access(out, mode=2)==-1  ){
			print("output file exists and is not writable")
		#if( file.exists(out) ){
		#	print("output file exists")
		} else {
			file.copy("~/.local/bin/REdiscoverTE_EdgeR_rmarkdown.Rmd",tempdir())
			rmarkdown::render(paste(tempdir(),"REdiscoverTE_EdgeR_rmarkdown.Rmd",sep="/"), output_dir = output_dir, output_file = output_file )
			Sys.chmod(out, ( file.info(out)\$mode - as.octmode("200") ) )
		}

	EOF

#	Looks like render has 2 options which may have worked instead of copying file to tempdir()
#	intermediates_dir = NULL,
#	knit_root_dir = NULL,


else

	date=$( date "+%Y%m%d%H%M%S" )
	k=15
	indir=${PWD}/rollup/

#	grep GBM,Primary,BTC,M metadata.csv > metadata.test.csv
#	grep Test metadata.csv >> metadata.test.csv

#	awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"} ( $3 ~ /^(B|CD4_T|CD8_T|NK|monocytes)$/ ){print $0,$1,$2,$3,$4}' > metadata.select.csv

#ID,Well,LabID1,Agilent Sample Number,LabID2,Source,Analysis,case/control status,timepoint,Study,Gender ,Age,run type:,Index5,Index 5 seq,"i5 full sequence (3' adapter, i5 index, 5' adapter)",Index7,idex 7 seq,"i7 full sequence (3' adapter, i7 index, 5' adapter)",oligo dt structure
#SFHH011A,A01,1-1,1,20451,SE,case control,control,control,AGS,F,58,NovaSeq SP 150PE 400M,CATS_IDT8_i5_28,CAGTCCAA,"AATGATACGGCGACCACCGAGATCTACAC,CAGTCCAA,TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG",CATS_IDT8_i7_28_NoUMI ,GATTACCG,"CAAGCAGAAGACGGCATACGAGAT,GATTACCG,GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG",GGA GAT GTG TAT AAG AGA CAG NNN NNN NNN GTT TTT TTT TTT TTT TTT TTT TTT TTT TTT TV

	#	data has commas in columns, but its passed where needed so not important


	echo -n > ${arguments_file}

	column="PrimaryTestSE"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $8 == "Test-SE" ) || ( $9 == "Primary" && $11 == "M" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
	for i in $( seq 9 ); do
		echo $i
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${arguments_file}
	done


	column="PrimaryRecurrent"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
	for i in $( seq 9 ); do
		echo $i
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${arguments_file}
	done


	column="PrimaryRecurrentControl"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
	for i in $( seq 9 ); do
		echo $i
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${arguments_file}
	done


	column="TumorControl"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv | sed -E 's/Primary|Recurrent/tumor/' > ${outdir}/metadata.csv
	for i in $( seq 9 ); do
		echo $i
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${arguments_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${arguments_file}
	done




	max=$( cat ${arguments_file} | wc -l )

	mkdir ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%8 --job-name="rmarkdown" \
		--output="${PWD}/logs/REdiscoverTE.${date}.rmarkdown.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=8 --mem=60G \
		${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash

fi



