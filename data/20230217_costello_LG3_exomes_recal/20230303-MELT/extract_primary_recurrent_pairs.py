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
parser.add_argument('-o', '--output', nargs=1, type=str, default='primary_recurrent_pairs.tsv', help='output csv filename to %(prog)s (default: %(default)s)')
#	#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
#	#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#	parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
#	parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')
#	
# read arguments from the command line
args = parser.parse_args()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )



data_frames = []


for filename in args.files:
	print("Processing "+filename)

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0]	#	everything before the first "."

		#print("Reading "+filename+": Sample "+sample)

		d = pd.read_csv(filename,
			sep=",",
			usecols=[0,1,6])
		print(d.head())

#	looks like each patient only has 1 normal, which is good
#	awk -F, '($6=="Normal"){print $1}' patient_ID_conversions.2022.exists.covariates.sorted.csv | sort | uniq -d

out=pd.DataFrame(columns=["Patient","Normal","Primary","Recurrent"])

for patient in d.loc[d['npr']=="Normal"].patient.unique():
	normal=d.loc[(d['patient']==patient)&(d['npr']=="Normal")]
	primaries=d.loc[(d['patient']==patient)&(d['npr']=="Primary")]
	recurrents=d.loc[(d['patient']==patient)&(d['npr']=="Recurrent")]
	if( len(primaries) > 0 ) and ( len(recurrents) > 0 ):
		for index, primary in primaries.iterrows():
			for index, recurrent in recurrents.iterrows():
				out.loc[len(out.index)] = [patient,normal.iloc[0].Z,primary.Z,recurrent.Z]


print(out)
out.to_csv(output,sep="\t",index=False)

