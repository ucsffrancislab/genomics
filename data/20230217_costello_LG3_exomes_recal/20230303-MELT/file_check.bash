#!/usr/bin/env bash



module load CBI samtools bcftools

#positions=""
#positions="chr2:209113112 chr2:209113192 chr15:90631934 chr15:90631838"

positions="chr2:209113112 chr2:209113192 chr15:90631934 chr15:90631838"	# chr13:108863591 chr13:108863609"

#	IDH1
#	chr2:209113112 - p.Arg132His ( also R132C )
#	chr2:209113192 - has no impact on protein created

#	IDH2
#	chr15:90631934 - 
#	chr15:90631838 - 


#	most don't have
#	chr5:1286516 chr5:1295228 chr5:1295250 chr5:1295349 chr7:54978924 chr7:55159349 chr8:130685457 chr9:22068652 chr11:118477367 chr20:62309839"


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
			echo -n -e "\t${s} bases\t${s} bam call\t${s} vcf call"
		done
		echo
	#elif [ -f "in/${bam}" ] ; then
	elif [ -s "in/${bam}" ] ; then

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
			#bases=$( samtools_bases_at_position.bash -q 60 -c ${c} -p ${p} -b in/${bam} 2>/dev/null | sort | uniq -c | paste -s -d, | sed 's/ //g' 2>/dev/null )
			bases=$( samtools_bases_at_position.bash -q 60 -c ${c} -p ${p} -b in/${bam} 2>/dev/null | sort | uniq -c | sed 's/^ *//' | paste -sd\; | sed 's/ /:/g' )
			echo -n -e "\t${bases}"

			call=$( echo ${bases} | tr \; "\n" | awk 'BEGIN{FS=":"}{b[$2]=$1;total+=$1}END{if(total>10){for(k in b){if(b[k]/total<0.2){delete b[k]}}; for(k in b){x=x""k}; if(length(x)==1){x=x""x};print x }}' )
			echo -n -e "\t${call}"


			f="vcfallq60/${bam%.bam}.vcf.gz"
			if [ -f ${f}.csi ] && [ ! -w ${f}.csi ] ; then
				vcfcall=$( bcftools view -H -r ${c}:${p}-${p} ${f} | grep -vs INDEL | awk '{gt=$NF;split(gt,gta,":");gsub(/0/,$4,gta[1]);gsub(/1/,$5,gta[1]);print gta[1]}' )

#bam=Patient263.Z00286.bam
#f=vcfallq60/${bam%.bam}.vcf.gz"
#c=chr15
#p=90631934
#bcftools view -H -r ${c}:${p}-${p} ${f} 
#chr15	90631932	.	TCC	.	30.5542	.	INDEL;IDV=2;IMF=0.0588235;DP=34;VDB=0.509452;SGB=-0.453602;RPBZ=-0.659792;MQBZ=0;MQSBZ=0;SCBZ=0;FS=0;MQ0F=0;AN=2;DP4=14,15,1,1;MQ=60	GT	0/0
#chr15	90631934	.	C	.	284.59	.	DP=32;MQSBZ=0;FS=0;MQ0F=0;AN=2;DP4=11,11,0,0;MQ=60	GT	0/0


				#	for better comparison of my call and vcf call
				#	remove /?
				#	sort bases in alphabetic order?
				#echo cba | grep -o . | sort |tr -d "\n"
				#awk '{split($0,a,"");asort(a);for(i in a){s=s""a[i]};print s}'

				if  [ -z "$vcfcall" ]; then
					echo -n -e "\t"	#./."
				else
					echo -n -e "\t${vcfcall}"
				fi
			else
				echo -n -e "\t-"
			fi

		done

		#positions="chr2:209113112 chr2:209113192 chr15:90631934 chr15:90631838"

		echo 

	fi

done < patient_ID_conversions.2022.tsv

#done < <( tail -n +2 patient_ID_conversions.2022.tsv )





#	Add some more columns


#	https://www.ncbi.nlm.nih.gov/variation/view/

#	hg19 

#	IDH1 chr2	209113192	rs11554137 ???? G->A
#	https://www.ncbi.nlm.nih.gov/snp/rs11554137
#	https://www.ncbi.nlm.nih.gov/snp/?term=hg19+rs11554137
#	don't understand the differences
#	IDH1
#	GRCh37, 2:209113112, G->A???  (rs121913500 CAGT)

#	https://cancer.sanger.ac.uk/cosmic/mutation/overview?cosm=COSM41590&id=25815454&trans=IDH2
#	IDH2
#	AA mutation p.R140Q (Substitution - Missense, position 140, R➞Q)
#	CDS mutation c.419G>A (Substitution, position 419, G➞A)
#	Genomic coordinates GRCh37, 15:90631934..90631934, view Ensembl contig

#	IDH2
#	https://cancer.sanger.ac.uk/cosmic/mutation/overview?id=25815454
#	GRCh37, 15:90631934, G->A???  rs121913502
#	GRCh37, 15:90631838, G->A???  rs121913503



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





