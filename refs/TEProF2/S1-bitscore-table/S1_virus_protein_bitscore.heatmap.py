#!/usr/bin/env python3


import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys

#df = pd.read_csv("S1_virus_protein_bitscore.csv",index_col=[0,1])
#df = pd.read_csv("S1_virus_protein_bitscore.csv")
df = pd.read_csv(sys.argv[1])
print(df.head(10))


#	HHV1,2,3,4 and 5
#df=df[df.virus.str.contains("HHV[12345]")]

df=df.set_index(["virus","protein"])

df=df.filter(regex=("_tumor"))

print(df.head(10))

from matplotlib.colors import LogNorm





#	vmin = df.values.min()
#	vmax = df.values.max()
#	
#	plt.close('all')
#	fig = plt.figure(figsize=(25, 90))
#	
#	ax1 = plt.subplot2grid((6, 2), (0, 0))
#	ax2 = plt.subplot2grid((6, 2), (1, 0))
#	ax3 = plt.subplot2grid((6, 2), (2, 0))
#	ax4 = plt.subplot2grid((6, 2), (3, 0))
#	ax5 = plt.subplot2grid((6, 2), (4, 0))
#	ax6 = plt.subplot2grid((6, 2), (5, 0))
#	ax7 = plt.subplot2grid((3, 2), (0, 1), rowspan=6)
#	
#	
#	#fig.set_title("Highest 25AA fragment bit score",fontsize=50)
#	fig.suptitle("Highest 25AA fragment bit score",fontsize=50)
#	
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV1"], 
#	xticklabels=True, yticklabels=True, annot=False,
#	norm=LogNorm(), cmap="YlOrBr", 
#	cbar=False, ax=ax1, vmin=vmin, vmax=vmax)
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV2"], 
#	norm=LogNorm(), cmap="YlOrBr",
#	xticklabels=True, yticklabels=True, annot=False,
#	cbar=False, ax=ax2, vmin=vmin, vmax=vmax)
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV3"], 
#	norm=LogNorm(), cmap="YlOrBr",
#	xticklabels=True, yticklabels=True, annot=False,
#	cbar=False, ax=ax3, vmin=vmin, vmax=vmax)
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV4"], 
#	norm=LogNorm(), cmap="YlOrBr",
#	xticklabels=True, yticklabels=True, annot=False,
#	cbar=False, ax=ax4, vmin=vmin, vmax=vmax)
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV4t2"], 
#	norm=LogNorm(), cmap="YlOrBr",
#	xticklabels=True, yticklabels=True, annot=False,
#	cbar=False, ax=ax5, vmin=vmin, vmax=vmax)
#	
#	sns.heatmap(df[df.index.get_level_values(0)=="HHV5"], 
#	norm=LogNorm(), cmap="YlOrBr",
#	xticklabels=True, yticklabels=True, annot=False,
#	cbar=False, ax=ax6, vmin=vmin, vmax=vmax)
#	
#	
#	
#	#fig.colorbar(axs[5,0].collections[0], cax=axs[1,0])
#	fig.colorbar(ax1.collections[0], cax=ax7)





fig = plt.figure(figsize=(25, 200))

sns_plot=sns.heatmap(df,
	norm=LogNorm(),
	cmap="YlOrBr",
  xticklabels=True, yticklabels=True
)
plt.tick_params(labelbottom = False, bottom=False, top = True, labeltop=True)
plt.xticks(rotation=60, horizontalalignment='left')

#plt.tick_params(axis='both', which='major', labelsize=10, labelbottom = False, bottom=False, top = False, labeltop=True)
#plt.tick_params(labelbottom = False, labeltop=True)

#plt.savefig("S1_virus_protein_bitscore.heatmap.png")
plt.savefig(str(sys.argv[1])+".png")

plt.tight_layout()
plt.show()

