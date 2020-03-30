#!/usr/bin/env python

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
		sep="\t",
		header=None,
		usecols=[1,2],
		names=["position","depth"])
		#,
		#	index_col="position")

	if len(d) > 0:
		#d.fillna(0).reset_index().plot(
		d.plot(
			title="Depth chart of "+basename,
			logy=False,kind='scatter',x='position',y='depth',ylim=[1,10000])
		plt.savefig(basename+".png")

