#!/usr/bin/env bash

set -x



#	cat /francislab/data1/refs/refseq/viral-20220923/viral.protein.faa \
#		| sed  -e '/^>/s/,//g' -e '/^>/s/->//g' | grep "^>" | sed 's/^>//' > viral_proteins.names.txt
#	
#	(echo -e "accession\tdescription" &&awk -F_ '{print $1"_"$2"\t"$0}' viral_proteins.names.txt ) > viral_proteins.names.tsv
#	
#	head -1 viral_proteins.names.tsv > viral_proteins.names.sorted.tsv
#	tail -n +2 viral_proteins.names.tsv | sort >> viral_proteins.names.sorted.tsv
#	
#	cat /francislab/data1/refs/refseq/viral-20220923/viral.protein.faa \
#		| sed  -e '/^>/s/,//g' -e '/^>/s/->//g' \
#		| awk -F_ '(/^>/){print $1"_"$2}(!/>/){print}' > viral_protein_accessions.faa
#	makeblastdb -in viral_protein_accessions.faa -input_type fasta -dbtype prot -out viral_protein_accessions -title viral_protein_accessions -parse_seqids
#	
#	
#	cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa \
#		| sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' \
#		| awk -F_ '(/^>/){print $1"_"$2}(!/>/){print}' > Human_herpes_protein_accessions.faa
#	
#	makeblastdb -in Human_herpes_protein_accessions.faa -input_type fasta -dbtype prot -out Human_herpes_accessions -title Human_herpes_accessions -parse_seqids
#	
#	
#	head -2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -1 | tr -d '\015' > S1.TCONS_sorted.csv
#	tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 | tr -d '\015' >> S1.TCONS_sorted.csv



cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human*herpes*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_endogenous_retrovirus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_immunodeficiency_virus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_T-lymphotropic_virus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*nterovirus_C*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Norovirus_G*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_adenovirus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Variola_virus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Influenza*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Torque_teno_virus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_polyomavirus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_papillomavirus*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_endogenous*.fa \
	/francislab/data1/refs/refseq/viral-20220923/viral.protein/*Human_orthopneumovirus*.fa \
	| sed  -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' \
	| awk -F_ '(/^>/){print $1"_"$2}(!/>/){print}' > select_protein_accessions.faa

makeblastdb -in select_protein_accessions.faa -input_type fasta -dbtype prot -out select_accessions -title select_accessions -parse_seqids
















#for viruses in viral_protein_accessions Human_herpes_protein_accessions ; do
for viruses in select_protein_accessions ; do

for transcripts in S10_S1Brain_ProteinSequences S10_All_ProteinSequences ; do

for evalue in 0.05 0.005 ; do


	#	blast viral proteins to TCONS database

	echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  	> ${viruses}_IN_${transcripts}.blastp.e${evalue}.tsv
	blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/${transcripts} -outfmt 6 \
  	-query ${viruses}.faa -evalue ${evalue} >> ${viruses}_IN_${transcripts}.blastp.e${evalue}.tsv




	#	Add species name column to blast results based on accession number

	accessions=$( awk -F"\t" '(NR>1){split($1,a,".");print a[1]}' ${viruses}_IN_${transcripts}.blastp.e${evalue}.tsv | sort | uniq | sed -E 's/^(.+)$/"\1"/' | paste -sd, )
	echo "${accessions}"

	sqlite3 -header -csv /francislab/data1/refs/taxadb/asgf.sqlite \
		"SELECT accession,species FROM asgf WHERE accession IN ( ${accessions} ) ORDER BY accession" \
		| tr -d \" \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.accession_species.csv

	echo -e "qaccver,saccver,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore,TCONS" \
  	> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.csv
	awk 'BEGIN{FS="\t";OFS=","}(NR>1){split($1,a,".");$1=a[1];split($2,b,"_");print $0,"TCONS_"b[2]}' \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.tsv \
		| sort -t, -k1,1 \
		>> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.csv

	join -t, --header -1 1 -2 1 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.csv \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.accession_species.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.csv



	#	Drop all columns except TCONS and Viral species

	echo -e "Transcript ID,Species" \
  	> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.csv
	tail -n +2 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.csv \
		| awk 'BEGIN{FS=OFS=","}{print $(NF-1),$NF}' | sort | uniq \
		>> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.csv
#		| awk 'BEGIN{FS=OFS=","}{split($2,a,"_");print "TCONS_"a[2],$NF}' | sort | uniq \
	
	
	#	Select just protein and antigen and then add transcript name 
	
	#echo -e "qaccver\tsaccver" \
  #	> ${viruses}_IN_${transcripts}.blastp.e${evalue}.sorted.tsv
	#tail -n +2 ${viruses}_IN_${transcripts}.blastp.e${evalue}.tsv \
	#	| awk 'BEGIN{FS=OFS="\t"}{print $1,$2}' | sort | uniq >> ${viruses}_IN_${transcripts}.blastp.e${evalue}.sorted.tsv
	#
	#join --nocheck-order --header viral_proteins.names.sorted.tsv \
	#	${viruses}_IN_${transcripts}.blastp.e${evalue}.sorted.tsv \
	#	| sed 's/ /\t/g' > ${viruses}_IN_${transcripts}.blastp.e${evalue}.sorted.descriptions.tsv
	
	
	
	
	join -t, --header -1 1 -2 1 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.csv \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.accession_species.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.csv



	sort -t, -k13,13 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONSsorted.csv

	join -t, --header -1 13 -2 1 \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONSsorted.csv \
		S1.TCONS_sorted.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.S1.csv

	

	#	Add TCONS cancer type table columns

	join -t, --header S1.TCONS_sorted.csv \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.csv
	

	awk 'BEGIN{FS=OFS=",";tc=split("10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74",tumors,",")}
		(NR==1){line=$NF; for(j=1;j<=tc;j++){line=line OFS $tumors[j]}print line} (NR>1){for(i in tumors){ counts[$NF][tumors[i]]+=int($tumors[i]) } }
		END{for(k in counts){ line=k; for(j=1;j<=tc;j++){line=line OFS counts[k][tumors[j]]}print line }}' \
		${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.csv \
	| sed '1s/_tumor//g' \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.grouped.csv


	head -1 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.grouped.csv \
		> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.grouped.sorted.csv
	tail -n +2 ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.grouped.csv \
		| sort \
		>> ${viruses}_IN_${transcripts}.blastp.e${evalue}.trimandsort.species.TCONS.S1.grouped.sorted.csv

done

done

done


