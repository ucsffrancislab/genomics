#!/usr/bin/env python3

import os    
import sys
import pandas as pd

## include standard modules
#import argparse
#
## initiate the parser
#parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
#
#parser.add_argument('files', nargs='*', help='files help')
#parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
#
#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')
#
##parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
#
##	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
#
#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')
#
## read arguments from the command line
#args = parser.parse_args()



#~/.local/USalign/USalign -outfmt 2 fold_np_040188_model_0.cif fold_tcons_00000820_9_model_0.cif
#PDBchain1	PDBchain2	TM1	TM2	RMSD	ID1	ID2	IDali	L1	L2	Lali
#fold_np_040188_model_0.cif:A	fold_tcons_00000820_9_model_0.cif:A	0.5543	0.3861	3.28	0.137	0.093	0.217	393	581	249


#infile=/francislab/data1/refs/PhIP-Seq/human_herpes_usalign.tsv
#pdbs=$( cut -f1 human_herpes_usalign_TEST.tsv | cut -f1 -d: | uniq )

#	/francislab/data1/refs/PhIP-Seq/human_herpes/10000/ranked_0.pdb:A
#	Always A Chain so far

df=pd.read_csv("/francislab/data1/refs/PhIP-Seq/human_herpes_usalign.tsv", sep="\t", header=None,
names=["PDBchain1","PDBchain2","TM1","TM2","RMSD","ID1","ID2","IDali","L1","L2","Lali"]
)

print(df.head())

df['PDBchain1']=df['PDBchain1'].apply(lambda x: 
os.path.basename(os.path.dirname(x))+'_'+os.path.basename(x).split('_')[1].split('.')[0]
)

df['PDBchain2']=df['PDBchain2'].apply(lambda x: 
os.path.basename(os.path.dirname(x))+'_'+os.path.basename(x).split('_')[1].split('.')[0]
)

df['aveTM']=(df['TM1']+df['TM2'])/2

df=df[['PDBchain1','PDBchain2','aveTM']]
print(df.head())

df=df.pivot(index='PDBchain1', columns='PDBchain2', values='aveTM')
print(df.iloc[1:9,1:9])

print(df.shape)

df.fillna(0, inplace=True)

df.to_csv('human_herpes_usalign_TMscores.csv',index_label=['xxx'])


