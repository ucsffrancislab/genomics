#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

arguments_file=${PWD}/RepEnrich2_EdgeR_rmarkdown.arguments

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


	cat <<- EOF | R --no-save --no-echo --args $args

		args = commandArgs(trailingOnly=TRUE)

		meta = args[1]
		in_dir = args[2]
		out_dir = args[3]
		out_file = args[4]

		output_dir = out_dir
		output_file = paste(out_file,"html", sep=".")

		out=paste(output_dir,output_file,sep="/")
		print(out)

		if( file.exists(out) && file.access(out, mode=2)==-1  ){
			print("output file exists and is not writable")
		#if( file.exists(out) ){
		#	print("output file exists")
		} else {
			rmarkdown::render("~/.local/bin/RepEnrich2_EdgeR_rmarkdown.Rmd", output_dir = output_dir, output_file = output_file )
			Sys.chmod(out, ( file.info(out)\$mode - as.octmode("200") ) )
		}

	EOF



else

	date=$( date "+%Y%m%d%H%M%S" )

#	grep GBM,Primary,BTC,M metadata.csv > metadata.test.csv
#	grep Test metadata.csv >> metadata.test.csv

#	awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"} ( $3 ~ /^(B|CD4_T|CD8_T|NK|monocytes)$/ ){print $0,$1,$2,$3,$4}' > metadata.select.csv

#ID,Well,LabID1,Agilent Sample Number,LabID2,Source,Analysis,case/control status,timepoint,Study,Gender ,Age,run type:,Index5,Index 5 seq,"i5 full sequence (3' adapter, i5 index, 5' adapter)",Index7,idex 7 seq,"i7 full sequence (3' adapter, i7 index, 5' adapter)",oligo dt structure
#SFHH011A,A01,1-1,1,20451,SE,case control,control,control,AGS,F,58,NovaSeq SP 150PE 400M,CATS_IDT8_i5_28,CAGTCCAA,"AATGATACGGCGACCACCGAGATCTACAC,CAGTCCAA,TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG",CATS_IDT8_i7_28_NoUMI ,GATTACCG,"CAAGCAGAAGACGGCATACGAGAT,GATTACCG,GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG",GGA GAT GTG TAT AAG AGA CAG NNN NNN NNN GTT TTT TTT TTT TTT TTT TTT TTT TTT TTT TV

	#	data has commas in columns, but its passed where needed so not important

#meta <- data.frame(
#	row.names=colnames(counts),
#	condition=c("young","young","young","old","old","old","veryold","veryold","veryold"),
#	libsize=c(24923593,28340805,21743712,16385707,26573335,28131649,34751164,37371774,28236419)
#)

	datadir=/francislab/data1/working/20220610-EV/20221010-preprocess-trim-R1only-correction/out
	#indir=/francislab/data1/working/20220610-EV/20221012-RepEnrich2/out
	indir=${PWD}/out

	echo -n > ${arguments_file}

	column="PrimaryTestSE"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	while read id condition ; do
		if [ ${id} == "id" ] ; then
			echo "id,condition,libsize"
		else
			c=$( cat ${datadir}/${id}.format.umi.quality15.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt )
			f=${indir}/${id}/${id}_fraction_counts.txt
			if [ -f ${f} ] && [ ! -w ${f} ] ; then
				echo ${id},${condition},${c}
			fi
		fi
	done < <( awk 'BEGIN{FS=",";OFS="\t";print "id","condition"}( ( $8 == "Test-SE" ) || ( $9 == "Primary" && $11 == "M" ) ){print $1,$9}' metadata.csv ) | tr -d '-' > ${outdir}/metadata.csv

	echo ${outdir}/metadata.csv ${indir} ${outdir} ${column} >> ${arguments_file}




	column="PrimaryRecurrent"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	while read id condition ; do
		if [ ${id} == "id" ] ; then
			echo "id,condition,libsize"
		else
			c=$( cat ${datadir}/${id}.format.umi.quality15.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt )
			f=${indir}/${id}/${id}_fraction_counts.txt
			if [ -f ${f} ] && [ ! -w ${f} ] ; then
				echo ${id},${condition},${c}
			fi
		fi
	done < <( awk 'BEGIN{FS=",";OFS="\t";print "id","condition"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) ){print $1,$9}' metadata.csv ) | tr -d '-' > ${outdir}/metadata.csv

	echo ${outdir}/metadata.csv ${indir} ${outdir} ${column} >> ${arguments_file}




	column="PrimaryRecurrentControl"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	while read id condition ; do
		if [ ${id} == "id" ] ; then
			echo "id,condition,libsize"
		else
			c=$( cat ${datadir}/${id}.format.umi.quality15.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt )
			f=${indir}/${id}/${id}_fraction_counts.txt
			if [ -f ${f} ] && [ ! -w ${f} ] ; then
				echo ${id},${condition},${c}
			fi
		fi
	done < <( awk 'BEGIN{FS=",";OFS="\t";print "id","condition"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv ) | tr -d '-' > ${outdir}/metadata.csv

	echo ${outdir}/metadata.csv ${indir} ${outdir} ${column} >> ${arguments_file}




	column="TumorControl"
	outdir=${PWD}/rmarkdown_results_${column}
	mkdir -p ${outdir}
	while read id condition ; do
		if [ ${id} == "id" ] ; then
			echo "id,condition,libsize"
		else
			c=$( cat ${datadir}/${id}.format.umi.quality15.t2.t3.hg38.name.marked.bam.F3844.aligned_count.txt )
			f=${indir}/${id}/${id}_fraction_counts.txt
			if [ -f ${f} ] && [ ! -w ${f} ] ; then
				echo ${id},${condition},${c}
			fi
		fi
	done < <( awk 'BEGIN{FS=",";OFS="\t";print "id","condition"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv ) | sed -E 's/Primary|Recurrent/tumor/' > ${outdir}/metadata.csv

	echo ${outdir}/metadata.csv ${indir} ${outdir} ${column} >> ${arguments_file}


	max=$( cat ${arguments_file} | wc -l )

	mkdir ${PWD}/logs/
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--array=1-${max}%8 --job-name="rmarkdown" \
		--output="${PWD}/logs/RepEnrich2.${date}.rmarkdown.%A_%a.out" \
		--time=1440 --nodes=1 --ntasks=8 --mem=60G \
		${PWD}/RepEnrich2_EdgeR_rmarkdown.bash

fi



