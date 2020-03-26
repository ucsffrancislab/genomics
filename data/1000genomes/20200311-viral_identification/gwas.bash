#!/usr/bin/env bash


REFS=/francislab/data1/raw/1000genomes/gwas

WORK=/francislab/data1/working/1000genomes/20200311-viral_identification
mkdir -p $WORK/gwas
cd $WORK/gwas

#	in pheno files, 2 should be presence ( and 1 is absence )

for population in afr amr eas eur sas ; do
for pheno_dir in pheno_files_1 pheno_files_3 ; do
for pheno_file in ${WORK}/${pheno_dir}/${population}/* ; do
	for bedfile in ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ; do
	
		echo $bedfile
	
		# drop the shortest suffix match to ".*" (the .bed extension)
		bedfile_noext=${bedfile%.*}
	
		#	drop the longest prefix match to "*/" (the path)
		bedfile_core=${bedfile_noext##*/}
	
		pheno_name=$(basename $pheno_file)
		mkdir -p ${WORK}/gwas/${pheno_dir}
	
		plink2 --snps-only \
					--covar-variance-standardize \
					--threads 32 \
					--logistic hide-covar \
					--covar-name C1,C2,C3,C4,C5,C6 \
					--bfile ${bedfile_noext} \
					--pheno ${pheno_file} \
					--out ${WORK}/gwas/${pheno_dir}/${pheno_name}.${bedfile_core}.no.covar \
					--covar ${REFS}/1kg_all_chroms_pruned_mds.mds
	
					#	produces .PHENO1.glm.logistic and .log
	
		#awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.logistic \
		#	> ${bedfile_core}.for.plot.txt
		awk '{print $1,$2,$3,$9,$4,$7}' \
			${pheno_dir}/${pheno_name}.${bedfile_core}.no.covar.PHENO1.glm.logistic \
			> ${pheno_dir}/${pheno_name}.${bedfile_core}.for.plot.txt
	
	done	#	for bedfile in ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ; do

	#	Not keeping for.plot.all.txt so doesn't need a header
	#echo "CHR SNP BP P A1 OR" > ${pheno_name}.for.plot.all.txt
	#grep -v "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
	#grep --invert-match --no-filename "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
	grep --invert-match --no-filename "CHR" \
		${WORK}/gwas/${pheno_dir}/${pheno_name}.*.for.plot.txt \
		> ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.plot.all.txt

	#	No wildcards, so don't need to specify --no-filename
	grep --invert-match "NA" ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.plot.all.txt \
		| shuf -n 200000 > ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.qq.plot
	#	If not keeping header, don't need to skip the first line anymore!
	#tail -n +2 ${pheno_name}.for.plot.all.txt | grep -v "NA" | shuf -n 200000 > ${pheno_name}.for.qq.plot

	#	Keeping the NA rows now
	grep "NA" ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.plot.all.txt \
		> ${WORK}/gwas/${pheno_dir}/${pheno_name}.NA.txt

	awk '$4 < 0.10' ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.plot.all.txt \
		> ${WORK}/gwas/${pheno_dir}/${pheno_name}.for.manhattan.plot

done	#	for pheno_dir in 
done	#	for pheno_file in 
done	#	for population in afr amr eas eur sas ; do

