#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	#set -e  #       exit if any command fails
	set -u  #       Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		#module load CBI samtools
		module load CBI samtools/1.13 bowtie2/2.4.4 
		#bedtools2/2.30.0
	fi
	#set -x  #       print expanded command before executing it
	
	date
	
	#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
	OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
	
	#while [ $# -gt 0 ] ; do
	#	case $1 in
	#		-d|--dir)
	#			shift; OUT=$1; shift;;
	#		*)
	#			echo "Unknown params :${1}:"; exit ;;
	#	esac
	#done
	
	mkdir -p ${OUT}
	
	line=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line :${line}:"

	#	Use a 1 based index since there is no line 0.

	bam=$( sed -n "$line"p ${arguments_file} )
	echo $bam

	if [ -z "${bam}" ] ; then
		echo "No line at :${bam}:"
		exit
	fi

	echo $bam

	date=$( date "+%Y%m%d%H%M%S%N" )
	
	basename=$( basename $bam .bam )
	echo ${basename}
	
	
	MELTJAR="/c4/home/gwendt/.local/MELTv2.1.5fast/MELT.jar"
	
	
	outbase=${OUT}/${basename}
	inbase=${outbase}
	f=${outbase}.bam
	if [ -h $f ] ; then
		#       -h file True if file exists and is a symbolic link.
		echo "Link $f exists. Skipping."
	else
		ln -s ${bam} ${f}
		ln -s ${bam}.bai ${f}.bai
	fi
	
	f=${outbase}.bam.disc.bai
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running MELT Preprocess on ${inbase}.bam"
	
		java -Xmx2G -jar ${MELTJAR} Preprocess \
			-bamfile ${inbase}.bam \
			-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa
		chmod -w ${f}
		chmod -w ${f%.bai}
		chmod -w ${f%.disc.bai}.fq
	fi
	
	
	inbase=${outbase}
	
	outbase=${OUT}/DISCOVERYIND/${basename}
	f=${outbase}.ALU.tmp.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
	
		trap "{ chmod -R +w $TMPDIR ; }" EXIT
		scratch_in=${TMPDIR}/in
		mkdir -p ${scratch_in}
		ln -s ${inbase}.bam ${scratch_in}
		ln -s ${inbase}.bam.bai ${scratch_in}
		cp ${inbase}.bam.disc ${scratch_in}
		cp ${inbase}.bam.disc.bai ${scratch_in}
		cp ${inbase}.bam.fq ${scratch_in}
		cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa ${scratch_in}
		cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa.fai ${scratch_in}
		#cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa ${scratch_in}
		#cp /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa.fai ${scratch_in}
		scratch_bam=${scratch_in}/$( basename ${inbase}.bam )
		scratch_work=${TMPDIR}/work
		mkdir -p ${scratch_work}
	
	
	
		echo "Computing depth of coverage"
		#coverage=$( ~/.local/bin/mosdepth_coverage.bash ${bam} )
		coverage=$( ~/.local/bin/mosdepth_coverage.bash ${scratch_bam} )
	
		echo "Computed depth of coverage at ${coverage}"
	
		#echo "Running MELT IndivAnalysis on ${inbase}.bam"
		#echo "Running MELT IndivAnalysis on ${bam}"
		echo "Running MELT IndivAnalysis on ${scratch_bam}"
	
	
	
	
		#	EXOME !!!!!
		#	The human exome is about 1% of the genome.
		#	Does that mean the the coverage calculated by mosdepth should be upped by 100x?
	
		coverage=$( printf "%.2f\n" $(echo "$coverage * 100" | bc -l) )
		echo "RE Computed EXOME depth of coverage at ${coverage}"
		coverage="${coverage} -exome "
	
	
	
	
		java -Xmx6G -jar ${MELTJAR} IndivAnalysis \
			-c ${coverage} \
			-bamfile ${scratch_bam} \
			-h ${scratch_in}/hg19.chrXYMT_alts.fa \
			-t ~/.local/MELTv2.2.2/me_refs/1KGP_Hg19/transposon_file_list.txt \
			-w ${scratch_work}
	
		#	-bamfile ${bam} \
		#	-bamfile ${inbase}.bam \
		#	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa \
		#	-w $( dirname ${f} )
		#	-t ~/.local/MELTv2.2.2/me_refs/Hg38/transposon_file_list.txt \
	
	
	
		mkdir -p $( dirname ${f} )
		#cp ${scratch_work}/$( basename ${f} .ALU.tsv ).*.tsv $( dirname ${f} )/
		cp ${scratch_work}/* $( dirname ${f} )/
	
		#chmod -w ${outbase}.*
		chmod -w ${outbase}.{ALU,LINE1,SVA}.aligned.final.sorted.bam{,.bai}
		chmod -w ${outbase}.{ALU,LINE1,SVA}.hum_breaks.sorted.bam{,.bai}
		chmod -w ${outbase}.{ALU,LINE1,SVA}.pulled.sorted.bam{,.bai}
		chmod -w ${outbase}.{ALU,LINE1,SVA}.tmp.bed
	
	#-rw-r----- 1 gwendt francislab 10340398 Mar  6 11:00 out/DISCOVERYIND/Patient01.Z00324.ALU.aligned.final.sorted.bam
	#-rw-r----- 1 gwendt francislab       96 Mar  6 11:00 out/DISCOVERYIND/Patient01.Z00324.ALU.aligned.final.sorted.bam.bai
	#-rw-r----- 1 gwendt francislab  8758935 Mar  6 13:48 out/DISCOVERYIND/Patient01.Z00324.ALU.hum_breaks.sorted.bam
	#-rw-r----- 1 gwendt francislab  1541320 Mar  6 13:48 out/DISCOVERYIND/Patient01.Z00324.ALU.hum_breaks.sorted.bam.bai
	#-rw-r----- 1 gwendt francislab 10993782 Mar  6 11:02 out/DISCOVERYIND/Patient01.Z00324.ALU.pulled.sorted.bam
	#-rw-r----- 1 gwendt francislab  2331280 Mar  6 11:02 out/DISCOVERYIND/Patient01.Z00324.ALU.pulled.sorted.bam.bai
	#-rw-r----- 1 gwendt francislab    34535 Mar  6 13:48 out/DISCOVERYIND/Patient01.Z00324.ALU.tmp.bed
	
	fi
	
	date


else

	#	This seems to really only use 1 thread and about 3GB so could really ramp this up.
	#	Changed from 4/30GB to 2/10GB


	#	ll ${PWD}/in/*bam | wc -l

	#	scontrol update ArrayTaskThrottle=6 JobId=352083

	#	ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz > to_run.txt
	#	wc -l to_run.txt 
	#	1564 to_run.txt

	ls -1 /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in/*bam > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--job-name="MELT1" --output="${PWD}/logs/MELT1.${date}-%A_%a.out" \
		--time=10080 --nodes=1 --ntasks=2 --mem=15G \
		$( realpath ${0} )

		#${PWD}/MELT_1_array_wrapper.bash

fi


