#!/usr/bin/env python

import os    
import sys
import numpy as np
import pandas as pd
import csv

gene_chromosome = pd.read_csv('gene_chromosome.tsv', sep="\t",header=None,names=['chromosome','gene'])

for filename in sys.argv[1:]:
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)

		df = pd.read_csv(filename, sep="\t")
		#print(df.head())
		df = df.merge(gene_chromosome,how='left',left_on='target_name',right_on='gene')
		#print(df.head())
		df = df.assign(binding_sites=df.binding_sites.str.split(" "))
		#print(df.head())
		#df = pd.DataFrame({'A':df.A.repeat(df.B.str.len()),'B':np.concatenate(df.B.values)})
		#	I don't quite get why I need the ".str"
 		df['strand']=df.direction.str.replace('(','').str.replace(')','')
		df = pd.DataFrame({
			'tf_name':df.tf_name.repeat(df.binding_sites.str.len()),
			'target_name':df.target_name.repeat(df.binding_sites.str.len()),
			'seqname':df.chromosome.repeat(df.binding_sites.str.len()),
			'source':'tf2dna_db',
			'feature':'feature',
			'start':0,
			'end':0,
			'score':'.',
			'strand':df.strand.repeat(df.binding_sites.str.len()),
			'frame':'.',
			'binding_site':np.concatenate(df.binding_sites.values),
			'attribute':''
		})
		#print(df.head())

		df[['position','binding_score', 'p_value']] = df['binding_site'].str.split(':', 2, expand=True)
		#print(df.head())
		#df.start = int(df.position)
		df.start = df.position.astype(int)
		#print(df.head())
		df.end = df.start+1
		#print(df.head())

		df.attribute = 'tf_name "'+df['tf_name']+'"; target_name "'+df['target_name']+'"; binding_score '+df['binding_score']+'; p_value '+df['p_value']+';'

		#df = df.explode('binding_sites')
		#print(df)

		gtf = df[['seqname','source','feature','start','end','score','strand','frame','attribute']]

		gtfsorted=gtf.sort_values(by=['seqname', 'start','end'])
		#print(gtfsorted.head())

		print("Writing CSV")
		gtfsorted.to_csv(filename+'.gtf.gz',header=False,sep="\t",index=False,quoting=csv.QUOTE_NONE)

	else:
		print(filename + " is empty")


