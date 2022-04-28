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
	module load CBI bcftools
fi
set -x  #       print expanded command before executing it


IN="/francislab/data1/raw/20220303-FluPaper/PRJNA736483"
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
bam=$( ls -1 ${IN}/*/*_alignment_bam.bam | sed -n ${line}p )
echo $bam

#basename=$( ls -1 ${IN}/*/*_alignment_bam.bam | xargs -I% basename % _alignment_bam.bam | sed -n ${line}p )
basename=$( basename $bam _alignment_bam.bam )
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

f=${outbase}.call.vcf.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

#	grep -m 1 B1_c1 /francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt | awk -F, '{print $2}'
#HMN83551

	echo bcftools mpileup --output-type u --fasta-ref /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select.fa ${bam} XXX bcftools call  --output-type z --output ${f} --multiallelic-caller --variants-only 

	bcftools mpileup --output-type u --fasta-ref /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select.fa ${bam} | bcftools call  --output-type z --output ${f} --multiallelic-caller --variants-only 

	bcftools index ${f}

	chmod -w $f
	
fi

echo "Done"
date
exit


ls -1 /francislab/data1/raw/20220303-FluPaper/PRJNA736483/*/*alignment_bam.bam | wc -l
89


mkdir -p /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-89%1 --job-name="bcf" --output="/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs/bcftools.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=120G /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/bcftools_array.bash




