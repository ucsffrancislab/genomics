#!/usr/bin/env python3

import os    
import sys
import pandas as pd


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('-i', '--input', nargs=1, type=str,
	help='netMHCIIpan output filename to %(prog)s (default: %(default)s)')

#	default='human_herpes.netMHCpan.txt',

#parser.add_argument('files', nargs='*', help='files help')
#parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')
##parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
##	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()



#---------------------------------------------------------------------------------------------------------------------------
# Pos         MHC        Peptide      Core Of Gp Gl Ip Il        Icore        Identity  Score_EL %Rank_EL BindLevel
#---------------------------------------------------------------------------------------------------------------------------
#   1 HLA-A*02:01      HVAQAGFKL HVAQAGFKL  0  0  0  0  0    HVAQAGFKL   00000346-5-13 0.0514620    2.880
#---------------------------------------------------------------------------------------------------------------------------


rawdf=pd.read_csv(args.input[0], sep="\s+",header=None,skipinitialspace=True,
skiprows=17,skipfooter=3,
names=["Pos","MHC","Peptide","Of","Core","Core_Rel","Inverted","Identity","Score_EL","%Rank_EL","Exp_Bind","extra","BindLevel"]
)
print(rawdf.head())
#rawdf.dropna(inplace=True)

rawdf['Tile']=rawdf['Identity'].apply(lambda x: str(x).split('_')[0])
print(rawdf.head())



df = rawdf.drop('Pos', axis=1)
print(df.head())

print("Current size")
print(df.shape)

print("Dropping any duplicates")
df = df.drop_duplicates()
print(df.shape)


#                            MHC Alleles ..........
# Identity - Icore/Peptide -

#df=rawdf.pivot(index=['Tile','Icore'], columns='MHC', values='%Rank_EL')
#df=rawdf.pivot(index=['Tile','Icore','Pos'], columns='MHC', values='%Rank_EL')
#df=rawdf.pivot(index=['Tile','Peptide','Pos'], columns='MHC', values='%Rank_EL')
#df=df.pivot(index=['Tile','Icore'], columns='MHC', values='%Rank_EL')
df=df.pivot(index=['Tile','Peptide'], columns='MHC', values='%Rank_EL')
print(df.head())

print(df.shape)

df.to_csv( args.input[0].rsplit('.',1)[0]+".csv",index_label=['Tile','Peptide'])

#Tile,Peptide,HLA-A*0101,HLA-A*0102,HLA-A*0103,HLA-A*0201,HLA-A*0202,HLA-A*0203,HLA-A*0205,HLA-A*0206,HLA-A*0207,HLA-A*0211,HLA-A*0216
#100,RNDQTHDESY,,0.187,,,,,,,,,
#10000,ALHLDSLNLI,,,,,,0.403,,,,,0.42
#10000,ATVPLPHVTY,0.206,0.121,0.18,,,,,,,,
#10000,ITADKIIATV,,,,,,0.407,0.215,0.305,,,
#10000,TVPLPHVTYI,,,,,,,,,0.465,,
#10001,ATVPLPHVTY,0.206,0.121,0.18,,,,,,,,
#10001,TVPLPHVTYI,,,,,,,,,0.465,,
#10002,PLCDSVIMSY,0.243,,0.299,,,,,,,,

