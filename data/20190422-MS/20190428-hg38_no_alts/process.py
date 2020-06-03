#!/usr/bin/env python

import pandas as pd
import numpy as np
import glob
import os


dfs=[]

for filepath in glob.iglob('*hg38_no_alts.proper_pair.counts'):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath, header=None, names=[sample], 
			delim_whitespace=True,
			index_col=[1], dtype={'count':int})
		dfs.append(f.transpose())
	
df = pd.concat(dfs,sort=True)
df=df.fillna(0)
df.sort_index(inplace=True)


print(df)
df.to_csv('hg38_no_alts.proper_pairs.counts.csv')

df['total']=df.sum(axis = 1, skipna = True) 


perc = pd.DataFrame()
for column in df.columns:
	perc[column] = df[column]/df['total']



perc.drop('total',axis='columns',inplace=True)

print(perc)
perc.to_csv('hg38_no_alts.proper_pairs.portions.csv')






dfs=[]

for filepath in glob.iglob('*hg38_no_alts.counts'):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath, header=None, names=[sample], 
			delim_whitespace=True,
			index_col=[1], dtype={'count':int})
		dfs.append(f.transpose())
	
df = pd.concat(dfs,sort=True)
df=df.fillna(0)
df.sort_index(inplace=True)


print(df)
df.to_csv('hg38_no_alts.counts.csv')

df['total']=df.sum(axis = 1, skipna = True) 


perc = pd.DataFrame()
for column in df.columns:
	perc[column] = df[column]/df['total']



perc.drop('total',axis='columns',inplace=True)

print(perc)
perc.to_csv('hg38_no_alts.portions.csv')


