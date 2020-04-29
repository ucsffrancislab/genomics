#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

REFS=/francislab/data1/raw/1000genomes/gwas

WORK=/francislab/data1/working/Geuvadis/20200311-viral_identification/bowtie2.hg38-masked-viruses

OUT=${WORK}/gwas
mkdir -p $OUT
cd $OUT

#	in pheno files, 2 should be presence ( and 1 is absence )

for pheno_dir in pheno_files_1 pheno_files_3 pheno_files_10 ; do
	echo ${pheno_dir}
#for population in afr amr eas eur sas ; do
for pop_dir in ${WORK}/${pheno_dir}/* ; do
	echo ${pop_dir}
	population=$( basename ${pop_dir} )
	echo ${population}
for pheno_file in ${WORK}/${pheno_dir}/${population}/NC_0* ; do
	pheno_name=$(basename $pheno_file)
	echo ${pheno_name}



	#	Not multithreaded so not needed?
	#			--threads 64 \

	#outbase="${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}"
	outdir="${OUT}/${population}/${pheno_dir}"
	mkdir -p ${outdir}
	outbase="${outdir}/${pheno_name}"

	echo ${outbase}

	f="${outbase}.for.manhattan.plot.png"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	I get a lot of 
		#	mkdir: cannot create directory `/scratch/gwendt/job/1776100.cclc01.som.ucsf.edu': Input/output error
		#	WTF
		#	This appears to be happening only on n2 and I can't login directly to investigate.
		#	This does not require this many resources, but running too many breaks things

		#$ qsub -l nodes=1:ppn=2 -l gres=scratch:150 -l vmem=4gb ex-scratch.sh
		#This will identify a node with 2 cores, 2 * 150 GiB = 300 GiB of scratch, and 4 GiB of RAM available.

		#	want total of 200gb

		#	-l feature=nocommunal \
		qsub -N ${pheno_dir/pheno_files_/}:${pheno_name:5:6}:${population} \
			-l gres=scratch:50 \
			-l nodes=1:ppn=4 -l vmem=8gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/plink_to_plot_scratch.bash \
			-F "--plot_prefix '${population^^}-${pheno_dir/pheno_files_/}' \
				--beddir ${REFS}/20200421-all/${population}/ \
				--pheno ${pheno_file} \
				--out ${outdir} \
				--covar ${REFS}/1kg_all_chroms_pruned_mds.mds"

	fi

done	#	for pheno_file in 
done	#	for population in afr amr eas eur sas ; do
done	#	for pheno_dir in 

