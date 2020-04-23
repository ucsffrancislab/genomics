#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

plot_prefix=""
while [ $# -gt 0 ] ; do
	case $1 in
		--out)
			shift; out=$1; shift;;
		--pheno)
			shift; pheno=$1; shift;;
		--covar)
			shift; covar=$1; shift;;
		--beddir)
			shift; beddir=$1; shift;;
		--plot_prefix)
			shift; plot_prefix=$1; shift;;
	esac
done

## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT


pheno_name=$(basename ${pheno} )

f="${out}/${pheno_name}.for.manhattan.plot.png"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	mkdir -p ${SCRATCH_JOB}/bed
	cp --archive ${beddir}/*.{bed,bim,fam} ${SCRATCH_JOB}/bed/
	scratch_beddir=${SCRATCH_JOB}/bed/

	cp --archive ${pheno} ${SCRATCH_JOB}/
	scratch_pheno=${SCRATCH_JOB}/${pheno_name}

	cp --archive ${covar} ${SCRATCH_JOB}/
	scratch_covar=${SCRATCH_JOB}/$( basename ${covar} )

	scratch_out=${SCRATCH_JOB}/out
	mkdir -p ${scratch_out}

	for bedfile in ${scratch_beddir}/*.bed ; do

		echo $bedfile

		# drop the shortest suffix match to ".*" (the .bed extension)
		bedfile_noext=${bedfile%.bed}

		#	drop the longest prefix match to "*/" (the path)
		bedfile_core=${bedfile_noext##*/}

#		mkdir -p ${OUT}/${population}/${pheno_dir}

		#	Initial run was with PLINK v1.90b3.38 64-bit (7 Jun 2016)
		#	This output produced .no.covar.assoc.logistic
		#	This is different than now with different columns
		#	Not sure how to resolve. Will try downloading older version.

		#	$ head test.no.covar.assoc.logistic 
		#	 CHR            SNP         BP   A1       TEST    NMISS         OR         STAT            P 
		#	   6    rs561313667      63979    T        ADD      489         NA           NA           NA
		#	   6    rs530120680      63980    G        ADD      489         NA           NA           NA
		#	   6    rs540888038      73938    G        ADD      489         NA           NA           NA

		#	head gwas/pheno_files_1/10298_Human_alphaherpesvirus_1.ALL.chr13.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.afr.pruned.no.covar.PHENO1.glm.logistic
		#	#CHROM	POS	ID	REF	ALT	A1	TEST	OBS_CT	OR	LOG(OR)_SE	Z_STAT	P
		#	13	19020047	rs186129910	A	T	T	ADD	661	NA	NA	NA	NA
		#	13	19020078	rs527875342	C	T	T	ADD	661	NA	NA	NA	NA
		#	13	19020095	rs140871821	C	T	T	ADD	661	1.78567	0.259021	2.2384	0.0251947
		#	13	19020165	rs550529448	T	A	A	ADD	661	1.25648	1.21356	0.188137	0.85077


		#plink2 --covar-variance-standardize \

#--out /scratch/gwendt/job/1775728.cclc01.som.ucsf.edu/pheno_files_1/NC_000898_e2e.chr1.no.covar
#Error: Failed to open /scratch/gwendt/job/1775728.cclc01.som.ucsf.edu/pheno_files_1/NC_000898_e2e.chr1.no.covar.log.  Try changing the --out parameter.

		plink --allow-no-sex \
					--snps-only \
					--logistic hide-covar \
					--covar-name C1,C2,C3,C4,C5,C6 \
					--bfile ${bedfile_noext} \
					--pheno ${scratch_pheno} \
					--out ${scratch_out}/${pheno_name}.${bedfile_core}.no.covar \
					--covar ${scratch_covar}

					#	plink  produces .assoc.logistic and .log
					#	plink2 produces .PHENO1.glm.logistic and .log

		if [ -f ${scratch_out}/${pheno_name}.${bedfile_core}.no.covar.assoc.logistic ] ; then
			#	PLINK v1.90b6.16 64-bit (19 Feb 2020)
			awk '{print $1,$2,$3,$9,$4,$7}' \
				${scratch_out}/${pheno_name}.${bedfile_core}.no.covar.assoc.logistic \
				> ${scratch_out}/${pheno_name}.${bedfile_core}.for.plot.txt
		else
			touch ${scratch_out}/${pheno_name}.${bedfile_core}.for.plot.txt
		fi

		#	plink2 output
		#	PLINK v2.00a2LM 64-bit Intel (10 Aug 2019)
		#	Newer version uses different columns in different file
		#	awk '{print $1,$3,$2,$12,$6,$9}' \
		#		${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.no.covar.PHENO1.glm.logistic \
		#		> ${OUT}/${population}/${pheno_dir}/${pheno_name}.${bedfile_core}.for.plot.txt

	done	#	for bedfile in ${REFS}/pruned_vcfs/${population}/ALL.chr*.bed ; do

	#	Not keeping for.plot.all.txt so doesn't need a header
	#echo "CHR SNP BP P A1 OR" > ${pheno_name}.for.plot.all.txt
	#grep -v "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
	#grep --invert-match --no-filename "CHR" *.for.plot.txt >> ${pheno_name}.for.plot.all.txt
	grep --invert-match --no-filename "CHR" \
		${scratch_out}/${pheno_name}.*.for.plot.txt \
		| sed -e 's/^X/23/' -e 's/^Y/24/' \
		> ${scratch_out}/${pheno_name}.for.plot.all.txt

	#	No wildcards, so don't need to specify --no-filename
	grep --invert-match "NA" ${scratch_out}/${pheno_name}.for.plot.all.txt \
		| shuf -n 200000 > ${scratch_out}/${pheno_name}.for.qq.plot
	#	If not keeping header, don't need to skip the first line anymore!
	#tail -n +2 ${pheno_name}.for.plot.all.txt | grep -v "NA" | shuf -n 200000 > ${pheno_name}.for.qq.plot

	#	Keeping the NA rows now
	grep "NA" ${scratch_out}/${pheno_name}.for.plot.all.txt \
		> ${scratch_out}/${pheno_name}.NA.txt

	awk '$4 < 0.10' ${scratch_out}/${pheno_name}.for.plot.all.txt \
		> ${scratch_out}/${pheno_name}.for.manhattan.plot

	if [ -s ${scratch_out}/${pheno_name}.for.manhattan.plot ] && \
		[ -s ${scratch_out}/${pheno_name}.for.qq.plot ] ; then
		manhattan_qq_plot.r \
			--plot_prefix "${plot_prefix}" \
			--manhattan ${scratch_out}/${pheno_name}.for.manhattan.plot \
			--qq ${scratch_out}/${pheno_name}.for.qq.plot \
			--outpath ${scratch_out}
		#	produces ${pheno_name}.for.manhattan.plot.png
	fi

	chmod a-w ${scratch_out}/*
	mkdir -p ${out}/	#	just in case
	mv --update ${scratch_out}/* ${out}/

fi
