#!/usr/bin/env python3
from __future__ import division

import os
import sys
#import gzip
import difflib
import argparse

# import regex
import pandas as pd





assigned_peptides = set()
epitope_len = 7

def is_novel_peptide(peptide, assigned_peptides, epitope_len):
	for assigned_peptide in assigned_peptides:
		matcher = difflib.SequenceMatcher(None, peptide, assigned_peptide)
		match = matcher.find_longest_match(0, len(peptide), 0, len(assigned_peptide))
		if match.size >= epitope_len:
			return False
	return True

for arg in sys.argv[1:]:

	#	read file
	lib = pd.read_csv(arg,low_memory=False)

	columns = ['id','species','public_epitope']

	peptides = lib[columns].set_index(columns)

	peptides_for_export = []

	#	loop over all
	for peptide1 in peptides.index:
		#print(peptide1)
		#(42, 'Human herpesvirus 5', 'TIKNTKPQCRPEDYATRLQDLRVTFHRVKPTLQREDDYSVWLDGDHVYPGLKTELH')

		seq1=peptide1[2]

		#compare to ALL others
		for peptide2 in peptides.index:

			if( peptide1[0] != peptide2[0] ):

				seq2=peptide2[2]
				matcher = difflib.SequenceMatcher(None, seq1, seq2)
				match = matcher.find_longest_match(0, len(seq1), 0, len(seq2))
				if match.size >= epitope_len:
					#print( peptide1 )
					#print( peptide2 )
					#print( match )
					#print( seq1[match.a:(match.a+match.size)])
					#print
					peptides_for_export.append([
						peptide1[0], peptide1[1], peptide1[2],
						match.a,match.b,match.size,seq1[match.a:(match.a+match.size)],
						peptide2[0], peptide2[1], peptide2[2]
					])


	pd.DataFrame(peptides_for_export, 
		columns=[ 'id1', 'species1', 'peptide1',
			'match1 start','match2 start','match size','matched seq',
			'id2', 'species2', 'peptide2'
		]).sort_values(by=['id1']).to_csv(arg+'.shared_epitopes.csv',index=False)


#Match(a=17, b=29, size=14)

#	(95293, 'Enterovirus C', 'MIDNTVRETVGAATSRDALPNTEASGPAHSKEIPALTAVETGATNPLVPSDTVQTR')
#	(89351, 'Enterovirus C', 'QGALTLSLPKQQDSLPDTKASGPAHSKEVPALTAVETGATNPLAPSDTVQTRHVVQ')
#	Match(a=33, b=29, size=14)
#	PALTAVETGATNPL

