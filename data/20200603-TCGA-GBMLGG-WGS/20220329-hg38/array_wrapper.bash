#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out"

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
sample=$( sed -n ${line}p to_run.txt )
echo ${sample}

#r1=$( ls -1 ${IN}/*_R1.fastq.gz | sed -n "$line"p )
r1=$( ls -1 ${IN}/${sample}*_R1.fastq.gz )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S" )

r2=${r1/_R1./_R2.}
echo $r2
basename=$( basename $r1 _R1.fastq.gz )
echo ${basename}



outbase=${OUT}/${basename}

f=${outbase}.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	#sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${basename} --time=2880 \
	#	--nodes=1 --ntasks=${threads} --mem=${mem} \
	#	--output=${outbase}.${date}.%j.txt \
	~/.local/bin/bowtie2_scratch.bash \
		--very-sensitive --threads ${SLURM_NTASKS} \
		-1 ${r1} -2 ${r2} --sort --output ${f} \
		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts
fi




date
exit




mkdir -p /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-122%4 --job-name="hg38" --output="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083


ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz > to_run.txt
wc -l to_run.txt 
278 to_run.txt

mkdir -p /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-278%4 --job-name="hg38" --output="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/array_wrapper.bash



