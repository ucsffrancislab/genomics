#!/usr/bin/python3

import os    
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')

parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.matrix.tsv', help='output csv filename to %(prog)s (default: %(default)s)')


# read arguments from the command line
args = parser.parse_args()

data_frames=[]


#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )


for filename in args.files:  
	d = pd.read_csv(filename,
		sep="\t",
		header=[0,1],
		index_col=0
	)
	data_frames.append(d)


df = pd.concat(data_frames, axis=1, sort=True)
#print(df)

df.to_csv(output,sep="\t")

