#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

REFS=/francislab/data1/raw/1000genomes/gwas

WORK=/francislab/data1/working/1000genomes/20200311-viral_identification/diamond.viral
#WORK=/francislab/data1/working/1000genomes/20200311-viral_identification/blastn.viral.masked

OUT=${WORK}/gwas_all
mkdir -p $OUT
#cd $OUT
#cd $WORK

#	in pheno files, 2 should be presence ( and 1 is absence )

for pheno_dir in pheno_files_1 pheno_files_3 pheno_files_10 pheno_files_100 pheno_files_1000 ; do
#for pheno_dir in pheno_files_1 pheno_files_3 ; do
#for pheno_dir in pheno_files_10 pheno_files_100 pheno_files_1000 ; do
	echo ${pheno_dir}
#for population in afr amr eas eur sas ; do
for population in eur ; do
	echo ${population}
for pheno_file in ${WORK}/${pheno_dir}/${population}/* ; do
	pheno_name=$(basename $pheno_file)
	echo ${pheno_name}

	#for bedfile in ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ; do
	#for bedfile in ${WORK}/select_eur_positions/chr*.bed ; do
	#for bedfile in ${REFS}/20200401/eur/chr*.bed ; do		#	Select SNPS
	for bedfile in ${REFS}/20200402/eur/chr*.bed ; do			#	ALL SNPS

		echo $bedfile

		# drop the shortest suffix match to ".*" (the .bed extension)
		bedfile_noext=${bedfile%.*}

		#	drop the longest prefix match to "*/" (the path)
		bedfile_core=${bedfile_noext##*/}

		mkdir -p ${OUT}/${population}/${pheno_dir}

		#	Initial run was with PLINK v1.90b3.38 64-bit (7 Jun 2016)
		#	This output produced .no.covar.assoc.logistic
		#	This is different than now with different columns
		#	Not sure how to resolve. Will try downloading older version.

		#	$ head test.no.covar.assoc.logistic 
		#	 CHR                                             SNP         BP   A1       TEST    NMISS         OR         STAT            P 
		#	   6                                     rs561313667      63979    T        ADD      489         NA           NA           NA
		#	   6                                     rs530120680      63980    G        ADD      489         NA           NA           NA
		#	   6                                     rs540888038      73938    G        ADD      489         NA           NA           NA

		#	head gwas/pheno_files_1/10298_Human_alphaherpesvirus_1.ALL.chr13.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.afr.pruned.no.covar.PHENO1.glm.logistic
		#	#CHROM	POS	ID	REF	ALT	A1	TEST	OBS_CT	OR	LOG(OR)_SE	Z_STAT	P
		#	13	19020047	rs186129910	A	T	T	ADD	661	NA	NA	NA	NA
		#	13	19020078	rs527875342	C	T	T	ADD	661	NA	NA	NA	NA
		#	13	19020095	rs140871821	C	T	T	ADD	661	1.78567	0.259021	2.2384	0.0251947
		#	13	19020165	rs550529448	T	A	A	ADD	661	1.25648	1.21356	0.188137	0.85077

		#plink2 --covar-variance-standardize \






		#	Not multithreaded so not needed?
		#			--threads 64 \

		outbase="${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}"

		qsub -N ${pheno_name:0:5}:${population}:${bedfile_core/chr/} \
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/plink.bash \
			-F "--allow-no-sex \
				--check ${outbase}.no.covar.assoc.logistic \
				--snps-only \
				--logistic hide-covar \
				--covar-name C1,C2,C3,C4,C5,C6 \
				--bfile ${bedfile_noext} \
				--pheno ${pheno_file} \
				--out ${outbase}.no.covar \
				--covar ${REFS}/1kg_all_chroms_pruned_mds.mds"






#					#	plink  produces .assoc.logistic and .log
#					#	plink2 produces .PHENO1.glm.logistic and .log
#
#		#awk '{print $1,$2,$3,$9,$4,$7}' ${bedfile_core}.no.covar.assoc.logistic \
#		#	> ${bedfile_core}.for.plot.txt
#
#		#	PLINK v1.90b6.16 64-bit (19 Feb 2020)
#		awk '{print $1,$2,$3,$9,$4,$7}' \
#			${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.no.covar.assoc.logistic \
#			> ${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.for.plot.txt
#
#		#	plink2 output
#		#	PLINK v2.00a2LM 64-bit Intel (10 Aug 2019)
#		#	Newer version uses different columns in different file
#		#	awk '{print $1,$3,$2,$12,$6,$9}' \
#		#		${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.no.covar.PHENO1.glm.logistic \
#		#		> ${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.for.plot.txt

	done	#	for bedfile in ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ; do

#	#	Not keeping for.plot.all.txt so doesn't need a header
#	#echo "CHR SNP BP P A1 OR" > ${pheno_name}.for.plot.all.txt
#	#grep -v "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
#	#grep --invert-match --no-filename "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
#	grep --invert-match --no-filename "CHR" \
#		${OUT}/${population}/${pheno_dir}/${pheno_name}.*.for.plot.txt \
#		| sed -e 's/^X/23/' -e 's/^Y/24/' \
#		> ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.plot.all.txt
#
#	#	No wildcards, so don't need to specify --no-filename
#	grep --invert-match "NA" ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.plot.all.txt \
#		| shuf -n 200000 > ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.qq.plot
#	#	If not keeping header, don't need to skip the first line anymore!
#	#tail -n +2 ${pheno_name}.for.plot.all.txt | grep -v "NA" | shuf -n 200000 > ${pheno_name}.for.qq.plot
#
#	#	Keeping the NA rows now
#	grep "NA" ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.plot.all.txt \
#		> ${OUT}/${population}/${pheno_dir}/${pheno_name}.NA.txt
#
#	awk '$4 < 0.10' ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.plot.all.txt \
#		> ${OUT}/${population}/${pheno_dir}/${pheno_name}.for.manhattan.plot

done	#	for pheno_file in 
done	#	for population in afr amr eas eur sas ; do
done	#	for pheno_dir in 

