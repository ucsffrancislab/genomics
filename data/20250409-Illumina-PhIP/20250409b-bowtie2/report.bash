#!/usr/bin/env bash

rawdir=/francislab/data1/raw/20250409-Illumina-PhIP/fastq
cutdir=/francislab/data1/working/20250409-Illumina-PhIP/20250409a-cutadapt/out
bowdir=/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out




#manifest=/francislab/data1/raw/20250409-Illumina-PhIP/manifest.csv
#sample,desc,fastq
#S1,C678IVS,C678IVS_121724_S1_L001_R1_001.fastq.gz
#S10,P232JCSdup,P232JCSdup_121724_S10_L001_R1_001.fastq.gz
#S100,14629-01,14629-01_121724_S100_L001_R1_001.fastq.gz
#S101,4121,4121_121724_S101_L001_R1_001.fastq.gz



#manifest=/francislab/data1/working/20250409-Illumina-PhIP/20250128c-PhIP/manifest.all.csv
#subject,sample,bampath,type,study,group,age,sex
#14061-01,14061-01dup,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S124.VIR3_clean.1-84.bam,glioma serum,,case,,
#14061-01,14061-01,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S116.VIR3_clean.1-84.bam,glioma serum,,case,,
#14091-01,14091-01dup,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S154.VIR3_clean.1-84.bam,glioma serum,,case,,
#14091-01,14091-01,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S146.VIR3_clean.1-84.bam,glioma serum,,case,,

#manifest=/francislab/data1/raw/20250409-Illumina-PhIP/L1_full_covariates_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-4-24hmh.csv


#join -j 2 --header -t, <( cat /francislab/data1/working/20250409-Illumina-PhIP/20250128c-PhIP/manifest.all.csv | ( head -1 && tail -n +2 | sort -t, -k2,2 )) <( cat /francislab/data1/raw/20250409-Illumina-PhIP/manifest.csv | ( head -1 && tail -n +2 | sort -t, -k2,2 ) ) > /francislab/data1/raw/20250409-Illumina-PhIP/manifest.TEST.csv - problematic

#join -j 2 -t, <( tail -n +2 /francislab/data1/working/20250409-Illumina-PhIP/20250128c-PhIP/manifest.all.csv | sort -t, -k2,2 ) <( tail -n +2 /francislab/data1/raw/20250409-Illumina-PhIP/manifest.csv | sort -t, -k2,2 ) > /francislab/data1/raw/20250409-Illumina-PhIP/manifest.TEST.csv
#sed -i '1isample,subject,bampath,type,study,group,age,sex,sample,fastq' /francislab/data1/raw/20250409-Illumina-PhIP/manifest.TEST.csv


#manifest=/francislab/data1/raw/20250409-Illumina-PhIP/manifest.TEST.csv
#sample,subject,bampath,type,study,group,age,sex,sample,fastq
#074KBP,074KBP,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S66.VIR3_clean.1-84.bam,pemphigus serum,,Non Endemic Control,,,S66,074KBP_121724_S66_L001_R1_001.fastq.gz
#074KBPdup,074KBP,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S74.VIR3_clean.1-84.bam,pemphigus serum,,Non Endemic Control,,,S74,074KBPdup_121724_S74_L001_R1_001.fastq.gz
#1322,1322,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S67.VIR3_clean.1-84.bam,meningioma serum,,,,,S67,1322_121724_S67_L001_R1_001.fastq.gz
#1322dup,1322,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S75.VIR3_clean.1-84.bam,meningioma serum,,,,,S75,1322dup_121724_S75_L001_R1_001.fastq.gz
#1323,1323,/francislab/data1/working/20250409-Illumina-PhIP/20250409b-bowtie2/out/S70.VIR3_clean.1-84.bam,meningioma serum,,,,,S70,1323_121724_S70_L001_R1_001.fastq.gz


#manifest=/francislab/data1/raw/20250409-Illumina-PhIP/manifest.csv
#Plate,well,column order,Sample type,samplenamefor sequence,sample name at plating,Index primer,192 sequencing Lane,Date of library amplified,Date of library shipped,Need to reamplify bc of Failed qPCR twice,Vlookup ID ,AGSID (AGS control),Backtrack Study Code,Analysis group,age,sex,dx/StdDiag (IPS & MENS),Matching Race (glioma),IDH mut (IPS case),dex_draw (IPS case),dex_prior_month (IPS case),Timepoint (IPS cases),DNA_methylation_subgroup (MENS),GERS (MENS),GERG (MENS),Avera RunName,Avera Sample_ID
#2,A01,1,glioma serum,20232,20232,IDX097,L2,12/12/24,12/16/24,,20232,AGS43545,AGS,control,63,F,,Hispanic,,,,,,,,112024_192PhiP_L1_requeue(#2),474RHI_112024_2
#2,B01,2,glioma serum,14291_02,14291-02,IDX098,L2,12/12/24,12/16/24,,14291-02,,IPS,case,51,F,1 new gbm,NH White,IDH-WT,Yes,Yes,3 postchemorad/pre adj,,,,,
#2,C01,3,glioma serum,14734_01,14734-01,IDX099,L2,12/12/24,12/16/24,,14734-01,,IPS,case,65,F,1 new gbm,NH White,IDH-WT,Yes,Yes,1 pre surg,,,,,
#2,D01,4,glioma serum,14629_01,14629-01,IDX100,L2,12/12/24,12/16/24,,14629-01,,IPS,case,46,M,1 new gbm,NH White,IDH-WT,Yes,Yes,1 pre surg,,,,,
#2,E01,5,glioma serum,4121,4121,IDX101,L2,12/12/24,12/16/24,,4121,AGS51072,AGS,control,49,M,,NH White,,,,,,,,,
#2,F01,6,glioma serum,20239,20239,IDX102,L2,12/12/24,12/16/24,,20239,AGS45174,AGS,control,45,M,,NH White,,,,,,,,,
#2,G01,7,glioma serum,3108,3108,IDX103,L2,12/12/24,12/16/24,,3108,AGS48460,AGS,control,87,F,,NH White,,,,,,,,,
#2,H01,8,glioma serum,4343,4343,IDX104,L2,12/12/24,12/16/24,,4343,AGS41970,AGS,control,57,F,,NH White,,,,,,,,,




