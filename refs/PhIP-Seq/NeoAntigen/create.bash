#!/usr/bin/env bash


\rm *proteins.faa orf* cterm* protein_tiles* oligos* tmp*csv

cat << EOF > proteins.faa
>Manual_HER2:654-662
IISAVVGIL
>Manual_HER2:366-379
KIFGSLAFL
>Manual_IDH1NeoEpitope
PIIIGHHAYGDQYH
>Manual_EGFR-Deletion
LEEKKGNYVVTDH
>FRa
MAQRMTTQLLLLLLVWVAVVGEAQTRIAWARTELLNVCMNAKHHKEKPGPEDKLHEQCRPWRKNACCSTNSTQEAHKDVSYLYRFNWNHCGEMAPACKRHFIQDTCLYECSPNLGPWIQQVDQSWRKERVLNVPLCKEDCEQWWEDCRTSYTCKSNWHKGWNWTSGFNKCAVGQACPQFHFYFPTPTVLCNEIWTHSYKVSNYSRGSGRCIQMWFDPAQGNPNNEEVARFYAAMSGAGPWAALPFLLSLALMLWLLLS
EOF

echo ">EGFR_Complete" >> proteins.faa
tail -n +2 genes_for_hotspots/P00533.fasta | tr -d "\n" >> proteins.faa
echo >> proteins.faa

#	EGFR Hotspot original and mutated sequences
EGFR_selection.bash >> proteins.faa

awk -F, '(NR==FNR){ids[$1]++}(NR!=FNR){if(ids[$1])print $2}' s41586-020-1969-6-CNS-GBM.txt neopeptides_shi.csv | sort | uniq | awk '{print ">NeoPeptidesShi_"$0;print $0}' >> proteins.faa

tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">Darwin_"$0; print $0}' >> proteins.faa

#	Hotspot original and mutated sequences
./extract_sequences_and_mutate.bash >> proteins.faa

tail -n +2 13059_2023_3005_MOESM1_ESM-S5.csv | cut -d, -f3 | sort | uniq | awk '{print ">NeoEpitope_"$0; print $0}' >> proteins.faa

tail -n +2 41467_2019_13035_moesm9_esm.csv | head -40 | cut -d, -f1 | sort | uniq | awk '{print ">REdiscoverTE_"$0; print $0}' >> proteins.faa

#	No Normal, No GTEx without Testis, 1+ for GBM or LGG
./BRCA_LAML_GBM_LGG_TCONS.bash >> proteins.faa

zcat ../VirScan/VIR3_clean.csv.gz | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")";split("6977,125114,20956,17599,33024,63941,15935,52913,22261,7041,81003,121343,6385,69594,96041,79421,34208,71294,53070,4340",a,",");for(i in a){ids[a[i]]=1}}($17 in ids){ print ">VIR3Common_"$17;print $21 }' >> proteins.faa

cat proteins.faa | paste - - | sort | awk '{print $1;print $2}' > sorted_proteins.faa
cat sorted_proteins.faa | paste - - | uniq | awk '{if(!seen[$2]){seen[$2]++;print $1;print $2}}' > unique_proteins.faa

grep -c "^>" proteins.faa unique_proteins.faa


#	Not using cd-hit because it removes tiles without really linking them.
#	At worst, this would mean that we've wasted some sequences.

phip_seq_create_tiles.bash -t 56 -o 28 -i unique_proteins.faa


#	The VIR3Common sequences are 56AA. 
#	The script adds once as expected then again with a STOP codon shifted once to the left.
#	Dropping those "duplicates"
sed -i -e '/^>VIR3Common.*|CTERM|STOP/,+1 d' oligos-ref-56-28.fasta

#	swap out several specific, frame dependent rare e coli codons with more prefered ones
./frame_swap.bash

#	Compare the original and swapped codons proteins to make sure the translated protein will be the same.
pepsyn translate oligos-ref-56-28.fasta oligos-ref-56-28.proteins.fasta
pepsyn translate tmp.fasta tmp.proteins.fasta
diff tmp.proteins.fasta oligos-ref-56-28.proteins.fasta

#	Move out originals and replace with the swapped versions
mv oligos-ref-56-28.fasta oligos-ref-56-28.orig.fasta
mv oligos-56-28.fasta oligos-56-28.orig.fasta
mv tmp.fasta oligos-ref-56-28.fasta

#	Add the prefix and suffix to each read
sed -e '2~2s/^/AGGAATTCCGCTGCGT/' -e '2~2s/$/GCCTGGAGACGCCATC/' oligos-ref-56-28.fasta > oligos-56-28.fasta 

#	Extract just the sequences
grep -vs "^>" oligos-??-??.fasta > oligos.sequences.txt
#	and count them
wc -l oligos.sequences.txt

