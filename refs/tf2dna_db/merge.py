#!/usr/bin/env python

import os    
import sys
import pandas as pd

data_frames = []

for filename in sys.argv[1:]:
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		#sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename)	#+": Sample "+sample)

		d = pd.read_csv(filename,
			sep="\t",
			header=None,
			names=['chromosome','gene'])

		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	#df = pd.concat(data_frames, axis='columns', sort=True)
	df = pd.concat(data_frames, axis='index').drop_duplicates('gene').reset_index(drop=True)
	df.sort_values(['gene','chromosome'],inplace=True)
	print(df.head())
	data_frames = []


df.to_csv('gene_chromosome.v8.tsv',header=False,sep="\t",index=False)


