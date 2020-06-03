#!/usr/bin/env bash


echo $0

if [ $# -ne 2 ] ; then
	echo "Expecting project and human reference"
	exit
fi

{

project=$1		#	$( basename $PWD )
echo "Project: ${project}"

human=$2		#	hg38.chr6	#	hg38_no_alts
echo "Human: ${human}"

script_base=$( basename $0 .bash )
echo "script_base: ${script_base}"


for virus in HERV_K113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
echo $virus

mkdir ${script_base}-${virus}-${human}
cd ${script_base}-${virus}-${human}

chimera.bash --human ${human} --viral ${virus} --threads 4 /raid/data/raw/${project}/*.fastq.gz &

cd ..

done

} > $0.log 2> $0.err
