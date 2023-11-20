#!/usr/bin/env python3


import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("S1_virus_protein_bitscore.csv",index_col=[0,1])
print(df.head(10))

df=df.filter(regex=("_tumor"))


plt.figure(figsize=(25, 100))

from matplotlib.colors import LogNorm

sns_plot=sns.heatmap(df,
	norm=LogNorm(),
	cmap="vlag",
  xticklabels=True, yticklabels=True
)	#,annot=labels,fmt="",cmap='RdYlGn',linewidths=0.30,ax=ax)
#b.axes.set_title("Title",fontsize=50)


#sns.color_palette("vlag", as_cmap=True)

plt.tick_params(labelbottom = False, bottom=False, top = True, labeltop=True)
plt.xticks(rotation=60, horizontalalignment='left')

#plt.tick_params(axis='both', which='major', labelsize=10, labelbottom = False, bottom=False, top = False, labeltop=True)
#plt.tick_params(labelbottom = False, labeltop=True)


#	annot=True,	#	show all the data

sns_plot.set_title("Highest 25AA fragment bit score",fontsize=50)



plt.savefig("S1_virus_protein_bitscore.heatmap.png")

plt.show()

