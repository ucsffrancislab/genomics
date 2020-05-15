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

IN=/francislab/data1/raw/20200430_Raleigh_RNASeq/Raleigh_cell_lines
OUT=/francislab/data1/working/20200430_Raleigh_RNASeq/20200515_REdiscoverTE/trimmed
mkdir -p ${OUT}

#dr-xr-xr-x 2 gwendt francislab 4096 Apr 30 06:59 Raleigh_cell_lines
#[gwendt@cclc01 /francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression]$ ll -tr /francislab/data1/raw/20200430_Raleigh_RNASeq/Raleigh_cell_lines/
#total 11046476
#-r--r--r-- 1 gwendt francislab 1070633281 Apr 30 06:58 Ctrl_EV_2_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab  958421167 Apr 30 06:58 Ctrl_EV_3_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 1318072030 Apr 30 06:59 NF2kd_EV_1_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 1151275979 Apr 30 06:59 NF2kd_EV_2_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 1013205217 Apr 30 06:59 NF2kd_EV_3_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 1229350988 Apr 30 06:59 NF2kd_NF2_1_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 1477930846 Apr 30 06:59 NF2kd_NF2_2_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab 2100223872 Apr 30 06:59 NF2kd_NF2_3_R1_001.fastq.gz
#-r--r--r-- 1 gwendt francislab  992461826 Apr 30 06:59 Ctrl_EV_1_R1_001.fastq.gz

for r1 in ${IN}/*fastq.gz ; do

	#base=${r1%_R1.fastq.gz}
	#r2=${r1/_R1/_R2}

	base=${r1%_R1_001.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

	outbase=${OUT}/${jobbase}

	f=${outbase}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${jobbase}.bbduk -l nodes=1:ppn=2 -l vmem=32gb \
			-j oe -o ${outbase}.bbduk.${date}.txt \
			~/.local/bin/bbduk.bash \
				-F "-Xmx16g \
					in1=${r1} \
					out1=${outbase}.fastq.gz \
					ref=/francislab/data1/refs/fasta/illumina_adapters.fa \
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
					qtrim=w trimq=5 minavgquality=0"
	fi

#	I'm guessing that this is ok
#	/var/spool/torque/mom_priv/jobs/1798237.cclc01.som.ucsf.edu.SC: line 30: out2: unbound variable

done

