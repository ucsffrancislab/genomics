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

parser.add_argument('-o', '--output', nargs=1, type=str, default=['merged.csv.gz'], help='output csv filename to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()


output=args.output[0]
print( "Using output name: ", output )


data_frames = []

for filename in args.files:  
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#	q40.TR1.count.Zscores.sample_output_PED_9.virus_scores.abovethreshold.txt
		sample = basename.split(".")[4]
		sample = sample[14:]

		print("Reading "+filename+": Sample "+sample)

		#	this is the only way to read a file separated by spaces but containing spaces.

		d = pd.read_csv(filename,
			skipinitialspace=True,
			sep="\t",
			header=None,
			names=['virus'])
		d[sample]=1

		d.set_index('virus',inplace=True)
		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	data_frames = []

	print("Replacing all NaN with 0")
	df.fillna(0, inplace=True)
#	df.info(verbose=True)
#	df.head()
#	df.dtypes

	df = pd.DataFrame(df, dtype=int)
	
	print("Writing CSV")
	#df.to_csv(output,index_label=['chromosome','position'])
	#df.to_csv(output,index_label=['sequence'])
	df.to_csv(output,index_label=['virus'])

else:
	print("No data.")


