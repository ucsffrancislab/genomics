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
		skipinitialspace=True, sep="\t",
		header=None,
		names=["i","count","total"])

	print(d.head())
#	print(d)
#	print(d['count'].value_counts())

	if len(d) > 0:

		d.plot(
			x='i',
			y='count',
			kind='line',
			legend=False)
#			title="Count chart of "+basename,
#			color="skyblue",
#			edgecolor='Black')
#		plt.suptitle("PolyA Count of "+basename,fontsize=20)
		plt.title("PolyA Count of "+basename,fontsize=20)
		plt.xlabel('PolyA Length',fontsize=16)
		plt.ylabel('Count',fontsize=16)
		plt.xticks(fontsize=16)
		plt.yticks(fontsize=16)
		plt.savefig(basename+".png")
		plt.close()


