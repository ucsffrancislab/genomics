#!/usr/bin/env python3


import pandas as pd


for k in [9,10,11,12,13,14,15,16,17,18,19,20,21,25,31]:
	print(str(k))
	for source in ["raw","rescaled"]:
		print(source)

		input_file='V01/'+str(k)+'/kmers.'+source+'.count.Zscores.reordered.joined.csv'
		print(input_file)
		dataset = pd.read_csv(input_file,sep=",",index_col=0) 

		df=dataset.loc[
			(abs(dataset['SFHH005k_z'])>3.5) &
			(abs(dataset['SFHH005ag_z'])>3.5) &
			(abs(dataset['SFHH011I_z'])>3.5) &
			(abs(dataset['SFHH011S_z'])>3.5) &
			(abs(dataset['SFHH011AC_z'])>3.5) &
			(abs(dataset['SFHH011BB_z'])>3.5) &
			(abs(dataset['SFHH011BZ_z'])>3.5) &
			(abs(dataset['SFHH011CH_z'])>3.5) &
			(abs(dataset['1_10_z'])>3.5) &
			(abs(dataset['2_10_z'])>3.5) &
			(abs(dataset['3_9_z'])>3.5) &
			(abs(dataset['4_9_z'])>3.5) &
			(abs(dataset['5_10_z'])>3.5) &
			(abs(dataset['6_2_z'])>3.5) &
			(abs(dataset['7_6_z'])>3.5) &
			(abs(dataset['8_3_z'])>3.5)
		]

		df=df.drop(['input', 'SFHH005k_z', 'SFHH005ag_z',
		'SFHH011I_z', 'SFHH011S_z', 'SFHH011AC_z', 'SFHH011BB_z', 'SFHH011BZ_z',
		'SFHH011CH_z', '1_10_z', '2_10_z', '3_9_z', '4_9_z', '5_10_z', '6_2_z',
		'7_6_z', '8_3_z', 'id_z', 'group_z', 'input.1'],axis='columns')

		for method in ["pearson","spearman","kendall"]:
			print(method)

			out=pd.DataFrame(index=df.columns, columns=df.columns)

			for a in df:
				for b in df:
					if(a==b):
						continue
					print("Compare ",a," to ",b)
					out[a][b]=df[a].corr(df[b], method=method)
					out.to_csv(str(k)+".zscorefiltered."+source+"."+method+".csv")

