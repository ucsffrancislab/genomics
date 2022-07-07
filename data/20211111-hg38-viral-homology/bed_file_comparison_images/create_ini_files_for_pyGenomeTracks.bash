#!/usr/bin/env bash


mkdir -p general
mkdir -p aligner_comparison
mkdir -p aligner_comparison2

DIR=/francislab/data1/working/20211111-hg38-viral-homology/bed_file_comparison_images

for f in /francislab/data1/working/20211111-hg38-viral-homology/out/raw/*fasta ; do
	echo $f

	b=$( basename ${f} .fasta )

	if [ ! -e ${DIR}/RM/${b}.masked.fasta.bed ] ; then
		ln -s \
			${DIR}/raw/${b}.fasta.bed \
			${DIR}/RM/${b}.masked.fasta.bed
	fi

	if [ ! -e ${DIR}/raw.split.HM.bt2/${b}.split.25.mask.fasta.bed ] ; then
		ln -s \
			${DIR}/raw/${b}.fasta.bed \
			${DIR}/raw.split.HM.bt2/${b}.split.25.mask.fasta.bed
	fi

	if [ ! -e ${DIR}/raw.split.HM.STAR/${b}.split.25.mask.fasta.bed ] ; then
		ln -s \
			${DIR}/raw/${b}.fasta.bed \
			${DIR}/raw.split.HM.STAR/${b}.split.25.mask.fasta.bed
	fi

	if [ ! -e ${DIR}/RM.split.HM.bt2/${b}.masked.split.25.mask.fasta.bed ] ; then
		ln -s \
			${DIR}/RM/${b}.masked.fasta.bed \
			${DIR}/RM.split.HM.bt2/${b}.masked.split.25.mask.fasta.bed
	fi

	if [ ! -e ${DIR}/RM.split.HM.STAR/${b}.masked.split.25.mask.fasta.bed ] ; then
		ln -s \
			${DIR}/RM/${b}.masked.fasta.bed \
			${DIR}/RM.split.HM.STAR/${b}.masked.split.25.mask.fasta.bed
	fi

	sed -e "s'RAW_HM_FASTA_BED_FILE'${DIR}/raw.split.HM.bt2/${b}.split.25.mask.fasta.bed'" \
		-e "s'RM_FASTA_BED_FILE'${DIR}/RM/${b}.masked.fasta.bed'" \
		-e "s'RM_HM_FASTA_BED_FILE'${DIR}/RM.split.HM.bt2/${b}.masked.split.25.mask.fasta.bed'" \
		general_template.ini > general/${b}.ini

	sed -e "s'BT2_RAW_HM_FASTA_BED_FILE'${DIR}/raw.split.HM.bt2/${b}.split.25.mask.fasta.bed'" \
		-e "s'STAR_RAW_HM_FASTA_BED_FILE'${DIR}/raw.split.HM.STAR/${b}.split.25.mask.fasta.bed'" \
		-e "s'RM_FASTA_BED_FILE'${DIR}/RM/${b}.masked.fasta.bed'" \
		-e "s'BT2_RM_HM_FASTA_BED_FILE'${DIR}/RM.split.HM.bt2/${b}.masked.split.25.mask.fasta.bed'" \
		-e "s'STAR_RM_HM_FASTA_BED_FILE'${DIR}/RM.split.HM.STAR/${b}.masked.split.25.mask.fasta.bed'" \
		aligner_comparison_template.ini > aligner_comparison/${b}.ini

	sed -e "s'BT2_RAW_HM_FASTA_BED_FILE'${DIR}/raw.split.HM.bt2/${b}.split.25.mask.fasta.bed'" \
		-e "s'STAR_RAW_HM_FASTA_BED_FILE'${DIR}/raw.split.HM.STAR/${b}.split.25.mask.fasta.bed'" \
		aligner_comparison2_template.ini > aligner_comparison2/${b}.ini

done

