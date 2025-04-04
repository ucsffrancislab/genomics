
#	PhIP-Seq/NeoAntigen


2025_0124_cross_analysis_summary_ha_mf_ag.tsv is a table of HLA types and peptides.
Peptides are in the tsv multiple times for multiple HLA types.
Extract a unique list of peptides and convert to fasta file.
Then prep phip seq tiles


```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | head

cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | wc -l 
#	172

cat sequences.txt  | assemble_peptides.py 2> /dev/null  | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null | assemble_peptides.py 2> /dev/null > assembled_peptides.txt

wc -l assembled_peptides.txt 
#172 assembled_peptides.txt

awk '{print ">"NR;print $0}' assembled_peptides.txt > assembled_peptides.faa

tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq > peptides.txt

./align_peptides.py -s peptides.txt -r assembled_peptides.txt > aligned_peptides.sam

samtools sort -o aligned_peptides.bam aligned_peptides.sam 

samtools index aligned_peptides.bam 
```

Moved all into assemble/



##	20250401


Prep libraries for multiple lengths

Here is a count of each peptide length.
```
awk '{print length($0)}' assemble/peptides.txt | sort -n | uniq -c
    762 8
    823 9
    631 10
    484 11
```

Separate into files by length.
```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">"$0 >> "peptides."length($0)".faa"; print $0 >> "peptides."length($0)".faa"}'
```

Run phip_seq_create_tiles at that length.  There will be no overlap as they are simply too short.
```
for i in 8 9 10 11; do
 phip_seq_create_tiles.bash -t ${i} -o 0 -i peptides.${i}.faa
done
```

It generates a number of files, but the number of reads for each length is ...
```
grep -c "^>" oligos-ref-{?,??}-0.fasta
oligos-ref-8-0.fasta:1524
oligos-ref-9-0.fasta:1643
oligos-ref-10-0.fasta:1261
oligos-ref-11-0.fasta:968
```
Note that this is twice the number of peptides because it creates a separate sequence for every tile replacing the last amino acid with the stop codon. Not certain what purpose this has or how it impacts things.

```
grep -A1 ">AAAAPASR" {orf,cterm}_tiles-8-0.fasta 
orf_tiles-8-0.fasta:>AAAAPASR|0-8
orf_tiles-8-0.fasta-AAAAPASR
--
cterm_tiles-8-0.fasta:>AAAAPASR|CTERM|STOP
cterm_tiles-8-0.fasta-AAAPASR*
```

```
grep -A 1 AAAAPASR oligos-ref-8-0.fasta 
>AAAAPASR|0-8
GCTGCCGCTGCGCCGGCGTCTCGC
--
>AAAAPASR|CTERM|STOP
GCGGCCGCACCGGCTTCTCGTTAG
```

Additionally, another file is created that includes 16 bp appended to each end.
```
grep -A 1 AAAAPASR oligos-8-0.fasta 
>AAAAPASR|0-8
AGGAATTCCGCTGCGTGCTGCCGCTGCGCCGGCGTCTCGCGCCTGGAGACGCCATC
--
>AAAAPASR|CTERM|STOP
AGGAATTCCGCTGCGTGCGGCCGCACCGGCTTCTCGTTAGGCCTGGAGACGCCATC
```

Moved all to 20250401/


##	20250403



```
tail -n +2 2025_0124_cross_analysis_summary_ha_mf_ag.tsv | cut -f2 | sort | uniq | awk '{ print ">"$0; print $0}' > peptides.faa
```

Run phip_seq_create_tiles at length 12.  There will be no overlap as they are simply too short.
```
phip_seq_create_tiles.bash -t 12 -o 0 -i peptides.faa
```

It generates a number of files, but the number of reads for each length is ...
```
grep -c "^>" oligos-ref-12-0.fasta
oligos-ref-12-0.fasta:2700
```





