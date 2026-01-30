#!/usr/bin/env bash

data=$1
#model=$2

set -x
#set -e	#	exit if any command fails	#	the liftover command technically fails
set -u	#	Error on usage of unset variables
set -o pipefail


threads=${SLURM_NTASKS:-4}
memory=${SLURM_MEM_PER_NODE:-10000}


#module load bcftools 	#	don't use the module. use my install which includes the liftover plugin
module load plink2 htslib


indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

#	csi is the preferred, more modern, index and supports larger
#	tbi is more compatible, but I haven't found any issues yet

#	vcf files need indexing before concatenating

for f in ${indir}/imputed-umich-${data}/chr*.dose.vcf.gz; do
	echo $f
	if [ -f ${f}.csi ] ; then
		echo "Index exists. Skipping."
	else
		bcftools index --threads ${threads} --force ${f}
	fi
done


#if [ -f ${indir}/imputed-umich-${data}/dose.vcf.gz.csi ] ; then
if [ -f ${indir}/imputed-umich-${data}/dose.vcf.gz ] ; then
	echo "Exists. Skipping."
else

#		--naive \

	#	This really only uses about 3 or threads and a couple GB of memory

	bcftools concat --threads ${threads} -Ov \
		${indir}/imputed-umich-${data}/chr?.dose.vcf.gz \
		${indir}/imputed-umich-${data}/chr??.dose.vcf.gz |
	bcftools annotate --threads ${threads} --rename-chrs <( for c in {1..22}; do echo -e "${c}\tchr${c}"; done ) \
		 --set-id '%CHROM:%POS:%REF:%ALT' -Ov | \
	bcftools view --threads ${threads} -Oz --write-index=csi -o ${indir}/imputed-umich-${data}/dose.vcf.gz

fi







#		liftdir=${indir}/imputed-umich-${data}/hg38
#		mkdir -p ${liftdir}
#		mkdir -p ${liftdir}/maf-output/
#		mkdir -p ${liftdir}/chunksDir/
#		mkdir -p ${liftdir}/statisticsDir/
#		mkdir -p ${liftdir}/metaFilesDir/
#		
#		
#		#	java -Xmx$((9 * SLURM_MEM_PER_NODE / 10))M -jar /francislab/data1/refs/Imputation/imputationserver-utils.jar \
#		#		run-qc \
#		#		--population off \
#		#		--reference /francislab/data1/refs/Imputation/1kgp3.FAKE-HG38.reference-panel.json \
#		#		--build hg19 \
#		#		--maf-output ${liftdir}/maf-output/ \
#		#		--phasing-window 5000000 \
#		#		--chunksize 20000000 \
#		#		--chunks-out ${liftdir}/chunksDir/ \
#		#		--statistics-out ${liftdir}/statisticsDir/ \
#		#		--metafiles-out ${liftdir}/metaFilesDir/ \
#		#		--report ${liftdir}/qc_report.txt \
#		#		--no-index \
#		#		--chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
#		#		${indir}/imputed-umich-${data}/chr{?,??}.dose.vcf.gz
#		
#		#	There doesn't seem to be an error, but this usually returns 1
#		
#		echo "Return code :$?:"
#		
#		
#		
#		\rm ${liftdir}/chunksDir/chunk_*_*_*.vcf.gz
#		
#		
#		
#		
#		#	The lifted vcfs contain the "chr" prefix, but not in the header
#		
#		#	I want it, but not yet so need to remove it when I convert to bed
#		
#		
#		echo "Liftover Complete"
#		
#		for vcf in ${liftdir}/chunksDir/*.lifted.vcf.gz ; do
#			echo "Indexing $vcf"
#			bcftools index --threads ${threads} --tbi ${vcf}
#		done
#		
#		#if [ -f ${indir}/imputed-umich-${data}/dose.vcf.gz ] ; then
#		if [ -f ${liftdir}/chunksDir/lifted.vcf.gz ] ; then
#			echo "Exists. Skipping."
#		else
#			bcftools concat --threads ${threads} -Oz \
#				-o ${liftdir}/chunksDir/lifted.vcf.gz \
#				${liftdir}/chunksDir/*.lifted.vcf.gz
#		#		-o ${indir}/imputed-umich-${data}/dose.vcf.gz \
#		#		${indir}/imputed-umich-${data}/chr*.dose.vcf.gz
#		fi


