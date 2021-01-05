#!/usr/bin/env python


#	ID	Species	Name	chromosome Location	5' Flanking Gene	3' Flanking Gene	Validation Method	In Situ Function	Description	Reference
#	INSUL_MAN00001	Human	GTL2-a	chr14:100364027-100364047	DLK1	FP504	sequence analysis		imprinting	11076856
#	INSUL_MAN00002	Human	GTL2-b	chr14:100364319-100364339	DLK1	FP504	sequence analysis		imprinting	11076856
#	INSUL_MAN00003	Human	apoB CTCF	chr2:21174437-21174468	APOB	-	in vitro binding;enhancer-blocking assay	chromatin boundary		11389587
#	INSUL_MAN00004	Human	DM1 site 1	chr19:50965398-50965458	SIX5	DMPK	in vitro binding;in vivo binding	enhancer-blocking	CTG/CAG repeats;methylation-sensitive	11479593
#	INSUL_MAN00005	Human	DM1 site 2	chr19:50965141-50965201	SIX5	DMPK	in vitro binding;in vivo binding	enhancer-blocking	CTG/CAG repeats;methylation-sensitive	11479593
#	INSUL_MAN00006	Human	PLK promoter site	chr16:23597358-23597397	DCTN5	PLK1	in vitro binding		11782357
#	INSUL_MAN00007	Human	human beta-globin 5'HS5	chr11:5269210-5269281	HBE1	HBG2	in vitro binding;enhancer-blocking assay	enhancer-blocking		11997516
#	INSUL_MAN00008	Human	human beta-globin 3'HS1	chr11:5182745-5182816	OR51V1	HBB	in vitro binding;enhancer-blocking assay	enhancer-blocking		11997516
#	INSUL_MAN00009	Human	hPCT12	chr11:1947003-1947086	MRPL23	AK126380	in vitro binding	imprinting boundary	imprinting	12075007


#	chr1	HAVANA	gene	11869	14412	.	+	.	gene_id "ENSG00000223972.4"; transcript_id "ENSG00000223972.4"; gene_type "pseudogene"; gene_status "KNOWN"; gene_name "DDX11L1"; transcript_type "pseudogene"; transcript_status "KNOWN"; transcript_name "DDX11L1"; level 2; havana_gene "OTTHUMG00000000961.2";



import os    
import sys
import pandas as pd


#for filename in args.files:  
#for filename in sys.arg:
for filename in sys.argv[1:]:
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)

		df = pd.read_csv(filename,
			sep="\t",index_col=0)
#			sep="\t",
#			names=['chromosome','position',sample],
#			index_col=['chromosome','position'])

		print(df.head())


		#raw['rp']=filenameparts[7]
		#raw['dir']=filenameparts[11][0]			####	f or r
		#raw['pup']=filenameparts[5][0]
		#raw['hkle']=filenameparts[3]
		#raw['q']=filenameparts[10][1:2]


		#	Fields must be tab-separated. Also, all but the final field in each feature line must contain a value; "empty" columns should be denoted with a '.'
		#	
		#	seqname - name of the chromosome or scaffold; chromosome names can be given with or without the 'chr' prefix. Important note: the seqname must be one used within Ensembl, i.e. a standard chromosome name or an Ensembl identifier such as a scaffold ID, without any additional content such as species or assembly. See the example GFF output below.
		#	source - name of the program that generated this feature, or the data source (database or project name)
		#	feature - feature type name, e.g. Gene, Variation, Similarity
		#	start - Start position* of the feature, with sequence numbering starting at 1.
		#	end - End position* of the feature, with sequence numbering starting at 1.
		#	score - A floating point value.
		#	strand - defined as + (forward) or - (reverse).
		#	frame - One of '0', '1' or '2'. '0' indicates that the first base of the feature is the first base of a codon, '1' that the second base is the first base of a codon, and so on..
		#	attribute - A semicolon-separated list of tag-value pairs, providing additional information about each feature.
		#	*- Both, the start and end position are included. For example, setting start-end to 1-2 describes two bases, the first and second base in the sequence.

#Index([u'Species', u'Name', u'chromosome Location', u'5' Flanking Gene',
#       u'3' Flanking Gene', u'Validation Method', u'In Situ Function',
#       u'Description', u'Reference'],

#df[['A', 'B']] = df['AB'].str.split(' ', 1, expand=True)
#	INSUL_MAN00009	Human	hPCT12	chr11:1947003-1947086	MRPL23	AK126380	in vitro binding	imprinting boundary	imprinting	12075007

		df['seqname']=df['chromosome Location'].str.split(':',1, expand=True)[0]
		df['source']='CTCFBSDB'
		df['feature']=df['In Situ Function'].astype(str)
		df['positions']=df['chromosome Location'].str.split(':',1, expand=True)[1]
		df['start']=df['positions'].str.split('-',1, expand=True)[0]
		df['end']=df['positions'].str.split('-',1, expand=True)[1]
		df['score']='.'
		df['strand']='+'
		df['frame']='.'
		df['attribute']='attributes'

		print(df.head())

		df.drop(df[df['Species'] != 'Human'].index, inplace = True) 


		df2=df[['seqname','source','feature','start','end','score','strand','frame','attribute']]
		print(df2.head())

		gtf=df2.sort_values(by=['seqname', 'start','end'])
		print(gtf.head())


		print("Writing CSV")
		gtf.to_csv(filename+'.gtf.gz',header=False,sep="\t",index=False)

	else:
		print(filename + " is empty")


