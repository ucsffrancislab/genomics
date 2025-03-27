
#	PhIP-Seq/NeoAntigen



2025_0124_cross_analysis_summary_ha_mf_ag.tsv is a table of HLA types and peptides.
Peptides are in the tsv multiple times for multiple HLA types.
Extract a unique list of peptides and convert to fasta file.
Then prep phip seq tiles



tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | head


cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | wc -l 
172

cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null > assembled_peptides.txt


wc -l assembled_peptides.txt 
172 assembled_peptides.txt

awk '{print ">"NR;print $0}' assembled_peptides.txt > assembled_peptides.faa


tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq > peptides.txt



./align_peptides.py -s peptides.txt -r assembled_peptides.txt > aligned_peptides.sam

samtools sort -o aligned_peptides.bam aligned_peptides.sam 

samtools index aligned_peptides.bam 


