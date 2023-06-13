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
parser.add_argument('-o', '--output', nargs=1, type=str, default='genotype_diffs.tsv.gz', help='output tsv filename to %(prog)s (default: %(default)s)')
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
# data_frames = [x]

data_frames = []

for filename in args.files:
	print("Processing "+filename)

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0]	#	everything before the first "."

		sample=".".join(basename.split(".")[0:3])

		print("Reading "+filename+": Sample "+sample)

		d = pd.read_csv(filename,
			header=None,
			names=['CHR','POS','REF','ME',sample],
			sep="\t")


		#	y=[x[1] for x in d.columns[2:4].str.split(".")]
		#	>>> y
		#	['Z00109', 'Z00110']
		#	>>> "-".join(y)
		#	'Z00109-Z00110'
		#	>>> d.columns[2:4].str.split(".")[1][1]
		#	'Z00110'
		#	>>> d.columns[2:4].str.split(".")[0][0]
		#	'Patient124'

		#	
		#newcolumn=d.columns[2:4].str.split(".")[0][0]+" "+"-".join([x[1] for x in d.columns[2:4].str.split(".")])

		#>>> d['asdf']=d['Patient124.Z00109']+"-"+d['Patient124.Z00110']

		#d[newcolumn]=d[d.columns[2]]+"->"+d[d.columns[3]]
		#d["MUT"]=d[d.columns[2]]+"->"+d[d.columns[3]]
		#d[newcolumn]="1"


			#skipinitialspace=True,
			#dtype = {0: str},
			#header=None,
			#names=['CHR','POS','MEI Type','INFO',sample+"_AF"])

		#CHR	POS	Patient124.Z00109	Patient124.Z00110
		#chr1	568214	C/C	C/T
		#chr1	802300	T/T	T/C
		#chr1	895973	C/T	C/C
		#chr1	976514	C/A	C/C
		#chr1	1004427	G/A	G/G
		#chr1	1159175	G/G	G/C
		#chr1	1247589	C/C	C/G
		#chr1	1475231	T/T	T/G
		#chr1	1535234	G/T	G/G

		print(d.head())
		#d.drop([d.columns[2],d.columns[3]],axis='columns',inplace=True)
		#print(d.head())

		#if args.seqint:
		#	d[sample]=d[sample].astype(int)

		#d.drop(['INFO'],axis='columns',inplace=True)
		#chrX	64936276	T	<INS:ME:LINE1>	0/0->./.

		d.set_index(['CHR','POS','REF','ME'],inplace=True)
		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True )
	data_frames = []

	print("Replacing all NaN with 0")
	#df.fillna('0', inplace=True)
	print(df.head())

#	if args.int:
#		print("Converting all counts back to integers")
#		df = pd.DataFrame(df, dtype=int)

	print("Writing CSV")
	df.to_csv(output,index_label=['CHR','POS','REF','ME'],sep="\t")

else:
	print("No data.")


