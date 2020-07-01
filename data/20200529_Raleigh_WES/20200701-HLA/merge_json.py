#!/usr/bin/env python

import json
import pandas as pd
import os    
import sys

from collections import defaultdict



# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()



#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )


data_frames = []

for filename in args.files:  

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0]	#	everything before the first "."
		parts=basename.split("-")
		sample=parts[1]

		print("Reading "+filename+": Sample "+sample)

		with open(filename) as f:
		  data = json.load(f)
		
		# Output: {'name': 'Bob', 'languages': ['English', 'Fench']}
		#print(data)
		#print
		
		#{u'subject_id': u'30T', u'creation_time': u'2020-06-30T15:39:32Z', u'report_version': u'1.2', u'report_type': u'hla_typing', u'sample_id': u'30T', u'hla': {u'alleles': [u'A*31:01', u'A*31:01', u'B*15:01N', u'B*15:08', u'C*01:02', u'C*02:02', u'DPB1*04:02', u'DPB1*14:01', u'DQB1*04:02', u'DQB1*04:02', u'DRB1*04:10', u'DRB1*08:02']}}
		
		#print(data['hla']['alleles'])
		
		#print(df)
		dd = defaultdict(int)
		
		for v in data['hla']['alleles']:
			#print(v)
			dd[str(v)]+=1
		
		#print(dd)
		#print(dict(dd))
		
		df=pd.DataFrame.from_dict({sample: dd})
		#print(df)

		print("Appending")
		data_frames.append(df)
	else:
		print(filename + " is empty")
	
if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True)
#	df.info(verbose=True)

	data_frames = []

	print("Replacing all NaN with 0")
	df.fillna(0, inplace=True)
#	df.info(verbose=True)
	df.head()
#	df.dtypes

	
	if args.int:
		print("Converting all counts back to integers")
		df = pd.DataFrame(df, dtype=int)
	#	df.info(verbose=True)
	#	df.head()
	#	df.dtypes

	print("Writing CSV")
	df.to_csv(output,index_label="HLA")

else:
	print("No data.")


