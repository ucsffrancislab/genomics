#!/usr/bin/env bash

set -x

module load bcftools
module load plink2

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

data=cidr

for f in ${indir}/imputed-umich-${data}/chr*.dose.vcf.gz; do
	echo $f
	if [ -f ${f}.csi ] ; then
		echo "Index exists. Skipping."
	else
		bcftools index --threads 64 --force ${f}
	fi
done

if [ -f ${indir}/imputed-umich-${data}/dose.vcf.gz ] ; then
	echo "Exists. Skipping."
else
	bcftools concat --threads 64 -Oz \
		-o ${indir}/imputed-umich-${data}/dose.vcf.gz \
		${indir}/imputed-umich-${data}/chr*.dose.vcf.gz
fi

if [ -f ${indir}/imputed-umich-${data}/dose.psam ] ; then
	echo "Exists. Skipping."
else

	#	for plink2 appa
	plink2 --memory 450000 --threads 64 --make-pgen \
		--set-all-var-ids @:#:\$r:\$a --new-id-max-allele-len 662 \
		--vcf ${indir}/imputed-umich-${data}/dose.vcf.gz \
		--out ${indir}/imputed-umich-${data}/dose
fi

#	zcat paper/idhmut_1p19qcodel_scoring_system.txt.gz | awk '{split($1,a,":");print a[1]":"a[2]" "$2" "$3}' |sed 's/^chr//' > paper/idhmut_1p19qcodel_scoring_system.test

#	zcat paper/idhmut_1p19qcodel_scoring_system.txt.gz |sed 's/^chr//' > paper/idhmut_1p19qcodel_scoring_system.test

#	--set-all-var-ids 'chr#:\$pos:\$r:\$a' \

plink2 --memory 450000 --threads 64 \
	--pfile ${indir}/imputed-umich-${data}/dose \
	--score ${outdir}/paper/idhmut_1p19qcodel_scoring_system.test 1 2 3 header-read \
	--out ${outdir}/pgs-${data}

#	The core file can be gzipped, space or tab delimited.

#	Command Breakdown:
#	--pfile: Specifies the input genotype data in PLINK 2 format.
#	--score <file> <col1> <col2> <col3> header-read:
#	<file>: The scoring file (e.g., PGS.betas.tsv) containing variant IDs, effect alleles, and weights (BETAs).
#	<col1>: Column number for variant ID (e.g., 3).
#	<col2>: Column number for effect allele (e.g., 5).
#	<col3>: Column number for effect size/weight (e.g., 6).
#	header-read: Tells PLINK the first line is a header.
#	--out: Specifies the prefix for output files. 


#	--score ${outdir}/paper/allGlioma_scoring_system.tsv 1 2 3 header-read \

#	Verify Variant IDs: Check if the ID column matches your .pvar or .bim files. Differences in RS ID or Chromosome:Position format will cause this.

#	The are not the same. The psam file is CHR:POSITION. The scores are rsid or CHR:POSITION:REF:ALT
#	and RSIDs are RSIDs.

#	the score file's ids MUST MATCH the ids in the pvar file.



#	Error: --score variant ID '1:54847488' appears multiple times in main dataset. ( in the pvar file which looks a lot like a vcf )
#	End time: Tue Jan 27 18:47:29 2026

#	1       54847294        1:54847294      G       A       IMPUTED;AF=0.000517635;MAF=0.000517635;AVG_CS=0.999482;R2=0.477014
#	1       54847488        1:54847488      C       A       IMPUTED;AF=0.00173029;MAF=0.00173029;AVG_CS=0.999294;R2=0.720756
#	1       54847488        1:54847488      C       T       IMPUTED;AF=0.00123755;MAF=0.00123755;AVG_CS=0.999796;R2=0.865299
#	1       54847528        1:54847528      G       A      




#	Not sure how to deal with this because its valid

#	need to recreate pfiles with --set-all-var-ids 'chr#:\$pos:\$r:\$a'



