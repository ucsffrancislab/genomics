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


IN="/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/out"
OUT="/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220104-viral-chimera/out"

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

r1=$( ls -1 ${IN}/*_R1.fastq.gz | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi



date=$( date "+%Y%m%d%H%M%S" )


echo $r1
r2=${r1/_R1./_R2.}
echo $r2
s=$( basename $r1 _R1.fastq.gz )


#	Select those that align to viral masked then align those to human


outbase=${OUT}/${s}.viral

f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/bin/paired_reads_select_scratch.bash \
		--threads 8 \
		-x /francislab/data1/working/20211111-hg38-viral-homology/double_masked_viral \
		--very-sensitive-local -1 ${r1} -2 ${r2} -o ${f%.R1.fastq.gz}.bam
		#-x /francislab/data1/working/20211122-Homology-Paper/bowtie2/RMhg38masked \
fi


#ir1=${f}
#ir2=${f%.R1.fastq.gz}.R2.fastq.gz
#
#outbase=${outbase}.hg38
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --sort --threads 8 \
#		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
#		--very-sensitive-local -1 ${ir1} -2 ${ir2} -o ${f}
#fi
#
#
#
#
#
#vbam=${OUT}/${s}.viral.bam
#
#viruses=$( cat ${vbam}.aligned_sequence_counts.txt | awk '{print $2}' | sort | uniq )
#
#for v in ${viruses} ; do
#
#	f=${vbam%.bam}.hg38.bam.${v}.count.txt
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#
#		samtools view ${vbam} 2> /dev/null | grep ${v} | awk '{print "^"$1"\t"}' | uniq > ${vbam}.${v}.seqs
#
#		samtools view -f64 ${vbam%.bam}.hg38.bam 2> /dev/null | grep -f ${vbam}.${v}.seqs | gawk '( !and($2,4) || !and($2,8) ){ print }' | wc -l > ${f}
#
#		chmod a-w $f
#	fi
#
#done





#outbase=${OUT}/${s}.viral

f=${outbase}
if [ -d $f ] ; then
	echo "Dir $f exists. Skipping."
else
	echo "Creating $f"
	${PWD}/bam_to_fastq_by_refseq.bash ${f}.bam
fi

inbase=${outbase}
for r1 in ${inbase}/*.R1.fastq.gz ; do

	outbase=${r1%.R1.fastq.gz}

	f=${outbase}.hg38.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		~/.local/bin/bowtie2.bash --sort --threads 8 \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
			--very-sensitive-local -1 ${r1} -2 ${r1/.R1./.R2.} -o ${f}

	fi

	f=${outbase}.hg38.bam.mapped_pair_read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		~/.local/bin/count_mapped_paired_reads.bash ${outbase}.hg38.bam

	fi

done









date
exit




mkdir -p /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220104-viral-chimera/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-532%8 --job-name="viralchimera" --output="/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220104-viral-chimera/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220104-viral-chimera/array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083


