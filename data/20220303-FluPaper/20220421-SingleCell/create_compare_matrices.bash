#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
#set -o pipefail	#	causes the sdiff | wc -l to fail?
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
#	module load CBI samtools
fi
#set -x  #       print expanded command before executing it

for b in $( seq 1 10 ); do
for c in 1 2 ; do
echo
echo "B${b}_c${c}"

matrix="out/B${b}_c${c}.csv"

echo -n "sample" > ${matrix}
for i in $( seq 0 5 ) ; do
echo -n ",${i}" >> ${matrix}
done
echo  >> ${matrix}

for s in $( grep "B${b}_c${c}" metadata.csv | awk -F, '{print $2}' ) ; do
echo -n "${s}" >> ${matrix}

for i in $( seq 0 5 ) ; do
	#echo -n "${i} - ${s} - "
	d=$( sdiff -s out/B${b}-c${c}/souporcell/${i}.snps out/B${b}-c${c}/souporcell/${s}.snps | wc -l )
	echo -n ",${d}" >> ${matrix}
done
echo >> ${matrix}

done
echo 
done
done


echo "Done"
date
exit


for b in $( seq 5 10 ); do
for c in 1 2 ; do
echo "B${b}_c${c}"
./souporcell_cluster_genotypes_to_SNP_lists.bash out/B${b}-c${c}/souporcell/cluster_genotypes.vcf 
for s in $( grep "B${b}_c${c}" metadata.csv | awk -F, '{print $2}' ) ; do
echo "Extracting"
./extract -v=out/${s}.call.vcf.gz -p=out/B${b}-c${c}/souporcell/positions > out/B${b}-c${c}/souporcell/${s}.snps
done; done; done


