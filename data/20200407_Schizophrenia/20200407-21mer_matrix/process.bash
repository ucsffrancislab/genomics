#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
threads=8

date=$( date "+%Y%m%d%H%M%S" )




for r1 in /francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/unpaired/??.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )







	#for k in 11 21 31 ; do
	for k in 21 ; do

		infile="${outbase}.bowtie2-${ali}.unmapped.fasta.gz"

		unmappeddskid=''
		qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped.${k}mers.dsk"
		f="${qoutbase}.h5"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unmappedid} ] ; then
				depend="-W depend=afterok:${unmappedid}"
			else
				depend=""
			fi
			#vmem=8;threads=8;
			vmem=16;threads=8;
			#unset size vmem threads
			#case $k in 
			#	9 | 11 | 13 | 15) size=5;vmem=8;threads=8;;
			#	17 | 19 ) size=5;vmem=32;threads=8;;
			#	21 | 31 ) vmem=16;threads=8;;
			#esac 
			unmappeddskid=$( qsub ${depend} -N ${jobbase}.udsk.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${qoutbase}.${date}.out.txt \
				-e ${qoutbase}.${date}.err.txt \
				~/.local/bin/dsk.bash \
					-F "-nb-cores ${threads} -kmer-size ${k} -abundance-min 0 \
						-max-memory $[vmem/2]000 -file ${infile} -out ${f}" )
			echo $unmappeddskid
		fi

		infile="${f}"
		f="${qoutbase}.txt.gz"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unmappeddskid} ] ; then
				depend="-W depend=afterok:${unmappeddskid}"
			else
				depend=""
			fi
			vmem=8;threads=8;
			qsub ${depend} -N ${jobbase}.ud2a.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${qoutbase}2ascii.${date}.out.txt \
				-e ${qoutbase}2ascii.${date}.err.txt \
				~/.local/bin/dsk2ascii.bash \
					-F "-nb-cores ${threads} -file ${infile} -out ${f}"
		fi

	done

done

