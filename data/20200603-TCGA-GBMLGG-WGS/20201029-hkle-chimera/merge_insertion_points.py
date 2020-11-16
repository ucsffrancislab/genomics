#!/usr/bin/env python

import os    
import sys
import pandas as pd
import glob

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')

parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')
parser.add_argument('-s', '--sep', nargs=1, type=str, default='|', help='the separator to %(prog)s (default: %(default)s)')

parser.add_argument('-p','--pattern', nargs=1, type=str, default='', help='alternate file selector for when argument list would be too long')


#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

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

if isinstance(args.pattern,list):
	pattern=args.pattern[0]
else:
	pattern=args.pattern
print( "Using separator :", pattern, ":" )




data_frames = []

for filename in glob.glob(pattern) + args.files:
	print("Processing "+filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

#	02-2483-01A.SVAs_and_HERVs_KWHE.bowtie2.SVA_F.very_sensitive_local.unpaired.aligned.pre.bowtie2.hg38.Q20.rc_insertion_points
#	0 - 02-2483-01A
#	1 - SVAs_and_HERVs_KWHE
#	2 - bowtie2
# 3 - SVA_F
#	4 - very_sensitive_local
#	5 - unpaired
#	6 - aligned
# 7 - pre
# 8 - bowtie2
#	9 - hg38
# 10 - Q20
# 11 - rc_insertion_points

		filenameparts=basename.split(".")	#[0]	#	everything before the first "."
		sample=filenameparts[0]
		print("Reading "+filename+": Sample "+sample)

		raw=pd.read_csv( filename,
			sep=sep,
			header=None,
			names=['chromosome','position'])

		#raw['rp']=filenameparts[7]
		#raw['dir']=filenameparts[11][0]			####	f or r
		#raw['pup']=filenameparts[5][0]
		#raw['hkle']=filenameparts[3]
		#raw['q']=filenameparts[10][1:2]

		d=raw.groupby(raw.columns.tolist(),as_index=False).size().to_frame(sample)

		#	sample
		#	relpos
		#	direction
		#	pup
		#	hkle
		#	mapq
		d.columns=pd.MultiIndex.from_product([
			[sample],
			[filenameparts[7]],
			['reverse' if filenameparts[11][0]=='r' else 'forward'],
			[filenameparts[5]],
			[filenameparts[3]],
			[filenameparts[10]]
		])

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
	data_frames = []
	print(df.head())

	print("Replacing all NaN with 0")
	df.fillna(0, inplace=True)
##	df.info(verbose=True)
#	df.head()
##	df.dtypes
#
#	
#	if args.int:
	print("Converting all counts back to integers")
	df = pd.DataFrame(df, dtype=int)
	#	df.info(verbose=True)
	#	df.head()
	#	df.dtypes

	print("Writing CSV")
	df.to_csv(output,index_label=['chromosome','position'])
		#	sample
		#	relpos
		#	direction
		#	pup
		#	hkle
		#	mapq
	print("Writing transposed CSV")
	df.T.to_csv(output.replace('csv', 'T.csv', 1),index_label=['sample','relpos','direction','pup','hkle','mapq'])

else:
	print("No data.")


