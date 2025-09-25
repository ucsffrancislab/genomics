#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20250925-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20250925-Illumina-PhIP/20250925a-cutadapt/out
bowdir=/francislab/data1/working/20250925-Illumina-PhIP/20250925b-bowtie2/out



manifest=/francislab/data1/raw/20250925-Illumina-PhIP/manifest.csv

#[gwendt@c4-log1 /francislab/data1/raw/20250925-Illumina-PhIP]$ head -1 L5_full_covariates_Vir3_phip-seq_GBM_ALL_p15_and_p16_8-22-25hmh.csv 
#Sequencer S#,Avera Sample_ID,Avera RunName,Index primer,Index 'READ',UCSF sample name (PRN BlindID/PLCO liid),UCSF sample name for sequencing (PRN BlindID/PLCO liid),Sample type,Study,Analysis group (PLCO and PRN),PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 IPS GBM repeats],sex,age,best_draw_label (PLCO),match_race7 (PLCO),self-identified race/ethnicity (PRN),M_BLINDID (PRN),BIRTH_YEAR (PRN),Matching Race (IPS case),IDH mut (IPS case),dex_draw (IPS case),dex_prior_month (IPS case),Timepoint (IPS cases),192 sequencing Lane,Plate,well,column order,,

#head /francislab/data1/raw/20250925-Illumina-PhIP/manifest.csvSequencer S#,Avera Sample_ID,Avera RunName,Index primer,Index 'READ',UCSF sample name (PRN BlindID/PLCO liid),UCSF sample name for sequencing (PRN BlindID/PLCO liid),Sample type,Study,Analysis group (PLCO and PRN),PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 IPS GBM repeats],sex,age,best_draw_label (PLCO),match_race7 (PLCO),self-identified race/ethnicity (PRN),M_BLINDID (PRN),BIRTH_YEAR (PRN),Matching Race (IPS case),IDH mut (IPS case),dex_draw (IPS case),dex_prior_month (IPS case),Timepoint (IPS cases),192 sequencing Lane,Plate,well,column order,,
#S1,D149048_082025,082125_192Phip_L5,IDX001,AACCAAG,D149048,D149048,glioma serum,PLCO,CA,UP6094,M,59,draw5,White Non-Hispanic,,,,,,,,,L5,15,A01,1,,
#S2,465513_082025,082125_192Phip_L5,IDX002,AACCGCA,465513,465513,ALL maternal serum,PRN,CA,33100,F,,,,LAT,15850,2003,,,,,,L5,15,B01,2,,
#S3,846782_082025,082125_192Phip_L5,IDX003,AACCTGC,846782,846782,ALL maternal serum,PRN,CO,33434,F,,,,LAT,132078,2003,,,,,,L5,15,C01,3,,
#S4,D051856_082025,082125_192Phip_L5,IDX004,AACGACC,D051856,D051856,glioma serum,PLCO,CA,UZ6656,M,69,draw4,White Non-Hispanic,,,,,,,,,L5,15,D01,4,,
#S5,E150248_082025,082125_192Phip_L5,IDX005,AACGCAT,E150248,E150248,glioma serum,PLCO,CO,KF1413,M,67,baseline (1st) draw,White Non-Hispanic,,,,,,,,,L5,15,E01,5,,


#	head -1 manifest.csv | tr ',' '\n' | awk '{print NR,$0}'
#	1 Sequencer S#
#	2 Avera Sample_ID
#	3 Avera RunName
#	4 Index primer
#	5 Index 'READ'
#	6 UCSF sample name (PRN BlindID/PLCO liid)
#	7 UCSF sample name for sequencing (PRN BlindID/PLCO liid)
#	8 Sample type
#	9 Study
#	10 Analysis group (PLCO and PRN)
#	11 PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 IPS GBM repeats]
#	12 sex
#	13 age
#	14 best_draw_label (PLCO)
#	15 match_race7 (PLCO)
#	16 self-identified race/ethnicity (PRN)
#	17 M_BLINDID (PRN)
#	18 BIRTH_YEAR (PRN)
#	19 Matching Race (IPS case)
#	20 IDH mut (IPS case)
#	21 dex_draw (IPS case)
#	22 dex_prior_month (IPS case)
#	23 Timepoint (IPS cases)
#	24 192 sequencing Lane
#	25 Plate
#	26 well
#	27 column order
#	28 
#	29 




