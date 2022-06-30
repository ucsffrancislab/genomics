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
	module load CBI samtools/1.13 
	#picard
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--bam)
			shift; bam=$1; shift;;
		-o|--fasta)
			shift; f=$1; shift;;
		-r|--ref)
			shift; ref=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

#mkdir -p ${OUT}

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else

	while read region ; do
		samtools faidx ${ref} $region
	done < <( samtools view -F 3844 ${bam} | awk -F"\t" '{gsub(/^[[:digit:]]+S/,"",$6);gsub(/[[:digit:]]+S$/,"",$6);gsub(/[[:alpha:]]/,"+",$6);split($6,a,"+");l=0;for(i in a){l+=a[i]}; flag=( and($2,16) )?"-i":""; print flag" "$3":"$4"-"$4+l}' ) > ${f}

#| gzip > ${scratch_f}


#	actually, we should remove 1 from the length? Several get "truncated" because the last number is 1 too big.
#	[faidx] Truncated sequence: chrUn_KI270442v1:391927-392063
#	[faidx] Truncated sequence: chrUn_KI270435v1:92861-92984
#	[faidx] Truncated sequence: chrUn_KI270591v1:5670-5797
#	Don't want to do anything until this is complete though.



fi


