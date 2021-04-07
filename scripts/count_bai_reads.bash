#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#	git clone https://github.com/chmille4/bamReadDepther.git
#	cd bamReadDepther
#	gcc -lstdc++ -o bamReadDepther bamReadDepther.cpp
#	cp bamReadDepther somewhere_in_your_path

while [ $# -gt 0 ] ; do

	echo $1

	f=${1}.mapped_read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		cat $1 | bamReadDepther | awk '( /^#/ ){s+=$2}END{print s}' > ${f}
		chmod a-w $f
	fi

	f=${1}.read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		cat $1 | bamReadDepther | awk '( /^[#*]/ ){s+=$2;s+=$3}END{print s}' > ${f}
		chmod a-w $f
	fi

	f=${1}.unmapped_read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		cat $1 | bamReadDepther | awk '( /^[#*]/ ){s+=$NF}END{print s}' > ${f}
		chmod a-w $f
	fi

	shift
done
