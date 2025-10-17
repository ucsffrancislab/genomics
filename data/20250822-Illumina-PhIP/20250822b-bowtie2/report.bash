#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20250822-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20250822-Illumina-PhIP/20250822a-cutadapt/out
bowdir=/francislab/data1/working/20250822-Illumina-PhIP/20250822b-bowtie2/out



manifest=/francislab/data1/raw/20250822-Illumina-PhIP/manifest.csv

#	head -1 L5_full_covariatesv3_Vir3_phip-seq_GBM_ALL_p15_and_p16_10-7-25hmh.csv | tr , "\n" | awk '{print NR,$0}'
#	1 Sequencer S#
#	2 Avera Sample_ID
#	3 "Avera RunName"
#	4 Index primer
#	5 Index 'READ'
#	6 "UCSF sample name (PRN BlindID/PLCO liid)"
#	7 "UCSF sample name for sequencing (PRN BlindID/PLCO liid)"
#	8 Sample type
#	9 Study
#	10 "Analysis group (PLCO and PRN - child)"
#	11 PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 IPS GBM repeats]
#	12 sex (SE donor)
#	13 age
#	14 "best_draw_label (PLCO)"
#	15 match_race7 (PLCO)
#	16 self-identified race/ethnicity (PRN - birth certificate?)
#	17 M_BLINDID (PRN - mother)
#	18 BIRTH_YEAR (PRN - child)
#	19 Sex (PRN - child)
#	20 "Matching Race (IPS case)"
#	21 "IDH mut (IPS case)"
#	22 dex_draw (IPS case)
#	23 "dex_prior_month (IPS case)"
#	24 "Timepoint (IPS cases)"
#	25 192 sequencing Lane
#	26 Plate
#	27 well
#	28 column order
#	29 
#	30 



samples="S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25 S26 S27 S28 S29 S30 S31 S32 S33 S34 S35 S36 S37 S38 S39 S40 S41 S42 S43 S44 S45 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 S57 S58 S59 S60 S61 S62 S63 S64 S65 S66 S67 S68 S69 S70 S71 S72 S73 S74 S75 S76 S77 S78 S79 S80 S81 S82 S83 S84 S85 S86 S87 S88 S89 S90 S91 S92 S93 S94 S95 S96 S97 S98 S99 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192"

#	sample_index=/francislab/data1/raw/20250822-Illumina-PhIP/sample_index.csv

echo -n " --- "
for s in ${samples} ; do
	echo -n ",${s}"
done
echo

echo -n "Subject"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $6}' ${manifest} )
	#v=${v/dup/}
	echo -n ",${v}"
done
echo

echo -n "Name"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $7}' ${manifest} )
	echo -n ",${v}"
done
echo

#echo -n "Index"
#for s in ${samples} ; do
#	name=$( awk -F, -v sample=${s} '( $1 == sample ){print $3}' ${manifest} )
#	v=$( awk -F, -v sample=${name} '( $1 == sample ){print $2}' ${sample_index} )
#	echo -n ",${v}"
#done
#echo

#	7 glioma serum
#	8 AGS
#	9 control
#	10 AGS50215
#	11 68
#	12 M

echo -n "Type"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $8}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Study"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $9}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Group"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $10}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Age"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $13}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Sex"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $12}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Plate"
for s in ${samples} ; do
	v=$( awk -F, -v sample=${s} '( $1 == sample ){print $26}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Well X"
for s in ${samples} ; do
	v=$( awk -F"," -v sample=${s} '( $1 == sample ){x=substr($27,1,1); print x}' ${manifest} | tr 'A-H' '1-8' )
	echo -n ",${v}"
done
echo

echo -n "Well Y"
for s in ${samples} ; do
	v=$( awk -F"," -v sample=${s} '( $1 == sample ){x=substr($27,2,2); print int(x)}' ${manifest} )
	echo -n ",${v}"
done
echo


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
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q20 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q20.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q20 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q20.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q40 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q40.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q40 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q40.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo



echo -n "Q40 Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_sequence_counts.q40.txt | wc -l )
	echo -n ",${c}"
done
echo


echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




