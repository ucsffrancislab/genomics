#!/usr/bin/env bash



#positions="chr2:209113192 chr5:1286516 chr5:1295228 chr5:1295250 chr5:1295349 chr7:54978924 chr7:55159349 chr8:130685457 chr9:22068652 chr11:118477367 chr15:90631934 chr20:62309839"
positions=""

while read Z SF patient sample_type ; do
	#echo $Z $SF $patient $sample_type
	#ls -1 in/${patient}.${Z}.bam

	#if [ -f "in/${patient}.${Z}.bam" ] || [ $Z == "Z" ] ; then
	#	echo -e "${Z}\t${SF}\t${patient}\t${sample_type}"
	#fi

	bam="${patient}.${Z}.bam"

	if [ $Z == "Z" ] ; then
		echo -n "Z	SF	patient	sample_type	bam	tn	npr"
		for s in $positions ; do
			echo -n -e "\t${s}"
		done
		echo
	elif [ -f "in/${bam}" ] ; then

		tn=Unset
		npr=Unset

		if [[ ${sample_type} == "Normal"* ]] ; then
			tn=Normal
			npr=Normal
		elif [[ ${sample_type} == "Primary"* ]] ; then
			tn=Tumor
			npr=Primary
		elif [[ ${sample_type} == "Recurren"* ]] ; then
			tn=Tumor
			npr=Recurrent
		fi


		echo -n -e "${Z}\t${SF}\t${patient}\t${sample_type}\t${bam}\t${tn}\t${npr}"
		
		for s in $positions ; do
			c=$( echo $s | cut -d: -f1 )
			p=$( echo $s | cut -d: -f2 )
			bases=$( samtools_bases_at_position.bash -q 60 -c ${c} -p ${p} -b in/${bam} 2>/dev/null | sort | uniq -c | paste -s -d, | sed 's/ //g' 2>/dev/null )
			echo -n -e "\t${bases}"
		done

		echo 

	fi

done < patient_ID_conversions.2022.tsv

#done < <( tail -n +2 patient_ID_conversions.2022.tsv )


#	Add some more columns

#	hg19 

#	IDH1 chr2	209113192	rs11554137

#	https://cancer.sanger.ac.uk/cosmic/mutation/overview?cosm=COSM41590&id=25815454&trans=IDH2
#	IDH2
#	AA mutation p.R140Q (Substitution - Missense, position 140, R➞Q)
#	CDS mutation c.419G>A (Substitution, position 419, G➞A)
#	Genomic coordinates GRCh37, 15:90631934..90631934, view Ensembl contig
#	

#	https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4229642/
#	The two most common mutations in TERT, C228T and C250T, map −124 and −146 bp, respectively, upstream of the TERT ATG site (chr5, 1,295,228 C>T and 1,295,250 C>T, respectively), creating binding sites for Ets/TCF transcription factors that are associated with a two- to four-fold increased transcriptional

#	rs2853669 genotypes were available for 385 of the tumours. The distribution of genotypes showed no significant departure from HWE (39 CC, 161 CT, 185 TT P=0.650). There was no difference in the distribution of genotypes between the TERTp mut and the TERTp wt cases (TT 45.8 vs 53.5%, CT 44.3 vs 36.0% and CC: 10.0 vs 10.5%, respectively).

#	chr5	1295349	rs2853669 5:1295349 (GRCh37)
#	chr5, 1,295,228 C>T and 1,295,250 C>T,

#	https://www.ncbi.nlm.nih.gov/snp/rs2736100
#	rs2736100 - chr5 1286516

#	https://www.ncbi.nlm.nih.gov/snp/?term=hg19+rs11554137

#	rs11979158 7:55159349 (GRCh37)
#	rs2252586	7:54978924 (GRCh37)
#	rs4295627 8:130685457 (GRCh37)
#	rs4977756 9:22068652 (GRCh37)
#	rs498872	11:118477367 (GRCh37)
#	rs6010620	20:62309839 (GRCh37)





