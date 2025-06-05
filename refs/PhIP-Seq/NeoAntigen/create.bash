#!/usr/bin/env bash

set -v


#TILESIZE=56
#OVERLAP=28
#TILESIZE=38
#OVERLAP=19
TILESIZE=28
OVERLAP=14

\rm *proteins.faa orf* cterm* protein_tiles* oligos* tmp*

cat << EOF > proteins.faa
>Manual_HER2:654-662
IISAVVGIL
>Manual_HER2:366-379
KIFGSLAFL
>Manual_IDH1NeoEpitope
PIIIGHHAYGDQYH
>Manual_EGFR-Deletion
LEEKKGNYVVTDH
>FRa_31
RTELLNVCMNAKHHKEK
>FRa_57
QCRPWRKNACCSTNT
>FRa_57_Alt
QCRPWRKNACCSTNST
>FRa_77
KDVSYLYRFNWNHCGEMA
>FRa_114
LGPWIQQVDQSWRKERV
>FRa_239
PWAAWPFLLSLALMLLWL
>FRa_239_Alt
PWAALPFLLSLALMLWLL
>FRa
MAQRMTTQLLLLLLVWVAVVGEAQTRIAWARTELLNVCMNAKHHKEKPGPEDKLHEQCRPWRKNACCSTNSTQEAHKDVSYLYRFNWNHCGEMAPACKRHFIQDTCLYECSPNLGPWIQQVDQSWRKERVLNVPLCKEDCEQWWEDCRTSYTCKSNWHKGWNWTSGFNKCAVGQACPQFHFYFPTPTVLCNEIWTHSYKVSNYSRGSGRCIQMWFDPAQGNPNNEEVARFYAAMSGAGPWAALPFLLSLALMLWLLLS
EOF

#>FRa
#MAQRMTTQLLLLLLVWVAVVGEAQTRIAWARTELLNVCMNAKHHKEKPGPEDKLHEQCRPWRKNACCSTNSTQEAHKDVSYLYRFNWNHCGEMAPACKRHFIQDTCLYECSPNLGPWIQQVDQSWRKERVLNVPLCKEDCEQWWEDCRTSYTCKSNWHKGWNWTSGFNKCAVGQACPQFHFYFPTPTVLCNEIWTHSYKVSNYSRGSGRCIQMWFDPAQGNPNNEEVARFYAAMSGAGPWAALPFLLSLALMLWLLLS

#	FRa 5 subsequences (the whole above produces 9 so this would save 4) currently 35 over
#RTELLNVCMNAKHHKEK
#QCRPWRKNACCSTNT
#KDVSYLYRFNWNHCGEMA
#LGPWIQQVDQSWRKERV
#PWAAWPFLLSLALMLLWL


#	Adds 43 tiles
echo ">EGFR_Complete" >> proteins.faa
tail -n +2 genes_for_hotspots/P00533.fasta | tr -d "\n" >> proteins.faa
echo >> proteins.faa

#	EGFR Hotspot original and mutated sequences
EGFR_selection.bash >> proteins.faa



#	Pan-cancer analysis of whole genomes
#	https://www.nature.com/articles/s41586-020-1969-6
#		s41586-020-1969-6-CNS-GBM.txt
#
#	Comprehensive analysis of neoantigens derived from structural variation across whole genomes from 2528 tumors
#	https://genomebiology.biomedcentral.com/articles/10.1186/s13059-023-03005-9
#		neopeptides_shi.csv
#
#awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS-GBM.txt neopeptides_shi.csv | sort | uniq | awk '{print ">NeoPeptidesShi_"$0;print $0}' >> proteins.faa
awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS.txt neopeptides_shi.csv | sort | uniq | awk '{print ">NeoPeptidesShi_"$0;print $0}' >> proteins.faa
#	Breast adds : 21632 - 7973
#awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-Breast.txt neopeptides_shi.csv | sort | uniq | awk '{print ">NeoPeptidesShi_"$0;print $0}' >> proteins.faa

#	From Darwin
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">Darwin_"$0; print $0}' >> proteins.faa


#	Fundamental immune–oncogenicity trade-offs define driver mutation fitness
#	https://www.nature.com/articles/s41586-022-04696-z
#	Manually generated the csv from within the paper
#	Hotspot original and mutated sequences
./extract_sequences_and_mutate.bash >> proteins.faa


#	Comprehensive analysis of neoantigens derived from structural variation across whole genomes from 2528 tumors
#	https://pmc.ncbi.nlm.nih.gov/articles/PMC10351168/
tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{print ">NeoEpitope_"$0; print $0}' >> proteins.faa


tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{print ">REdiscoverTE_"$0; print $0}' >> proteins.faa


