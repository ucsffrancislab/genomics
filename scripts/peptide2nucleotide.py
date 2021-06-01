#!/usr/bin/env python3

from io import StringIO 
import numpy as np
import pandas as pd
import sys


print(len(sys.argv))


if( len(sys.argv) != 2 ):
	print("Please pass just one peptide")
	exit()

print("Processing "+sys.argv[1])

ACID_TABLE = u"""\
P	CCC,CCU,CCA,CCG
L	CUC,CUU,CUA,CUG,UUA,UUG
H	CAC,CAU
Q	CAA,CAG
R	CGC,CGU,CGA,CGG,AGA,AGG
S	UCC,UCU,UCA,UCG,AGC,AGU
F	UUC,UUU
T	UAC,UAU,ACC,ACU,ACA,ACG
X	UAA,UAG
C	UGC,UGU
U	UGA
W	UGG
I	AUC,AUU,AUA
M	AUG
N	AAC,AAU
K	AAA,AAG
A	GCC,GCU,GCA,GCG
V	GUC,GUU,GUA,GUG
D	GAC,GAU
E	GAA,GAG
G	GGC,GGU,GGA,GGG
"""

#acids=pd.read_csv("20210528-herv-peptide-sequences/acid_table",
acids=pd.read_csv(StringIO(ACID_TABLE),
	header=None,
	sep="\t",
	names=['amino','nucleic'])

aminos={}
for index, row in acids.iterrows():
	aminos[row['amino']]=pd.DataFrame(row['nucleic'].split(','))

n=pd.DataFrame(data={0:[""]})
for a in sys.argv[1]:
	n=n.merge(aminos[a],how='cross')

n.sum(axis='columns').to_csv(sys.argv[1]+".nucleotides.gz",header=False,index=False)


