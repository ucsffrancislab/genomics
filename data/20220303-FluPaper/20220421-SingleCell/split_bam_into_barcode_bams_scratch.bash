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
	module load CBI samtools
fi
set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out"
OUT="/francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out"

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

sample=$( ls -1trd ${IN}/B*-c?  | sed -n "$line"p )
sample=$( basename ${sample} )

echo $sample

if [ -z "${sample}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S" )

trap "{ chmod -R +w $TMPDIR ; }" EXIT


barcodes=${IN}/${sample}/souporcell/barcodes.tsv 
bam=${IN}/${sample}/outs/possorted_genome_bam.bam

f=${OUT}/${sample}/outs/possorted_genome_bam.bam_barcodes

#if [ -d $f ] && [ ! -w $f ] ; then
if [ -d $f ] ; then
	echo "$f dir exists. Skipping."
else
	echo "Creating $f"
	mkdir -p ${f}

	scratch_out=${TMPDIR}/sam
	mkdir -p ${scratch_out}

	scratch_bam=${TMPDIR}/$( basename ${bam} )
	cp ${bam} ${TMPDIR}

#	Not all reads have a CB tag?

awk -v dir=${scratch_out} '(FNR==NR){
	barcodes[$1]++
	next
}
(FNR!=NR){
	if(/^@/) {
		for(cb in barcodes){
			print $0 > dir"/"cb".sam"
		}
	}else{
		cbi=index($0,"CB:Z:")
		if(cbi>0){
			a=substr($0,cbi)
			cb=substr(a,6,index(a,"\t")-6)
			if(cb in barcodes){
				print $0 > dir"/"cb".sam"
			}
		}
	}
}' ${barcodes} <( samtools view -h ${scratch_bam} )
#}' <( head ${barcodes} ) <( samtools view -h ${scratch_bam} | head -10000 )


for sam in ${scratch_out}/*sam ; do
	bam=$( basename ${sam} .sam).bam
	samtools view -o ${f}/${bam} ${sam}
	chmod -w ${f}/${bam}
done

fi

echo "Done"
date
exit





mkdir -p /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/logs
date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-30%1 --job-name="splitbam" --output="${PWD}/logs/splitbam.${date}-%A_%a.out" --time=10080 --nodes=1 --ntasks=4 --mem=30G --gres=scratch:500G ${PWD}/split_bam_into_barcode_bams_scratch.bash




