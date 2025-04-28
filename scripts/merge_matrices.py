#!/usr/bin/env python3

import os    
import re
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

#	Don't use "nargs=1". It makes it an array.

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
#parser.add_argument('-o', '--output', nargs=1, type=str, default=['merged.csv.gz'],
parser.add_argument('-o', '--output', type=str, default='merged.csv.gz',
	help='output csv filename to %(prog)s (default: %(default)s)')

#parser.add_argument('--header_rows', nargs=1, type=int, default=[2],
parser.add_argument('--header_rows', type=int, default=[2],
	help='number of header rows to %(prog)s (default: %(default)s)')
#parser.add_argument('--index_cols', nargs=1, type=int, default=3,
#	help='number of index cols to %(prog)s (default: %(default)s)')

parser.add_argument('--index_col', type=str, action='append', required=True,
	help='index column names to be output to %(prog)s (default: %(default)s)')

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
print(args)

#output=args.output[0]
output=args.output
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
			header=list(range(args.header_rows)),
			index_col=list(range(len(args.index_col))))
#			header=[0,1],
#			index_col=[0,1,2])

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

	#	dropping the index makes it cleaner to write to csv
	df = df.sort_index().reset_index()
#	df.rename(level=0,columns={"level_0": "subject","level_1":"type", "level_2":"sample"},inplace=True)

#	#	when not unique (all are blank) this doesn't work)
#	for i in range(len(args.index_col)):
#		print(i," : ",args.index_col[i])
#		#	1  :  species
#		print(df.columns[i])
#		#	('level_1', '', '', '', '', '', '', '', '')
#		for level in list(range(df.columns.nlevels)):
#			print("setting level ",level,":",args.index_col[i])
#			print("Renaming",df.columns[i][level],"to",args.index_col[i])
#			df.rename(level=level,columns={ df.columns[i][level]: args.index_col[i] }, inplace = True)
#		print(df.columns[i])
#		#('species', '', '', '', '', '', '', '', '')

#	for i in range(len(args.index_col)):
#		df.columns[i]=(args.index_col[i],)*df.columns.nlevels


#   for i in range(len(args.index_col)):
#     print(i," : ",args.index_col[i])
#     print(df.columns[i])
#     df.rename(level=0,columns={ df.columns[i][0]: args.index_col[i] }, inplace = True)
#     print(df.columns[i])


	if args.header_rows > 1 :
		cols=df.columns.to_list()
		for i in range(len(args.index_col)):
			cols[i]=(args.index_col[i],)*df.columns.nlevels
		df.columns = pd.MultiIndex.from_tuples(cols)

	print(df.shape)

	print(df.head())

	print("Writing CSV: "+output)
	df.to_csv(output,index=False)

else:
	print("No data.")


