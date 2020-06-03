#!/usr/bin/env python

import numpy as np
import pandas as pd

base="USC-CHLA-NBL"

#source  molecule  sample  subject  read_count  blast_err_count  qaccver  saccver  pident  length  mismatch  gapopen  qstart  qend  sstart  send  evalue  bitscore

#  don't use 'category' as crashes when trying to 'reset_index'

print('Reading '+base+'.viral.genomic.csv.gz')
genomic=pd.read_csv(base+'.viral.genomic.csv.gz', sep='\t',
  usecols=['sample','subject','read_count','blast_err_count','qaccver','saccver'],
  dtype={'sample':'str','subject':'str','read_count':np.int32,'blast_err_count':np.int32,'qaccver':'str','saccver':'str'})
#sys:1: DtypeWarning: Columns (3) have mixed types. Specify dtype option on import or set low_memory=False.

print(genomic.head())
#          sample     subject  read_count  blast_err_count                                    qaccver      saccver
#0  080217_S10.R1  080217_S10       85060                0   NS500273:36:HJCKLBGX2:1:11101:11970:3647  NC_001710.1
#1  080217_S10.R1  080217_S10       85060                0    NS500273:36:HJCKLBGX2:1:11101:5155:4216  NC_005856.1
#2  080217_S10.R1  080217_S10       85060                0    NS500273:36:HJCKLBGX2:1:11101:5155:4216  NC_022749.1
#3  080217_S10.R1  080217_S10       85060                0  NS500273:36:HJCKLBGX2:1:11104:10672:10013  NC_032111.1
#4  080217_S10.R1  080217_S10       85060                0   NS500273:36:HJCKLBGX2:1:11106:9610:12471  NC_001710.1

print('genomic.info()')
print(genomic.info())
#print('genomic.shape')
#print(genomic.shape)
print('len(genomic)')
print(len(genomic))

print('Dropping any duplicates as sometimes reads align to multiple places in the same virus')
genomic.drop_duplicates(inplace=True)

print('genomic.info()')
print(genomic.info())
#print('genomic.shape')
#print(genomic.shape)
print('len(genomic)')
print(len(genomic))

genomic.drop('qaccver',inplace=True,axis=1)
print('genomic.info()')
print(genomic.info())

#  count the number of hits
genomic=genomic.pivot_table(index=['subject','sample','read_count','blast_err_count'],
  columns='saccver', aggfunc=len, fill_value=0)
#  creates a 'super column' called 'saccver'
#  moves index columns to index so need to reset to drop
genomic.reset_index(inplace=True)
genomic.drop('sample',inplace=True,axis=1)
genomic=genomic.groupby('subject').sum()
#genomic.drop('index',axis=1,inplace=True)
genomic['reads']=genomic['read_count']-genomic['blast_err_count']
genomic.drop(['read_count','blast_err_count'],axis=1,inplace=True)
del genomic.columns.name  #  saccver
print(genomic.columns)

for column in genomic.columns:
  if column=='reads':
    continue 
  print(column)
  genomic[column]=genomic[column]/genomic['reads']

genomic.drop('reads',axis=1,inplace=True)







masked=pd.read_csv(base+'.viral.masked.csv.gz', sep='\t',
  usecols=['sample','subject','read_count','blast_err_count','qaccver','saccver'],
  dtype={'sample':'str','subject':'str','read_count':np.int32,'blast_err_count':np.int32,'qaccver':'str','saccver':'str'})
print('masked.info()')
print(masked.info())
print('Dropping any duplicates as sometimes reads align to multiple places in the same virus')
masked.drop_duplicates(inplace=True)
print('masked.info()')
print(masked.info())

masked.drop('qaccver',inplace=True,axis=1)
print('masked.info()')
print(masked.info())

#  count the number of hits
masked=masked.pivot_table(index=['subject','sample','read_count','blast_err_count'],
  columns='saccver', aggfunc=len, fill_value=0)
#  creates a 'super column' called 'saccver'
#  moves index columns to index so need to reset to drop
masked.reset_index(inplace=True)
masked.drop('sample',inplace=True,axis=1)
masked=masked.groupby('subject').sum()
#masked.drop('index',axis=1,inplace=True)
masked['reads']=masked['read_count']-masked['blast_err_count']
masked.drop(['read_count','blast_err_count'],axis=1,inplace=True)
del masked.columns.name  #  saccver
print(masked.columns)

for column in masked.columns:
  if column=='reads':
    continue 
  print(column)
  masked[column]=masked[column]/masked['reads']

masked.drop('reads',axis=1,inplace=True)







for column in genomic.columns:
	if column not in masked.columns:
		masked[column]=0
genomic=genomic.add_suffix('_genomic')
masked=masked.add_suffix('_masked')





merged=genomic.merge(masked,on='subject',how='outer')	#,suffixes=('_genomic','_masked'))
merged=merged.reindex(sorted(merged.columns), axis=1)

merged.to_csv(base+'.viral.merged.csv.gz',float_format='%0.10f')




