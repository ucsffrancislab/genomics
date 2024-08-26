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

#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()



output=args.output[0]



data_frames = []

for filename in args.files:  
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0]	#	everything before the first "."
		#sample=basename.split(".")[0]	#	everything before the first "."

		print("Reading "+filename)#+": Sample "+sample)

		d = pd.read_csv(filename,
			skipinitialspace=True,
			sep=",",index_col=[0])
			#header=None)
		#d[[sample,'sequence']] = d['sequence'].str.split(" ", 1, expand=True)

		if args.seqint:
			d[sample]=d[sample].astype(int)
			#d['sequence']=d['sequence'].astype(int)

		#d.set_index('sequence',inplace=True)
		#d.set_index('Transcript_Name',inplace=True)
		print(d.head())

		print("Appending")

                #   convert to strings to don't get converted to floats if any are missing in concat
		data_frames.append(d.astype('string'))
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	data_frames = []

#	print("Replacing all NaN with 0")
#	df.fillna(0, inplace=True)

#	df.info(verbose=True)
#	df.head()
#	df.dtypes

	
	if args.int:
		print("Converting all counts back to integers")
		df = pd.DataFrame(df, dtype=int)
	#	df.info(verbose=True)
	#	df.head()
	#	df.dtypes

	print("Writing CSV")
	#df.to_csv(output,index_label=['chromosome','position'])
	#df.to_csv(output,index_label=['sequence'])
	#df.to_csv(output,index_label=['Transcript_Name'])
	df.to_csv(output,index_label=['Transcript'])

else:
	print("No data.")


