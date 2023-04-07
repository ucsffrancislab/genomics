#!/usr/bin/env python3

import os
import sys
import numpy as np
import pandas as pd


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')

parser.add_argument('-a', nargs=1, type=str, help='first bed filename to %(prog)s (default: %(default)s)')
parser.add_argument('-b', nargs=1, type=str, help='second bed filename to %(prog)s (default: %(default)s)')
parser.add_argument('-o', '--output', nargs=1, type=str, default="intersection.bed", help='output bed filename to %(prog)s (default: %(default)s)')
##parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
##	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.a,list):
	a=args.a[0]
else:
	a=args.a
print( "Using a name: ", a )

if isinstance(args.b,list):
	b=args.b[0]
else:
	b=args.b
print( "Using b name: ", b )

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )

serieses=[]

#for filename in sys.argv[1:]:
for filename in [a,b]:
	print(filename)
	df=pd.read_csv(filename,
		sep="\t",
		comment="@",
		header=None,
		usecols=[0,1,2],
		names=['CHR','START','STOP'])

	print(df)

	series={}

	for index, row in df.iterrows():
		#print(row)
		if row['CHR'] in series:
			series[row['CHR']]=np.concatenate([series[row['CHR']],np.arange(row['START'],row['STOP']+1)])
		else:
			series[row['CHR']]=np.arange(row['START'],row['STOP']+1)
			
	print(series)
	del df

	print("Appending")
	serieses.append(series)
	del series


print(serieses)

print(list(serieses[0].keys()))
print(list(serieses[1].keys()))

keys=np.concatenate([list(serieses[0].keys()),list(serieses[1].keys())])

print(np.unique(keys))

print("Intersecting")
intersection={}
for k in np.unique(keys):
	intersection[k]=np.intersect1d(serieses[0][k],serieses[1][k])

print (intersection)


print("Ranging")

ranges=pd.DataFrame(columns=["CHR","START","STOP"])
start=-1
stop=-1
for k in intersection.keys():
	for i in intersection[k]:
		if(i==stop+1):
			stop=i
		else:
			if(start>0):
				print(k,start,stop)
				ranges = ranges.append({'CHR' : k, 'START' : start, 'STOP' : stop},
        	ignore_index = True)
			start=i
			stop=i



print("Writing CSV")
ranges.to_csv(output,sep="\t",header=False,index=False)

