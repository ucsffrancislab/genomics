#!/usr/bin/env python3

import os    
import sys
import pandas as pd

import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
#from mpl_toolkits.axes_grid1 import AxesGrid

# Some random data
#values1 = np.random.rand(10,10)
#values2 = np.random.rand(10,10)
#values3 = np.random.rand(10,10)
#values4 = np.random.rand(10,10)
#vals = [values1,values2,values3,values4,
 #values1,values2,values3,values4,
 #values1,values2,values3,values4,
 #values1,values2,values3,values4]


files=[
	"idxstats.All8.above_threshold.csv",
	"idxstats.TR1.above_threshold.csv",
	"idxstats.TR2.above_threshold.csv",
	"idxstats.Zero.above_threshold.csv",
	"q20.All8.above_threshold.csv",
	"q20.TR1.above_threshold.csv",
	"q20.TR2.above_threshold.csv",
	"q20.Zero.above_threshold.csv",
	"q30.All8.above_threshold.csv",
	"q30.TR1.above_threshold.csv",
	"q30.TR2.above_threshold.csv",
	"q30.Zero.above_threshold.csv",
	"q40.All8.above_threshold.csv",
	"q40.TR1.above_threshold.csv",
	"q40.TR2.above_threshold.csv",
	"q40.Zero.above_threshold.csv" ]

vals = []

for filename in files:  
	print("Processing "+filename)
	basename=os.path.basename(filename)

	#	q40.TR1.abovethreshold.txt
	#x = basename.split(".")[1]
	#y = basename.split(".")[1]

	#print("Reading "+filename+": Sample "+sample)

	#	this is the only way to read a file separated by spaces but containing spaces.

	d = pd.read_csv(filename, sep=",", index_col='virus')
	print(d.head())

	#d	= open(filename)

	vals.append(d)

i=0
for d in vals:
	i+=1
	plt.subplot(4, 4, i)
	sns.heatmap(d, cmap="plasma", cbar=False)

plt.show()


#	the heatmaps are too dense to really get anything from
#	abandoning this

