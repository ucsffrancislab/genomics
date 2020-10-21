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
STAR=${REFS}/STAR
SALMON=${REFS}/salmon

INDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out"
DIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20201001-bowtie2-hg38_rmsk/out"
mkdir -p ${DIR}

#	remember 64 cores and ~504GB mem
threads=8
vmem=62

date=$( date "+%Y%m%d%H%M%S" )

for r1 in ${INDIR}/{02,CS-6668,HT-7468,HT-7481}*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
#while IFS=, read -r r1 ; do

	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.bowtie2.hg38_rmsk"
	bowtie2id=''
	#f=${outbase}.bam
	f=${outbase}.fa.gz
	#if [ -d $f ] && [ ! -w $f ] ; then
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		index=${BOWTIE2}/hg38_rmsk
		
		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )

		index_size=$( stat --dereference --format %s ${index}.*.bt2 | awk '{s+=$1}END{print s}' )

		scratch=$( echo $(( ((4*(${r1_size}+${r2_size})+${index_size})/${threads}/1000000000)+1 )) )
		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		echo "Using scratch:${scratch}"

		#	dev discordant_unmapped_mates_scratch.bash?

		bowtie2id=$( qsub -N ${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-l feature=nocommunal \
			-l gres=scratch:${scratch} \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/discordant_unmapped_mates_scratch.bash \
			-F "--very-sensitive --threads ${threads} -x ${index} \
					--rg-id ${base} --rg "SM:${base}" -1 ${r1} -2 ${r2} -o ${f}" )
		echo ${bowtie2id}
	fi
	all_reads=${f}


	for g in ';Family=Alu:' ';Class=LINE;' ; do
		n=${g#*=}
		n=${n/:/}
		n=${n/;/}
		echo $g
		echo $n

		fsid=''
		outbase="${DIR}/${base}.bowtie2.hg38_rmsk.${n}"
		f=${outbase}.fa.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Running fasta select ${base} ${n}"
			if [ ! -z ${bowtie2id} ] ; then
				depend="-W depend=afterok:${bowtie2id}"
			else
				depend=""
			fi
#				-l gres=scratch:${scratch} \
			fsid=$( qsub ${depend} -N fs${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-l feature=nocommunal \
				-j oe -o ${outbase}.${date}.out.txt \
				~/.local/bin/fasta_select.bash \
				-F "-i ${all_reads} -p '${g}' -o ${f}" )
			echo "${fsid}"
		fi
		selected=${f}
		
#		dskid=''
#		#k=31
#		k=15
#		outbase="${DIR}/${base}.bowtie2.hg38_rmsk.${n}.${k}.dsk"
#		f=${outbase}.h5
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Running dsk ${base} ${n} ${k}"
#			if [ ! -z ${fsid} ] ; then
#				depend="-W depend=afterok:${fsid}"
#			else
#				depend=""
#			fi
##				-l gres=scratch:${scratch} \
#				#-F "-max-memory ${vmem} -nb-cores ${threads} -kmer-size ${k} \
##       -max-memory                             (1 arg) :    max memory (in MBytes)  [default '5000']
##			using max-memory of just vmem, say 62, will cause the large results (~>100000) to be different
##		subtracting 2 from vmem to allow room for other stuff. not sure if needed
#			dskid=$( qsub ${depend} -N dsk${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-j oe -o ${outbase}.${date}.out.txt \
#				-l feature=nocommunal \
#				~/.local/bin/dsk.bash \
#				-F "-max-memory $((vmem-2))000 -nb-cores ${threads} -kmer-size ${k} \
#					-abundance-min 0 -file ${selected} -out ${f}" )
#			echo "${dskid}"
#		fi
#		asciiid=''
#		f=${outbase}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Running dsk2ascii ${base} ${n} ${k}"
#			if [ ! -z ${dskid} ] ; then
#				depend="-W depend=afterok:${dskid}"
#			else
#				depend=""
#			fi
##				-l gres=scratch:${scratch} \
#			asciiid=$( qsub ${depend} -N d2a${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-l feature=nocommunal \
#				-j oe -o ${outbase}.dsk2ascii.${date}.out.txt \
#				~/.local/bin/dsk2ascii.bash \
#				-F "-nb-cores ${threads} -file ${outbase}.h5 -out ${f}" )
#			echo "${asciiid}"
#		fi
#
#		splitid=''
#		f=${outbase}	#	DIRECTORY HERE
#		#if [ -f $f ] && [ ! -w $f ] ; then
#		if [ -d $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Running dsk_ascii_split ${base} ${n} ${k}"
#			if [ ! -z ${asciiid} ] ; then
#				depend="-W depend=afterok:${asciiid}"
#			else
#				depend=""
#			fi
#
#			#input_size=$( stat --dereference --format %s ${outbase}.txt.gz )
#			#	The above file probably won't exist yet
#			#	Actually all_reads shouldn't exist yet if running first time
#			#input_size=$( stat --dereference --format %s ${all_reads} )
#			input_size=10000000000
#			scratch=$( echo $(( ((2*${input_size})/${threads}/1000000000)+1 )) )
#			echo "Using scratch:${scratch}"
#
##				-l feature=nocommunal \
#			#	Very serial process. Could be 2 and 15. Not true anymore.
#			#splitid=$( qsub ${depend} -N split${base} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			splitid=$( qsub ${depend} -N split${base} \
#				-l nodes=1:ppn=${threads} -l vmem=250gb \
#				-l gres=scratch:${scratch} \
#				-j oe -o ${outbase}.split.${date}.out.txt \
#				~/.local/bin/dsk_ascii_split_scratch.bash \
#				-F "-k 31 -u 15 -outbase ${f}" )
#			echo "${splitid}"
#		fi

	done



	#	merge split counts into matrices (post)
	#merge_mer_counts.py -o merged.bowtie2.hg38_rmsk.${k}.dsk2ascii.csv.gz out/*.bowtie2.hg38_rmsk.${k}.dsk2ascii.txt.gz &

	#	concat matrices (post)

#done < ALL-P2.fastq_files.txt
done