#	Pan-cancer analysis identifies tumor-specific antigens derived from transposable elements
#	https://www.nature.com/articles/s41588-023-01349-3
#	No Normal, No GTEx without Testis, 1+ for GBM or LGG
./BRCA_LAML_GBM_LGG_TCONS.bash >> proteins.faa


#	10
#	6977   Human respiratory syncytial virus    0.0     263.0
#	125114 Streptococcus dysgalactiae           0.0     267.0
#	20956  Human herpesvirus 4                  0.0     281.0
#	17599  Human respiratory syncytial virus    0.0     284.0
#	33024  Human herpesvirus 4                  0.0     303.0
#	63941  Enterovirus B                        0.0     307.0 ---
#	15935  Cowpox virus                         0.0     340.0
#	52913  Human herpesvirus 4                  0.0     355.0
#	22261  Human respiratory syncytial virus    0.0     374.0
#	7041   Human respiratory syncytial virus    0.0     400.0
#
#	1
#	81003  Influenza A virus                                     0.0     195.0
#	121343 Cryptomeria japonica (Japanese cedar) (Cupressu...    0.0     197.0
#	6385   Hepatitis E virus                                     0.0     197.0
#	69594  Parainfluenza virus 5                                 0.0     198.0
#	96041  Influenza A virus                                     0.0     200.0
#	79421  Hepatitis B virus                                     0.0     207.0 ---
#	34208  Human herpesvirus 5                                   0.0     210.0
#	71294  Camelpox virus                                        0.0     219.0
#	53070  Human herpesvirus 4                                   0.0     226.0
#	4340   Chapare virus                                         0.0     228.0

zcat ../VirScan/VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")";split("6977,125114,20956,17599,33024,63941,15935,52913,22261,7041,81003,121343,6385,69594,96041,79421,34208,71294,53070,4340",a,",");for(i in a){ids[a[i]]=1}}($17 in ids){ print ">VIR3Common_"$17;print $21 }' >> proteins.faa
#zcat ../VirScan/VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")";split("63941,15935,52913,22261,7041,79421,34208,71294,53070,4340",a,",");for(i in a){ids[a[i]]=1}}($17 in ids){ print ">VIR3Common_"$17;print $21 }' >> proteins.faa

cat proteins.faa | paste - - | sort | awk '{print $1;print $2}' > sorted_proteins.faa
cat sorted_proteins.faa | paste - - | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' > unique_proteins.faa

grep -c "^>" proteins.faa unique_proteins.faa


#	Not using cd-hit because it removes tiles without really linking them.
#	At worst, this would mean that we've wasted some sequences.


phip_seq_create_tiles.bash -t ${TILESIZE} -o ${OVERLAP} -i unique_proteins.faa


#	The VIR3Common sequences are 56AA.
#	The script adds once as expected then again with a STOP codon shifted once to the left.
#	Dropping those "duplicates"
sed -i -e '/^>VIR3Common.*|CTERM|STOP/,+1 d' oligos-ref-${TILESIZE}-${OVERLAP}.fasta

#	swap out several specific, frame dependent rare e coli codons with more prefered ones
./frame_swap.bash ${TILESIZE} ${OVERLAP}

#	Compare the original and swapped codons proteins to make sure the translated protein will be the same.
pepsyn translate oligos-ref-${TILESIZE}-${OVERLAP}.fasta oligos-ref-${TILESIZE}-${OVERLAP}.proteins.fasta
pepsyn translate tmp.fasta tmp.proteins.fasta
diff tmp.proteins.fasta oligos-ref-${TILESIZE}-${OVERLAP}.proteins.fasta

#	Move out originals and replace with the swapped versions
mv oligos-ref-${TILESIZE}-${OVERLAP}.fasta oligos-ref-${TILESIZE}-${OVERLAP}.orig.fasta
mv oligos-${TILESIZE}-${OVERLAP}.fasta oligos-${TILESIZE}-${OVERLAP}.orig.fasta
mv tmp.fasta oligos-ref-${TILESIZE}-${OVERLAP}.fasta

#	Add the prefix and suffix to each read
sed -e '2~2s/^/AGGAATTCCGCTGCGT/' -e '2~2s/$/GCCTGGAGACGCCATC/' oligos-ref-${TILESIZE}-${OVERLAP}.fasta > oligos-${TILESIZE}-${OVERLAP}.fasta

#	Extract just the sequences
grep -vs "^>" oligos-${TILESIZE}-${OVERLAP}.fasta > oligos.sequences.txt
#	and count them
wc -l oligos.sequences.txt

grep "^>" oligos-ref-${TILESIZE}-${OVERLAP}.fasta | cut -d_ -f1 | cut -d\| -f1 | sort | uniq -c
