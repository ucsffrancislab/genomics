#!/usr/bin/env bash

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools bowtie2 bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it

mkdir -p raw
mkdir -p masks

#for f in /francislab/data1/refs/fasta/nuccore/*.fasta /francislab/data1/refs/fasta/Burkholderia.fasta /francislab/data1/refs/fasta/Salmonella.fasta /francislab/data2/refs/fasta/viruses/NC_001422.1_Coliphage_phi-X174.fasta /francislab/data1/refs/fasta/coronaviruses/NC_??????.?.fasta /francislab/data1/refs/refseq/viral-20210316/split/*BeAn*complete_genome.fa /francislab/data1/refs/refseq/viral-20210316/split/*Burkholderia*complete_genome.fa /francislab/data1/refs/refseq/viral-20210316/split/*oronavirus*complete_genome.fa /francislab/data1/refs/refseq/viral-20210316/split/*cytomegalovirus*complete_genome.fa ; do

for f in /francislab/data1/refs/refseq/viral-20210316/split/*{BeAn,Burkholder,Coliphage,oronavirus,cytomegalovirus,epatitis,Human*herpes,Human_papillomavirus,immuno,Salmonella}*complete_genome.fa ; do

#${PWD}/tmp/*fa 


	echo $f
	
	accession=$( head -1 $f | sed -e 's/_/ /g' -e 's/^>NC />NC_/' -e 's/^>AC />AC_/' -e 's/^>//' | awk '{print $1}' )
	echo $accession

	l=raw/${accession}.fasta

	if [ ! -f ${l} ] ; then
		#ln -s ${f} ${l}
		#cp ${f} ${l}
		cat ${f} | sed -e '1s/_/ /g' -e '1s/^>NC />NC_/' -e 's/^>AC />AC_/' > ${l}
		chmod +w ${l}
	fi

	m=masks/$( basename $l )
	if [ ! -f ${m}.cat ] ; then
		echo ~/.local/RepeatMasker/RepeatMasker -pa 8 $l
		~/.local/RepeatMasker/RepeatMasker -pa 8 -dir masks $l 
		if [ -f ${m}.masked ] ; then
			mv ${m}.masked ${m%.fasta}.masked.fasta
		fi
		chmod -w ${m%.fasta}* ${l}
	fi

done


for f in raw/*fasta masks/*fasta ; do

	echo $f
	mkdir -p split
	mkdir -p split.custom
	mkdir -p split.vsl
	mkdir -p split.dev
	b=$( basename $f .fasta )

	for s in 100 75 50 25 ; do
	
		o=split/${b}.split.${s}.fa
		echo $o
		if [ ! -f ${o} ] ; then
			faSplit -oneFile -extra=${s} size ${f} ${s} split
			mv split.fa ${o}
			chmod -w $o
		fi

		for a in dev custom vsl ; do
			echo ${a}

			#	I can't remember the details, but I believe the custom settings
			#	were meant to inspire more alignments.

			o=split.${a}/${b}.split.${s}.sam
			if [ ! -f ${o} ] ; then
				if [ ${a} == 'dev' ] ; then
					bowtie2 -x hg38-noEBV -f -U split/${b}.split.${s}.fa --no-unal \
						--local -D 25 -R 3 -N 0 -L 15 -i S,1,0.25 --score-min G,15,8 \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'custom' ] ; then
					bowtie2 -x hg38-noEBV -f -U split/${b}.split.${s}.fa --no-unal \
						--local -D 25 -R 3 -N 0 -L 18 -i S,1,0.30 --score-min G,15,8 \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'vsl' ] ; then
					bowtie2 -x hg38-noEBV -f -U split/${b}.split.${s}.fa --no-unal \
						--very-sensitive-local \
						-S ${o} 2> ${o%.sam}.summary.txt
				fi
				chmod -w ${o} ${o%.sam}.summary.txt
			fi
	
			#	Above and below NEED the complete reference (with its version number as it is in the fasta)


			o=split.${a}/${b}.split.${s}.mask.bed
			if [ ! -f ${o} ] ; then
				samtools view split.${a}/${b}.split.${s}.sam | awk -v s=${s} -v ref=${b%.masked} '{
					sub(/^split/,"",$1);
					a=1+s*$1
					b=a+(2*s-1)
					print ref"\t"a"\t"b
				}' | awk -v ext=0 'BEGIN{FS=OFS="\t"}{
					if( r == "" ){
						#	first record
						r=$1
						s=(($2>ext)?$2:(ext+1))-ext
						e=$3+ext
					} else {
						if( $2 <= (e+ext+1) ){
							e=$3+ext
						}else{
							print $1,s,e
							s=$2-ext
							e=$3+ext
						} 
					}
				}END{ if( r != "" ) print r,s,e }' > ${o}
				chmod -w ${o}
			fi

			o=split.${a}/${b}.split.${s}.mask.masked_length.txt
			if [ ! -f ${o} ] ; then
				awk -F"\t" 'BEGIN{s=0}(length($0)>2){s+=($3-$2+1)}END{print s}' split.${a}/${b}.split.${s}.mask.bed > ${o}
				chmod -w ${o}
			fi

			# always the same reference here so no need to actually compare?


#	expanding ...
#	#	
#	#		echo maskFastaFromBed
#	#	
#	#		maskFastaFromBed -fi ${f} -fo ${b}.${s}.loc-masked.fa -bed ${b}.${s}.loc.mask.bed -fullHeader

			o=split.${a}/${b}.split.${s}.fasta
			if [ ! -f ${o} ] ; then
				maskFastaFromBed -fi ${f} -fo ${o} -bed split.${a}/${b}.split.${s}.mask.bed -fullHeader
				chmod -w ${o}
			fi

		done	#	for a in custom vsl ; do
	
	done	#	for s in 100 50 25 ; do

done	#	for f in raw/*fasta ; do

for f in raw/*fasta masks/*fasta split.*/*fasta ; do

	echo $f

	o=${f}.base_count.txt
	if [ ! -f ${o} ] ; then
		tail -n +2 ${f} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | sort | uniq -c > ${o}
		chmod -w ${o}
	fi

done

