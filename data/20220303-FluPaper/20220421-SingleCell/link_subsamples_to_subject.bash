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


out_dir=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/$1/souporcell


#	Sometimes its a dash. Sometimes its an underscore.
# B1-c1 or B1_c1


cat /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/$1.csv | datamash transpose -t, | awk -F, -v dir=${out_dir} '
(NR==1){
	for(i=2;i<=NF;i++){
		s[i]=$i
	}
}
(NR>1){
	min_i=10
	min_v=10000000
	for(i=2;i<=NF;i++){
		if($i<min_v){
			min_i=i
			min_v=$i
		}
	}
	print "ln -s "dir"/"$1" "dir"/" s[min_i]
}' | bash


echo "Done"
date
exit


for b in $( seq 1 15 ) ; do
for c in 1 2 ; do
link_subsamples_to_subject.bash B${b}-c${c}
done
done


#	1 subject was not included in the WGS.

#	ln -s /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B7-c1/souporcell/1 /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B7-c1/souporcell/HMN52545

#	ln -s /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B7-c2/souporcell/5 /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/out/B7-c2/souporcell/HMN52545



