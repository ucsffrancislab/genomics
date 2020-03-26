#!/usr/bin/env python

import os    
import sys
#import pandas as pd
import dask.dataframe as dd


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-o', '--output', nargs=1, type=str, default='merged-jellyfish.csv', help='output csv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-p', '--percentage', nargs=1, type=int, default=50, help='the percentage to %(prog)s (default: %(default)s)')
#parser.add_argument('-d', '--depth', nargs=1, type=int, default=1, help='the depth to %(prog)s (default: %(default)s)')
#parser.add_argument('-n', '--name', nargs=1, type=str, default='Reference', help='the name to %(prog)s (default: %(default)s)')
#parser.add_argument('-l', '--length', nargs=1, type=int, default=1000000, help='the length to %(prog)s (default: %(default)s)')
#parser.add_argument('-e', '--expand', nargs=1, type=int, default=1000, help='the expand to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print(os.path.basename(__file__), " 1.0")
	quit()


#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

#if isinstance(args.percentage,list):
#	percentage=args.percentage[0]
#else:
#	percentage=args.percentage
#print( "Filtering commonality on sample percentage: ", percentage )
#
#if isinstance(args.depth,list):
#	depth=args.depth[0]
#else:
#	depth=args.depth
#print( "Filtering commonality on sample depth: ", depth )
#
#if isinstance(args.name,list):
#	name=args.name[0]
#else:
#	name=args.name
#print( "Using reference name: ", name )
#
#if isinstance(args.length,list):
#	length=args.length[0]
#else:
#	length=args.length
#print( "Using reference length: ", length )
#
#if isinstance(args.expand,list):
#	expand=args.expand[0]
#else:
#	expand=args.expand
#print( "Using region expand: ", expand )

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )





data_frames = []

for filename in args.files:  
#for filename in sys.argv[1:]:
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)
		#d = pd.read_csv(filename,
		#	older version of python and dask
		d = dd.read_csv(filename,
			sep=" ",
			header=None,
			usecols=[0,1],
			names=["mer",sample],
			compression='gzip', blocksize=None,
			dtype={sample: int} ).set_index('mer')
			#dtype={sample: int}, index_col=["mer"] )	#	old dask doesn't take index_col
		#print(d.head())
		#d.dtypes
		#d.info(verbose=True)
#		if( len(d.index) > 0 ):
		#print("Appending")
		data_frames.append(d)
#		else:
#			print("Empty. Ignoring.")
	else:
		print(filename + " is empty")



if len(data_frames) > 0:
	print("Concating all")
	#df = pd.concat(data_frames, axis=1, sort=True)
	df = dd.concat(data_frames, axis=1)	#	dask can't sort
	print(df.head())
	df.info(verbose=True)

	data_frames = []

	print("Replacing all NaN with 0")
	#df.fillna(0, inplace=True)
	df = df.fillna(0)	#	dask can't do inplace
	print(df.head())
	df.info(verbose=True)
	df.dtypes

	print("Converting all counts back to integers")
	#df = pd.DataFrame(df, dtype=int)
	df = df.astype(int)
	print(df.head())
	df.info(verbose=True)
	df.dtypes

	print("Writing CSV")
	df.to_csv(output,index_label="mer",single_file=True,compression='gzip')	#	dask defaults to multiple csv files.
	#	old dask doesn't do single file.

else:
	print("No data.")