manifest=/francislab/data1/raw/20250409-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv 
#	head -3 /francislab/data1/raw/20250409-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv 
#	Avera S#,Avera Sample_ID,UCSF sample name for sequence (combined table & manifest),"Avera RunName",Index primer,Index 'READ',Sample type,"Backtrack Study Code",Analysis group,"AGSID (AGS control)",age,sex,"dx/StdDiag (IPS & MENS)","Matching Race (glioma)","IDH mut (IPS case)",dex_draw (IPS case),"dex_prior_month (IPS case)",Timepoint (IPS cases),"DNA_methylation_subgroup (MENS)","GERS (MENS)","GERG (MENS)",192 sequencing Lane,Plate,well,column order
#	S1,1474101_012225,1474101,012225_192PhiP_L3,IDX001,AACCAAG,glioma serum,IPS,case,,69,M,1 new gbm,NH White,IDH-WT,Yes,Yes,1 pre surg,,,,L3,3,A01,1
#	S2,20489_012225,20489,012225_192PhiP_L3,IDX002,AACCGCA,glioma serum,AGS,control,AGS50215,68,M,,NH White,,,,,,,,L3,3,B01,2


samples="S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S25 S26 S27 S28 S29 S30 S31 S32 S33 S34 S35 S36 S37 S38 S39 S40 S41 S42 S43 S44 S45 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 S57 S58 S59 S60 S61 S62 S63 S64 S65 S66 S67 S68 S69 S70 S71 S72 S73 S74 S75 S76 S77 S78 S79 S80 S81 S82 S83 S84 S85 S86 S87 S88 S89 S90 S91 S92 S93 S94 S95 S96 S97 S98 S99 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192"
#samples="U 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192"

sample_index=/francislab/data1/raw/20250409-Illumina-PhIP/sample_index.csv

echo -n " --- "
for s in ${samples} ; do
	echo -n ",${s}"
done
echo

#	echo -n "Subject"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $3}' ${manifest} )
#		v=${v/dup/}
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Name"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $3}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Index"
#	for s in ${samples} ; do
#		name=$( awk -F, -v sample=${s} '( $1 == sample ){print $3}' ${manifest} )
#		v=$( awk -F, -v sample=${name} '( $1 == sample ){print $2}' ${sample_index} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	#	7 glioma serum
#	#	8 AGS
#	#	9 control
#	#	10 AGS50215
#	#	11 68
#	#	12 M
#	
#	echo -n "Type"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $7}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Study"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $8}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Group"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $9}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Age"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $11}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Sex"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $12}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Plate"
#	for s in ${samples} ; do
#		v=$( awk -F, -v sample=${s} '( $1 == sample ){print $23}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Well X"
#	for s in ${samples} ; do
#		v=$( awk -F"," -v sample=${s} '( $1 == sample ){x=substr($24,1,1); print x}' ${manifest} | tr 'A-H' '1-8' )
#		echo -n ",${v}"
#	done
#	echo
#	
#	echo -n "Well Y"
#	for s in ${samples} ; do
#		v=$( awk -F"," -v sample=${s} '( $1 == sample ){x=substr($24,2,2); print int(x)}' ${manifest} )
#		echo -n ",${v}"
#	done
#	echo


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


echo -n "Q20 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.q20.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q20 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.q20.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo


echo -n "Q40 Aligned Read Count"
for s in ${samples} ; do
	c=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.q40.txt 2> /dev/null)
	echo -n ",${c}"
done
echo

echo -n "Q40 Aligned % Read Count"
for s in ${samples} ; do
	n=$(cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_count.q40.txt 2> /dev/null)
	d=$(cat ${cutdir}/${s}.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n ",${c}"
done
echo



echo -n "Q40 Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_sequence_counts.q40.txt | wc -l )
	echo -n ",${c}"
done
echo


echo -n "Unique Aligned Tile Count"
for s in ${samples} ; do
	c=$( cat ${bowdir}/${s}.VIR3_clean.1-84.bam.aligned_sequence_counts.txt | wc -l )
	echo -n ",${c}"
done
echo




