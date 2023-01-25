#!/usr/bin/env bash


#	https://genome.cshlp.org/content/31/12/2225.long
#	https://genome.cshlp.org/content/suppl/2021/11/12/gr.275323.121.DC1/Supplemental_Materials.pdf
#	https://genome.cshlp.org/content/suppl/2021/11/12/gr.275323.121.DC1/Supplemental_Table_S1.xlsx


#	PRIOR TO RUNNING THIS ... create sample lists for each ... subtype - sample type

awk -F, '{    
	gsub(/ /,"_",$5)
	sampletype=substr($2,9,2)
	sampleid=substr($2,1,20)
	print sampleid > $5"-"sampletype".sample_list"
}' metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv


#
#awk -F, '{print $5}' metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv  | sort | uniq -c
#    200 Brain Lower Grade Glioma
#     78 Glioblastoma Multiforme
#
#awk -F, '{print $2}' metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv  | cut -c9,10 | sort | uniq -c
#    125 01
#     27 02
#    126 10
#

#	Error: subset called for sample that does not exist in header: "FG-5963-10A-01D-1703". Use "--force-samples" to ignore this error.

for f in *.sample_list ; do
	echo $f

	for me in HERVK SVA LINE1 ALU ; do
		#vcf=${me}.final_comp.vcf.gz
		vcf=$( ls -1 out/*VCF/${me}*vcf.gz )
		basevcf=$( basename $vcf )

		bcftools view --apply-filters PASS --samples-file ${f} --force-samples ${vcf} \
			| bcftools +fill-tags -o ${f}.${basevcf} -Oz -- -t AF

		tsv=${f}.${basevcf%.vcf.gz}.tsv
		zcat ${f}.${basevcf} | awk -v me=${me} 'BEGIN{FS=OFS="\t"}(!/^#/){sub(/chr/,"",$1);split($8,a,";AF=");print $1,$2,me,$8,a[2]}' > ${tsv}
	done

	s=${f%.sample_list}

	sort -k1,1 -k2n,2 ${s}.*.final_comp.tsv > ${s}.combined.tsv

done


#	Warn: subset called for sample that does not exist in header: "FG-5963-10A-01D-1703"... skipping
#	Warn: subset called for sample that does not exist in header: "FG-6689-01A-11D-1891"... skipping
#	Warn: subset called for sample that does not exist in header: "HT-7468-01A-11D-2022"... skipping
#	Warn: subset called for sample that does not exist in header: "HT-7472-01A-11D-2022"... skipping
#	Warn: subset called for sample that does not exist in header: "FG-7636-10A-01D-2088"... skipping


