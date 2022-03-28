#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date


if [ $# -gt 0 ] ; then

	set -e	#	exit if any command fails
	set -u	#	Error on usage of unset variables
	set -o pipefail
	set -x	#	print expanded command before executing it

	f=$1
	date=$( date "+%Y%m%d%H%M%S%N" )

	a=${f%.txt.gz}.families.gz
	b=${f%.txt.gz}.family_counts
	if [ -f $a ] && [ ! -w $a ] ; then
		echo "Skipping"
	else
		sortdir=~/.sort_families.${date}.$$
		mkdir ${sortdir}
		zcat ${f} | awk 'BEGIN{FS=OFS="\t"}($NF!~/^\s*$/){print $1, $NF}' | uniq \
			| sort --temporary-directory=${sortdir} | uniq \
			| awk 'BEGIN{FS=OFS="\t"}{print $2}' | gzip > ${a}
		zcat ${a} | sort | uniq -c | sort -rn > ${b}
		chmod -w $a $b
		/bin/rm -rf ${sortdir}
	fi

else

	date=$( date "+%Y%m%d%H%M%S" )
	for f in output/*diamond.nr.species_genus_family.txt.gz ; do
		a=${f%.txt.gz}.families
		b=${f%.txt.gz}.family_counts
		if [ -f $b ] && [ ! -w $b ] ; then
		echo "Skipping $f"
		else
		sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
			--job-name=$( basename $f ) --time=999 --ntasks=2 --mem=10G \
			--output=${f}.${date}.txt \
			${PWD}/extract_family_counts.bash $f
		fi
	done

fi

