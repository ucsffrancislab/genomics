#!/usr/bin/env python3

from io import StringIO 
import numpy as np
import pandas as pd
import sys
import os
import stat
import gzip

from Bio import SeqIO


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
parser.add_argument('-o', '--output', nargs=1, type=str, default=['peptides.fasta.gz'], help='output csv filename to %(prog)s (default: %(default)s)')
# read arguments from the command line
args = parser.parse_args()

output=args.output[0]
print( "Using output name: ", output )

ACID_TABLE = u"""\
A	GCC,GCT,GCA,GCG
C	TGC,TGT
D	GAC,GAT
E	GAA,GAG
F	TTC,TTT
G	GGC,GGT,GGA,GGG
H	CAC,CAT
I	ATC,ATT,ATA
K	AAA,AAG
L	CTC,CTT,CTA,CTG,TTA,TTG
M	ATG
N	AAC,AAT
P	CCC,CCT,CCA,CCG
Q	CAA,CAG
R	CGC,CGT,CGA,CGG,AGA,AGG
S	TCC,TCT,TCA,TCG,AGC,AGT
T	ACC,ACT,ACA,ACG
V	GTC,GTT,GTA,GTG
W	TGG
X	TAA,TAG,TGA
Y	TAC,TAT
"""

# Used T and not U since all of my indexes are built with T
#https://www.researchgate.net/figure/Amino-Acid-Translation-Table_fig12_45151954
#https://www.bugsinourbackyard.org/wp-content/uploads/2020/03/Screen-Shot-2020-03-10-at-4.50.53-PM.png
#
#	I've seen some tables that use U, instead of T, as the abbreviation Threonine
#	https://www.semanticscholar.org/paper/Translation-tables%3A-A-genetic-code-in-a-algorithm-Ashlock-Schonfeld/342d4e9fceaaebeb42fe8b179c2364dbc3decaac/figure/6
#https://d3i71xaburhd42.cloudfront.net/342d4e9fceaaebeb42fe8b179c2364dbc3decaac/1-TableI-1.png

acids=pd.read_csv(StringIO(ACID_TABLE),
	header=None,
	sep="\t",
	names=['amino','nucleic'])

aminos={}
for index, row in acids.iterrows():
	aminos[row['amino']]=pd.DataFrame(row['nucleic'].split(','))


#	When gzipping, requires byte strings and byte file
#with open(output, "w") as out_file:
with gzip.open(output, "wb") as out_file:
#with gzip.open(output, "w") as out_file:

	for arg in args.files:	#sys.argv:
		for record in SeqIO.parse(arg, "fasta"):
			#print(record.id)
			#print(record.seq)
	
			#	Create an empty dataframe with the correct structure as to continually merge to
			n=pd.DataFrame(data={0:[""]})

			for a in record.seq:
				n=n.merge(aminos[a],how='cross')
	
			#	Summing text concatenates, so this concatenates all columns into single strings
			for index, row in n.sum(axis='columns').iteritems():
				out_file.write((">"+record.id+"_"+str(index)+"\n").encode('UTF-8'))
				out_file.write((row+"\n").encode('UTF-8'))

os.chmod(output,stat.S_IREAD)

