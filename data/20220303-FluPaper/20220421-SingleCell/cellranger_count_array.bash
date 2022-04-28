#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI cellranger/4.0.0 # htslib samtools bowtie2
fi
set -x  #       print expanded command before executing it


IN="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq"
OUT="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out"

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
basename=$( ls -1 /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR*/B*-c*-10X_L001_R1_001.fastq.gz | xargs -I% basename % -10X_L001_R1_001.fastq.gz | sed -n ${line}p )
echo ${basename}


#	#	Use a 1 based index since there is no line 0.
#	sample=$( sed -n ${line}p to_run.txt )
#	echo ${sample}
#	
#	#r1=$( ls -1 ${IN}/*_R1.fastq.gz | sed -n "$line"p )
#	r1=$( ls -1 ${IN}/${sample}*_R1.fastq.gz )
#	echo $r1
#	
#	if [ -z "${r1}" ] ; then
#		echo "No line at :${line}:"
#		exit
#	fi
#	
#	date=$( date "+%Y%m%d%H%M%S" )
#	
#	r2=${r1/_R1./_R2.}
#	echo $r2
#	basename=$( basename $r1 _R1.fastq.gz )
#	echo ${basename}








outbase=${OUT}/${basename}

f=${outbase}/outs/possorted_genome_bam.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

	#--fastqs /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13194367/B1-c1-10X_L001_R1_001.fastq.gz /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13194367/B1-c1-10X_L001_R2_001.fastq.gz \
	#If your files came from bcl2fastq or mkfastq:
	# - Make sure you are specifying the correct --sample(s), i.e. matching the sample sheet
	# - Make sure your files follow the correct naming convention, e.g. SampleName_S1_L001_R1_001.fastq.gz (and the R2 version)
	# - Make sure your --fastqs points to the correct location.
	#
	#Refer to the "Specifying Input FASTQs" page at https:
	
	# 1159  ln -s B1-c1-10X_L001_R1_001.fastq.gz B1-c1-10X_S0_L001_R1_001.fastq.gz
	# 1160  ln -s B1-c1-10X_L001_R2_001.fastq.gz B1-c1-10X_S0_L001_R2_001.fastq.gz
	
	#--transcriptome /francislab/data1/raw/20220303-FluPaper/hg38_iav \
	
	#--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/hg38 \
	
	#s="B1-c1"
	
	#mkdir -p ${outbase}
	#cd ${outbase}
	cd ${OUT}
	cellranger count \
		--id ${basename} \
		--sample ${basename}-10X \
		--fastqs ${IN} \
		--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select_iav \
		--localcores 16 \
		--localmem 120 \
		--localvmem 120
	chmod -w ${f}
	
#		--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/hg38_iav \
	
	#cellranger mkref --genome=hg38_iav \
	#--fasta=/francislab/data1/raw/20220303-FluPaper/hg38_iav.fa \
	#--genes=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
	#--nthreads=32 --memgb=240
	
	
fi

echo "Done"
date
exit


mkdir -p /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-30%1 --job-name="count" --output="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=120G /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/cellranger_count_array.bash


