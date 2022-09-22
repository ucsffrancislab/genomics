#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
#set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
#	module load CBI samtools 
fi
set -x	#	print expanded command before executing it


which blastx

zcat /francislab/data1/working/20220610-EV/20220913-preprocess/out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.unmatched.fa.gz | blastx -db nr -num_threads ${SLURM_NTASKS:-8} -outfmt "6 std scomname" | gzip > /francislab/data1/working/20220610-EV/20220913-preprocess/out/SFHH011T.quality15.format.umi.t1.t2.t3.notphiX.readname.hg38.unmapped.blastn-nt.unmatched.blastx-nr.tsv.gz




exit


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=blastx --time=10080 --nodes=1 --ntasks=16 --mem=120G --output=/francislab/data1/working/20220610-EV/20220913-preprocess/blastx.log /francislab/data1/working/20220610-EV/20220913-preprocess/blastx.bash 




