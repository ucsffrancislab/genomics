#!/usr/bin/env python

import pandas as pd
import glob

from pandarallel import pandarallel
pandarallel.initialize()




#def parallelize_dataframe(df, func, n_cores=4):
#	df_split = np.array_split(df, n_cores)
#	pool = Pool(n_cores)
#	df = pd.concat(pool.map(func, df_split))
#	pool.close()
#	pool.join()
#	return df
#
#train = parallelize_dataframe(train_df, add_features)


base='NA12878.SVAs_and_HERVs_KWHE.e2e.all.positions.csv'
print("Reading base ",base)
ref = pd.read_csv(base, header=None, names=['contig','position','HKLE'])

for f in sorted(glob.glob('NA12878.??-??.P.e2e.all.positions.csv')+glob.glob('NA12878.*_primers.P.e2e.all.positions.csv')):
	s=f.replace('NA12878.','')
	s=s.replace('.e2e.all.positions.csv','')
	print("Processing ",f)
	sample = pd.read_csv(f, header=None, usecols=[0,1],names=['contig','position'])
	#ref[s] = ref.apply( lambda row: len(sample[
	ref[s] = ref.parallel_apply( lambda row: len(sample[
		( sample['contig'] == row['contig'] )
		& ( sample['position'] > ( row['position'] - 1000 ) )
		& ( sample['position'] < ( row['position'] + 1000 ) )
	]), axis='columns' )

ref.to_csv('NA12878.SVAs_and_HERVs_KWHE.e2e.all.coverage.csv')



#	df = pd.read_csv('NA12878.SVAs_and_HERVs_KWHE.e2e.all.coverage.csv')
#	print(df.iloc[:,4:len(df.columns)].sum(axis='index'))


base='NA12878.primers.P.e2e.all.positions.csv'
print("Reading base ",base)
ref = pd.read_csv(base, header=None, names=['contig','position','HKLE'])

for f in sorted(glob.glob('NA12878.??-??.?.e2e.all.positions.csv')):
	s=f.replace('NA12878.','')
	s=s.replace('.e2e.all.positions.csv','')
	print("Processing ",f)
	sample = pd.read_csv(f, header=None, usecols=[0,1],names=['contig','position'])
	#ref[s] = ref.apply( lambda row: len(sample[
	ref[s] = ref.parallel_apply( lambda row: len(sample[
		( sample['contig'] == row['contig'] )
		& ( sample['position'] > ( row['position'] - 1000 ) )
		& ( sample['position'] < ( row['position'] + 1000 ) )
	]), axis='columns' )

ref.to_csv('NA12878.primers.e2e.all.coverage.csv')


