#!/usr/bin/env python

import os    
import sys
import pandas as pd
from multiprocessing import Pool

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-o', '--output', nargs=1, type=str, default='merged-jellyfish.csv', help='output csv filename to %(prog)s (default: %(default)s)')

parser.add_argument('-p', '--threads', nargs=1, type=int, default=8, help='Pool threads to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print(os.path.basename(__file__), " 1.0")
	quit()


#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )

if isinstance(args.threads,list):
	threads=args.threads[0]
else:
	threads=args.threads
print( "Using threads: ", threads )



# wrap your csv importer in a function that can be mapped
def read_csv(filename):
	'converts a filename to a pandas dataframe'
	basename=os.path.basename(filename)
	sample=basename.split(".")[0]	#	everything before the first "."
	print("Reading "+filename+": Sample "+sample)
		#error_bad_lines=False,
	return pd.read_csv(filename,
		sep="\s+",
		header=None,
		usecols=[0,1],
		names=["sequence",sample],
		dtype={sample: int},
		index_col=["sequence"] )





data_frames = []



for filename in args.files:  
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)
		sample=basename.split(".")[0]	#	everything before the first "."
		print("Reading "+filename+": Sample "+sample)
		d = read_csv(filename)
		d.head()
		d.dtypes
		d.info(verbose=True)
#		if( len(d.index) > 0 ):
		print("Appending")
		data_frames.append(d)
#		else:
#			print("Empty. Ignoring.")
	else:
		print(filename + " is empty")



#	#	python3
#	# set up your pool
#	#with Pool(processes=threads) as pool: # or whatever your hardware can support
#	#
#	#	# have your pool map the file names to dataframes
#	#	data_frames = pool.map(read_csv, args.files)
#	
#	#	python2
#	pool = Pool(threads)
#	data_frames = pool.map(read_csv, args.files)






if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	df.info(verbose=True)

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
	df.to_csv(output,index_label="sequence")

else:
	print("No data.")