#if [ -f ${indir}/imputed-umich-${data}/dose.vcf.gz.csi ] ; then
#	echo "Index exists. Skipping."
#else
#	bcftools index --threads ${threads} --csi ${indir}/imputed-umich-${data}/dose.vcf.gz
#fi







#	liftdir=${indir}/imputed-umich-${data}/hg38-bcftools
#	mkdir -p ${liftdir}

#	NEEDS A PLUGIN
#	bcftools plugin <name> [OPTIONS] <file> [-- PLUGIN_OPTIONS]
#	use local bcftools with plugin
#	module unload bcftools
bcftools +liftover --threads ${threads} \
	-Oz --output ${indir}/imputed-umich-${data}/dose.bcftools-hg38.vcf.gz \
	${indir}/imputed-umich-${data}/dose.vcf.gz \
	--write-index=csi -- \
	--src-fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz \
	--chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
	--fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
	--reject ${indir}/imputed-umich-${data}/dose.bcftools-hg38.rejected.vcf.gz





module load picard
#java -Xmx500G -jar $PICARD_HOME/picard.jar LiftoverVcf \
java -Xmx${SLURM_MEM_PER_NODE}M -jar $PICARD_HOME/picard.jar LiftoverVcf \
	I=${indir}/imputed-umich-${data}/dose.vcf.gz \
	O=${indir}/imputed-umich-${data}/dose.picard-hg38.vcf.gz \
	REJECT=${indir}/imputed-umich-${data}/dose.picard-hg38.rejected.vcf.gz \
	CHAIN=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
	R=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa.gz





#		#if [ -f ${indir}/imputed-umich-${data}/dose.psam ] ; then
#		if [ -f ${liftdir}/chunksDir/lifted.psam ] ; then
#			echo "Exists. Skipping."
#		else
#		
#			#	for plink2 appa
#			plink2 --memory ${memory} --threads ${threads} --make-pgen \
#				--exclude-if-info "R2<0.8" \
#				--set-all-var-ids @:#:\$r:\$a --new-id-max-allele-len 662 \
#				--vcf ${liftdir}/chunksDir/lifted.vcf.gz \
#				--out ${liftdir}/chunksDir/lifted.psam
#		#		--vcf ${indir}/imputed-umich-${data}/dose.vcf.gz \
#		#		--out ${indir}/imputed-umich-${data}/dose
#		fi
#		
#		#	zcat paper/idhmut_1p19qcodel_scoring_system.txt.gz | awk '{split($1,a,":");print a[1]":"a[2]" "$2" "$3}' |sed 's/^chr//' > paper/idhmut_1p19qcodel_scoring_system.test
#		
#		#	zcat paper/idhmut_1p19qcodel_scoring_system.txt.gz |sed 's/^chr//' > paper/idhmut_1p19qcodel_scoring_system.test
#		
#		#	--set-all-var-ids 'chr#:\$pos:\$r:\$a' \
#		
#		
#		for model in /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/plink_models/*txt.gz ; do
#		
#		#	if [ -f ${outdir}/pgs-${data}-$(basename ${model} .txt.gz).sscore ] ; then
#			if [ -f ${outdir}/plink-pgs-${data}-$(basename ${model} .txt.gz).sscore ] ; then
#				echo "Done. Skipping."
#			else

