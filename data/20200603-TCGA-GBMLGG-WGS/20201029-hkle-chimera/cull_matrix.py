#!/usr/bin/env python

import pandas as pd

import sys

for i, arg in enumerate(sys.argv):
	if i == 0:
 		continue
	#print("Argument ",i,": ",arg)

	print("Processing "+arg)



	# Use the "normal" version, NOT the "transposed" version
	
	
	#df=pd.read_csv("merged.0-D.rounded----.T.csv.gz",index_col=[0,1,2,3],header=[0,1])
	#df=pd.read_csv("merged.0-D.rounded----.csv.gz",header=[0,1,2,3],index_col=[0,1])
	
	
	df=pd.read_csv(arg,header=[0,1,2,3],index_col=[0,1])
	
	
	
	#print(df.head())
	
	
	#tdf=pd.read_csv("merged/merged.0-D.rounded.chrY.T.csv.gz",index_col=[0,1,2,3],header=[0,1])
	#print(tdf.head())
	
	
	#>>> ndf=df.drop(df[df.sum(axis=1) == 1].index,axis='index')
	#>>> ndf.shape
	#(6977, 7640)
	#>>> cdf=df.loc[(df.sum(axis=1) > 1),]
	#>>> cdf.shape
	#(6977, 7640)
	
	
	
	output=arg.replace('csv', 'culled.csv', 1)
	
	df.drop(df[df.sum(axis=1) == 1].index,axis='index',inplace=True)
	
	
	print("Writing CSV : ",output)
	sys.stdout.flush()
	df.to_csv(output,index_label=['chromosome','position'])
	
	toutput=output.replace('csv', 'T.csv', 1)
	print("Writing transposed CSV : ",toutput)
	sys.stdout.flush()
	df.T.to_csv(toutput,index_label=['sample','pup','hkle','mapq'])

