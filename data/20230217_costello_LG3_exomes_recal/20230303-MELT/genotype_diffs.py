#!/usr/bin/env python3

import os
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')

parser.add_argument('-o', '--output', nargs=1, type=str, default='genotype_diffs.csv', help='output csv filename to %(prog)s (default: %(default)s)')
##parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
##	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )


#	CHR isn't sorting properly when column contains ints and strs? So dtype

#x = pd.read_csv("Supplemental_Table_S1_A.tsv",
#x = pd.read_csv("tcga.allele_frequencies.csv",
#	dtype = {0: str},
#	skipinitialspace=True,
#	sep="\t")
##	CHR POS MEI Type  INFO  1kGP2504_AF 1kGP698_AF  Amish_AF  JHS_AF  GTEx100bp_AF  GTEx150bp_AF  UKBB50k_AF
##x.drop(['INFO'],axis='columns',inplace=True)
#x.set_index(['CHR','POS','MEI Type'],inplace=True)
#x.head()


data_frames = []

for filename in args.files:
	print("Processing "+filename)

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0:1].join('.')	#	everything before the first "."
		sample=".".join(basename.split(".")[0:2])

		print("Reading "+filename+": Sample "+sample)

		#	dtype = {0: str},
		#	skipinitialspace=True,
		d = pd.read_csv(filename,
			sep="\t",
			header=None,

			#usecols=[0,1,2,4],
			#names=['CHR','POS','REF',sample])

			usecols=[0,1,2,3,4],
			names=['CHR','POS','REF','ALT',sample])

		d['ALT1']=d['ALT'].str.split(',',expand=True)[0]

		altsplit=d['ALT'].str.split(',',expand=True)
		if(len(altsplit.columns)>=1):
			d['ALT2']=None
		else:
			#d['ALT2']=d['ALT'].str.split(',',expand=True)[1]
			d['ALT2']=altsplit[1]

		altsplit=d['ALT'].str.split(',',expand=True)
		if(len(altsplit.columns)>=2):
			d['ALT3']=None
		else:
			#d['ALT3']=d['ALT'].str.split(',',expand=True)[1]
			d['ALT3']=altsplit[2]

		print(d.head())

		print("Sample now has "+str(d.shape))

		print("Selecting only REF SNPs")
		d=d[d['REF'].str.len()==1]
		print("Sample now has "+str(d.shape))

		print("Selecting only ALT SNPs")
		d=d[d['ALT'].str.len()==1]
		print("Sample now has "+str(d.shape))

		d[sample]= d.apply(lambda x: 
			x[sample].replace('0', str(x['REF'])).replace('1',str(x['ALT1'])).replace('2',str(x['ALT2'])).replace('3',str(x['ALT3'])), axis=1)

		print(d.head())

		d.drop(['REF','ALT','ALT1','ALT2','ALT3'],axis='columns',inplace=True)

		print(d.head())

		#if args.seqint:
		#	d[sample]=d[sample].astype(int)

		#d.drop(['INFO'],axis='columns',inplace=True)
		#d.set_index(['CHR','POS','REF','ALT'],inplace=True)
		#d.set_index(['CHR','POS','REF'],inplace=True)
		d.set_index(['CHR','POS'],inplace=True)
		print(d.head())

		print("Sample now has "+str(d.shape))

		print("Looking for duplications")
		print(d[d.index.duplicated()])
		print("Dropping duplicates")
		#d.drop_duplicates(inplace=True)
		d=d[~d.index.duplicated()]
		print("Sample now has "+str(d.shape))
		print("Looking for duplications")
		print(d[d.index.duplicated()])

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")

if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True )
	print(df.head())
	data_frames = []

	print("Merged dataframe now has "+str(df.shape))

	#print("Replacing all NaN with 0")
	#df.fillna('.', inplace=True)
	#print(df.head())

	#if args.int:
	#	print("Converting all counts back to integers")
	#	df = pd.DataFrame(df, dtype=int)

	#print(df.columns)

	print("Drop all rows which have a blank entry.")
	df.dropna(inplace=True)
	print("Merged dataframe now has "+str(df.shape))
	print(df.head())

	print("Drop all rows which have a ./.")
	df=df[df[df.columns[0]] != "./."]
	df=df[df[df.columns[1]] != "./."]
	print("Merged dataframe now has "+str(df.shape))
	print(df.head())

	print("Drop all rows which are the same.")
	#df.drop(df[df[df.columns[0]]==df[df.columns[1]]],inplace=True)
	#df.drop(df[ df.iloc[:, [0]] == df.iloc[:, [1]] ].index ,inplace=True)
	df=df[df[df.columns[0]] != df[df.columns[1]]]
	print("Merged dataframe now has "+str(df.shape))
	print(df.head())

	print("Writing CSV")
	#df.to_csv(output,index_label=['CHR','POS','REF','ALT'],sep="\t")
	#df.to_csv(output,index_label=['CHR','POS','REF'],sep="\t")
	df.to_csv(output,index_label=['CHR','POS'],sep="\t")

else:
	print("No data.")


