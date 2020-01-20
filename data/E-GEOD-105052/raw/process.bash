#!/usr/bin/env bash



set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2

#       do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
threads=8

date=$( date "+%Y%m%d%H%M%S" )



for r1 in /francislab/data1/raw/E-GEOD-105052/fastq/trimmed/*.fastq.gz ; do

	#       NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )
	jobbase=${jobbase:(-3)}	#	just the last 3 digits


#	was done on herv ...
#~/github/unreno/genomics/dev/data_sets/E-GEOD-105052/20190926-exploratory/process.bash 


	#for kref in ${KALLISTO}/??_??.idx ${KALLISTO}/a??_??.idx ${KALLISTO}/rsrna_??.idx ; do
	#for kref in ${KALLISTO}/rsrna_??.idx ; do
	#for kref in ${KALLISTO}/hrna_11.idx ; do
	#for kref in ${KALLISTO}/rsrna_31.idx ; do
	#for kref in ${KALLISTO}/rsrna_13.idx ; do
	#for kref in ${KALLISTO}/ami_21.idx ; do
	#for kref in ${KALLISTO}/mi_21.idx ; do
	#for kref in ${KALLISTO}/rsrna_21.idx ; do
	#for kref in ${KALLISTO}/vm_??.idx ${KALLISTO}/rsg_??.idx ; do
	#for kref in ${KALLISTO}/{ami,mi,ahp,hp,amt,mt}_??.idx ; do

	for kref in ${KALLISTO}/rsg_13.idx ; do

#	rsrna_13 rsrna_31 mi_11 mi_21 ami_11 ami_21

		basekref=$( basename $kref .idx )

		case $basekref in
			rsg_13)
				vmem=128;;
			rsg_*|rsrna_13|vm_13)
				vmem=64;;
			hrna_11|rsrna_21|rsrna_31)
				vmem=32;;
			mi_*|mt_*|hp_*|ami_*|amt_*|ahp_*)
				vmem=8;;
			*)
				vmem=16;;
		esac

		qoutbase=${base}.kallisto.single.${basekref}
		f=${qoutbase}
		#	NOTE THAT THIS IS A DIRECTORY AND NOT A FILE
		if [ -d $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else

			#	Not sure if we actually need the bam file
			#-F "quant -b ${threads}0 --threads ${threads} --pseudobam \

			qsub -N ${jobbase}.${basekref}.ks -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
				~/.local/bin/kallisto.bash \
				-F "quant -b ${threads}0 --threads ${threads} \
					--single-overhang --single -l 42.4732 -s 5.46411 --index ${kref} \
					--output-dir ${qoutbase} ${r1}"
		fi

		#	zcat /francislab/data1/raw/20191008_Stanford71/trimmed/*fastq.gz | paste - - - - | cut -f 2 |
		#		awk '{ l=length; sum+=l; sumsq+=(l)^2; print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' > trimmed.avg_length.ssstdev.txt
		#	cat trimmed.avg_length.ssstdev.txt
		#	Avg: 144.9 Stddev:20.6282

		#	Avg: 144.924 	Stddev:	20.6833

	done


done

