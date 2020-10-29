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

#	remember 64 cores and ~504GB mem
threads=8
vmem=62

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20201027-hkle-select/out"
OUTDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20201029-hkle-chimera/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

#while IFS=, read -r r1 ; do

for r1 in ${INDIR}/02*.R1.fastq.gz ; do
	echo ${r1}

	r2=${r1/R1/R2}
	echo ${r2}

	base=${OUTDIR}/$( basename $r1 _R1.fastq.gz )
	echo ${base}

	jobbase=$( basename ${base} )
	echo ${jobbase}

	outbase="${base}.hkle"
	f=${outbase}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		human=${BOWTIE2}/hg38
		
		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )

		human_size=$( stat --dereference --format %s ${human}.?.bt2 ${human}.rev.?.bt2 | awk '{s+=$1}END{print s}' )

		viral=${BOWTIE2}/SVAs_and_HERVK113
		viral_size=$( du -sb ${viral} | awk '{print $1}' )

		scratch=$( echo $(( ((4*(${r1_size}+${r2_size})+${human_size}+${viral_size})/${threads}/1000000000)+1 )) )
		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		echo "Using scratch:${scratch}"


		#	NOTE THAT THIS RUNS ON EACH VIRAL REFERENCE IN THE INDEX DIR SO AN INDEX DIR NEEDS TO BE PREPPED!
		#	This is not a single reference run.
	

		#	gres=scratch should be about total needed divided by num threads
		qsub -N ${jobbase}.hkle \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:${scratch} \
			-l feature=nocommunal \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/hkleseq_scratch.bash \
			-F "--base ${jobbase} -1 $r1 -2 $r2 --dir ${f} --human ${human} --index_dir ${viral}"


#			-F "--base ${jobbase} -1 $r1 -2 $r2 --dir ${f} --human ${BOWTIE2}/hg38 --index_dir ${BOWTIE2}/SVAs_and_HERVs_KWHE"

	fi

done	#	for r1 in

#done < FILE_LIST

