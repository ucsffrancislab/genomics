

#	20230426-PanCancerAntigens


https://www.nature.com/articles/s41588-023-01349-3



https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-023-01349-3/MediaObjects/41588_2023_1349_MOESM1_ESM.pdf


https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-023-01349-3/MediaObjects/41588_2023_1349_MOESM3_ESM.xlsx



```
tail -n +3 41588_2023_1349_MOESM3_ESM/S2.csv | awk -F, '{print $1}' > S2_TranscriptID.txt


grep -f S2_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12;print $13}'  | sed 's/ /_/' > S10_S2_ProteinSequences.fa

grep -f S2_TranscriptID.txt 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$7,$9,$10;print $13}'  | sed 's/ /_/' > S10_S2_ProteinSequences.fa


makeblastdb -in S10_S2_ProteinSequences.fa -input_type fasta -dbtype prot -title S10_S2_ProteinSequences -parse_seqids



tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | awk 'BEGIN{FS=",";OFS="_"}($13!="None"){print ">"$1,$2,$7,$9,$10;print $13}' | sed 's/ /_/' > S10_All_ProteinSequences.fa


makeblastdb -in S10_All_ProteinSequences.fa -input_type fasta -dbtype prot -out S10_All_ProteinSequences -title S10_All_ProteinSequences -parse_seqids

```



