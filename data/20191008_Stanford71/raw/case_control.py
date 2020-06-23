#!/usr/bin/env python

import pandas as pd

#	when index_col in an integer, it is relative to the usecols array
a=pd.read_csv("sample sheet_cfDNA+Exosome-miRNA seq_himc091919 - Sheet1.csv",
	usecols=[0,1])	#, index_col=1)
a.rename(columns={" Sample Barcode": "Barcode"},inplace=True)
a.dropna(inplace=True)
print(a.head())

b=pd.read_csv("Serum_sample_list_77_case_control_03Oct2019 - Serum_sample_77.csv",
	usecols=[2,4])	#, index_col=0)
b.rename(columns={"Specimen_Barcode": "Barcode"},inplace=True)
print(b.head())

merged=a.merge(b)
print(merged.head())
print(merged.shape)

merged['id'] = merged['Sample number'].str.split('_', expand=True)[1].astype(str)
merged['id'] = merged['id'].apply(lambda x: x.zfill(2))
print(merged.head())

merged['cc'] = merged['casetype'].apply(lambda x: 'Control' if 'ontrol' in x else 'Case')
print(merged.head())

final = merged[['id','cc']].sort_values('id')
print(final)

final.to_csv('metadata.csv',index = None, header=True)

