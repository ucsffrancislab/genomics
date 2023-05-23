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
parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )


print("Reading translation table")
x = pd.read_csv("accession_description.tsv.gz",
	header=None,
	names=['accession','description'],
	skipinitialspace=True,
	sep="\t")
#	CHR POS MEI Type  INFO  1kGP2504_AF 1kGP698_AF  Amish_AF  JHS_AF  GTEx100bp_AF  GTEx150bp_AF  UKBB50k_AF
#x.drop(['INFO'],axis='columns',inplace=True)
#x.set_index(['CHR','POS','MEI Type'],inplace=True)
x.set_index(['accession'],inplace=True)
print(x.head())
print("done")

data_frames = [x]

for filename in args.files:
	print("Processing "+filename)

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		sample=basename.split(".")[0]	#	everything before the first "."

		print("Reading "+filename+": Sample "+sample)

		d = pd.read_csv(filename,
			skipinitialspace=True,
			sep=" ",
			header=None,
			names=[sample,"accession"])
			#names=['CHR','POS','MEI Type','INFO',sample+"_AF"])
			#dtype = {0: str},
			#sep="\t",

		#head e2e/QM397.RMHM.bam.aligned_sequence_counts.txt
		# 150217 NC_007653.1
		#  20565 NC_003347.1
		#   4341 NC_001506.1
		#   1429 NC_001422.1

		if args.seqint:
			d[sample]=d[sample].astype(int)

		#d.drop(['INFO'],axis='columns',inplace=True)
		#d.set_index(['CHR','POS','MEI Type'],inplace=True)
		d.set_index(['accession'],inplace=True)
		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True )
	data_frames = []
	print(df.head())
	df.reset_index(inplace=True)
	print(df.head())
	df.set_index(['index','description'],inplace=True)
	print(df.head())

	print("Replacing all NaN with 0")
	#df.fillna('.', inplace=True)
	df.fillna('0', inplace=True)
	print(df.head())

	if args.int:
		print("Converting all counts back to integers")
		df = pd.DataFrame(df, dtype=int)

	print("Writing CSV")
	#df.to_csv(output,index_label=['CHR','POS','MEI Type'],sep="\t")
	df.to_csv(output,index_label=['accession','description'],sep="\t")

else:
	print("No data.")


