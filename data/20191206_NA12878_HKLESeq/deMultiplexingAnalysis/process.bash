#!/usr/bin/env bash

set -x

dir="raw"
if [ ! -d ${dir} ] ; then
	mkdir ${dir}
	cd ${dir}

	for f in ../../Sample*_S*_L001_R?_001.fastq.gz ; do
		s=$( basename $f )
		s=${s/_001/}
		s=${s/_L001/}
		s=${s#Sample*_S}
		if [ ${s:1:1} == '_' ] ; then
			s="0${s}"
		fi
		s=${s/_R/.R}
		#echo $s $f
		ln -s ${f} ${s}
	done

	cd ..
fi


awk '{print $1}' umi_indexes.tsv > Name
awk '{print $2}' umi_indexes.tsv > Index1
awk '{print $2}' umi_indexes.tsv | tr "[ATGCatgc]" "[TACGtacg]" | rev > Index1.RC
awk '{print $3}' umi_indexes.tsv > Index2
awk '{print $3}' umi_indexes.tsv | tr "[ATGCatgc]" "[TACGtacg]" | rev > Index2.RC


#	https://github.com/ucsffrancislab/umi

#	A lot of repetition here. Could have nested these a little differently.

for min_reads in 1 10 100 ; do
	dmdir="umi.${min_reads}.1"	# 1 = max hamming
	mkdir -p $dmdir
	cd $dmdir

	if [ ! -f seqcounts.txt ] ; then
		python ~/github/ucsffrancislab/umi/demultiplex.py --min_reads ${min_reads} \
			--read1  ../../SFSP003_S1_L001_R1_001.fastq.gz \
			--read2  ../../SFSP003_S1_L001_R2_001.fastq.gz \
			--index1 ../../SFSP003_S1_L001_I1_001.fastq.gz \
			--index2 ../../SFSP003_S1_L001_I2_001.fastq.gz \
			--sample_barcodes ../umi_indexes.tsv --max_hamming 1

		if [ ! -d "tagged" ] ; then
			mkdir -p tagged
			cd tagged
			for r1 in ../??.r1.fastq ; do
				#base=${r1%.r1.fastq}
				base=$( basename $r1 .r1.fastq )
				echo ${base}
				python ~/github/ucsffrancislab/umi/umitag.py \
					--read1_in  ../${base}.r1.fastq \
					--read2_in  ../${base}.r2.fastq \
					--read1_out ${base}.umitagged.r1.fastq \
					--read2_out ${base}.umitagged.r2.fastq \
					--index1    ../${base}.i1.fastq \
					--index2    ../${base}.i2.fastq
			done

#			for min_qual in 5 10 15 20 ; do
#				#dir="umi.${min_reads}.1.${min_qual}.0.9"
#				dir="${min_qual}.0.9"
#				if [ ! -d ${dir} ] ; then
#					mkdir ${dir}
#					cd ${dir}
#					#	Usage: python consolidate.py fastq_file consolidated_fastq_file min_qual min_freq
#					for r1 in *.umitagged.r1.fastq ; do
#						base=${r1%.umitagged.r1.fastq}
#						python ~/github/ucsffrancislab/umi/consolidate.py \
#							${base}.umitagged.r1.fastq ${base}.consolidated.r1.fastq ${min_qual} 0.9
#						python ~/github/ucsffrancislab/umi/consolidate.py \
#							${base}.umitagged.r2.fastq ${base}.consolidated.r2.fastq ${min_qual} 0.9
#					done
#					cd ..
#				fi
#			done	#	for min_qual in 5 10 15 20 ; do

			cd ..	#	tagged
		fi
	fi
	cd ..	#	dmdir="umi.${min_reads}.1"	# 1 = max hamming
done	#	for min_reads in 1 10 100 ; do


#paste Name Index1 > umi_indexes.1.tsv
#
#for min_reads in 1 ; do
#	dmdir="umi1.${min_reads}.1"	# 1 = max hamming
#	mkdir -p $dmdir
#	cd $dmdir
#
#	if [ ! -f seqcounts.txt ] ; then
#		python2 ~/github/aryeelab/umi/demultiplex.py --min_reads ${min_reads} \
#			--read1  ../../SFSP003_S1_L001_R1_001.fastq.gz \
#			--read2  ../../SFSP003_S1_L001_R2_001.fastq.gz \
#			--index1 ../../SFSP003_S1_L001_I1_001.fastq.gz \
#			--index2 ../../SFSP003_S1_L001_I2_001.fastq.gz \
#			--sample_barcodes ../umi_indexes.1.tsv
#	fi
#	cd ..
#done




#	1	GTCAACCA	GCATGCAA
#		to
#	GTCAACCA	GCATGCAA	1


echo -e "#Index1\tIndex2\tName" > deML_indexes.12.tsv
paste Index1 Index2 Name       >> deML_indexes.12.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.12rc.tsv
paste Index1 Index2.RC Name    >> deML_indexes.12rc.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.1rc2.tsv
paste Index1.RC Index2 Name    >> deML_indexes.1rc2.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.1rc2rc.tsv
paste Index1.RC Index2.RC Name >> deML_indexes.1rc2rc.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.21.tsv
paste Index2 Index1 Name       >> deML_indexes.21.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.2rc1.tsv
paste Index2.RC Index1 Name    >> deML_indexes.2rc1.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.21rc.tsv
paste Index2 Index1.RC Name    >> deML_indexes.21rc.tsv

echo -e "#Index1\tIndex2\tName" > deML_indexes.2rc1rc.tsv
paste Index2.RC Index1.RC Name >> deML_indexes.2rc1rc.tsv

echo -e "#Index1\tName" > deML_indexes.1.tsv
paste Index1 Name      >> deML_indexes.1.tsv

echo -e "#Index2\tName" > deML_indexes.2.tsv
paste Index2 Name      >> deML_indexes.2.tsv



#	https://github.com/grenaud/deML
for x in 1 2 12 12rc 1rc2 1rc2rc 21 2rc1 21rc 2rc1rc ; do
	dir="deML.${x}"
	if [ ! -d ${dir} ] ; then
		mkdir ${dir}
		cd ${dir}
		~/github/grenaud/deML/src/deML -i ../deML_indexes.${x}.tsv \
			-f   ../../SFSP003_S1_L001_R1_001.fastq.gz \
			-r   ../../SFSP003_S1_L001_R2_001.fastq.gz \
			-if1 ../../SFSP003_S1_L001_I1_001.fastq.gz \
			-if2 ../../SFSP003_S1_L001_I2_001.fastq.gz \
			-s deML.summary.txt	-e deML.error.txt -o deML
		cd ..	#	dir="deML.${x}"
	fi
done






for x in 12 ; do

	dir="deML.${x}"
#	if [ ! -d ${dir} ] ; then
#		mkdir ${dir}
#		cd ${dir}
#		~/github/grenaud/deML/src/deML -i ../deML_indexes.${x}.tsv \
#			-f   ../../SFSP003_S1_L001_R1_001.fastq.gz \
#			-r   ../../SFSP003_S1_L001_R2_001.fastq.gz \
#			-if1 ../../SFSP003_S1_L001_I1_001.fastq.gz \
#			-if2 ../../SFSP003_S1_L001_I2_001.fastq.gz \
#			-s deML.summary.txt	-e deML.error.txt -o deML
#		cd ..
#	fi
	cd ${dir}

	#	deML does not include a consolidator
	if [ ! -d "tagged" ] ; then
		mkdir -p tagged
		cd tagged
		for r1 in ../deML_??_r1.fq.gz ; do
			#	deML_01_r1.fq.gz
			base=$( basename $r1 _r1.fq.gz )
			base=${base/deML_/}
			echo ${base}
			python ~/github/ucsffrancislab/umi/umitag.py \
				--read1_in  ../deML_${base}_r1.fq.gz \
				--read2_in  ../deML_${base}_r2.fq.gz \
				--read1_out ${base}.r1.fastq \
				--read2_out ${base}.r2.fastq \
				--index1    ../deML_${base}_i1.fq.gz \
				--index2    ../deML_${base}_i2.fq.gz
		done
		cd ..
	fi

	cd tagged
	#for min_qual in 5 10 15 20 ; do
	for min_qual in 15 ; do
		dir="${min_qual}.0.9"
		if [ ! -d ${dir} ] ; then
			mkdir ${dir}
			#cd ${dir}
			#	Usage: python consolidate.py fastq_file consolidated_fastq_file min_qual min_freq
			for r1 in *.r1.fastq ; do
				base=${r1%.r1.fastq}
				python ~/github/ucsffrancislab/umi/consolidate.py \
					${base}.r1.fastq ${dir}/${base}.r1.fastq ${min_qual} 0.9
				python ~/github/ucsffrancislab/umi/consolidate.py \
					${base}.r2.fastq ${dir}/${base}.r2.fastq ${min_qual} 0.9
			done
			#cd ..	#	dir="${min_qual}.0.9"
		fi

		
		cd ${dir}
		for r1 in *.r1.fastq ; do
			base=${r1%.r1.fastq}

			if [ ! -f ${base}.hg38.uvs.bam ] ; then
				bowtie2 -x hg38 -U ${base}.r1.fastq,${base}.r2.fastq --very-sensitive \
					--threads 4 2> ${base}.hg38.uvs.err.txt \
					| samtools view -o ${base}.hg38.uvs.bam -
			fi
	
			if [ ! -f ${base}.hg38.uvsl.bam ] ; then
				bowtie2 -x hg38 -U ${base}.r1.fastq,${base}.r2.fastq --very-sensitive-local \
					--threads 4 2> ${base}.hg38.uvsl.err.txt \
					| samtools view -o ${base}.hg38.uvsl.bam -
			fi
	
			if [ ! -f ${base}.hg38.vs.bam ] ; then
				bowtie2 -x hg38 -1 ${base}.r1.fastq -2 ${base}.r2.fastq --very-sensitive \
					--threads 4 2> ${base}.hg38.vs.err.txt \
					| samtools view -o ${base}.hg38.vs.bam -
			fi

			if [ ! -f ${base}.hg38.vsl.bam ] ; then
				bowtie2 -x hg38 -1 ${base}.r1.fastq -2 ${base}.r2.fastq --very-sensitive-local \
					--threads 4 2> ${base}.hg38.vsl.err.txt \
					| samtools view -o ${base}.hg38.vsl.bam -
			fi

		done
		cd ..	#	dir="${min_qual}.0.9"

	done	#	for min_qual in 5 10 15 20 ; do
	cd ..	#	tagged

	cd ..	#	dir="deML.${x}"
done





