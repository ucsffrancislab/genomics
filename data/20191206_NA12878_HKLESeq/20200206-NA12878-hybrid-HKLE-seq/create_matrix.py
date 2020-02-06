#!/usr/bin/env python

import pandas as pd
import glob

#	ref = pd.read_csv('NA12878.SVAs_and_HERVs_KWHE.e2e.all.positions.csv', header=None, names=['contig','position','HKLE'])
#	
#	for f in sorted(glob.glob('NA12878.??-??.?.e2e.all.positions.csv')):
#		s=f.replace('NA12878.','')
#		s=s.replace('.e2e.all.positions.csv','')
#		print("Processing ",f)
#		sample = pd.read_csv(f, header=None, usecols=[0,1],names=['contig','position'])
#		ref[s] = ref.apply( lambda row: len(sample[
#			( sample['contig'] == row['contig'] )
#			& ( sample['position'] > ( row['position'] - 1000 ) )
#			& ( sample['position'] < ( row['position'] + 1000 ) )
#		]), axis='columns' )
#	
#	ref.to_csv('NA12878.SVAs_and_HERVs_KWHE.e2e.all.coverage.2.csv')



#df = pd.read_csv('NA12878.SVAs_and_HERVs_KWHE.e2e.all.coverage.csv')
#print(df.iloc[:,4:len(df.columns)].sum(axis='index'))


