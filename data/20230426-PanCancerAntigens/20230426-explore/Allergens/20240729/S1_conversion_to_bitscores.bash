#!/usr/bin/env bash

set -e  #       exit if any command fails     # can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools blast
	module load WitteLab python3/3.9.1
fi

#	python3 -m pip install --upgrade --user numpy scipy biopython==1.69 click tqdm pepsyn phip-stat pip wheel




TCONS_FASTA=/francislab/data1/raw/20230426-PanCancerAntigens/S10_S2_ProteinSequences.faa
PROTEIN_FASTA=All_Human_proteins.faa
#PROTEIN_FASTA=Human_herpes_proteins.faa
#PROTEIN_FASTA=Variola_virus_proteins.faa
EVALUE=0.05
TILESIZE=25

while [ $# -gt 0 ] ; do
	case $1 in
		--tcons)
			shift; TCONS_FASTA=$1; shift;;
		--protein)
			shift; PROTEIN_FASTA=$1; shift;;
		--evalue)
			shift; EVALUE=$1; shift;;
		--tilesize)
			shift; TILESIZE=$1; shift;;
		*)
			echo "Unknown"; exit 1;;
	esac
done

TCONS_FASTA_BASE=$( basename ${TCONS_FASTA} .gz )
TCONS_FASTA_BASE=$( basename ${TCONS_FASTA_BASE} .faa )
PROTEIN_FASTA_BASE=$( basename ${PROTEIN_FASTA} .gz )
PROTEIN_FASTA_BASE=$( basename ${PROTEIN_FASTA_BASE} .faa )

OVERLAP=$[TILESIZE-1]


echo "Tiling TCONS protein sequences"

f=${TCONS_FASTA_BASE}-tile-${TILESIZE}-${OVERLAP}.faa
if [ -f ${f} ] ; then
	echo "${f} exists. Skipping."
else
	if [ "${TCONS_FASTA: -3}" == ".gz" ] ; then
		command="zcat"
	else
		command="cat"
	fi
	eval ${command} ${TCONS_FASTA} | pepsyn tile -l ${TILESIZE} -p ${OVERLAP} - ${f}
fi
echo "head ${f}"
head ${f}
samtools faidx ${TCONS_FASTA_BASE}-tile-${TILESIZE}-${OVERLAP}.faa






#	echo "Preparing sequence names"
#	Remove characters that makeblastdb angry
#	Shorten to 50 chars
#	Add second iteration which was used by blast2bam or something but is otherwise ignored

#	scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/All_Human_proteins.faa ./
#cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_*.fa | sed  -e "/^>/s/'//g" -e '/^>/s/,//g' -e '/^>/s/->//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' -e '/^>/s/>\(.*\)$/>\1 \1/g' > All_Human_proteins.faa





#	echo "head ${PROTEIN_FASTA}"
#	head ${PROTEIN_FASTA}
#	
#	#echo "Indexing fasta"
#	#samtools faidx ${PROTEIN_FASTA}

echo "Making blastdb"
makeblastdb -parse_seqids \
  -in ${PROTEIN_FASTA} \
  -input_type fasta \
  -dbtype prot \
  -out ${PROTEIN_FASTA_BASE} \
  -title ${PROTEIN_FASTA_BASE}


echo "Blasting ${TCONS_FASTA_BASE} tiles to ${PROTEIN_FASTA_BASE}"

