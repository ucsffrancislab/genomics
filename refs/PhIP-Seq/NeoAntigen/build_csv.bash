#!/usr/bin/env bash


\rm -f tmp*.csv

cat oligos-ref-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1iname,oligo' > oligos-ref-28-14.csv

cat protein_tiles-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);split($1,a,"|");print $1,a[1],$2}' | sort -t, -k1,1 | sed '1iname,group,peptide' > protein_tiles-28-14.csv

join --header -t, protein_tiles-28-14.csv oligos-ref-28-14.csv > protein_tiles-oligos-28-14.csv


cat unique_proteins.faa | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1igroup,protein' > unique_proteins.csv


join -t, -1 1 -2 2 <( tail -n +2 unique_proteins.csv ) <( tail -n +2 protein_tiles-oligos-28-14.csv | sort -t, -k2,2 ) | sed '1iprotein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence' > protein_protein_tiles-oligos-28-14.csv



#	for p in $( diff unique_proteins.csv sorted_proteins.csv | grep "^>" | cut -d, -f2 ) ; do echo ; awk -F, -v p=$p '($2==p)' sorted_proteins.csv; done



cat << EOF | sort -t, -k1,1 | sed '1iprotein_sequence_name,alternate_protein_sequence_name' > alternate_sequence_names.csv
EGFR_HotSpot:594-602:Original,HotSpot_EGFR:594-602:Original
HotSpot_HRAS:57-65:Mutation:Q61R,HotSpot_NRAS:57-65:Mutation:Q61R
HotSpot_HRAS:57-65:Original,HotSpot_NRAS:57-65:Original
Darwin_ALEEKKGNYV,NeoPeptidesShi_ALEEKKGNYV
NeoEpitope_FPRGLWSI,NeoPeptidesShi_FPRGLWSI
NeoEpitope_FPRGLWSIL,NeoPeptidesShi_FPRGLWSIL
NeoEpitope_GLWSILPMS,NeoPeptidesShi_GLWSILPMS
NeoEpitope_RGLWSILPM,NeoPeptidesShi_RGLWSILPM
NeoEpitope_RTFPRGLWSI,NeoPeptidesShi_RTFPRGLWSI
RefSeqVZV_NP_040186.1_virion_protein_US10_Human_alphaherpesvirus_3,RefSeqVZV_NP_040191.1_virion_protein_US10_Human_alphaherpesvirus_3
RefSeqVZV_NP_040185.1_regulatory_protein_ICP22_Human_alphaherpesvirus_3,RefSeqVZV_NP_040192.1_regulatory_protein_ICP22_Human_alphaherpesvirus_3
RefSeqVZV_NP_040184.1_transcriptional_regulator_ICP4_Human_alphaherpesvirus_3,RefSeqVZV_NP_040193.1_transcriptional_regulator_ICP4_Human_alphaherpesvirus_3
TCONS_00004305-93-kozak,TCONS_00004307-24-kozak
TCONS_00028203-178-kozak,TCONS_00028205-178-kozak
TCONS_00040298-1086-kozak,TCONS_00040300-610-kozak
VirScan_115278,VirScan_25297
VirScan_115279,VirScan_25298
VirScan_115280,VirScan_25299
VirScan_115281,VirScan_25300
VirScan_115286,VirScan_25305
VirScan_115287,VirScan_25306
VirScan_115288,VirScan_25307
VirScan_115296,VirScan_25315
VirScan_115298,VirScan_25317
VirScan_115299,VirScan_25318
VirScan_27181,VirScan_60281
EOF


awk 'BEGIN{FS=OFS=","}
(NR==1){print $0",group,source,virscan_id,original_protein_sequence_name"}
(NR>1){
	opsn=$1
	split($1,a,"_")
	if(a[1]~/VirScan/){
		s="VirScan"
		vid=a[length(a)]
		$1="VirScan_"vid
	}else{
		s=a[1]
		vid=""
	}
	print $0,a[1],s,vid,opsn}' protein_protein_tiles-oligos-28-14.csv > tmp1.csv

#	protein_sequence_name,protein_sequence,tile_name,peptide_sequence,
#		oligo_sequence,
#		group,source,virscan_id,original_protein_sequence_name
#	Darwin_AAAAAPASR,AAAAAPASR,Darwin_AAAAAPASR|CTERM|STOP|C-PADDED-18,AAAAAPASR*GGSGGGSGGGSGGGSGGG,
#		GCTGCAGCCGCAGCGCCGGCGTCACGTTAGGGCGGGTCAGGGGGGGGCAGCGGGGGGGGGAGCGGGGGTGGCTCTGGCGGCGGT,
#		Darwin,Darwin,,Darwin_AAAAAPASR
#	VirScan_9709,KTTHAYTNAAFTSSDATLPMGTTGSYTPPQDGSFPPPPR,VirScanPublicEpitope_9709|CTERM|STOP,SSDATLPMGTTGSYTPPQDGSFPPPPR*,
#		AGTAGCGATGCGACCTTGCCGATGGGTACAACCGGGTCTTATACCCCGCCGCAGGACGGTTCATTTCCGCCGCCGCCGCGTTAG,
#		VirScanPublicEpitope,VirScan,9709,VirScanPublicEpitope_9709

