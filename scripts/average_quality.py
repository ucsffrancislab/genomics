#!/usr/bin/env python3

import os
import gzip
import Levenshtein
import math

import pandas as pd
pd.set_option('display.max_colwidth', None)
pd.set_option('display.max_columns', None)


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

# read arguments from the command line
args = parser.parse_args()


#	qin=auto            Input quality offset: 33 (Sanger), 64, or auto.


for filename in args.files:  

	with gzip.open(filename,'rt') as file:
		i=0
		while i<50:
			i+=1
			line1 = file.readline().strip()
			line2 = file.readline()
			line3 = file.readline()
			line4 = file.readline().strip()
			print(line1)
			print(line4)
			print(sum([ord(c)-33 for c in line4])/len(line4))
			print(-10*math.log(sum([10**(-(ord(c)-33)/10) for c in line4])/len(line4),10))


