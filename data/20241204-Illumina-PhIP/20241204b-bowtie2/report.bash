#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20241204-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20241204-Illumina-PhIP/20241204a-cutadapt/out
bowdir=/francislab/data1/working/20241204-Illumina-PhIP/20241204b-bowtie2/out
#manifest=/francislab/data1/raw/20241203-Illumina-PhIP/manifest.tsv
# NO manifest=/francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv
manifest=/francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv


samples="U S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25 S26 S27 S28 S29 S30 S31 S32 S33 S34 S35 S36 S37 S38 S39 S40 S41 S42 S43 S44 S45 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 S57 S58 S59 S60 S61 S62 S63 S64 S65 S66 S67 S68 S69 S70 S71 S72 S73 S74 S75 S76 S77 S78 S79 S80 S81 S82 S83 S84 S85 S86 S87 S88 S89 S90 S91 S92 S93 S94 S95 S96 S97 S98 S99 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192"
#samples="U 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192"


#Avera Sample_ID,UCSF sample name for sequence,"Avera RunName",Index primer,Sample type,"Backtrack Study Code",Analysis group,age,sex,"dx/StdDiag (IPS & MENS)","Matching Race (glioma)","IDH mut (IPS case)",dex_draw (IPS case),"dex_prior_month (IPS case)",Timepoint (IPS cases),"DNA_methylation_subgroup (MENS)","GERS (MENS)","GERG (MENS)",192 sequencing Lane,Phip-seq Plate,Phip-Seq well,column order 
#Blank01_1_112024_2,Blank01_1,112024_192PhiP_L1_requeue(#2),IDX001,PBS blank,,,,,,,,,,,,,,L1,1,A01,1
#14118-01_112024_2,14118-01,112024_192PhiP_L1_requeue(#2),IDX002,glioma serum,IPS,case,61,M,1 new gbm,Hispanic,IDH-WT,Yes,Yes,1 pre surg,,,,L1,1,B01,2
#PLib01_1_112024_2,PLib01_1,112024_192PhiP_L1_requeue(#2),IDX003,VIR phage Library,,,,,,,,,,,,,,L1,1,C01,3
#4207_112024_2,4207,112024_192PhiP_L1_requeue(#2),IDX004,glioma serum,AGS,control,74,M,,NH White,,,,,,,,L1,1,D01,4
#4460_112024_2,4460,112024_192PhiP_L1_requeue(#2),IDX005,glioma serum,AGS,control,29,M,,NH White,,,,,,,,L1,1,E01,5
#14235-01_112024_2,14235-01,112024_192PhiP_L1_requeue(#2),IDX006,glioma serum,IPS,case,72,M,1 new gbm,NH White,IDH-WT,Yes,Yes,1 pre surg,,,,L1,1,F01,6
#Blank04_1_112024_2,Blank04_1,112024_192PhiP_L1_requeue(#2),IDX007,PBS blank,,,,,,,,,,,,,,L1,1,G01,7


echo -n " --- "
for s in ${samples} ; do
	echo -n ",${s}"
done
echo

echo -n "Name"
for s in ${samples} ; do
	s=${s#S}
	#v=$( awk -F"\t" -v sample=${s} '( $1 == sample ){print $2}' ${manifest} )
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $2}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Type"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $5}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Study"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $6}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Group"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $7}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Age"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $8}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Plate"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){print $20}' ${manifest} )
	echo -n ",${v}"
done
echo

echo -n "Well X"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){x=substr($21,1,1); print x}' ${manifest} | tr 'A-H' '1-8' )
	echo -n ",${v}"
done
echo

echo -n "Well Y"
for s in ${samples} ; do
	s=${s#S}
	v=$( awk -F"," -v sample=${s} 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}( $22 == sample ){x=substr($21,2,2); print int(x)}' ${manifest} )
	echo -n ",${v}"
done
echo


#Number 	Name	 Index	% Reads	IDX #	READ	 # of Reads  
#S1	Blank01_1	CTTGGTT	0.4989	IDX001	AACCAAG	
#S2	14118-01	TGCGGTT	0.0004	IDX002	AACCGCA	 2,055,110 
#S3	PLib01_1	GCAGGTT	0.5306	IDX003	AACCTGC	


#echo -n "Index"
#for s in ${samples} ; do
#	v=$( awk -F"\t" -v sample=${s} '( $1 == sample ){print $3}' ${manifest} | tr -d "," | tr -d " " )
#	echo -n ",${v}"
#done
#echo
#
#echo -n "RC"
#for s in ${samples} ; do
#	v=$( awk -F"\t" -v sample=${s} '( $1 == sample ){print $6}' ${manifest} | tr -d "," | tr -d " " )
#	echo -n ",${v}"
#done
#echo
#
#echo -n "First Index"
#for s in ${samples} ; do
#	i=$( zcat ${cutdir}/${s}.fastq.gz | head -1 | cut -d: -f10 )
#	echo -n ",${i}"
#done
#echo

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



echo -n "Q40 Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-84.bam.q40.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo


echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




