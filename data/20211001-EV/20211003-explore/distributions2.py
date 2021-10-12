#!/usr/bin/env python3

#	NEEDED IN ORDER TO PLOT REMOTELY
import matplotlib as mpl
mpl.use('Agg')

import pandas
import matplotlib.pyplot as plt
import glob
import os.path

plt.rcParams["figure.figsize"] = [18.0,8.0]

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

# read arguments from the command line
args = parser.parse_args()

for filename in args.files:  
	print("Processing "+filename)
	basename=os.path.basename(filename)

	d = pandas.read_csv(filename,
		skipinitialspace=True, sep=" ",
		header=None,
		names=["count","value"])

	print(d.head())
	print(d)
#	print(d['count'].value_counts())

	if len(d) > 0:
		d.plot(
			x='value',
			y='count',
			title="Count chart of "+basename,
			kind='scatter')
		plt.savefig(basename+".png")
		plt.close()


