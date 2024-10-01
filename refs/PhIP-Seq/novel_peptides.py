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
					print( peptide1 )
					print( peptide2 )
					print( match )
					print( seq1[match.a:(match.a+match.size)])
					print

#Match(a=17, b=29, size=14)




#	assigned_peptides = set()
#	epitope_len = 7
#	
#	def is_novel_peptide(peptide, assigned_peptides, epitope_len):
#		for assigned_peptide in assigned_peptides:
#			matcher = difflib.SequenceMatcher(None, peptide, assigned_peptide)
#			match = matcher.find_longest_match(0, len(peptide), 0, len(assigned_peptide))
#			if match.size >= epitope_len:
#				return False
#		return True
#	
#	
#	if __name__ == '__main__':
#	
#		print(sys.argv);
#	
#		for arg in sys.argv[1:]:
#			print(arg)
#	
#			#	read file
#			lib = pd.read_csv(arg,low_memory=False)
#	
#			columns = ['id','species','public_epitope']
#	
#			hits2 = lib[columns].set_index(columns)
#	
#			#	loop over all
#			for virus_hit in hits2.index:
#				#print(virus_hit)
#				#(42, 'Human herpesvirus 5', 'TIKNTKPQCRPEDYATRLQDLRVTFHRVKPTLQREDDYSVWLDGDHVYPGLKTELH')
#	
#				peptide=virus_hit[2]
#	
#				if is_novel_peptide(peptide, assigned_peptides, epitope_len):
#					assigned_peptides.add(peptide)
#				else:
#					print("NOT NOVEL",virus_hit)
#	
#	#				peptides_for_export.append([virus_hit[0],virus_hit[1],virus_hit[2]])
#	#	virus_scores = calc_virus_scores(hits2[hits.columns[0]], args.level[0], args.epitope_len[0], species_order)
