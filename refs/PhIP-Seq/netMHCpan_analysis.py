#!/usr/bin/env python3

import os    
import sys
import pandas as pd


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('-i', '--input', nargs=1, type=str,
	help='netMHCpan output filename to %(prog)s (default: %(default)s)')

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

#rawdf=pd.read_csv("/francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.txt", sep="\s+",header=None,skipinitialspace=True,

rawdf=pd.read_csv(args.input[0], sep="\s+",header=None,skipinitialspace=True,
names=["Pos","MHC","Peptide","Core","Of","Gp","Gl","Ip","Il","Icore","Identity","Score_EL","%Rank_EL","extra","BindLevel"]
)
print(rawdf.head())
rawdf.dropna(inplace=True)

rawdf['Tile']=rawdf['Identity'].apply(lambda x: str(x).split('_')[0])
print(rawdf.head())

#./netMHCpan_analysis.py 
#   Pos         MHC     Peptide       Core  Of  Gp  Gl  Ip  Il       Icore         Identity  Score_EL  %Rank_EL extra BindLevel
#0   22  HLA-A*0101  DTLFSRLEEY  DTFSRLEEY   0   2   1   0   0  DTLFSRLEEY  45_Human_herpes  0.351116     0.461    <=        SB
#1   26  HLA-A*0101  SVMDWLLRRY  SVDWLLRRY   0   2   1   0   0  SVMDWLLRRY  48_Human_herpes  0.358801     0.449    <=        SB
#2   33  HLA-A*0101  DTLFSRLEEY  DTFSRLEEY   0   2   1   0   0  DTLFSRLEEY  50_Human_herpes  0.351116     0.461    <=        SB
#3   27  HLA-A*0101  DTLFSRLEEY  DTFSRLEEY   0   2   1   0   0  DTLFSRLEEY  54_Human_herpes  0.351116     0.461    <=        SB
#4   42  HLA-A*0101  LTFNFTGHSY  LTNFTGHSY   0   2   1   0   0  LTFNFTGHSY  141_Human_herpe  0.623302     0.202    <=        SB


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


