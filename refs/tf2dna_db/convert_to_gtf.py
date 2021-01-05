#!/usr/bin/env python

import os    
import sys
import pandas as pd
import csv


#zcat /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/genes/hg19.ncbiRefSeq.gtf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/genes/hg19.refGene.gtf.gz | awk 'BEGIN{FS=OFS="\t"}{n=split($NF,a," ");gene=a[n];gsub(/[;\"]/,"",gene);print $1,gene}' | sort | uniq > gene_chromosome.tsv

#	Many gene aliases aren't found. Need to include older gtf files

#	Built in ~2015
#ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz
#	zcat gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz | awk 'BEGIN{FS=OFS="\t"}{split($NF,a,";");g="";for(i in a){if(a[i] ~ /gene_name/){g=a[i];gsub(/gene_name/,"",g);gsub(/ /,"",g);gsub(/\"/,"",g)}}print($1,g)}' | sort | uniq > gene_chromosome.tsv


gene_chromosome = pd.read_csv('gene_chromosome.tsv', sep="\t",header=None,names=['chromosome','gene'])

#for filename in args.files:  
#for filename in sys.arg:
for filename in sys.argv[1:]:
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)

		df = pd.read_csv(filename, sep="\t")
		df=df.merge(gene_chromosome,how='left',left_on='target_name',right_on='gene')

		print(df.head())

		gtf = pd.DataFrame(columns = ['seqname','source','feature','start','end','score','strand','frame','attribute'])

		for index, row in df.iterrows():
			#print(index)
			#print(row['binding_sites'])
			binding_sites=row['binding_sites'].split(' ')
			#print(binding_sites)

			source='tf2dna_db'
			#strand=row['direction'].replace('\(','',regex=True).replace('\)','',regex=True)
			#strand=row['direction'].replace('\(','').replace('\)','')
			strand=row['direction'].replace('(','').replace(')','')

			for site in binding_sites:

				site_pieces=site.split(':')
				pos=int(site_pieces[0])

				gtf = gtf.append({
					'seqname':row['chromosome'],
					'source':source,
					'feature':'feature',
					'start':pos,
					'end':pos+1,
					'score':'.',
					'strand':strand,
					'frame':'.',
					'attribute': 'tf_name "'+row['tf_name']+'"; target_name "'+row['target_name']+'"; binding_score '+site_pieces[1]+'; p_value '+site_pieces[2]+';'
#					'attribute': 'tf_name "'+row['tf_name']+'"; target_name "'+row['target_name']+'"; binding_score "'+site_pieces[1]+'"; p_value "'+site_pieces[2]+'";'
					},
					ignore_index=True)

#	head pscan_files/Homo-sapiens_experimental_Berger-2006/POU2F1.pscan 
#	tf_name	target_name	start_position	end_position	direction	binding_score	p_value	binding_sites
#	POU2F1	C3orf84	49228791	49230791	(-)	872.59	0.000709	49229444:872.59:0.000709 49230511:859.98:0.000767
#	POU2F1	SLC40A1	190445037	190447037	(-)	822.15	0.000948	190446042:822.15:0.000948
#	POU2F1	BLOC1S3	45680502	45682502	(+)	960.87	0.000402	45680887:960.87:0.000402
#	POU2F1	HEATR3	50098380	50100380	(+)	1086.98	0.000090	50099423:1086.98:0.000090 50098795:1023.92:0.000169 50098877:960.87:0.000402 50099091:885.20:0.000624 50099628:885.20:0.000624
#	POU2F1	UNC5D	35091474	35093474	(+)	1011.31	0.000227	35092432:1011.31:0.000227 35092172:998.70:0.000312
#	POU2F1	ZNF257	22233765	22235765	(+)	998.70	0.000312	22234247:998.70:0.000312
#	POU2F1	CCDC66	56589683	56591683	(+)	998.70	0.000312	56590451:998.70:0.000312 56590704:897.81:0.000513
#	POU2F1	PTPN9	75871132	75873132	(-)	822.15	0.000948	75872423:822.15:0.000948
#	POU2F1	USP30	109459393	109461393	(+)	1036.53	0.000117	109461043:1036.53:0.000117 109459667:1011.31:0.000227 109459834:1011.31:0.000227 109460642:1011.31:0.000227 109459659:897.81:0.000513 109460982:885.20:0.000624 109460653:834.76:0.000836 109459535:822.15:0.000948


#	chr1	HAVANA	gene	11869	14412	.	+	.	gene_id "ENSG00000223972.4"; transcript_id "ENSG00000223972.4"; gene_type "pseudogene"; gene_status "KNOWN"; gene_name "DDX11L1"; transcript_type "pseudogene"; transcript_status "KNOWN"; transcript_name "DDX11L1"; level 2; havana_gene "OTTHUMG00000000961.2";


#	tf_name	target_name	start_position	end_position	direction	binding_score	p_value	binding_sites

		gtf2=gtf.sort_values(by=['seqname', 'start','end'])
		print(gtf2.head())

		print("Writing CSV")
		gtf2.to_csv(filename+'.gtf.gz',header=False,sep="\t",index=False,quoting=csv.QUOTE_NONE)

	else:
		print(filename + " is empty")


