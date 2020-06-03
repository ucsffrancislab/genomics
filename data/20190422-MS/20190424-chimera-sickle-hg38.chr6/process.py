#!/usr/bin/env python

import numpy as np
import pandas as pd

hkles=['HERV_K113','SVA_A','SVA_B','SVA_C','SVA_D','SVA_E','SVA_F']
statuses=['paired','unpaired']

groups = {
	'insertion_points': 'insertion_points_table.hg38.chr6.Q20.sorted',
	'overlappers': 'overlappers_table.hg38.chr6.Q20'
}


for key in groups.keys():
	dfs=[]
	grouped_dfs=[]
	for status in statuses:
		for hkle in hkles:
			df = pd.read_csv('20190424-HKLE-chimera-'+hkle+'-hg38.chr6/working_dir/'+status+'_'+groups[key]+'.csv')
	
			df['hkle'] = hkle
			df['status'] = status
	
			df.rename(index=str, columns={'position': 'original_position'},inplace=True)

			print(df.head())

			print(df['original_position'])

			if( len(df.index) > 0 ):
	
				df['position']  = df['original_position'].str.split('|',expand=True)[1].astype(int)
				df['direction'] = df['original_position'].str.split('|',expand=True)[2]	#	F, R, FR, RF
				#df['relation']  = df['original_position'].str.split('|',expand=True)[3]	#	pre or post
	
				dfs.append(df)
	
				print('Raw shape')
				print(df.shape)

				grouped_df = df.groupby( [pd.cut(df['position'], np.arange(0, 180000000+1, 10000)),'hkle','status','direction'] ).sum()
				grouped_df = grouped_df[grouped_df['position'] >= 0]
				grouped_df.drop('position',axis='columns',inplace=True)

				print(grouped_df.head())
				grouped_dfs.append(grouped_df)
				print('Grouped shape')
				print(grouped_df.shape)

	
	all=pd.concat(dfs,sort=True)
	all.drop('original_position',axis='columns',inplace=True)
	
	all.fillna(0,inplace=True)
	for col in all:
		#if( str(col) not in ['position','hkle','status','direction','relation'] ):
		if( str(col) not in ['position','hkle','status','direction'] ):
			all[col] = all[col].astype(int)
	
	#all.set_index(['position','hkle','status','direction','relation'],inplace=True)
	#all.sort_values(by=['position','hkle','status','direction','relation'],inplace=True)
	all.set_index(['position','hkle','status','direction'],inplace=True)
	all.sort_values(by=['position','hkle','status','direction'],inplace=True)
	
	print(all.shape)
	print(all.head(50))
	
	all.to_csv('hkle_'+key+'.csv')


	vcf = all
	vcf.reset_index(inplace=True)
	vcf[vcf.columns] = vcf[vcf.columns].astype(str)
	for col in vcf:
		if( str(col) not in ['position','hkle','status','direction'] ):
			z=vcf[col].astype(int) <= 0
			vcf.loc[z, col] = '0/0'
			vcf.loc[~z, col] = '1/1'
	
	vcf.insert(1,'FORMAT','GT')
	vcf.insert(1,'INFO','HKLE='+vcf['hkle']+';PUP='+vcf['status']+';DIR='+vcf['direction'])
	vcf.insert(1,'FILTER','.')
	vcf.insert(1,'QUAL','.')
	#vcf.insert(1,'ALT','N')
	#	can't have duplicate ALTs, so add 
	vcf.insert(1,'ALT','<INS_MEI:'+vcf['hkle']+'/'+vcf['status']+'/'+vcf['direction']+'>')
	#	Could search the index for the actual value
	#	samtools faidx /raid/refs/fasta/hg38.fa chr6:33464261-33464261 | tail -n 1 | tr a-z A-Z
	#	import subprocess
	#	output = subprocess.getoutput("ls -l")
	#	or
	#	import os
	#	output = os.popen('ls -l').read()
	vcf.insert(1,'REF','N')
	vcf.insert(1,'ID','.')
	vcf.insert(0,'#CHROM','chr6')
	vcf.rename(index=str, columns={'position': 'POS'},inplace=True)
	vcf.drop(['hkle','status','direction'],axis='columns',inplace=True)

	with open('hkle_'+key+'.vcf', 'w+') as f:
		f.write('##fileformat=VCFv4.2\n')
		f.write('##ALT=<ID=INS:MEI:HERVK,Description="HERVK insertion">\n')
		f.write('##INFO=<ID=HKLE,Number=1,Type=String,Description="HKLE detected">\n')
		f.write('##INFO=<ID=PUP,Number=1,Type=String,Description="Paired or Unpaired detection">\n')
		f.write('##INFO=<ID=DIR,Number=1,Type=String,Description="Direction of detection">\n')
		f.write('##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n')
	with open('hkle_'+key+'.vcf', 'a') as f:
		vcf.to_csv(f, sep='\t', index=False)



	all=pd.concat(grouped_dfs,sort=True)
#	all.drop('original_position',axis='columns',inplace=True)
	
	all.fillna(0,inplace=True)
	for col in all:
		if( str(col) not in ['position','hkle','status','direction'] ):
			all[col] = all[col].astype(int)
	
#	all.set_index(['position','hkle','status','direction'],inplace=True)
	all.sort_values(by=['position','hkle','status','direction'],inplace=True)
	
	print(all.shape)
	print(all.head(50))
	
	all.to_csv('hkle_'+key+'_grouped.csv')


