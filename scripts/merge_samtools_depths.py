#!/usr/bin/env python

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
parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')


#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()



#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )

if isinstance(args.sep,list):
	sep=args.sep[0]
else:
	sep=args.sep
print( "Using separator :", sep, ":" )




data_frames = []

for filename in args.files:  
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)

		d = pd.read_csv(filename,
			sep="\t",
			header=None,
			usecols=[0,1,2],
			names=['chromosome','position',sample],
			index_col=['chromosome','position'])

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	data_frames = []

#	print("Replacing all NaN with 0")
#	df.fillna(0, inplace=True)
##	df.info(verbose=True)
#	df.head()
##	df.dtypes
#
#	
#	if args.int:
#		print("Converting all counts back to integers")
#		df = pd.DataFrame(df, dtype=int)
#	#	df.info(verbose=True)
#	#	df.head()
#	#	df.dtypes

	print("Writing CSV")
	df.to_csv(output,index_label=['chromosome','position'])

else:
	print("No data.")


