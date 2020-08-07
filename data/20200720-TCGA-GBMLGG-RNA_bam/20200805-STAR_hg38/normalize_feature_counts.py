#!/usr/bin/env python

import os    
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')

parser.add_argument('-r', '--read_counts', nargs=1, type=str, help='csv filename to %(prog)s (default: %(default)s)')
parser.add_argument('-f', '--feature_counts', nargs=1, type=str, help='csv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')

#	store_true means 'int=False unless --int passed, then int=True' (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()



#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


if isinstance(args.read_counts,list):
	read_counts=args.read_counts[0]
else:
	read_counts=args.read_counts
print( 'Using read_counts name: ', read_counts )

if isinstance(args.feature_counts,list):
	feature_counts=args.feature_counts[0]
else:
	feature_counts=args.feature_counts
print( 'Using feature_counts name: ', feature_counts )

#if isinstance(args.output,list):
#	output=args.output[0]
#else:
#	output=args.output
#print( 'Using output name: ', output )

#if isinstance(args.sep,list):
#	sep=args.sep[0]
#else:
#	sep=args.sep
#print( 'Using separator :', sep, ':' )




#	read read counts
#	comma sep

#if os.path.isfile(read_counts) and os.path.getsize(read_counts) > 0:
print('Reading '+read_counts)
d = pd.read_csv(read_counts,
	skipinitialspace=True,
	header=None,
	names=['sample','count'],
	dtype={'sample': str, 'count': int},
	sep=',')
#	index_col='sample' )

#d.set_index('sample')
#d.index = d.index.map(unicode) 

#	To force a column of just numbers to stay strings, particularly with leading zeroes.
d.set_index('sample', inplace=True)
#d.index




print(d.head())

print(d.index)


#	read feature counts
#	tab sep

#if os.path.isfile(feature_counts) and os.path.getsize(feature_counts) > 0:
print('Reading '+feature_counts)
df = pd.read_csv(feature_counts,
	comment='#',
	sep='\t')	#, header=True)

print(df.head())

for sample in d.index:
	df[sample]=df[sample].divide(d.loc[sample,'count']).multiply(1000000)

print(df.head())

#	normalize

print('Writing CSV')
#df.to_csv(feature_counts+'.normal.csv',index=False,sep='\t')
df.to_csv(os.path.splitext(feature_counts)[0]+'.normal.csv',index=False,sep='\t')


