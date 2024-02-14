#!/usr/bin/env python3


import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns


#for k in [9,10,11,12,13,14,15,16,17,18,19,20,21,25,31]:
for k in [9]:
	print(str(k))
	for source in ["raw","rescaled"]:
		print(source)

		input_file='V01/'+str(k)+'/kmers.'+source+'.count.Zscores.reordered.joined.csv'
		print(input_file)
		df = pd.read_csv(input_file,sep=",",index_col=0) 

		df=df.drop(['input', 'id_z', 'group_z', 'input.1'],axis='columns')

		df=df.drop(['SFHH005k','SFHH005ag'],axis='columns')
		df=df.drop(['SFHH005k_z','SFHH005ag_z'],axis='columns')

		#		df=df.loc[
		#			(abs(df['SFHH005k_z'])>3.5) &
		#			(abs(df['SFHH005ag_z'])>3.5) &
		#			(abs(df['SFHH011I_z'])>3.5) &
		#			(abs(df['SFHH011S_z'])>3.5) &
		#			(abs(df['SFHH011AC_z'])>3.5) &
		#			(abs(df['SFHH011BB_z'])>3.5) &
		#			(abs(df['SFHH011BZ_z'])>3.5) &
		#			(abs(df['SFHH011CH_z'])>3.5) &
		#			(abs(df['1_10_z'])>3.5) &
		#			(abs(df['2_10_z'])>3.5) &
		#			(abs(df['3_9_z'])>3.5) &
		#			(abs(df['4_9_z'])>3.5) &
		#			(abs(df['5_10_z'])>3.5) &
		#			(abs(df['6_2_z'])>3.5) &
		#			(abs(df['7_6_z'])>3.5) &
		#			(abs(df['8_3_z'])>3.5)
		#		]
		#
		#		df=df.drop(['SFHH005k_z', 'SFHH005ag_z',
		#			'SFHH011I_z', 'SFHH011S_z', 'SFHH011AC_z', 'SFHH011BB_z', 'SFHH011BZ_z',
		#			'SFHH011CH_z', '1_10_z', '2_10_z', '3_9_z', '4_9_z', '5_10_z', '6_2_z',
		#			'7_6_z', '8_3_z'],axis='columns')

		#	generalized with the following loop which produced identical results to the hardcode above
		#	loop through giant matrix. Split and keep only those with all absolute zscores larger than 3.5
		for column in df.columns[df.columns.str.contains("_z$")]:
			df=df.loc[(abs(df[column])>3.5)]
			df=df.drop([column],axis='columns')

		#for method in ["pearson","spearman","kendall"]:
		for method in ["pearson"]:
			print(method)

			out=pd.DataFrame(index=df.columns, columns=df.columns, dtype='float')

			for a in df:
				for b in df:
					#if(a==b):
					#	continue
					print("Compare ",a," to ",b)
					out[a][b]=df[a].corr(df[b], method=method)

			#print(out)
			#print(out.dtypes)
			out.to_csv(str(k)+".zscorefiltered."+source+"."+method+".csv")
			hm=sns.heatmap(out,vmin=0,vmax=1)
			plt.savefig( str(k)+".zscorefiltered."+source+"."+method+".png" )
			#del hm
			plt.clf()