head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

join --header -t, -a 1 -o auto tmp2.csv alternate_sequence_names.csv > tmp3.csv
#	protein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence,
#		group,source,virscan_id,original_protein_sequence_name,alternate_protein_sequence_name

head -1 tmp3.csv > tmp4.csv
tail -n +2 tmp3.csv | sort -t, -k8,8 >> tmp4.csv
join --header -t, -1 8 -2 1 -a 1 -o auto tmp4.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv > tmp5.csv


sed -i -e "s/_Human_alphaherpesvirus_3//g" tmp5.csv





#	Add "virscan public epitope" column
join -t, -a 1 -o auto <( tail -n +2 tmp5.csv ) <( awk -F, '(NR>1){print $1","$2",Public"}' ../VirScan/public_epitope_annotations.join_sorted.csv ) | sed '1ivirscan_id,protein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence,group,source,original_protein_sequence_name,alternate_protein_sequence_name,species,protein_name,public_epitope_species,public_epitope' > tmp6.csv




awk 'BEGIN{FS=OFS=","}
(NR==1){
	print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,"protein_sequence_length","positions","start_position","stop_position","condition"}
(NR>1){

	condition=s1=s2=""

	if( $4 ~ /CTERM\|STOP$/ ){ 
		s1=length($3)-1-28
		s1=s1<0?0:s1
		s2=length($3)
	}else if( $4 ~ /CTERM\|STOP\|C-PADDED/ ){

		if( $2 ~ /HotSpot/ && $2 ~ /\-/ ){ 
			# EGFR_HotSpot:857-865:Original
			split($4,a,":")
			split(a[2],b,"-")
			s1=b[1]-1
			s2=b[2]
		} else if( $2 ~ /HotSpot/ && $2 ~ /EGFR/ && $2 ~ /del/ ){ # only valid for EGFR. Should be only "del"
			# EGFR_HotSpot:879del:Original
			split($2,a,":")
			gsub("del","",a[2])
			if( a[2] ~ /_/ ){
				split(a[2],b,"_")
				r1=b[1]
				r2=b[2]
			}else{
				r1=a[2]
				r2=a[2]
			}
			#length_of_deletion=r2-r1+1 # irrelevant?
			#length_of_peptide=54

			# r1/r2 positions are nucleotide positions from gene start, NOT protein start

			s1=int((r1-12)/3)

			if( $2 ~ /Original/ ){ 
				s2=s1+18
			}else{
				#s2=s1+18	#	Not sure how best to handle this given the deletion
			}

		} else {
			s1=0
			s2=length($3)
		}

		if( $2 ~ /HotSpot/ ){
			if( $2 ~ /Original/ ){ 
				condition="Original"
			}else{
				condition="Mutation"
			}
		}
	}else{
		split($4,a,"|")
		split(a[2],b,"-")
		s1=b[1]
		s2=b[2]
	}

	if ( $2~/EGFR/ ){
		$11="Human"
		$12="Epidermal Growth Factor Receptor"
	}else if( $2~/^FRa/ ){
		$11="Human"
		$12="Folate Receptor Alpha"
	}else if( $2~/^IDH/ ){
		$11="Human"
		$12="Isocitrate DeHydrogenase"
	}else if( $2~/HER2/ ){
		$11="Human"
		$12="Human Epidermal Growth Factor Receptor 2"
	}else if( $2~/RefSeqVZV/ ){
		$11="Human herpesvirus 3"
		tmp1=substr($2,1+index($2,"_"))
		tmp2=substr(tmp1,1+index(tmp1,"_"))
		$12=substr(tmp2,1+index(tmp2,"_"))
		gsub("_"," ",$12)
	}else if( $2~/HotSpot_APC/ ){
		$11="Human"
		$12="Adenomatous Polyposis Coli"
	}else if( $2~/HotSpot_ARF/ ){
		$11="Human"
		$12="ADP-ribosylation factors"
	}else if( $2~/HotSpot_ARID1A/ ){
		$11="Human"
		$12="AT-rich interaction domain 1A"
	}else if( $2~/HotSpot_BRAF/ ){
		$11="Human"
		$12="B-Raf"
	}else if( $2~/HotSpot_BRCA1/ ){
		$11="Human"
		$12="BReast CAncer gene 1"
	}else if( $2~/HotSpot_BRCA2/ ){
		$11="Human"
		$12="BReast CAncer gene 2"
	}else if( $2~/HotSpot_CTNNB1/ ){
		$11="Human"
		$12="beta-catenin"
	}else if( $2~/HotSpot_ERBB2/ ){
		$11="Human"
		$12="erb-b2 receptor tyrosine kinase 2"
	}else if( $2~/HotSpot_FAT4/ ){
		$11="Human"
		$12="FAT atypical cadherin 4"
	}else if( $2~/HotSpot_HRAS/ ){
		$11="Human"
		$12="Harvey Rat sarcoma virus"
	}else if( $2~/HotSpot_IDH/ ){
		$11="Human"
		$12="Isocitrate DeHydrogenase"
	}else if( $2~/HotSpot_KRAS/ ){
		$11="Human"
		$12="Kristen rat sarcoma viral oncogene homolog"
	}else if( $2~/HotSpot_MLH1/ ){
		$11="Human"
		$12="MutL protein homolog 1"
	}else if( $2~/HotSpot_MSH2/ ){
		$11="Human"
		$12="MutS Homolog 1"
	}else if( $2~/HotSpot_MYC/ ){
		$11="Human"
		$12="Myelocytomatosis Oncogene"
	}else if( $2~/HotSpot_NOTCH1/ ){
		$11="Human"
		$12="Neurogenic locus notch homolog protein 1"
	}else if( $2~/HotSpot_NRAS/ ){
		$11="Human"
		$12="Neuroblastoma RAS viral oncogene homolog"
	}else if( $2~/HotSpot_PIK3CA/ ){
		$11="Human"
		$12="Phosphatidylinositol-4 5-bisphosphate 3-kinase catalytic subunit alpha"
	}else if( $2~/HotSpot_PIK3R1/ ){
		$11="Human"
		$12="Phosphoinositide-3-kinase Regulatory Subunit 1"
	}else if( $2~/HotSpot_POLE/ ){
		$11="Human"
		$12="DNA polymerase epsilon catalytic subunit"
	}else if( $2~/HotSpot_PTEN/ ){
		$11="Human"
		$12="phosphatase and tensin homolog"
	}else if( $2~/HotSpot_RB1/ ){
		$11="Human"
		$12="Retinoblastoma 1"
	}else if( $2~/HotSpot_SMAD2/ ){
		$11="Human"
		$12="Mothers against decapentaplegic homolog 2"
	}else if( $2~/HotSpot_SMAD4/ ){
		$11="Human"
		$12="Mothers against decapentaplegic homolog 4"
	}else if( $2~/HotSpot_TP53/ ){
		$11="Human"
		$12="Tumor Protein p53"
	}
	print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,length($3),substr($4,1+index($4,"|")),s1,s2,condition
}' tmp6.csv > tmp7.csv



