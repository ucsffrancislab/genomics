#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

#arguments_file=${PWD}/REdiscoverTE_EdgeR_rmarkdown.arguments

#	SLURM_ARRAY_TASK_ID
#if [ $# -gt 0 ] ; then
#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
#			-o|--out)
#				shift; OUT=$1; shift;;
#			-e|--extension)
#				shift; extension=$1; shift;;
#			-s|--strand)
#				shift; strand=$1; shift;;
#				#	I really don't know which is correct
#				# --rf assume stranded library fr-firststrand
#				# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
#				#	5' ------------------------------> 3'
#				#	   /2 ----->            <----- /1 - fr-firststrand
#				#	   /1 ----->            <----- /2 - fr-secondstrand
#				#	unstranded
#				#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
#				#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done
	

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r
	fi
	set -x	#	print expanded command before executing it

	line=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line :${line}:"

	#	Use a 1 based index since there is no line 0.

	args=$( sed -n "$line"p ${array_file} )
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

	echo "Done"
	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""
	k=15
	indir=${PWD}/rollup/

	while [ $# -gt 0 ] ; do
		case $1 in
			--threads)
				shift; threads=$1; shift;;
		esac
	done


#	column="grade_collapsed"
#	outdir=${PWD}/rmarkdown_results_all_kirkwood_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){s=substr($NF,1,9);print $1,"CF "s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){s=substr($NF,1,9);print $1,"SE "s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}{s=substr($NF,1,9);print $1,"oldCF_"s}' 20211208-EV.csv >> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
#	column="grade_collapsed"
#	outdir=${PWD}/rmarkdown_results_all_kirkwood_CF_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){s=substr($NF,1,9);print $1,"CF "s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}{s=substr($NF,1,9);print $1,"CF_"s}' 20211208-EV.csv >> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
#	column="grade_collapsed"
#	outdir=${PWD}/rmarkdown_results_all_serum_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){s=substr($NF,1,9);print $1,s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="serum control"){print $1,"Control"}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
#	column="grade_collapsed"
#	outdir=${PWD}/rmarkdown_results_all_kirkwood_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){s=substr($NF,1,9);print $1,"CF "s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){s=substr($NF,1,9);print $1,"SE "s}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}{s=substr($NF,1,9);print $1,"oldCF_"s}' 20211208-EV.csv >> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
#	column="type"
#	outdir=${PWD}/rmarkdown_results_csf_liquid_biopsy_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($7=="CSF Liquid biopsy protocol"){print $1,$8}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		| sed 's/ /_/g' >> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
#
#	# could you please run a comparison based on the "group" column in this spreadsheet? Its our LB CSF vs the Diaz CSF... 
#	#	only a couple subjects but id like to peek
#
#	column="group"
#	outdir=${PWD}/rmarkdown_results_csf_lb_vs_diaz_${column}
#	mkdir -p ${outdir}
#	cp ${PWD}/CSF_compare.csv ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#	column="type"
#	outdir=${PWD}/rmarkdown_results_csf_liquid_biopsy_csf_v_plasma_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($6=="CSF Liquid biopsy protocol" && $7!="SE"){print $1,$7}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.csv \
#		>> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#	column="type"
#	outdir=${PWD}/rmarkdown_results_csf_liquid_biopsy_csf_v_se_${column}
#	mkdir -p ${outdir}
#	echo "id,${column}" > ${outdir}/metadata.csv
#	awk 'BEGIN{FS=OFS=","}($6=="CSF Liquid biopsy protocol" && $7!="PL" && $12==""){print $1,$7}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.csv \
#		>> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done

	column="type"
	outdir=${PWD}/rmarkdown_results_csf_liquid_biopsy_pl_v_se_${column}
	mkdir -p ${outdir}
	echo "id,${column}" > ${outdir}/metadata.csv
	awk 'BEGIN{FS=OFS=","}($6=="CSF Liquid biopsy protocol" && $7!="CSF" && $12==""){print $1,$7}' \
		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_8-1-23hmhmz.csv \
		>> ${outdir}/metadata.csv
	for i in $( seq 9 ); do
		echo $i
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
	done



















#	column="grade_collapsed"
#	outdir=${PWD}/rmarkdown_results_serum_${column}
#	mkdir -p ${outdir}
#	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){print $1,$NF}' \
#		/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv \
#		> ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.01 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 1 0.01 k${k} >> ${array_file}
#	done
#
#
##	grep GBM,Primary,BTC,M metadata.csv > metadata.test.csv
##	grep Test metadata.csv >> metadata.test.csv
#
##	awk '{print $1}' rollup/REdiscoverTE.tsv | awk 'BEGIN{FS="-";OFS=",";print "id","sample","infection","celltype","ancestry"} ( $3 ~ /^(B|CD4_T|CD8_T|NK|monocytes)$/ ){print $0,$1,$2,$3,$4}' > metadata.select.csv
#
##ID,Well,LabID1,Agilent Sample Number,LabID2,Source,Analysis,case/control status,timepoint,Study,Gender ,Age,run type:,Index5,Index 5 seq,"i5 full sequence (3' adapter, i5 index, 5' adapter)",Index7,idex 7 seq,"i7 full sequence (3' adapter, i7 index, 5' adapter)",oligo dt structure
##SFHH011A,A01,1-1,1,20451,SE,case control,control,control,AGS,F,58,NovaSeq SP 150PE 400M,CATS_IDT8_i5_28,CAGTCCAA,"AATGATACGGCGACCACCGAGATCTACAC,CAGTCCAA,TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG",CATS_IDT8_i7_28_NoUMI ,GATTACCG,"CAAGCAGAAGACGGCATACGAGAT,GATTACCG,GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG",GGA GAT GTG TAT AAG AGA CAG NNN NNN NNN GTT TTT TTT TTT TTT TTT TTT TTT TTT TTT TV
#
#	#	data has commas in columns, but its passed where needed so not important
#
#
#	echo -n > ${array_file}
#
#	column="PrimaryTestSE"
#	outdir=${PWD}/rmarkdown_results_${column}
#	mkdir -p ${outdir}
#	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $8 == "Test-SE" ) || ( $9 == "Primary" && $11 == "M" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#	done
#
#
#	column="PrimaryRecurrent"
#	outdir=${PWD}/rmarkdown_results_${column}
#	mkdir -p ${outdir}
#	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#	done
#
#
#	column="PrimaryRecurrentControl"
#	outdir=${PWD}/rmarkdown_results_${column}
#	mkdir -p ${outdir}
#	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv > ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#	done
#
#
#	column="TumorControl"
#	outdir=${PWD}/rmarkdown_results_${column}
#	mkdir -p ${outdir}
#	awk 'BEGIN{FS=OFS=",";print "id","'${column}'"}( ( $9 == "Primary" ) || ( $9 == "Recurrent" ) || ( $9 == "control" ) ){print $1,$9}' metadata.csv | sed -E 's/Primary|Recurrent/tumor/' > ${outdir}/metadata.csv
#	for i in $( seq 9 ); do
#		echo $i
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.05 0.5 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.1 0.2 k${k} >> ${array_file}
#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}
#	done






	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		# using M so can be more precise-ish
		mem=$[threads*7500]M
		scratch_size=$[threads*28]G	#	not always necessary

		#	ls -1 ${IN}/*${extension} > ${array_file}

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		set -x  #       print expanded command before executing it
		#	strand_option=""
		#	[ -n "${strand}" ] && strand_option="--strand ${strand}"
		[ -z "${array}" ] && array="1-${max}"
		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
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


#	No plotPCA?

#	BiocManager::install("affycoretools")
#	BiocManager::install("DESeq2")



