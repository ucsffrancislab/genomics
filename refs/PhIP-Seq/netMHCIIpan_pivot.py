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



#  Pos        MHC          Peptide Of       Core Core_Rel Inverted         Identity  Score_EL  %Rank_EL  Exp_Bind extra BindLevel
#0   1  DRB1_0101  MNDVDATDTFVGQGK  3  VDATDTFVG    0.980        0  NP_040188_1_ser  0.003109     35.29       NaN   NaN       NaN
#1   2  DRB1_0101  NDVDATDTFVGQGKF  2  VDATDTFVG    0.930        0  NP_040188_1_ser  0.000689     52.97       NaN   NaN       NaN
#2   3  DRB1_0101  DVDATDTFVGQGKFR  1  VDATDTFVG    0.530        0  NP_040188_1_ser  0.000042     85.71       NaN   NaN       NaN
#3   4  DRB1_0101  VDATDTFVGQGKFRG  6  FVGQGKFRG    0.750        0  NP_040188_1_ser  0.000230     66.90       NaN   NaN       NaN
#4   5  DRB1_0101  DATDTFVGQGKFRGA  5  FVGQGKFRG    0.960        0  NP_040188_1_ser  0.002755     36.56       NaN   NaN       NaN


#rawdf=pd.read_csv("/francislab/data1/refs/PhIP-Seq/MHC/human_herpes.netMHCpan.txt", sep="\s+",header=None,skipinitialspace=True,

rawdf=pd.read_csv(args.input[0], sep="\s+",header=None,skipinitialspace=True,
skiprows=17,skipfooter=3,
names=["Pos","MHC","Peptide","Of","Core","Core_Rel","Inverted","Identity","Score_EL","%Rank_EL","Exp_Bind","extra","BindLevel"]
)
print(rawdf.head())
#rawdf.dropna(inplace=True)

#rawdf['Tile']=rawdf['Identity'].apply(lambda x: str(x).split('_')[0])
#print(rawdf.head())


#	  Pos        MHC          Peptide Of       Core Core_Rel Inverted         Identity  Score_EL  %Rank_EL  Exp_Bind extra BindLevel
#	0   1  DRB1_0101  MNDVDATDTFVGQGK  3  VDATDTFVG    0.980        0  NP_040188_1_ser  0.003109     35.29       NaN   NaN       NaN
#	1   2  DRB1_0101  NDVDATDTFVGQGKF  2  VDATDTFVG    0.930        0  NP_040188_1_ser  0.000689     52.97       NaN   NaN       NaN
#	2   3  DRB1_0101  DVDATDTFVGQGKFR  1  VDATDTFVG    0.530        0  NP_040188_1_ser  0.000042     85.71       NaN   NaN       NaN
#	3   4  DRB1_0101  VDATDTFVGQGKFRG  6  FVGQGKFRG    0.750        0  NP_040188_1_ser  0.000230     66.90       NaN   NaN       NaN
#	4   5  DRB1_0101  DATDTFVGQGKFRGA  5  FVGQGKFRG    0.960        0  NP_040188_1_ser  0.002755     36.56       NaN   NaN       NaN

#	         MHC          Peptide Of       Core Core_Rel Inverted         Identity  Score_EL  %Rank_EL  Exp_Bind extra BindLevel
#	0  DRB1_0101  MNDVDATDTFVGQGK  3  VDATDTFVG    0.980        0  NP_040188_1_ser  0.003109     35.29       NaN   NaN       NaN
#	1  DRB1_0101  NDVDATDTFVGQGKF  2  VDATDTFVG    0.930        0  NP_040188_1_ser  0.000689     52.97       NaN   NaN       NaN
#	2  DRB1_0101  DVDATDTFVGQGKFR  1  VDATDTFVG    0.530        0  NP_040188_1_ser  0.000042     85.71       NaN   NaN       NaN
#	3  DRB1_0101  VDATDTFVGQGKFRG  6  FVGQGKFRG    0.750        0  NP_040188_1_ser  0.000230     66.90       NaN   NaN       NaN
#	4  DRB1_0101  DATDTFVGQGKFRGA  5  FVGQGKFRG    0.960        0  NP_040188_1_ser  0.002755     36.56       NaN   NaN       NaN

#	Current size
#	(382, 12)

#	Dropping any duplicates
#	(381, 12)


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
#df=df.pivot(index=['Tile','Peptide'], columns='MHC', values='%Rank_EL')



df=df.pivot(index='Peptide', columns='MHC', values='%Rank_EL')
print(df.head())
#	MHC              DRB1_0101
#	Peptide                   
#	AACFPVDINANRYYG      81.21
#	AAKRNLPICDILAIQ      76.22
#	ACFPVDINANRYYGW      82.24
#	ACMDSKTCEHVVIKA      77.44
#	AEARVGINKAGFVIL      14.11

print(df.shape)
#	(379, 1)

df.to_csv( args.input[0].rsplit('.',1)[0]+".csv",index_label='Peptide')


