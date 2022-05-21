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


clusters=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/$1/souporcell/clusters.tsv

barcode_bam_dir=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/$1/outs/possorted_genome_bam.bam_barcodes

out_dir=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/$1/souporcell
for i in $( seq 0 5) ; do
	mkdir ${out_dir}/${i}
done


awk -v idir=${barcode_bam_dir} -v odir=${out_dir} -F"\t" '($2 == "singlet"){print "ln -s "idir"/"$1".bam "odir"/"$3"/"}' ${clusters} | bash


echo "Done"
date
exit


for b in $( seq 1 15 ) ; do
for c in 1 2 ; do
link_barcodes_in_subsample.bash B${b}-c${c}
done
done


