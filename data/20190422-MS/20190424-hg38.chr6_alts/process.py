#!/usr/bin/env python

import pandas as pd
import numpy as np
import glob
import os



import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
#plt.rcParams["figure.figsize"] = [18.0,9.0]
plt.rcParams.update({
	'figure.figsize': [18.0,9.0],
	'xtick.labelsize':'x-small',
	'ytick.labelsize':'small' })
#import matplotlib.backends.backend_pdf
#pdf = matplotlib.backends.backend_pdf.PdfPages("plots.pdf")







#sequences = pd.read_csv('chr6_sequences.txt', header=None, names=['sequence'])
#	print( list(columns.sequence) )

#df = pd.DataFrame( columns=list(sequences.sequence) ) 
#print(df)

dfs=[]

for filepath in glob.iglob('*proper_pair.counts'):
	print(filepath)
	if os.stat(filepath).st_size > 0:
		sample=filepath.split('.')[0]
		f = pd.read_csv(filepath, header=None, names=[sample], 
			delim_whitespace=True,
			index_col=[1], dtype={'count':int})
#sep='\s*',
		#print(f.transpose())
		dfs.append(f.transpose())
	
df = pd.concat(dfs,sort=True)
df=df.fillna(0)
df.sort_index(inplace=True)

df['total']=df.sum(axis = 1, skipna = True) 

print(df)

perc = pd.DataFrame()
for column in df.columns:
	perc[column] = df[column]/df['total']
print(perc)


perc.drop('total',axis='columns',inplace=True)
perc.sort_values(by='chr6',inplace=True)
#perc.plot(kind='bar',stacked=True)	#,legend=False)	#,rot=45)
perc.plot(title='Proper Pair alignment ratios to chr6 alternates',kind='bar',stacked=True)

plt.savefig("plots.png")

#pdf.savefig( )
#plt.close()


#perc.plot(subplots=True,legend=False)
#pdf.savefig( )
#plt.close()
#
#df.plot(subplots=True,legend=False)
#pdf.savefig( )
#plt.close()


#pdf.close()