#	All fields added, sort by virscan numeric id, protein sequence name and then the start position

#	virscan_id,protein_sequence_name,protein_sequence,tile_name,peptide_sequence,
#		oligo_sequence,group,source,original_protein_sequence_name,alternate_protein_sequence_name,
#		species,protein_name,public_epitope_species,public_epitope,protein_sequence_length,
#		positions,start_position,stop_position,condition

head -1 tmp7.csv > tmp8.csv
tail -n +2 tmp7.csv | sort -t, -k1n,1 -k2,2 -k17n,17 >> tmp8.csv



#	Generate our unique id

awk 'BEGIN{FS=OFS=","}(NR==1){print "unique_id",$0}(NR>1){print NR-1,$0}' tmp8.csv > tmp9.csv


#	Noticed that 139 peptides are actually duplicated, 3 are triplicated.
#	Kinda wish I would've noticed this before today, but here we are.
#	How to deal with this? 
#		First off, mark them as over represented compared to others.
#		How to deal with this in analysis? Combine aligned counts? 
#		Or simply leave alone? Twice the exposure yields twice the counts?
for p in $( cut -d, -f6 tmp9.csv | tail -n +2 | sort | uniq -d ) ; do
	#awk -F, -v p=${p} '($6==p)' tmp9.csv | cut -d, -f1 | paste -d: - - - | awk -F: '{print $1","$0 }'
	for id in $( awk -F, -v p=${p} '($6==p)' tmp9.csv | cut -d, -f1 ) ; do
		ids=$( awk -F, -v p=${p} '($6==p)' tmp9.csv | cut -d, -f1 | paste -d: - - - )
		echo ${id},${ids}
	done
done | sed 's/:$//' | sort -t, -k1,1 | sed '1iunique_id,multiplicated_peptide_ids' > multiplicated_peptides.csv
head -1 tmp9.csv > tmp10.csv
tail -n +2 tmp9.csv | sort -t, -k1,1 >> tmp10.csv
join --header -t, -a 1 -o auto tmp10.csv multiplicated_peptides.csv > tmp11.csv

head -1 tmp11.csv > neoantigen_dataset.csv
tail -n +2 tmp11.csv | sort -t, -k1n,1 >> neoantigen_dataset.csv


#\rm tmp*.csv

