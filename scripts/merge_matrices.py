#!/usr/bin/env python3

import os    
import re
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
parser.add_argument('-o', '--output', nargs=1, type=str, default=['merged.csv.gz'],
	help='output csv filename to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true',
	help='convert values to ints to %(prog)s (default: %(default)s)')
parser.add_argument('--de_nan', action='store_true',
	help='convert Nans to 0s to %(prog)s (default: %(default)s)')
parser.add_argument('--de_neg', action='store_true',
	help='convert negatives to 0s to %(prog)s (default: %(default)s)')

parser.add_argument( "--axis",
    choices=['index', 'columns'],
    default='index',
    help="Concat along index or columns axis (default: %(default)s)"
)

# read arguments from the command line
args = parser.parse_args()

output=args.output[0]
print( "Using output name: ", output )

data_frames = []

for filename in args.files:  
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		sample=basename.split(".")[0]	#	everything before the first "."

		print("Reading "+filename+": Sample "+sample)

		d = pd.read_csv(filename,
			skipinitialspace=True,
			sep=",", low_memory=False,
			header=[0,1],
			index_col=[0,1,2])

		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")

if len(data_frames) > 0:
	print("Concating all")



	#df = pd.concat(data_frames, axis=1, sort=True)
	#df = pd.concat(data_frames, axis=0, sort=True)      # <--- add option for this
	df = pd.concat(data_frames, axis=args.axis, sort=True)      # <--- add option for this



	data_frames = []

	if args.de_nan:
		print("Replacing all NaN with 0")
		df.fillna(0, inplace=True)

	if args.int:
		print("Converting all counts back to integers")
		df = pd.DataFrame(df, dtype=int)

	if args.de_neg:
		print("Replacing all negatives with 0")
		df[df < 0] = 0

	df = df.sort_index().reset_index()
	df.rename(level=0,columns={"level_0": "subject","level_1":"type", "level_2":"sample"},inplace=True)

	print("Writing CSV: "+output)
	df.to_csv(output,index=False)

else:
	print("No data.")


