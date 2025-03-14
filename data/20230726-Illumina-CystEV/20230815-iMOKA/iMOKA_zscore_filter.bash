#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI r
fi
set -x


random_forest=""
#SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
#		--dir)
#			shift; dir=$1; shift;;
		--k)
			shift; k=$1; shift;;
#		--source_file)
#			shift; source_file=$1; shift;;
#		--stopstep)
#			shift; stopstep=$1; shift;;
#		--step)
#			shift; step=$1; shift;;
#		--threads)
#			shift; threads=$1; shift;;
#		--reduce)
#			shift; reduce="${reduce} $1 $2"; shift; shift;;
		--random_forest)
			shift; random_forest="${random_forest} $1 $2"; shift; shift;;
#		*)
#			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done



#\rm iMOKA_commands.${k}

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

mkdir -p ${PWD}/dump/${k}


#	create a matrix of just the samples that I want to dump

cat ${PWD}/{out,blank}/${k}/create_matrix.tsv | grep -vs SFHH00 > ${PWD}/dump/${k}/create_matrix.tsv


export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=32
export IMOKA_MAX_MEM_GB=220

#	prep to dump
singularity exec ${img} iMOKA_core create -i ${PWD}/dump/${k}/create_matrix.tsv -o ${PWD}/dump/${k}/create_matrix.json

#	dump rescaled kmers to be used in the zscore algorithm
singularity exec ${img} iMOKA_core dump -i ${PWD}/dump/${k}/create_matrix.json -o ${PWD}/dump/${k}/kmers.rescaled.tsv

gzip ${PWD}/dump/${k}/kmers.rescaled.tsv

#	dump raw kmers to be put back based on zscore results
singularity exec ${img} iMOKA_core dump --raw -i ${PWD}/dump/${k}/create_matrix.json -o ${PWD}/dump/${k}/kmers.raw.tsv; gzip ${PWD}/dump/${k}/kmers.raw.tsv






#	#	convert tsv to csv plus add header and merge the last 2 as blanks as "input"
#	zcat ${PWD}/dump/${k}/kmers.raw.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-2);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-2);i++){s=s","$i};print s,($(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.raw.count.csv
#	
#	#	convert tsv to csv plus add header and merge the last 2 as blanks as "input"
#	zcat ${PWD}/dump/${k}/kmers.rescaled.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-2);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-2);i++){s=s","$i};print s,($(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.rescaled.count.csv


#	convert tsv to csv plus add header and merge the last 4 as blanks as "input"
zcat ${PWD}/dump/${k}/kmers.raw.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-4);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-4);i++){s=s","$i};print s,($(NF-3)+$(NF-2)+$(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.raw.count.csv

#	convert tsv to csv plus add header and merge the last 4 as blanks as "input"
zcat ${PWD}/dump/${k}/kmers.rescaled.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-4);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-4);i++){s=s","$i};print s,($(NF-3)+$(NF-2)+$(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.rescaled.count.csv







#	run phip-seq zscore. This crashes on k>=35
elledge_Zscore_analysis.R ${PWD}/dump/${k}/kmers.rescaled.count.csv



#	rename headers by adding _z to zscore results
sed -i '1 s/,/_z,/g' ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.csv

#	reorder columns
awk 'BEGIN{FS=OFS=","}{print $(NF-2),$0}' ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.csv > ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.reordered.csv

gzip ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.csv

#	join the raw kmer counts with the zscores
join --header -t, ${PWD}/dump/${k}/kmers.raw.count.csv ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.reordered.csv > ${PWD}/dump/${k}/kmers.count.Zscores.reordered.joined.csv

gzip ${PWD}/dump/${k}/kmers.raw.count.csv
gzip ${PWD}/dump/${k}/kmers.rescaled.count.csv
gzip ${PWD}/dump/${k}/kmers.rescaled.count.Zscores.reordered.csv

#	loop through giant matrix. Split and keep only those with all absolute zscores larger than 3.5
awk -v dir="${PWD}/zscores_filtered/${k}/preprocess" 'BEGIN{FS=",";OFS="\t"}
(NR==1){ 
split($0,columns,",")
for(i=1;i<=NF;i++){ if($i=="input"){input_col=i;break}} 
for(i=input_col;i<=NF;i++){ if($i=="id_z"){id_z_col=i;break}} 
print $0; print input_col; print id_z_col; sample_count=id_z_col-input_col-1; print sample_count 
for(i=2;i<input_col;i++){ system("mkdir -p "dir"/"columns[i]) }
}
(NR>1){
count_close_to_zero=0; for(i=input_col+1;i<id_z_col;i++){ if(($i>-3.5)&&($i<3.5)){count_close_to_zero+=1} }
if(count_close_to_zero<(0.9*sample_count)){
for(i=2;i<input_col;i++){ 
print $1,$i >> dir"/"columns[i]"/"columns[i]".tsv"
} } }' ${PWD}/dump/${k}/kmers.count.Zscores.reordered.joined.csv

#	why sample_count=id_z_col-input_col-1
#	why not just sample_count=input_col-1



#	Run iMOKA on these selected kmers

dir=${PWD}/zscores_filtered/${k}/

create_matrix=${dir}/create_matrix.tsv

awk -v d=${dir} 'BEGIN{OFS=FS="\t"}($3!="blank"){
 print d"preprocess/"$2"/"$2".tsv",$2,$3
}' ${PWD}/dump/${k}/create_matrix.tsv > ${create_matrix}

random_forest_option=""
[ -n "${random_forest}" ] && random_forest_option="--random_forest ${random_forest}"

~/.local/bin/iMOKA.bash --dir ${dir} --k ${k} --step create ${random_forest_option}