#				plink2 --memory ${memory} --threads ${threads} \
#					--score ${model} 1 2 3 header-read list-variants \
#					--pfile ${liftdir}/chunksDir/lifted.psam \
#					--out ${outdir}/plink-pgs-${data}-$(basename ${model} .txt.gz)
#		#			--pfile ${indir}/imputed-umich-${data}/dose \
#		#			--out ${outdir}/pgs-${data}-$(basename ${model} .txt.gz)
#			fi
#		
#		done
#		
#		
#		
#		
#		#	The core file can be gzipped, space or tab delimited.
#		
#		#	Command Breakdown:
#		#	--pfile: Specifies the input genotype data in PLINK 2 format.
#		#	--score <file> <col1> <col2> <col3> header-read:
#		#	<file>: The scoring file (e.g., PGS.betas.tsv) containing variant IDs, effect alleles, and weights (BETAs).
#		#	<col1>: Column number for variant ID (e.g., 3).
#		#	<col2>: Column number for effect allele (e.g., 5).
#		#	<col3>: Column number for effect size/weight (e.g., 6).
#		#	header-read: Tells PLINK the first line is a header.
#		#	--out: Specifies the prefix for output files. 
#		
#		
#		#	--score ${outdir}/paper/allGlioma_scoring_system.tsv 1 2 3 header-read \
#		
#		#	Verify Variant IDs: Check if the ID column matches your .pvar or .bim files. Differences in RS ID or Chromosome:Position format will cause this.
#		
#		#	The are not the same. The psam file is CHR:POSITION. The scores are rsid or CHR:POSITION:REF:ALT
#		#	and RSIDs are RSIDs.
#		
#		#	the score file's ids MUST MATCH the ids in the pvar file.
#		
#		
#		
#		#	Error: --score variant ID '1:54847488' appears multiple times in main dataset. ( in the pvar file which looks a lot like a vcf )
#		#	End time: Tue Jan 27 18:47:29 2026
#		
#		#	1       54847294        1:54847294      G       A       IMPUTED;AF=0.000517635;MAF=0.000517635;AVG_CS=0.999482;R2=0.477014
#		#	1       54847488        1:54847488      C       A       IMPUTED;AF=0.00173029;MAF=0.00173029;AVG_CS=0.999294;R2=0.720756
#		#	1       54847488        1:54847488      C       T       IMPUTED;AF=0.00123755;MAF=0.00123755;AVG_CS=0.999796;R2=0.865299
#		#	1       54847528        1:54847528      G       A      
#		
#		
#		
#		
#		#	Not sure how to deal with this because its valid
#		
#		#	need to recreate pfiles with --set-all-var-ids 'chr#:\$pos:\$r:\$a'
#		
#		
#		module load openjdk
#		
#		for chrnum in {1..22} ; do
#		
#			cp ${indir}/imputed-umich-${data}/chr${chrnum}.dose.vcf.gz \${TMPDIR}/
#		
#		for vcf in ${liftdir}/chunksDir/*.lifted.vcf.gz ; do
#		
#			java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \
#				${TMPDIR}/chr${chrnum}.dose.vcf.gz \
#				--ref /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-collection.txt.gz \
#				--out ${TMPDIR}/chr${chrnum}.dose.scores.txt \
#				--info ${TMPDIR}/chr${chrnum}.dose.scores.info \
#				--report-csv ${TMPDIR}/chr${chrnum}.dose.scores.csv \
#				--report-html ${TMPDIR}/chr${chrnum}.dose.scores.html \
#				--min-r2 0.8 --no-ansi --threads 8
#		
#			mkdir -p ${outdir}/pgscalc-pgs-${data}-0.8/
#			cp ${TMPDIR}/chr${chrnum}.dose.scores.* \
#				${outdir}/pgscalc-pgs-${data}-0.8/
#			chmod -w ${outdir}/pgscalc-pgs-${data}-0.8/chr${chrnum}.dose.scores.*
#		
#		done
#		
#		
#		java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score \
#			${outdir}/pgscalc-pgs-${data}-0.8/chr*.dose.scores.txt \
#			--out ${outdir}/pgscalc-pgs-${data}-0.8/scores.txt
#		
#		java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info \
#			${outdir}/pgscalc-pgs-${data}-0.8/chr*.dose.scores.info \
#			--out ${outdir}/pgscalc-pgs-${data}-0.8/scores.info
#		
#		

