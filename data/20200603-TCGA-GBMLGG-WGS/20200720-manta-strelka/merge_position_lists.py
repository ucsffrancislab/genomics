#!/usr/bin/env python

import os    
import sys
import pandas as pd
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print(os.path.basename(__file__), " 1.0")
	quit()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


#	perhaps I can set the default as a list of one item instead?


if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )


data_frames = []

for filename in args.files:  
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		namepieces=basename.split(".")
		sample=namepieces[0]
#		hkle=namepieces[1]
#		pstatus=namepieces[2]
#		mapq=namepieces[3]
#		rounding=namepieces[5]
		print("Reading "+filename+": Sample "+sample)
		#	sep=" ",
		d = pd.read_csv(filename,
			header=None,
#			names=["position"],
#			index_col=["position"] )
			sep=':',
			usecols=[0,1],
			names=["chromosome","position"],
			index_col=["chromosome","position"] )
		print(d.head())
		if not d.index.is_unique:
			quit()

		#d.columns=[[sample],[hkle],[pstatus],[mapq],[rounding]]
		#d.dtypes
		d[sample]=1
		d.info(verbose=True)
		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")

if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	df.info(verbose=True)

	print(df.head())

	data_frames = []

	print("Replacing all NaN with 0")
	df.fillna(0, inplace=True)
	df.info(verbose=True)
	print(df.head())
	df.dtypes

	print("Converting all counts back to integers")
	df = pd.DataFrame(df, dtype=int)
	df.info(verbose=True)
	print(df.head())
	df.dtypes

	print("Writing CSV")
	#df.to_csv(output,index_label="position")
	df.to_csv(output,index_label=["chromosome","position"])

else:
	print("No data.")


