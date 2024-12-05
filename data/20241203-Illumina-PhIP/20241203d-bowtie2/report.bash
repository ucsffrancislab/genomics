#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20241203-Illumina-PhIP/merged
cutdir=/francislab/data1/working/20241203-Illumina-PhIP/20241203c-cutadapt/out
bowdir=/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out
manifest=/francislab/data1/raw/20241203-Illumina-PhIP/manifest.tsv


samples="S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25 S26 S27 S28 S29 S30 S31 S32 S33 S34 S35 S36 S37 S38 S39 S40 S41 S42 S43 S44 S45 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 S57 S58 S59 S60 S61 S62 S63 S64 S65 S66 S67 S68 S69 S70 S71 S72 S73 S74 S75 S76 S77 S78 S79 S80 S81 S82 S83 S84 S85 S86 S87 S88 S89 S90 S91 S92 S93 S94 S95 S96 S97 S98 S99 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192"


echo -n " --- "
for s in ${samples} ; do
	echo -n ",${s}"
done
echo


#Number  Name   Index  % Reads IDX # READ   # of Reads

echo -n "Name"
for s in ${samples} ; do
	v=$( awk -F"\t" -v sample=${s} '( $1 == sample ){print $2}' ${manifest} )
	echo -n ",${v}"
done
echo

#echo -n "First Index"
#for s in ${samples} ; do
#	i=$( zcat ${cutdir}/${s}.fastq.gz | head -1 | cut -d: -f10 )
#	echo -n ",${i}"
#done
#echo
#
#echo -n "#Reads"
#for s in ${samples} ; do
#	v=$( awk -F"\t" -v sample=${s} '( $1 == sample ){print $7}' ${manifest} | tr -d "," | tr -d " " )
#	echo -n ",${v}"
#done
#echo



echo -n "Raw Read Count"
for s in ${samples} ; do
	c=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed Read Count"
for s in ${samples} ; do
	c=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed % Read Count"
for s in ${samples} ; do
	n=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo



#echo -n "Q00 Aligned Read Count"
#for s in ${samples} ; do
#	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q00.aligned_count.txt 2> /dev/null)
#	echo -n ",${c}"
#done
#echo
#
#echo -n "Q00 Aligned % Read Count"
#for s in ${samples} ; do
#	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q00.aligned_count.txt 2> /dev/null)
#	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#	echo -n ",${c}"
#done
#echo


#echo -n "Q10 Aligned Read Count"
#for s in ${samples} ; do
#	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q10.aligned_count.txt 2> /dev/null)
#	echo -n ",${c}"
#done
#echo
#
#echo -n "Q10 Aligned % Read Count"
#for s in ${samples} ; do
#	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q10.aligned_count.txt 2> /dev/null)
#	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
#	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
#	echo -n ",${c}"
#done
#echo


echo -n "Q20 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q20.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q20 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q20.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q40 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q40.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q40 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q40.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo



echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




