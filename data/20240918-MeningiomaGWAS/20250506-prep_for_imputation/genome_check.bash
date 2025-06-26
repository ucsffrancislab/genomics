#!/usr/bin/env bash


#	rs4940595:
#	This rsID has a T as the reference allele and G as the alternative in hg19, causing a stop lost. However, in hg38, the reference is G and the alternative is T, which can cause a stop gained, according to a SEQanswers forum discussion. 
#	rs855581:
#	Genotypes for this rsID may appear as both homozygous and heterozygous in hg19, while all individuals appear homozygous in hg38, as mentioned in the SEQanswers discussion. 


#	#CHROM POS ID REF ALT QUAL FILTER INFO FORMAT NA00001 NA00002 NA00003

#	Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name
#	Variant identifier
#	Position in morgans or centimorgans (safe to use dummy value of '0')
#	Base-pair coordinate (1-based; limited to 231-2)
#	Allele 1 (corresponding to clear bits in .bed; usually minor)
#	Allele 2 (corresponding to set bits in .bed; usually major)
#	
#	bim and vcf usually reverse order?

while read chr rsid ; do

#	grep -m1 ${rsid} prep/MENINGIOMA_GWAS_SHARED.bim
#	grep -m1 ${rsid} prep/MENINGIOMA_GWAS_SHARED-updated.bim
#	grep -m1 ${rsid} prep/MENINGIOMA_GWAS_SHARED-updated-${chr}.bim
#	zgrep -m1 ${rsid} prep/MENINGIOMA_GWAS_SHARED-updated-${chr}.vcf.gz | cut -c1-40
#	zgrep -m1 ${rsid} imputed/${chr}.info.gz | cut -c1-40
#	grep -m1 ${rsid} imputed/${chr}.QC.bim
#	grep -m1 ${rsid} prep_for_PRS/merged.bim
#	grep -m1 ${rsid} prep_for_PRS/merged-updated.bim
#	grep -m1 ${rsid} prep_for_PRS/merged-updated-${chr}.bim
#	zgrep -m1 ${rsid} prep_for_PRS/merged-updated-${chr}.vcf.gz | cut -c1-40

	echo ${chr} - ${rsid}

	zgrep -m1 ${rsid} \
		prep/MENINGIOMA_GWAS_SHARED.bim \
		prep/MENINGIOMA_GWAS_SHARED-updated.bim \
		prep/MENINGIOMA_GWAS_SHARED-updated-${chr}.bim \
		prep/MENINGIOMA_GWAS_SHARED-updated-${chr}.vcf.gz \
		imputed/${chr}.info.gz \
		imputed/${chr}.QC.bim \
		prep_for_PRS/merged.bim \
		prep_for_PRS/merged-updated.bim \
		prep_for_PRS/merged-updated-${chr}.bim \
		prep_for_PRS/merged-updated-${chr}.vcf.gz | tr ':' '\n' | cut -c1-40

	echo

done < <( cat <<EOF
chr7 rs1234567
chr2 rs78910115
chr3 rs6789012
chr18 rs4940595
EOF
)


#	
#	chr7	97795920	rs1234567	T	C	.	.	IMPUTED;
#	7	rs1234567	0	97795920	C	T
#	7	rs1234567	0	97795920	C	T
#	7	rs1234567	0	97425232	C	T
#	7	rs1234567	0	97425232	C	T
#	7	97425232	rs1234567	T	C	.	.	.	GT	0/0	0/
#	chr2	172685102	rs78910115	T	C	.	.	IMPUTE
#	2	rs78910115	0	172685102	C	T
#	2	rs78910115	0	172685102	C	T
#	2	rs78910115	0	173549830	C	T
#	2	rs78910115	0	173549830	C	T
#	2	173549830	rs78910115	T	C	.	.	.	GT	0/0	
#	chr3	103911570	rs6789012	A	T	.	.	IMPUTED
#	3	rs6789012	0	103911570	T	A
#	3	rs6789012	0	103911570	T	A
#	3	rs6789012	0	103630414	T	A
#	3	rs6789012	0	103630414	T	A
#	3	103630414	rs6789012	A	T	.	.	.	GT	0/1	0
#	18	rs4940595_r	0	61379838	G	T
#	18	rs4940595_r	0	61379838	G	T
#	18	rs4940595_r	0	61379838	G	T
#	18	61379838	rs4940595_r	T	G	.	.	.	GT	0/1
#	chr18	63712604	rs4940595	G	T	.	.	IMPUTED
#	18	rs4940595	0	63712604	G	T
#	18	rs4940595	0	63712604	G	T
#	18	rs4940595	0	61379838	G	T
#	18	rs4940595	0	61379838	G	T
#	18	61379838	rs4940595	T	G	.	.	.	GT	0/1	0
#	

