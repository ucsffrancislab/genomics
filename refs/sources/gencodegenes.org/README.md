

#	GenCode

The GenCode website

https://www.gencodegenes.org/human/

stores its references in ...

https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/

... but I'll keep them here in refs/sources/gencodegenes.org








Since this was built in ~2015, use something about that old
ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz

zcat gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz gencode.v36lift37.annotation.gtf.gz | awk 'BEGIN{FS=OFS="\t"}{split($NF,a,";");g="";for(i in a){if(a[i] ~ /gene_name/){g=a[i];gsub(/gene_name/,"",g);gsub(/ /,"",g);gsub(/\"/,"",g)}}print($1,g)}' | sort | uniq > gene_chromosome.v3.tsv


ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz


wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_15/gencode.v15.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_16/gencode.v16.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_17/gencode.v17.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_18/gencode.v18.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_23/GRCh37_mapping/gencode.v23lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_24/GRCh37_mapping/gencode.v24lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_25/GRCh37_mapping/gencode.v25lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_26/GRCh37_mapping/gencode.v26lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/GRCh37_mapping/gencode.v27lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_28/GRCh37_mapping/gencode.v28lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/GRCh37_mapping/gencode.v29lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_31/GRCh37_mapping/gencode.v31lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/GRCh37_mapping/gencode.v32lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_33/GRCh37_mapping/gencode.v33lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/GRCh37_mapping/gencode.v34lift37.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/GRCh37_mapping/gencode.v35lift37.annotation.gtf.gz

wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_18/gencode.v18.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_17/gencode.v17.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_16/gencode.v16.chr_patch_hapl_scaff.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_15/gencode.v15.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_14/gencode.v14.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_13/gencode.v13.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_12/gencode.v12.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_11/gencode.v11.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_10/gencode.v10.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_9/gencode.v9.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_8/gencode.v8.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_7/gencode.v7.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_6/gencode.v6.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_5/gencode.v5.annotation.gtf.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_3c/gencode.v3c.annotation.GRCh37.gtf.gz



wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.annotation.gtf.gz

# prep for TEProF2 (from TEProF2). Not sure if this went as expected

zcat gencode.v43.annotation.gtf.gz | awk '{if($3=="transcript"||$3=="exon"||$3=="start_codon"){print}}' |  awk -F "; " '{print $0"\t"$2}' > OUTPUT_sorted.gtf
~/github/twlab/TEProf2Paper/bin/genecode_to_dic.py OUTPUT_sorted.gtf

~/github/twlab/TEProf2Paper/bin/genecode_introns.py OUTPUT_sorted.gtf

sort -k1,1 -k2,2n -k3,3n OUTPUT_sorted.gtf_introns_plus > OUTPUT_sorted.gtf_introns_plus_sorted
sort -k1,1 -k2,2n -k3,3n OUTPUT_sorted.gtf_introns_minus > OUTPUT_sorted.gtf_introns_minus_sorted

bgzip OUTPUT_sorted.gtf_introns_plus_sorted
bgzip OUTPUT_sorted.gtf_introns_minus_sorted

tabix -p bed OUTPUT_sorted.gtf_introns_plus_sorted.gz
tabix -p bed OUTPUT_sorted.gtf_introns_minus_sorted.gz





module load htslib

zcat gencode.v43.basic.annotation.gtf.gz | awk '{if($3=="transcript"||$3=="exon"||$3=="start_codon"){print}}' |  awk -F "; " '{print $0"\t"$2}' > OUTPUT_sorted.gtf
~/github/twlab/TEProf2Paper/bin/genecode_to_dic.py OUTPUT_sorted.gtf

~/github/twlab/TEProf2Paper/bin/genecode_introns.py OUTPUT_sorted.gtf

sort -k1,1 -k2,2n -k3,3n OUTPUT_sorted.gtf_introns_plus > OUTPUT_sorted.gtf_introns_plus_sorted
sort -k1,1 -k2,2n -k3,3n OUTPUT_sorted.gtf_introns_minus > OUTPUT_sorted.gtf_introns_minus_sorted

bgzip OUTPUT_sorted.gtf_introns_plus_sorted
bgzip OUTPUT_sorted.gtf_introns_minus_sorted

tabix -p bed OUTPUT_sorted.gtf_introns_plus_sorted.gz
tabix -p bed OUTPUT_sorted.gtf_introns_minus_sorted.gz







wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.pc_transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.pc_translations.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/gencode.v43.lncRNA_transcripts.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/GRCh38.p13.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_43/GRCh38.primary_assembly.genome.fa.gz


