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



dir=${2}_barcodes

mkdir -p ${dir}


#	Not all reads have a CB tag?

awk -v dir=${dir} '(FNR==NR){
	barcodes[$1]++
	next
}
(FNR!=NR){
	if(/^@/) {
		for(cb in barcodes){
			print $0 > dir"/"cb
		}
	}else{
		cbi=index($0,"CB:Z:")
		if(cbi>0){
			a=substr($0,cbi)
			cb=substr(a,6,index(a,"\t")-6)
			if(cb in barcodes){
				print $0 > dir"/"cb
			}
		}
	}
}' $1 <( samtools view -h $2 )


echo "Done"
date
exit




This splits into all barcodes which is well above what is needed.
I need to load the list of desireable barcodes.
Also, save as fastq?




date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="splitbam" --output="${PWD}/split_bam_into_barcode_bams.${date}.log" --time=8640 --nodes=1 --ntasks=4 --mem=30G ${PWD}/split_bam_into_barcode_bams.bash ${PWD}/out/B1-c1/souporcell/barcodes.tsv ${PWD}/out/B1-c1/outs/possorted_genome_bam.bam





