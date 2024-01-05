
#	refs/PhIP-Seq


```
ln -s /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/VIR3_clean.csv.gz
ln -s /c4/home/gwendt/github/ucsffrancislab/PhIP-Seq/Elledge/vir3.fasta

zcat VIR3_clean.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}(NR>1){o=substr($18,17,168);print $17","o}' | uniq | sort -t, -k1n,1 | uniq | awk -F, '{print ">"$1;print $2}' | gzip > VIR3_clean.uniq.fna.gz
bowtie-build VIR3_clean.uniq.fna.gz VIR3_clean
bowtie2-build VIR3_clean.uniq.fna.gz VIR3_clean
```




```
#zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="HAPLib.2"){o=substr($8,18,168);print ">"$2;print o}' | tr -d \" | gzip > HAP.fna.gz

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"HAPLib.1\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > HAPLib.1.fna.gz

module load bowtie
bowtie-build HAPLib.1.fna.gz HAPLib.1
chmod 440 HAP*ebwt

module load bowtie2
bowtie2-build HAPLib.1.fna.gz HAPLib.1
chmod 440 HAP*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"HAPLib.2\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > HAPLib.2.fna.gz

module load bowtie
bowtie-build HAPLib.2.fna.gz HAPLib.2
chmod 440 HAP*ebwt

module load bowtie2
bowtie2-build HAPLib.2.fna.gz HAPLib.2
chmod 440 HAP*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.1\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > LExPELib.1.fna.gz

module load bowtie
bowtie-build LExPELib.1.fna.gz LExPELib.1
chmod 440 LEx*ebwt

module load bowtie2
bowtie2-build LExPELib.1.fna.gz LExPELib.1
chmod 440 LEx*bt2

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}(NR>1 && $4=="\"LExPELib.2\""){o=substr($8,18,168);print ">"$2;print o}' | gzip > LExPELib.2.fna.gz

module load bowtie
bowtie-build LExPELib.2.fna.gz LExPELib.2
chmod 440 LEx*ebwt

module load bowtie2
bowtie2-build LExPELib.2.fna.gz LExPELib.2
chmod 440 LEx*bt2
```


```
"","id","peptide","sub_library","Original_Entry_Sequence","Original_Entry","Original_Entry_Name","oligo_200","Variant","mutations",
"WT_peptide","UniProtKB_Entry","Reviewed","Entry Name","Protein names","Gene Names","Organism","Length","Chain","Organism (ID)",
"Taxonomic lineage","Taxonomic lineage (Ids)","UniProt_Sequence","UniProt_Seq_Identical"

```
```
zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{print $2,$17}' | tr -d \" | sed -e 's/(.*)//g' -e 's/\s*$//' > HAP_id_virus.csv




zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/,"",$15);print $2,$15,$17}' | tr -d \" | sed -r -e 's/\([^(]*\)//g' -e 's/\s*,\s*/,/g' -e 's/\s+/ /g' -e 's/\s*$//' > HAP_id_protein_virus.csv

zcat HAP_LExP_Peptide_Oligo_Metadata_for_Distribution.csv.gz | awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")";OFS=","}{gsub(/,/,"",$15);print $2,$15,$17,$3,$24}' | tr -d \" | sed -r -e 's/\([^(]*\)//g' -e 's/\s*,\s*/,/g' -e 's/\s+/ /g' -e 's/\s*$//' > HAP_id_protein_virus_seqs_unique.csv


```


