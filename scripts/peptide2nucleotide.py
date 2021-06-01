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
P	CCC,CCT,CCA,CCG
L	CTC,CTT,CTA,CTG,TTA,TTG
H	CAC,CAT
Q	CAA,CAG
R	CGC,CGT,CGA,CGG,AGA,AGG
S	TCC,TCT,TCA,TCG,AGC,AGT
F	TTC,TTT
T	TAC,TAT,ACC,ACT,ACA,ACG
X	TAA,TAG
C	TGC,TGT
U	TGA
W	TGG
I	ATC,ATT,ATA
M	ATG
N	AAC,AAT
K	AAA,AAG
A	GCC,GCT,GCA,GCG
V	GTC,GTT,GTA,GTG
D	GAC,GAT
E	GAA,GAG
G	GGC,GGT,GGA,GGG
"""

# Used T and not U since all of my indexes are built with T

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


