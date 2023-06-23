#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0 fasta_file_1 fasta_file_2 fasta_file_3
	echo
	exit
}


threads=${SLURM_NTASKS:-4}
echo "threads :${threads}:"
mem=${SBATCH_MEM_PER_NODE:-30000M}
echo "mem :${mem}:"

db=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts
extension=".fasta"	#_R1.fastq.gz"
word_size=10
evalue=0.001
fasta_files=""

while [ $# -gt 0 ] ; do
	case $1 in
		-o|--out)
			shift; OUT=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
		-word_size)
			shift; word_size=$1; shift;;
		-evalue)
			shift; evalue=$1; shift;;
		-db)
			shift; db=$1; shift;;
		-h|--help)
			usage ;;
		*)
			echo "Unknown param. Assuming file:${1}:"; fasta_files="${fasta_files} $1"; shift ;;
	esac
done






if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI #samtools bwa bedtools2 cufflinks star/2.7.7a
fi

date

mkdir -p ${OUT}

echo 
echo "ext : ${extension}"
echo 


for fasta in ${fasta_files} ; do

	base=$( basename $fasta ${extension} )
	
	echo
	echo "base : ${base}"
	echo
	
	date=$( date "+%Y%m%d%H%M%S%N" )
	
	echo "Running"
	
	set -x
	
	outbase=${OUT}/${base}
	
	f=${outbase}.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running blast"
	
		blastn \
			-db ${db} \
			-query ${fasta} \
			-evalue ${evalue} \
			-word_size ${word_size} \
			-outfmt '6 qaccver qstart qend' > ${f}.tmp
	
		cat ${f}.tmp | sort -k1,1 -k2n,3 | uniq \
			| awk -v ext=1 'BEGIN{FS=OFS="\t"}{
				if( r == "" ){
					# First record for initial accession in given SORTED results
					r=$1
					s=(($2>ext)?$2:(ext+1))-ext
					e=$3+ext
				} else if ( r != $1 ) {
					# First record for new accession
					print r,s-1,e
					r=$1
					s=$2-ext
					e=$3+ext
				} else {
					if( $2 <= (e+ext+1) ){
						if(e>$3){
							e=$3+ext
						} 
					}else{
						print r,s-1,e
						s=$2-ext
						e=$3+ext
					} 
				}
			}END{ 
				# Final record
				if( r != "" ) print r,s-1,e 
			}' > ${f}

##	blast results are 1 based?
##	BED format is zero-based for the coordinate start and one-based for the coordinate end.
#
##						| awk -v ext=1 'BEGIN{FS=OFS="\t"}{
##							if( r == "" ){
##								#	first record
##								r=$1
##								s=(($2>ext)?$2:(ext+1))-ext
##								e=$3+ext
##							} else {
##								if( $2 <= (e+ext+1) ){
##									e=$3+ext
##								}else{
##									print $1,s-1,e
##									s=$2-ext
##									e=$3+ext
##								} 
##							}
##						}END{ if( r != "" ) print r,s-1,e }' > ${o}
#
#
##			| awk 'BEGIN{FS=OFS="\t"}
##				{ 
##					if( r == "" ){
##						r=$1;s=$2;e=$3 
##					} else { 
##						if( $2 <= (e+1) ){ 
##							if(e>$3){
##								e=$3
##							} 
##						}else{ 
##							print $1,s-1,e; s=$2; e=$3 
##						}
##					} 
##				}END{ if( r != "" ) print r,s-1,e }' > ${f}
	
		chmod -R a-w ${f}	#	$( dirname ${f} )
	fi
	
	date

done


