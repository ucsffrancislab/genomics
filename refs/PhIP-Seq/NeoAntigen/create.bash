#!/usr/bin/env bash

echo "Don't run this anymore."

exit


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
>Manual_EGFRDeletion
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


#	Adds 43 tiles
echo ">EGFRComplete" >> proteins.faa
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



#grep "Human herpes" /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.join_sorted.csv | awk -F, '{print ">VirScanPublicEpitope_"$1;print $3}' >> proteins.faa
grep "Human herpes" /francislab/data1/refs/PhIP-Seq/VirScan/public_epitope_annotations.join_sorted.csv | awk -F, '{gsub(/ /,"-",$2);print ">VirScanPublicEpitope_"$2"_"$1;print $3}' >> proteins.faa


#	All VZV (HHV3) proteins - 2538 tiles
for fa in /francislab/data1/refs/refseq/viral-20231129/viral.protein/*Human_alphaherpesvirus_3*fa ; do 
#head -1 $fa | sed 's/^>/>RefSeqVZV_/' >> proteins.faa
head -1 $fa | sed -e 's/^>/>RefSeqVZV_/' -e 's/_Human_alphaherpesvirus_3//' >> proteins.faa
tail -n +2 ${fa} | tr -d "\n" >> proteins.faa
echo >> proteins.faa
done

#	10639 oligos.sequences.txt

#	only room for about 1300 CMV tiles. All proteins produce about 4500.
#for fa in /francislab/data1/refs/refseq/viral-20231129/viral.protein/*Human_betaherpesvirus_5*fa ; do 
#head -1 $fa | sed 's/^>/>CMV_/' >> proteins.faa
#tail -n +2 ${fa} | tr -d "\n" >> proteins.faa
#echo >> proteins.faa
#done

#	CMV is HHV5
#	Selecting those tiles found to be most significant in glioma case / control comparison
join --header -t, <( grep ",Human herpesvirus 5," /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim-case-control-Prop_test_results-Z-0-sex-F.csv | head -216 | cut -d, -f1 | sort | sed '1iid' ) /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_peptide.for_joining.csv | tail -n +2 > tmp.csv
join --header -t, <( grep ",Human herpesvirus 5," /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/out.12356/Multiplate_Peptide_Comparison-Counts.normalized.normalized.subtracted.trim-case-control-Prop_test_results-Z-0-sex-M.csv | head -216 | cut -d, -f1 | sort | sed '1iid' ) /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_peptide.for_joining.csv | tail -n +2 >> tmp.csv
sort -t, -k1,1 tmp.csv | uniq | sed -e 's/^/>VirScanCMV_/' -e 's/,/\n/' >> proteins.faa




#	10
#	6977   Human respiratory syncytial virus    0.0     263.0
#	125114 Streptococcus dysgalactiae           0.0     267.0
#	20956  Human herpesvirus 4                  0.0     281.0
#	17599  Human respiratory syncytial virus    0.0     284.0
#	33024  Human herpesvirus 4                  0.0     303.0
#	63941  Enterovirus B                        0.0     307.0
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
#	79421  Hepatitis B virus                                     0.0     207.0
#	34208  Human herpesvirus 5                                   0.0     210.0
#	71294  Camelpox virus                                        0.0     219.0
#	53070  Human herpesvirus 4                                   0.0     226.0
#	4340   Chapare virus                                         0.0     228.0

join --header -t, VIR3Common.txt /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_peptide.for_joining.csv | tail -n +2 | sed -e 's/^/>VirScanCommon_/' -e 's/,/\n/' >> proteins.faa



cat proteins.faa | paste - - | sort | awk '{print $1;print $2}' > sorted_proteins.faa
cat sorted_proteins.faa | paste - - | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' > unique_proteins.faa

grep -c "^>" proteins.faa unique_proteins.faa


#	Not using cd-hit because it removes tiles without really linking them.
#	At worst, this would mean that we've wasted some sequences.


phip_seq_create_tiles.bash -t ${TILESIZE} -o ${OVERLAP} -i unique_proteins.faa



#	swap out several specific, frame dependent rare e coli codons with more prefered ones
./frame_swap.bash ${TILESIZE} ${OVERLAP}

#	Check the number of changes
sdiff -sd oligos-ref-${TILESIZE}-${OVERLAP}.fasta tmp.fasta | wc -l

#	Compare the original and swapped codons proteins to make sure the translated protein will be the same.
pepsyn translate oligos-ref-${TILESIZE}-${OVERLAP}.fasta oligos-ref-${TILESIZE}-${OVERLAP}.proteins.fasta
pepsyn translate tmp.fasta tmp.proteins.fasta
diff tmp.proteins.fasta oligos-ref-${TILESIZE}-${OVERLAP}.proteins.fasta
diff tmp.proteins.fasta protein_tiles-${TILESIZE}-${OVERLAP}.fasta

#	Move out originals and replace with the swapped versions
mv oligos-ref-${TILESIZE}-${OVERLAP}.fasta oligos-ref-${TILESIZE}-${OVERLAP}.orig.fasta
mv oligos-${TILESIZE}-${OVERLAP}.fasta oligos-${TILESIZE}-${OVERLAP}.orig.fasta
mv tmp.fasta oligos-ref-${TILESIZE}-${OVERLAP}.fasta


#	Do it again to check that it was actually done.
./frame_swap.bash ${TILESIZE} ${OVERLAP}

#	Check the number of changes again. This should be 0.
sdiff -sd oligos-ref-${TILESIZE}-${OVERLAP}.fasta tmp.fasta | wc -l


#	Add the prefix and suffix to each read
sed -e '2~2s/^/AGGAATTCCGCTGCGT/' -e '2~2s/$/GCCTGGAGACGCCATC/' oligos-ref-${TILESIZE}-${OVERLAP}.fasta > oligos-${TILESIZE}-${OVERLAP}.fasta

grep -c "^>" sorted_proteins.faa

grep -c "^>" unique_proteins.faa

#	Extract just the sequences
grep -vs "^>" oligos-${TILESIZE}-${OVERLAP}.fasta > oligos.sequences.txt
#	and count them
wc -l oligos.sequences.txt

head -1 oligos.sequences.txt | awk '{print length($0)}'

cut -c1-16 oligos.sequences.txt | uniq -c

cut -c101- oligos.sequences.txt | uniq -c

grep "^>" oligos-ref-${TILESIZE}-${OVERLAP}.fasta | cut -d_ -f1 | cut -d\| -f1 | sort | uniq -c

