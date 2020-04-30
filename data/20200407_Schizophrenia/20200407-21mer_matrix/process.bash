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
vmem=16

date=$( date "+%Y%m%d%H%M%S" )



for r1 in /francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/????_R1.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	echo $base
	jobbase=$( basename ${base} )

	nonhuman_dskid=""
	outbase="${base}.hg38.bowtie2-e2e.unmapped.21mers.dsk"
	f="${outbase}.txt.gz"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	dsk crashes often on other machines. No idea why. Guessing its a compiled library thing.
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 348724 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 428386 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 428382 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 432574 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 440511 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 464722 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 495647 Illegal instruction     dsk $ARGS
		#	/home/gwendt/.local/bin/dsk.bash: line 28: 488282 Illegal instruction     dsk $ARGS
		#	So use -l feature=nocommunal
		nonhuman_dskid=$( qsub -N ${jobbase}.unk -l nodes=1:ppn=${threads} -l vmem=16gb \
			-j oe -o ${outbase}.${date}.out.txt \
			-l feature=nocommunal \
			~/.local/bin/nonhuman_dsk.bash \
				-F "-r1 ${r1} -r2 ${r2}" )
		echo $nonhuman_dskid
	fi

	outbase="${base}.hg38.bowtie2-e2e.unmapped.21mers.dsk"
	f="${outbase}" # DIRECTORY
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${nonhuman_dskid} ] ; then
			depend="-W depend=afterok:${nonhuman_dskid}"
		else
			depend=""
		fi
		#vmem=8;threads=8;
		#-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
		#		-l nodes=1:ppn=4 -l vmem=8gb \
		qsub ${depend} -N ${jobbase}.uslt.21 \
			-l feature=nocommunal \
			-l gres=scratch:50 \
			-l nodes=1:ppn=8 -l vmem=16gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/dsk_ascii_split_scratch.bash \
			-F "-k 21 -u 15 -outbase ${outbase}"
	fi


	for k in 13 15 17 ; do

		outbase="${base}.hg38.bowtie2-e2e.unmapped.${k}mers.dsk"
		f="${outbase}.txt.gz"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${nonhuman_dskid} ] ; then
				depend="-W depend=afterok:${nonhuman_dskid}"
			else
				depend=""
			fi
			#	So use -l feature=nocommunal
			qsub ${depend} -N ${jobbase}.${k}unk -l nodes=1:ppn=${threads} -l vmem=16gb \
				-j oe -o ${outbase}.${date}.out.txt \
				-l feature=nocommunal \
				~/.local/bin/nonhuman_dsk.bash \
					-F "-k ${k} -r1 ${r1} -r2 ${r2}"
		fi

	done

done	#	for r1 in 

