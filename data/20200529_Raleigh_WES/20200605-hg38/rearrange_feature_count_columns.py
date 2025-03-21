#!/usr/bin/env python


import os
import sys
import pandas as pd


#for filename in sys.argv[1:]:



print( sys.argv[1] )
filename = sys.argv[1]

if os.path.isfile(filename) and os.path.getsize(filename) > 0:
	print('Reading '+filename)
	d = pd.read_csv(filename,
		comment='#',
		sep='\t')
#	header=None,
#	names=['sample','count'],
#	sep=',',
#	index_col=['sample'] )

	print(d.head())
	print(d.columns)
	d=d[['Geneid', 'Chr', 'Start', 'End', 'Strand', 'Length', '30N', '41N', '47N', '51N', '53N', '58N', '71N', '76N', '84N', '30T', '41T', '47T', '50T', '51T', '53T', '58T', '71T', '76T', '84T', '31N', '35N', '37N', '62N', '79N', '31T', '35T', '37T', '62T', '79T', '60N', '60T','50N']]
	print(d.head())
	print(d.columns)
	d.to_csv(os.path.splitext(filename)[0]+'.rearranged.csv',index=False,sep='\t') 

else:
	print("File doesn't exist")

