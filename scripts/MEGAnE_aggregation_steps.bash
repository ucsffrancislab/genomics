#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails			#	can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail
set -x  #       print expanded command before executing it

threads=${SLURM_NTASKS:-32}
using_reference=false

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
		-h|--help)
			echo
			echo $0
			echo
			exit;;
		*)
			echo "Unknown param :${1}:"; exit ;;
	esac
done


if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r/4.2.3 samtools cufflinks bedtools2 #plink2
			# bwa bedtools2 star/2.7.7a

		#	http://ccb.jhu.edu/software/stringtie/dl/		gffread / stringtie / gffcompare 
		#	http://ccb.jhu.edu/software/stringtie/dl/gffread-0.12.7.Linux_x86_64.tar.gz
		#	http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz
	fi
	
	date
	echo "IN:${IN}"
	echo "OUT:${OUT}"

	echo "IN and OUT should NOT be the same"

	mkdir -p ${OUT}
	cd ${OUT}

	date

	f=${OUT}/dirlist.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		echo "Creating dirlist ${f}"

		## first, list up samples (output directories from Step 1) you are going to merge
		#ls -d /path/to/[all_output_directories] > dirlist.txt
		#ls -d ${IN}/* > ${f}

		#	ONLY THOSE THAT SUCCESSFULLY COMPLETED

		ls -1d ${PWD}/out/*/absent_MEs_genotyped.vcf | xargs -I% dirname % > ${f}

		chmod a-w ${f}

	fi

	date

	#-r--r----- 1 gwendt francislab 617620 May 27 20:29 2023-5-27-201946_MEI_jointcall.vcf.gz
	#-r--r----- 1 gwendt francislab 591084 May 27 20:21 2023-5-27-201946_MEI_scaffold.vcf.gz
	#-r--r----- 1 gwendt francislab 249680 May 27 20:30 2023-5-27-202933_MEA_jointcall.vcf.gz
	#-r--r----- 1 gwendt francislab 243049 May 27 20:29 2023-5-27-202933_MEA_scaffold.vcf.gz

	#	all_MEI_scaffold.vcf.gz all_MEI_jointcall.vcf.gz
	f=${OUT}/jointcall_out/all_MEI_jointcall.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "merge non-reference ME insertions"
		singularity exec --bind /francislab,/scratch \
			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			joint_calling_hs \
			-p ${threads} \
			-cohort_name all \
			-merge_mei \
			-f ${OUT}/dirlist.txt \
			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa

		chmod -w ${f}

			#-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk \
			#-i ${bam} -sample_name ${base} -outdir ${f}
			#-fa /path/to/reference_human_genome.fa \

		#  -cohort_name str     Optional. Specify a cohort name. This will be used for
		#                       the variant names as well the output file name.
		#                       Default: YYYY-MM-DD-HHMMSS
	fi

	date

	#	all_MEA_scaffold.vcf.gz all_MEA_jointcall.vcf.gz
	f=${OUT}/jointcall_out/all_MEA_jointcall.vcf.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "merge reference ME polymorphisms"
		singularity exec --bind /francislab,/scratch \
			/francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			joint_calling_hs \
			-p ${threads} \
			-cohort_name all \
			-merge_absent_me \
			-f ${OUT}/dirlist.txt \
			-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa

		chmod -w ${f}
	fi

	#[gwendt@c4-log1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE]$ ll aggregation/jointcall_out/
	#total 1836
	#-rw-r----- 1 gwendt francislab 617620 May 27 20:29 2023-5-27-201946_MEI_jointcall.vcf.gz
	#-rw-r----- 1 gwendt francislab 591084 May 27 20:21 2023-5-27-201946_MEI_scaffold.vcf.gz
	#-rw-r----- 1 gwendt francislab 249680 May 27 20:30 2023-5-27-202933_MEA_jointcall.vcf.gz
	#-rw-r----- 1 gwendt francislab 243049 May 27 20:29 2023-5-27-202933_MEA_scaffold.vcf.gz
	#-rw-r----- 1 gwendt francislab  66858 May 27 20:30 for_debug_jointcall_abs.log
	#-rw-r----- 1 gwendt francislab  99610 May 27 20:29 for_debug_jointcall_ins.log
  
	date

	#	ls -1 vcf_for_phasing/
	#	all_biallelic.bed.gz
	#	all_biallelic.vcf.gz
	#	all_MEA_biallelic.vcf.gz
	#	all_MEI_biallelic.vcf.gz
	#	multiallelic_ME_summary.log

	f=${OUT}/vcf_for_phasing/all_biallelic.bed.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Make a joint call for haplotype phasing"

		singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif \
			reshape_vcf \
			-i ${OUT}/jointcall_out/all_MEI_jointcall.vcf.gz \
			-a ${OUT}/jointcall_out/all_MEA_jointcall.vcf.gz \
			-cohort_name all

		chmod -w ${f}
	fi

	date

	memory=$[threads*7500] #M

	#for chr in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY; do
	#for chr in chr22 chrX chrY; do

		#echo "Processing chr ${chr}"

		#	# first, generate a SNP VCF
		#	snp_vcf=/path/to/SNP.vcf

		#	plink2 \
		#	--threads ${threads} \
		#	--memory ${memory} \
		#	--vcf ${snp_vcf} \
		#	--make-pgen \
		#	--max-alleles 2 \
		#	--mac 2 \
		#	--hwe 1e-6 \
		#	--chr ${chr} \
		#	--indiv-sort natural \
		#	--exclude bed0 ${OUT}/vcf_for_phasing/all_biallelic.bed.gz \
		#	--export vcf bgz \
		#	--out SNP


		#	# next, generate a ME VCF
		#	me_vcf=/path/to/vcf_for_phasing/[cohort_name]_biallelic.vcf.gz

		#plink2 \
		#	--threads ${threads} \
		#	--memory ${memory} \
		#	--vcf ${OUT}/vcf_for_phasing/all_biallelic.vcf.gz \
		#	--make-pgen \
		#	--max-alleles 2 \
		#	--mac 2 \
		#	--hwe 1e-6 \
		#	--chr ${chr} \
		#	--indiv-sort natural \
		#	--vcf-half-call missing \
		#	--export vcf bgz \
		#	--out ME
	

		#	# merge SNP and ME VCFs
		#	cat SNP.vcf.gz > _SNP_ME.vcf.gz
		#	zcat ME.vcf.gz | grep -v '#' | pigz -c >> _SNP_ME.vcf.gz
		#	zcat _SNP_ME.vcf.gz | pigz -c > SNP_ME.vcf.gz
		#	rm  _SNP_ME.vcf.gz
		#	
		#	plink2 \
		#	--threads ${threads} \
		#	--memory ${memory} \
		#	--vcf SNP_ME.vcf.gz \
		#	--make-pgen \
		#	--sort-vars \
		#	--vcf-half-call missing \
		#	--out SNP_ME
		#	
		#	plink2 \
		#	--threads ${threads} \
		#	--memory ${memory} \
		#	--pfile SNP_ME \
		#	--export vcf bgz \
		#	--out SNP_ME_sorted
		#	
		#	tabix SNP_ME_sorted.vcf.gz
		#	
		#	
		#	# haplotype-phasing
		#	map=/path/to/genetic_map
		#	
		#	shapeit4 \
		#	--input SNP_ME_sorted.vcf.gz \
		#	--map ${map} \
		#	--region ${chr} \
		#	--thread ${threads} \
		#	--output SNP_ME.phased.vcf.gz

	#done

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )

	mkdir -p ${PWD}/logs

	mem=$[threads*7500]M
	scratch_size=$[threads*28]G

	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="$(basename $0)" \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}.out.log \
			$( realpath ${0} ) --in ${IN} --out ${OUT} 

fi

