#!/usr/bin/env python3


#Serine=S
#DIAMOND serine group (including threonine and alanine) 
#Lysine (K) frequency is also important, as is its DIAMOND group (including arginine, glutamic acid, aspartic acid, glutamine and asparagine), 
#and K-DIAMOND pairs - what?



AA_DIAM = {'A' : "S", 'R': "K", 'N': "K", 'D': "K", 'C': "C", 'Q': "K", 'E': "K", 'G': "G", 'H': "H", 'I': "I", 'L': "I", 'K': "K", 'M': "M", 'F': "F", 'P': "P", 'S': "S", 'T': "S", 'W': "W", 'Y': "Y", 'V': "I"}
AMINOACIDS = ['A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V']
DIAMONDS = ['K', 'C', 'G', 'H', 'I', 'M', 'F', 'Y', 'W', 'P', 'S']

def all_feature_names():
    feat_list = ["sc_hydrophobic","sc_polaruncharged","sc_poseleccharged","sc_negeleccharged"]
    for aa in AMINOACIDS:
        feat_list.append(aa)
    
    for d_aa in DIAMONDS:
        feat_list.append("d_" + d_aa)
        
    for aa1 in AMINOACIDS:
        for aa2 in AMINOACIDS:
            feat_list.append(aa1+aa2)
    
    for d_aa1 in DIAMONDS:
        for d_aa2 in DIAMONDS:
            feat_list.append("d_" + d_aa1 + d_aa2)
            
    return feat_list

FEATURE_LIST = all_feature_names()

AA_FEAT = {'A':["sc_hydrophobic", "d_S"], 
           'R':["sc_poseleccharged", "d_K"], 
           'N':["sc_polaruncharged", "d_K"],
           'D':["sc_negeleccharged", "d_K"], 
           'C':["d_C"], 
           'Q':["sc_polaruncharged", "d_K"], 
           'E':["sc_negeleccharged", "d_K"], 
           'G':["d_G"],
           'H':["sc_poseleccharged", "d_H"], 
           'I':["sc_hydrophobic", "d_I"], 
           'L':["sc_hydrophobic", "d_I"], 
           'K':["sc_poseleccharged", "d_K"], 
           'M':["sc_hydrophobic", "d_M"],
           'F':["sc_hydrophobic", "d_F"], 
           'P':["d_P"], 
           'S':["sc_polaruncharged", "d_S"], 
           'T':["sc_polaruncharged", "d_S"], 
           'W':["sc_hydrophobic", "d_W"],
           'Y':["sc_hydrophobic", "d_Y"], 
           'V':["sc_hydrophobic", "d_I"]
          }
#NET_CHARGES = {'A':0, 'R':+1, 'N':0, 'D':-1, 'C':0, 'Q':0, 'E':-1, 'G':0, 'H':+1, 'I':0, 'L':0, 'K':+1, 'M':0, 'F':0, 'P':0, 'S':0, 'T':0, 'W':0, 'Y':0, 'V':0, '*':0 }
#POS_CHARGES = {'A':0, 'R':1, 'N':0, 'D':0, 'C':0, 'Q':0, 'E':0, 'G':0, 'H':1, 'I':0, 'L':0, 'K':1, 'M':0, 'F':0, 'P':0, 'S':0, 'T':0, 'W':0, 'Y':0, 'V':0, '*':0 }
#NEG_CHARGES = {'A':0, 'R':0, 'N':0, 'D':1, 'C':0, 'Q':0, 'E':1, 'G':0, 'H':0, 'I':0, 'L':0, 'K':0, 'M':0, 'F':0, 'P':0, 'S':0, 'T':0, 'W':0, 'Y':0, 'V':0, '*':0 }

import pandas as pd
f='neoantigen_dataset.csv'
df=pd.read_csv(f,index_col=0,na_filter=False)


#peptide='YQNPASWKNNRIWLQFAKLTGFTLMGKG'
#sum([POS_CHARGES.get(char) for char in peptide])
#sum([NEG_CHARGES.get(char) for char in peptide])
#sum([NET_CHARGES.get(char) for char in peptide])


df['presented_peptide_sequence']= df['peptide_sequence'].str.split("*",expand=True)[0]

#df['positive_charge'] = df.apply(lambda x: sum([POS_CHARGES.get(char) for char in x.peptide_sequence]), axis=1)
#df['negative_charge'] = df.apply(lambda x: sum([NEG_CHARGES.get(char) for char in x.peptide_sequence]), axis=1)
#df['net_charge'] = df.apply(lambda x: sum([NET_CHARGES.get(char) for char in x.peptide_sequence]), axis=1)


#The four main types of amino acid side chains (also known as R-groups) are: nonpolar (hydrophobic), polar (uncharged), acidic (negatively charged), and basic (positively charged). 

def get_diam(aa_seq):
	diam = ""
	for aa in aa_seq:
		diam += AA_DIAM[aa]        
	return(diam)

#peptide='YQNPASWKNNRIWLQFAKLTGFTLMGKG'

def add_features(row):
	seq=row.presented_peptide_sequence
	l=len(seq)
	diam_seq = get_diam(seq)
	feat = {}
	for f in FEATURE_LIST:
		feat[f] = 0
	#feat = pd.DataFrame(feat)	# not necessary?
	for i in range(0,l):
		aa = seq[i]
		feat[aa] += 1
		for f in AA_FEAT[aa]:
			feat[f] += 1   
	rangelen = l-1
	for i in range(0, rangelen):
		double = seq[i:i+2]
		feat[double] += 1
		diam_double = diam_seq[i:i+2]
		feat["d_" + diam_double] += 1
	return feat

df = df.join(df.apply(add_features, axis=1, result_type='expand'))


#	This will add the presented_peptide_sequence plus the 556 dolphyn features


#		exec(open("add_dolphyn_features.py").read())
#		df.to_csv('neoantigen_dataset.dolphyn.csv')


