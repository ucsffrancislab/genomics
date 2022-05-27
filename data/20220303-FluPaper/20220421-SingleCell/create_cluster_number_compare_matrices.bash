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

for b in $( seq 1 15 ); do
for c in 1 2 ; do
	echo "B${b}-c${c}"

	matrix="B${b}-c${c}_cluster_translation.csv"

	echo -n "sample" > ${matrix}
	for i in $( seq 0 5 ) ; do
		echo -n ",my${i}" >> ${matrix}
	done
	echo  >> ${matrix}

	#	my cluster number
	for j in $( seq 0 5 ) ; do
		echo -n "author${j}" >> ${matrix}

		#	author cluster number
		for i in $( seq 0 5 ) ; do
			#echo -n "${i} - ${s} - "
			#d=$( sdiff -s out/B${b}-c${c}/souporcell/${i}.snps out/B${b}-c${c}/souporcell/${sample}.snps | wc -l )
			d=$( comm -12 out/B${b}-c${c}/souporcell/clusters.tsv.${i} from_authors/cluster_outs/B${b}-c${c}_clusters.tsv.${j} | wc -l )

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



# /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B*-c?/souporcell/clusters.tsv
# /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/from_authors/cluster_outs/*_clusters.tsv


for f in out/B*-c?/souporcell/clusters.tsv ; do echo $f; awk -F"\t" '(NR>1 && $2 == "singlet"){print $1 > "'$f'."$3 }' $f; done
for f in *tsv ; do echo $f; awk -F"\t" '(NR>1 && $2 == "singlet"){print $1 > "'$f'."$3 }' $f; done