f=${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.${TILESIZE}-${OVERLAP}.blastp.e${EVALUE}.tsv
if [ -f ${f} ] ; then
	echo "${f} exists. Skipping."
else
	echo -e "qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" \
  	> ${f}
	blastp -db ${PROTEIN_FASTA_BASE} \
  	-outfmt 6 -evalue ${EVALUE} \
  	-query ${TCONS_FASTA_BASE}-tile-${TILESIZE}-${OVERLAP}.faa \
  	>> ${f}
fi
echo "head ${f}"
head ${f}





###echo "virus,accession,with_version,with_description" > ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
###sed -e 's/^>//' viral.protein.names.txt | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | 
###awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}'
###sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
##
###	scp c4:/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_herpes_proteins.faa ./
###	All_Human_proteins.faa
##
###echo "virus,accession,with_version,with_description" > ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
###grep "_Human_" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
###
###cut -d, -f1 all_human_protein_virus_translation_table.csv | uniq > all_human_virus_abbreviation_translation_table.csv 
##
###	Herpes viruses
###	grep "_Human_" viral.protein.names.txt | grep herpes | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print $1,$0}' | awk 'BEGIN{FS="_Human";OFS=","}{print "Human"$NF,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
##
###	Variola virus
###grep "_Variola_virus$" viral.protein.names.txt | sed -e 's/^>//' | awk 'BEGIN{FS=OFS="_"}{print $1,$2","$0}' | awk 'BEGIN{FS=".";OFS=","}{print "Variola_virus",$1,$0}' | sort >> ${PROTEIN_FASTA_BASE}.virus_translation_table.csv
##
###echo "accession,withversion,description" > Human_alphaherpesvirus_3.protein_translation_table.csv
###ls -1 /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_Human_alphaherpesvirus_3.fa | cut -d/ -f8 | sed 's/_Human_alphaherpesvirus_3.fa//' | awk 'BEGIN{OFS=","}{split($0,a,".");split($0,b,"_");print a[1],b[1]"_"b[2],$0}' >> Human_alphaherpesvirus_3.protein_translation_table.csv
##
###join --header -t, all_human_virus_abbreviation_translation_table.csv \
###	all_human_protein_virus_translation_table.csv > tmp1
##
###head -3 tmp1
###virus,abbreviation,accession,with_version,with_description
###Human_alphaherpesvirus_1,HHV1,YP_009137073,YP_009137073.1,YP_009137073.1_neurovirulence_protein_ICP34.5_Human_alphaherpesvirus_1
###Human_alphaherpesvirus_1,HHV1,YP_009137074,YP_009137074.1,YP_009137074.1_ubiquitin_E3_ligase_ICP0_Human_alphaherpesvirus_1





echo "Convert from tab separated to comma separated"
echo "select the TCONS base, accession without version and bitscore"
echo "and trimed any suffix from TCONS ( TCONS_00000246-104|100-125 -> TCONS_00000246 )"

sed 's/\t/,/g' ${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.${TILESIZE}-${OVERLAP}.blastp.e${EVALUE}.tsv \
  | awk 'BEGIN{FS=OFS=","}(NR>1){split($1,a,"_");split(a[2],b,"-");split($2,c,".");print a[1]"_"b[1],c[1],$NF}' > tcons_accession_bitscore.csv

#split($2,b,".");print a[1]"_"a[2],b[1],$NF}' > tcons_accession_bitscore.csv


echo "head tcons_accession_bitscore.csv"
head tcons_accession_bitscore.csv
#TCONS_00000560,YP_009505610,25.4
#TCONS_00000560,YP_009505610,25.0
#TCONS_00000560,YP_009505610,25.0
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_401658,25.8

#sort -t, -k1,2 -k3nr tcons_accession_bitscore.csv | uniq | head
#TCONS_00000246,NP_050190,23.9
#TCONS_00000246,YP_081561,24.6
#TCONS_00000667,YP_001129455,25.8
#TCONS_00000667,YP_001129455,24.3
#TCONS_00000667,YP_401658,25.8
#TCONS_00000667,YP_401658,24.3
#TCONS_00000802,YP_009137100,24.3
#TCONS_00000820,NP_040188,26.9
#TCONS_00000820,NP_040188,26.6
#TCONS_00000820,NP_040188,26.2

#sort -t, -k1,2 -k3nr tcons_accession_bitscore.csv | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | head
#NP_050190,TCONS_00000246,23.9
#YP_081561,TCONS_00000246,24.6
#YP_001129455,TCONS_00000667,25.8
#YP_401658,TCONS_00000667,25.8
#YP_009137100,TCONS_00000802,24.3
#NP_040188,TCONS_00000820,26.9
#YP_009137138,TCONS_00000820,28.5
#YP_009137215,TCONS_00000820,27.3
#YP_081510,TCONS_00000820,23.9
#YP_001129393,TCONS_00001232,24.3


echo "sort and select highest bitscore for each pair of accession / TCONS"
sort -t, -k1,2 -k3nr tcons_accession_bitscore.csv | uniq | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $2,$1,$3}' | sort -t, -k1,2 > accession_tcons_highestbitscore.csv
echo "head accession_tcons_highestbitscore.csv"
head accession_tcons_highestbitscore.csv
#AP_000108,TCONS_00016038,25.0
#AP_000108,TCONS_00060502,25.0
#AP_000108,TCONS_00101289,25.4
#AP_000112,TCONS_00083962,25.0
#AP_000114,TCONS_00013399,26.2
#AP_000115,TCONS_00094751,25.4
#AP_000116,TCONS_00010219,25.0
#AP_000120,TCONS_00043366,26.6
#AP_000121,TCONS_00110433,25.8
#AP_000124,TCONS_00016567,25.0



#echo "sort translation by accession and selecting just accession and description"
#echo "the uniq seems to be unnecessary"
#tail -n +2 all_human_protein_virus_translation_table.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
#tail -n +2 ${PROTEIN_FASTA_BASE}.virus_translation_table.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
#tail -n +2 virus_translation_table.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
#tail -n +2 virus_translation_table.20200507.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
##tail -n +2 virus_translation_table.20231122.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1}' | sort -t, -k1,2 | uniq > tmp4
##echo head tmp4
##head tmp4
#	AP_000001,Ovine mastadenovirus A
#	AP_000002,Ovine mastadenovirus A
#	AP_000003,Ovine mastadenovirus A
#	AP_000004,Ovine mastadenovirus A
#	AP_000005,Ovine mastadenovirus A
#	AP_000006,Ovine mastadenovirus A
#	AP_000007,Ovine mastadenovirus A
#	AP_000008,Ovine mastadenovirus A
#	AP_000009,Ovine mastadenovirus A
#	AP_000010,Ovine mastadenovirus A



##echo "Testing translation table with order and family"
##tail -n +2 virus_taxonomy_tree_translation_table.20231122.csv | awk 'BEGIN{FS=OFS=","}{print $4,$1,$2,$3}' | sort -t, -k1,2 > tmp4b
##echo head tmp4b
##head tmp4b
#	AP_000001,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000002,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000003,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000004,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000005,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000006,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000007,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000008,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000009,Rowavirales,Adenoviridae,Ovine mastadenovirus A
#	AP_000010,Rowavirales,Adenoviridae,Ovine mastadenovirus A

##echo "Testing translation table with order and family"
##echo "accession,order,family,name" > tmp4c
##tail -n +2 virus_taxonomy_tree_translation_table.20231122.csv | awk 'BEGIN{FS=OFS=","}{print $4,$1,$2,$3}' | sort -t, -k1,2 >> tmp4c






#	echo "Testing translation table with order,family,subfamily,genus,"
#	echo "accession,phylum,class,order,family,subfamily,genus,name" > tmp4c
#	tail -n +2 virus_taxonomy_tree_translation_table.20231129.20231122.csv | awk 'BEGIN{FS=OFS=","}{print $8,$1,$2,$3,$4,$5,$6,$7}' | sort -t, -k1,8 >> tmp4c
#	echo head tmp4c
#	head tmp4c










###	with or without abbreviation
##
###tail -n +2 tmp1 | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,2 | uniq > tmp4
####head -3 tmp4
####NP_040124,HHV3
####NP_040125,HHV3
####NP_040126,HHV3
##
##
###	Add virus description to table
###	
###	echo "virus,protein,TCONS,bitscore" > tmp5
###	#virus_protein_TCONS_bitscore.csv
###	join -t, tmp4 accession_tcons_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4}' | sort -t, -k1,3 >> tmp5
###	#virus_protein_TCONS_bitscore.csv
###	
###	#head -3 virus_protein_TCONS_bitscore.csv
###	#virus,protein,TCONS,bitscore
###	#HHV1,YP_009137074,TCONS_00009055,33.9
###	#HHV1,YP_009137074,TCONS_00030850,31.6
###	
###	
###	echo head tmp5
###	head tmp5
###	
###	virus,protein,TCONS,bitscore
###	Abalone herpesvirus Victoria/AUS/2009,YP_006908763,TCONS_00022805,33.5
###	Abelson murine leukemia virus,NP_057866,TCONS_00000820,40.4
###	Abelson murine leukemia virus,NP_057866,TCONS_00004840,32.3
###	Abelson murine leukemia virus,NP_057866,TCONS_00012449,47.8
###	Abelson murine leukemia virus,NP_057866,TCONS_00030512,35.0
###	Abelson murine leukemia virus,NP_057866,TCONS_00040320,45.4
###	Abelson murine leukemia virus,NP_057866,TCONS_00043710,32.7
###	Abelson murine leukemia virus,NP_057866,TCONS_00050645,31.2
###	Abelson murine leukemia virus,NP_057866,TCONS_00060648,31.6
##
##
###	Why do this then rearrange and resort?
##
###	echo "order,family,virus,protein,TCONS,bitscore" > tmp5b
###	join -t, tmp4b accession_tcons_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $2,$3,$4,$1,$5,$6}' | sort -t, -k1,5 >> tmp5b
###	echo head tmp5b
###	head tmp5b
##
###	order,family,virus,protein,TCONS,bitscore
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,TCONS_00125921,42.4
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,TCONS_00018705,37.7
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426700,TCONS_00011080,35.0
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426754,TCONS_00014359,32.0
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001427086,TCONS_00030512,31.6
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001427086,TCONS_00032482,34.7
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001427086,TCONS_00040986,35.4
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001427086,TCONS_00079225,33.5
###	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001427086,TCONS_00080445,36.6





#	For some reason, it quits after this line
echo "Creating local S1.csv"
#tail -n +2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | head -n 1 > S1.csv
head -n 2 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | tail -n 1 > S1.csv
#	but this line is fine. I think its the trailing head command.
echo "and sorting data"
tail -n +3 /francislab/data1/raw/20230426-PanCancerAntigens/41588_2023_1349_MOESM3_ESM/S1.csv | sort -t, -k1,1 >> S1.csv

echo "cleaning"
sed '1s/ /_/g' S1.csv | cut -d, -f1,10- | tr -d "\r" > S1._.csv

echo "Creating list of non-zero TCONS / TCGA Study relationship"
echo "Transcript_ID,Study_SampleType,Count" > S1.list.csv
awk 'BEGIN{FS=OFS=","}(NR==1){for(i=2;i<=NF;i++){k[i]=$i}}(NR>1){ for(i=2;i<=NF;i++){if($i>0){print $1,k[i],$i}}}' S1._.csv >> S1.list.csv



###tail -n +2 tmp5 | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> tmp13
###tail -n +2 virus_protein_TCONS_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $3,$1,$2,$4}' | sort -t, -k1,3 >> TCONS_virus_protein_bitscore.csv



#echo "Add virus description to table"
#echo "Rearrange columns and sort by TCONS"

##echo "Transcript_ID,virus,protein,bitscore" > tmp13
##join -t, tmp4 accession_tcons_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $3,$2,$1,$4}' | sort -t, -k1,3 >> tmp13
##wc -l accession_tcons_bitscore.csv tmp4 tmp13
##echo head tmp13
##head tmp13
#	Transcript_ID,virus,protein,bitscore
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4
#	TCONS_00000667,Human_gammaherpesvirus_4,YP_401658,25.8
#	TCONS_00000667,Human_herpesvirus_4_type_2,YP_001129455,25.8
#	TCONS_00000820,Human_alphaherpesvirus_1,YP_009137138,28.5
#	TCONS_00000820,Human_alphaherpesvirus_2,YP_009137215,27.3
#	TCONS_00000820,Human_alphaherpesvirus_3,NP_040188,26.9
#	TCONS_00002008,Human_alphaherpesvirus_3,NP_040188,26.2
#	TCONS_00002575,Human_papillomavirus_type_131,YP_004169279,25.8
#	TCONS_00003195,Human_betaherpesvirus_5,YP_081508,26.2


##echo "Transcript_ID,order,family,virus,protein,bitscore" > tmp13b
##join -t, tmp4b accession_tcons_bitscore.csv | awk 'BEGIN{FS=OFS=","}{print $5,$2,$3,$4,$1,$6}' | sort -t, -k1,5 >> tmp13b
##wc -l accession_tcons_bitscore.csv tmp4b tmp13b
##echo head tmp13b
##head tmp13b
#	Transcript_ID,order,family,virus,protein,bitscore
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,34.7
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion sertifer nucleopolyhedrovirus,YP_025159,32.3
#	TCONS_00000246,Unknown Order,Unknown Family,Pacmanvirus A23,YP_009361356,31.2
#	TCONS_00000463,Bunyavirales,,Carcinus maenas portunibunyavirus 1,YP_010839960,31.2
#	TCONS_00000463,Chitovirales,Poxviridae,Cowpox virus,NP_619804,33.5
#	TCONS_00000463,Chitovirales,Poxviridae,Ectromelia virus,NP_671527,32.7
#	TCONS_00000463,Chitovirales,Poxviridae,Horsepox virus,YP_010509227,33.5
#	TCONS_00000463,Chitovirales,Poxviridae,Murmansk poxvirus,YP_009408380,31.2




echo "Joining viral protein accessions and bitscores to S1 table list."

##join --header -t, tmp13 S1.list.csv > tmp6
##wc -l tmp13 S1.list.csv tmp6
##echo head tmp6
##head tmp6

#	Transcript_ID,virus,protein,bitscore,Study_SampleType,Count
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,BLCA_tumor,21
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,BRCA_tumor,4
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,CESC_tumor,17
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,COAD_tumor,3
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,DLBC_tumor,2
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,ESCA_tumor,7
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,HNSC_tumor,26
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,KIRC_tumor,3
#	TCONS_00000560,Human_rhinovirus_NAT001,YP_009505610,25.4,KIRP_tumor,1


##join --header -t, tmp13b S1.list.csv > tmp6b
##wc -l tmp13b S1.list.csv tmp6b
##echo head tmp6b
##head tmp6b

#	Transcript_ID,order,family,virus,protein,bitscore,Study_SampleType,Count
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,LUAD_tumor,5
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,STAD_tumor,1
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,TGCT_tumor,2
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,Testis_gtex,61
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,Tumor_Total,8
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,38.5,GTEx_Total,61
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,34.7,LUAD_tumor,5
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,34.7,STAD_tumor,1
#	TCONS_00000246,Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,34.7,TGCT_tumor,2






#	Not sure why I didn't do this in the beginning

echo "Transcript_ID,accession,bitscore" > tcons_accession_highestbitscore.csv
awk 'BEGIN{FS=OFS=","}{print $2,$1,$3}' accession_tcons_highestbitscore.csv | sort -t, -k1,3 >> tcons_accession_highestbitscore.csv

##	Done above now
##	TCONS_00000246-104|100-125
##	TCONS_00000246
##awk 'BEGIN{FS=OFS=","}{ split($2,a,"-"); print a[1],$1,$3}' accession_tcons_highestbitscore.csv | sort -t, -k1,3 | uniq >> tcons_accession_highestbitscore.csv


join --header -t, tcons_accession_highestbitscore.csv S1.list.csv > tcons_accession_highestbitscore_tcgastudy_count.csv
wc -l tcons_accession_highestbitscore.csv S1.list.csv tcons_accession_highestbitscore_tcgastudy_count.csv
echo head tcons_accession_highestbitscore_tcgastudy_count.csv
head tcons_accession_highestbitscore_tcgastudy_count.csv

#	Transcript_ID,accession,bitscore,Study_SampleType,Count
#	TCONS_00000246,NP_042110,23.5,LUAD_tumor,5
#	TCONS_00000246,NP_042110,23.5,STAD_tumor,1
#	TCONS_00000246,NP_042110,23.5,TGCT_tumor,2
#	TCONS_00000246,NP_042110,23.5,Testis_gtex,61
#	TCONS_00000246,NP_042110,23.5,Tumor_Total,8
#	TCONS_00000246,NP_042110,23.5,GTEx_Total,61
#	TCONS_00000246,NP_042240,23.9,LUAD_tumor,5
#	TCONS_00000246,NP_042240,23.9,STAD_tumor,1
#	TCONS_00000246,NP_042240,23.9,TGCT_tumor,2







echo "Drop TCONS Transcript ID and Count"


##echo "Keeping just virus,protein,Study_SampleType,bitscore"
##awk 'BEGIN{FS=OFS=","}{print $2,$3,$5,$4}' tmp6 > tmp7
##echo head tmp7
##head tmp7

#head -3 tmp7
#virus,protein,Study_SampleType,bitscore
#HHV5,YP_081561,LUAD_tumor,24.6
#HHV5,YP_081561,STAD_tumor,24.6

#	virus,protein,Study_SampleType,bitscore
#	Human_rhinovirus_NAT001,YP_009505610,BLCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,BRCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,CESC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,COAD_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,DLBC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,ESCA_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,HNSC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,KIRC_tumor,25.4
#	Human_rhinovirus_NAT001,YP_009505610,KIRP_tumor,25.4

##echo "Keeping just order,family,virus,protein,Study_SampleType,bitscore"
##awk 'BEGIN{FS=OFS=","}{print $2,$3,$4,$5,$7,$6}' tmp6b > tmp7b
##echo head tmp7b
##head tmp7b

#	order,family,virus,protein,Study_SampleType,bitscore
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,LUAD_tumor,38.5
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,STAD_tumor,38.5
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,TGCT_tumor,38.5
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,Testis_gtex,38.5
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,Tumor_Total,38.5
#	Lefavirales,Baculoviridae,Neodiprion abietis nucleopolyhedrovirus,YP_667900,GTEx_Total,38.5
#	Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,LUAD_tumor,34.7
#	Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,STAD_tumor,34.7
#	Lefavirales,Baculoviridae,Neodiprion lecontei nucleopolyhedrovirus,YP_025249,TGCT_tumor,34.7

echo "Keeping just protein,Study_SampleType,bitscore"
awk 'BEGIN{FS=OFS=","}{print $2,$4,$3}' tcons_accession_highestbitscore_tcgastudy_count.csv > accession_tcgastudy_bitscore.csv
echo head accession_tcgastudy_bitscore.csv
head accession_tcgastudy_bitscore.csv
#	accession,Study_SampleType,bitscore
#	NP_042110,LUAD_tumor,23.5
#	NP_042110,STAD_tumor,23.5
#	NP_042110,TGCT_tumor,23.5
#	NP_042110,Testis_gtex,23.5
#	NP_042110,Tumor_Total,23.5
#	NP_042110,GTEx_Total,23.5
#	NP_042240,LUAD_tumor,23.9
#	NP_042240,STAD_tumor,23.9
#	NP_042240,TGCT_tumor,23.9





##echo "select virus,protein,Study_SampleType,bitscore and sort by bitscore so can select highest"
##
##echo "virus,protein,Study_SampleType,bitscore" > tmp8
##tail -n +2 tmp7 | sort -t, -k1,3 -k4nr >> tmp8
##echo head tmp8
##head tmp8

#	virus,protein,Study_SampleType,bitscore
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BRCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,CESC_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,DLBC_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,27.7

##echo "select order,family,virus,protein,Study_SampleType,bitscore and sort by bitscore so can select highest"
##
##echo "order,family,virus,protein,Study_SampleType,bitscore" > tmp8b
##tail -n +2 tmp7b | sort -t, -k1,5 -k6nr >> tmp8b
##echo head tmp8b
##head tmp8b

#	order,family,virus,protein,Study_SampleType,bitscore
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,GTEx_Total,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,GTEx_Total_without_Testis,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,LAML_tumor,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,SARC_tumor,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,Skin_gtex,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,Tumor_Total,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,CESC_tumor,37.7
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,ESCA_tumor,37.7
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,GTEx_Total,37.7

echo "select protein,Study_SampleType,bitscore and sort by bitscore so can select highest"

echo "protein,Study_SampleType,bitscore" > accession_tcgastudy_bitscore_sorted.csv
tail -n +2 accession_tcgastudy_bitscore.csv | sort -t, -k1,2 -k3nr >> accession_tcgastudy_bitscore_sorted.csv
echo head accession_tcgastudy_bitscore_sorted.csv
head accession_tcgastudy_bitscore_sorted.csv

#	protein,Study_SampleType,bitscore
#	NP_042045,ACC_tumor,22.7
#	NP_042045,BLCA_tumor,22.7
#	NP_042045,Colon_gtex,22.7
#	NP_042045,GTEx_Total,22.7
#	NP_042045,GTEx_Total_without_Testis,22.7
#	NP_042045,LIHC_tumor,22.7
#	NP_042045,LUAD_tumor,22.7
#	NP_042045,TGCT_tumor,22.7
#	NP_042045,Tumor_Total,22.7







##echo "select highest (first actually, so better be sorted) bitscore for virus,protein,Study_SampleType relationship"
##
##echo "virus,protein,Study_SampleType,bitscore" > tmp9
##tail -n +2 tmp8 | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3] == "" ){k[$1][$2][$3]=$4;print $1,$2,$3,$4}' >> tmp9
##echo head tmp9
##head tmp9

#	virus,protein,Study_SampleType,bitscore
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BLCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,BRCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,Brain_gtex,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,CESC_tumor,27.7
#	Human_T-cell_leukemia_virus_type_I,NP_057860,DLBC_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,ESCA_tumor,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,GTEx_Total,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,GTEx_Total_without_Testis,28.5
#	Human_T-cell_leukemia_virus_type_I,NP_057860,HNSC_tumor,27.7


##echo "select highest (first actually, so better be sorted) bitscore for order,family,virus,protein,Study_SampleType relationship"
##
##echo "order,family,virus,protein,Study_SampleType,bitscore" > tmp9b
##tail -n +2 tmp8b | awk 'BEGIN{FS=OFS=","}( k[$1][$2][$3][$4][$5] == "" ){k[$1][$2][$3][$4][$5]=$6;print $1,$2,$3,$4,$5,$6}' >> tmp9b
##echo head tmp9b
##head tmp9b

#	order,family,virus,protein,Study_SampleType,bitscore
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,GTEx_Total,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,GTEx_Total_without_Testis,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,LAML_tumor,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,SARC_tumor,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,Skin_gtex,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426516,Tumor_Total,42.4
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,CESC_tumor,37.7
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,ESCA_tumor,37.7
#	Algavirales,Phycodnaviridae,Acanthocystis turfacea chlorella virus 1,YP_001426671,GTEx_Total,37.7

echo "select highest (first actually, so better be sorted) bitscore for protein,Study_SampleType relationship"

echo "protein,Study_SampleType,bitscore" > accession_tcgastudy_highestbitscore.csv
tail -n +2 accession_tcgastudy_bitscore_sorted.csv | awk 'BEGIN{FS=OFS=","}( k[$1][$2] == "" ){k[$1][$2]=$3;print $1,$2,$3}' >> accession_tcgastudy_highestbitscore.csv
echo head accession_tcgastudy_highestbitscore.csv
head accession_tcgastudy_highestbitscore.csv

#	protein,Study_SampleType,bitscore
#	NP_042045,ACC_tumor,22.7
#	NP_042045,BLCA_tumor,22.7
#	NP_042045,Colon_gtex,22.7
#	NP_042045,GTEx_Total,22.7
#	NP_042045,GTEx_Total_without_Testis,22.7
#	NP_042045,LIHC_tumor,22.7
#	NP_042045,LUAD_tumor,22.7
#	NP_042045,TGCT_tumor,22.7
#	NP_042045,Tumor_Total,22.7











echo "Fill in table list S1 but with bitscores"


##awk 'BEGIN{FS=OFS=",";split("ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose_Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary_Gland_gtex,Adrenal_Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood_Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small_Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix_Uteri_gtex,Bladder_gtex,Fallopian_Tube_gtex,Tumor_Total,Normal_Total,GTEx_Total,GTEx_Total_without_Testis",cols,",")}
##(NR>1){bitscores[$1][$2][$3]=$4}
##END{
##	s="virus,protein"
##	for(c in cols){
##		s=s","cols[c]
##	}print s
##
##	for(v in bitscores){
##		for(p in bitscores[v]){
##			s=v","p
##			for(c in cols){
##				if( bitscores[v][p][cols[c]]>0 ){
##					s=s","bitscores[v][p][cols[c]]
##				}else{
##					s=s","0
##				}
##			}
##			print s
##		}
##	}
##}' tmp9 > tmp10
##
##echo "head tmp10 | cut -c1-150"
##head tmp10 | cut -c1-150
##
##
##
##
##
##awk 'BEGIN{FS=OFS=",";columns="ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose_Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary_Gland_gtex,Adrenal_Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood_Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small_Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix_Uteri_gtex,Bladder_gtex,Fallopian_Tube_gtex,Tumor_Total,Normal_Total,GTEx_Total,GTEx_Total_without_Testis";split(columns,cols,",")}
##(NR>1){bitscores[$1][$2][$3][$4][$5]=$6}
##END{
##	print "order,family,virus,protein,"columns
##	#s="order,family,virus,protein"columns
##	#for(c in cols){
##	#	s=s","cols[c]
##	#}print s
##
##	for(o in bitscores){
##	for(f in bitscores[o]){
##	for(v in bitscores[o][f]){
##	for(p in bitscores[o][f][v]){
##		s=o","f","v","p
##		for(c in cols){
##			if( bitscores[o][f][v][p][cols[c]]>0 ){
##				s=s","bitscores[o][f][v][p][cols[c]]
##			}else{
##				s=s","0
##			}
##		}
##		print s
##	} } } }
##}' tmp9b > tmp10b
##echo "head tmp10b | cut -c1-150"
##head tmp10b | cut -c1-150




awk 'BEGIN{FS=OFS=",";columns="ACC_tumor,ACC_normal,BLCA_tumor,BLCA_normal,BRCA_tumor,BRCA_normal,CESC_tumor,CESC_normal,CHOL_tumor,CHOL_normal,COAD_tumor,COAD_normal,DLBC_tumor,DLBC_normal,ESCA_tumor,ESCA_normal,GBM_tumor,GBM_normal,HNSC_tumor,HNSC_normal,KICH_tumor,KICH_normal,KIRC_tumor,KIRC_normal,KIRP_tumor,KIRP_normal,LAML_tumor,LAML_normal,LGG_tumor,LGG_normal,LIHC_tumor,LIHC_normal,LUAD_tumor,LUAD_normal,LUSC_tumor,LUSC_normal,MESO_tumor,MESO_normal,OV_tumor,OV_normal,PAAD_tumor,PAAD_normal,PCPG_tumor,PCPG_normal,PRAD_tumor,PRAD_normal,READ_tumor,READ_normal,SARC_tumor,SARC_normal,SKCM_tumor,SKCM_normal,STAD_tumor,STAD_normal,TGCT_tumor,TGCT_normal,THCA_tumor,THCA_normal,THYM_tumor,THYM_normal,UCEC_tumor,UCEC_normal,UCS_tumor,UCS_normal,UVM_tumor,UVM_normal,Adipose_Tissue_gtex,Ovary_gtex,Vagina_gtex,Breast_gtex,Salivary_Gland_gtex,Adrenal_Gland_gtex,Spleen_gtex,Esophagus_gtex,Prostate_gtex,Testis_gtex,Nerve_gtex,Brain_gtex,Thyroid_gtex,Lung_gtex,Skin_gtex,Blood_gtex,Blood_Vessel_gtex,Pituitary_gtex,Heart_gtex,Colon_gtex,Pancreas_gtex,Stomach_gtex,Muscle_gtex,Small_Intestine_gtex,Uterus_gtex,Kidney_gtex,Liver_gtex,Cervix_Uteri_gtex,Bladder_gtex,Fallopian_Tube_gtex,Tumor_Total,Normal_Total,GTEx_Total,GTEx_Total_without_Testis";split(columns,cols,",")}
(NR>1){bitscores[$1][$2]=$3}
END{
	print "protein,"columns

	for(p in bitscores){
		s=p
		for(c in cols){
			if( bitscores[p][cols[c]]>0 ){
				s=s","bitscores[p][cols[c]]
			}else{
				s=s","0
			}
		}
		print s
	}
}' accession_tcgastudy_highestbitscore.csv > tmp10c
echo "head tmp10c | cut -c1-150"
head tmp10c | cut -c1-150



echo "Sorting S1 bitscore table"

##head -1 tmp10 > tmp11
##tail -n +2 tmp10 | sort -t, -k1,2 >> tmp11
##echo "head tmp11 | cut -c1-150"
##head tmp11 | cut -c1-150
##
##head -1 tmp10b > tmp11b
##tail -n +2 tmp10b | sort -t, -k1,4 >> tmp11b
##echo "head tmp11b | cut -c1-150"
##head tmp11b | cut -c1-150

head -n  1 tmp10c > tmp11c
tail -n +2 tmp10c | sort -t, -k1,1 >> tmp11c
echo "head tmp11c | cut -c1-150"
head tmp11c | cut -c1-150






cp tmp11c S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.${TILESIZE}-${OVERLAP}.accession_only.blastp.e${EVALUE}.csv

join -t, --header /francislab/data1/refs/AllergenOnline/AllergenGroups.csv  \
	S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.${TILESIZE}-${OVERLAP}.accession_only.blastp.e${EVALUE}.csv \
	> S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.${TILESIZE}-${OVERLAP}.extra.blastp.e${EVALUE}.csv




#	#	Only virus has the tmp4c
#	
#	
#	
#	join --header -t, tmp4c tmp11c > tmp12c
#	wc -l tmp4c tmp11c tmp12c
#	echo "head tmp12c | cut -c1-150"
#	head tmp12c | cut -c1-150
#	
#	
#	
#	
#	echo "Reordering the joined columns"
#	
#	#awk 'BEGIN{FS=OFS=","}{x=$1;$1=$2;$2=$3;$3=$4;$4=x;print}' tmp12c > tmp14c
#	awk 'BEGIN{FS=OFS=","}{x=$1;$1=$2;$2=$3;$3=$4;$4=$5;$5=$6;$6=$7;$7=$8;$8=x;print}' tmp12c > tmp14c
#	echo "head tmp14c | cut -c1-150"
#	head tmp14c | cut -c1-150
#	
#	
#	cp tmp14c S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.extra.${TILESIZE}-${OVERLAP}.blastp.e${EVALUE}.csv


#cp tmp11 S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.csv
#./S1_virus_protein_bitscore.heatmap.py S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.csv

#../../../scripts/

#	TEProf2_Heatmap_Maker.Rmd S1_${TCONS_FASTA_BASE}_fragments_in_${PROTEIN_FASTA_BASE}.blastp.e${EVALUE}.csv


