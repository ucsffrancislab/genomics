#!/usr/bin/env bash

#set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail


#REFS=/francislab/data1/refs
#FASTA=${REFS}/fasta
#KALLISTO=${REFS}/kallisto
#SUBREAD=${REFS}/subread
#BOWTIE2=${REFS}/bowtie2
#BLASTDB=${REFS}/blastn
#KRAKEN2=${REFS}/kraken2
#DIAMOND=${REFS}/diamond

threads=8

date=$( date "+%Y%m%d%H%M%S" )


IN=/francislab/data1/raw/20191008_Stanford71
OUT=/francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed
mkdir -p ${OUT}

for r1 in ${IN}/??_R1.fastq.gz ; do

	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	echo $base
	jobbase=$( basename ${base} )

	outbase=${OUT}/${jobbase}

#	qoutbase="${jobbase}.bbduk"

	bbduk_id=""
	#f=${OUT}/${base}_R1.fastq.gz
	f=${outbase}_R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		bbduk_id=$( qsub -N ${jobbase}.bbduk -l nodes=1:ppn=2 -l vmem=32gb \
			-o ${outbase}.bbduk.${date}.out.txt -e ${outbase}.bbduk.${date}.err.txt \
			~/.local/bin/bbduk.bash \
				-F "-Xmx16g \
					in1=${r1} \
					in2=${r2} \
					out1=${outbase}_R1.fastq.gz \
					out2=${outbase}_R2.fastq.gz \
					outs=${outbase}_S.fastq.gz \
					ref=${IN}/adapters.fa \
					ktrim=r \
					k=23 \
					mink=11 \
					hdist=1 \
					tbo \
					ordered=t \
					bhist=${outbase}.bhist.txt \
					qhist=${outbase}.qhist.txt \
					gchist=${outbase}.gchist.txt \
					aqhist=${outbase}.aqhist.txt \
					lhist=${outbase}.lhist.txt \
					gcbins=auto \
					maq=10 \
					qtrim=w trimq=5 minavgquality=0" )
		echo ${bbduk_id}
	fi

	#outbase=${OUT}/${jobbase}
	base=${outbase}

	mkdir -p ${OUT}/length
	outbase=${OUT}/length/${jobbase}

	length_id=""
	f=${outbase}_R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${bbduk_id} ] ; then
			depend="-W depend=afterok:${bbduk_id}"
		else
			depend=""
		fi
		length_id=$( qsub ${depend} -N ${jobbase}.length -l nodes=1:ppn=2 -l vmem=8gb \
			-o ${outbase}.length.${date}.out.txt -e ${outbase}.length.${date}.err.txt \
			~/.local/bin/filter_paired_fastq_on_equal_read_length.bash \
				-F "${base}_R1.fastq.gz \
					${base}_R2.fastq.gz \
					${outbase}_R1.fastq.gz \
					${outbase}_R2.fastq.gz \
					${outbase}_diff_R1.fastq.gz \
					${outbase}_diff_R2.fastq.gz" )
		echo $length_id
	fi


	#outbase=${OUT}/length/${jobbase}
	base=${outbase}

	mkdir -p ${OUT}/length/unpaired
	outbase=${OUT}/length/unpaired/${jobbase}

	unpair_id=""
	f=${outbase}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${length_id} ] ; then
			depend="-W depend=afterok:${length_id}"
		else
			depend=""
		fi

		qsub ${depend} -N ${jobbase}.unpair -l nodes=1:ppn=2 -l vmem=8gb \
			-o ${outbase}.unpair.${date}.out.txt -e ${outbase}.unpair.${date}.err.txt \
			~/.local/bin/unpair_fastqs.bash -F "-o ${f} ${base}_R?.fastq.gz"

	fi

done