snumbers="S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25 S26 S27 S28 S29 S30 S31 S32 S33 S34 S35 S36 S37 S38 S39 S40 S41 S42 S43 S44 S45 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 S57 S58 S59 S60 S61 S62 S63 S64 S65 S66 S67 S68 S69 S70 S71 S72 S73 S74 S75 S76 S77 S78 S79 S80 S81 S82 S83 S84 S85 S86 S87 S88 S89 S90 S91 S92 S93 S94 S95 S96 S97 S98 S99 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192"

#	sample_index=/francislab/data1/raw/20250925-Illumina-PhIP/sample_index.csv

#	Sample S Number
echo -n " --- "
for s in ${snumbers} ; do
	echo -n ",${s}"
done
echo

echo -n "Subject"
for s in ${snumbers} ; do
	#v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $6}' ${manifest} )
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $2}' ${manifest} )
	v=${v/dup/}
	echo -n ",${v}"
done
echo

echo -n "Name"
for s in ${snumbers} ; do
	#v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $7}' ${manifest} )
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $2}' ${manifest} )
	echo -n ",${v}"
done
echo

#echo -n "Index"
#for s in ${snumbers} ; do
#	name=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $3}' ${manifest} )
#	v=$( awk -F, -v snumber=${name} '( $1 == snumber ){print $2}' ${sample_index} )
#	echo -n ",${v}"
#done
#echo

#	7 glioma serum
#	8 AGS
#	9 control
#	10 AGS50215
#	11 68
#	12 M


#  40 ALL maternal serum
#  20 commercial serum control - Name starts with CSE
# 632 glioma serum
#  48 meningioma serum
#  80 PBS blank - Name starts with Blank
# 120 pemphigus serum
#  20 Phage Library - Name starts with PLib
echo -n "Type"
for s in ${snumbers} ; do
	#v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $8}' ${manifest} )

	subject=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $2}' ${manifest} )
	if [[ "${subject}" == Blank* ]] ; then
		v="PBS blank"
	elif [[ "${subject}" == CSE* ]] ; then
		v="commercial serum control"
	elif [[ "${subject}" == PLib* ]] ; then
		v="Phage Library"
	else
		v="Unknown"
	fi

	echo -n ",${v}"
done
echo

# 252 AGS
# 252 IPS
#  48 MENS
# 120 PEMS
# 128 PLCO
#  40 PRN
echo -n "Study"
for s in ${snumbers} ; do
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $9}' ${manifest} )
	echo -n ",${v}"
done
echo

# 320 case
# 352 control
#  40 Endemic Control
#   1 Group
#  16 Hypermitotic
#  16 Immune-enriched
#  16 Merlin-intact
#  40 Non Endemic Control
#  40 PF Patient
echo -n "Group"
for s in ${snumbers} ; do
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $10}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Age"
for s in ${snumbers} ; do
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $13}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Sex"
for s in ${snumbers} ; do
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $12}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Plate"
for s in ${snumbers} ; do
	v=$( awk -F, -v snumber=${s} '( $1 == snumber ){print $25}' ${manifest} )

v=99

	echo -n ",${v}"
done
echo

echo -n "Well X"
for s in ${snumbers} ; do
	v=$( awk -F"," -v snumber=${s} '( $1 == snumber ){x=substr($26,1,1); print x}' ${manifest} | tr 'A-H' '1-8' )
	echo -n ",${v}"
done
echo

echo -n "Well Y"
for s in ${snumbers} ; do
	v=$( awk -F"," -v snumber=${s} '( $1 == snumber ){x=substr($26,2,2); print int(x)}' ${manifest} )
	echo -n ",${v}"
done
echo


echo -n "Raw Read Count"
for s in ${snumbers} ; do
	c=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed Read Count"
for s in ${snumbers} ; do
	c=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Trimmed % Read Count"
for s in ${snumbers} ; do
	n=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Aligned Read Count"
for s in ${snumbers} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Aligned % Read Count"
for s in ${snumbers} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q20 Aligned Read Count"
for s in ${snumbers} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q20.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q20 Aligned % Read Count"
for s in ${snumbers} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q20.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q40 Aligned Read Count"
for s in ${snumbers} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q40.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q40 Aligned % Read Count"
for s in ${snumbers} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_count.q40.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo



echo -n "Q40 Unique Aligned Tile Count"
for s in ${snumbers} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_sequence_counts.q40.txt | wc -l )
	echo -n ",${c}"
done
echo


echo -n "Unique Aligned Tile Count"
for s in ${snumbers} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.id_upper_oligo.uniq.1-80.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




