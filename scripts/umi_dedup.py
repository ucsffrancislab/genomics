#!/usr/bin/env python3

import os
import gzip
import Levenshtein

import pandas as pd
pd.set_option('display.max_colwidth', None)
pd.set_option('display.max_columns', None)


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

# read arguments from the command line
args = parser.parse_args()


#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-GTACGTTGTCCCAAGTGG" > SFHH011Z.quality.umi.t1.t3.R1.select.fastq.gz
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-GTACGTTGTCCAAAGTGG" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-TAGACTCGTTTTAATTTT" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-TGTAAGTTTGATTTGGAA" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-TGTGTGTGCGAGGGAGTG" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-ATTACCTCCGAAGTTCTA" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#  zcat SFHH011Z.quality.umi.t1.t3.R1.fastq.gz| grep -A3 "\-ATTACCTCCGAATTTCTA" >> SFHH011Z.quality.umi.t1.t3.R1.select.fastq
#1   GTACGTTGTCCAAAGTGG  35.807947  
#6   TAGACTCGTTTTAATTTT  36.225806  
#7   TGTAAGTTTGATTTGGAA  35.379845  
#19  TGTGTGTGCGAGGGAGTG  35.883333  
#21  ATTACCTCCGAAGTTCTA  36.128713  

#raw=pd.read_csv("SFHH011Z.quality.umi.t1.t3.R1.head.fastq.gz", header=None, sep="\t", names=["name"])
#raw=pd.read_csv("SFHH011Z.quality.umi.t1.t3.R1.fastq.gz", header=None, sep="\t", names=["name"])

for filename in args.files:  
	print("Reading raw data " + filename)
	#raw=pd.read_csv("SFHH011Z.quality.umi.t1.t3.R1.select.fastq", header=None, sep="\t", names=["name"])
	raw=pd.read_csv(filename, header=None, sep="\t", names=["name"])
	
	print("Creating dataframe from raw data")
	df = pd.DataFrame({
		'name':raw['name'].iloc[0::4].values,
		'sequence':raw['name'].iloc[1::4].values,
		'sep':raw['name'].iloc[2::4].values,
		'qualities':raw['name'].iloc[3::4].values})

	print("Dataframe length :"+str(len(df)))
	del(raw)
	
	print("Extracting UMI")
	df['umi'] = df.apply(lambda row: row['name'].split("-")[-1], axis=1)
	
	print("Extracting Average Quality")
	df['ave_q'] = df.apply(lambda row: sum([ord(c)-33 for c in [*row['qualities']]])/len([*row['qualities']]), axis=1)
	
	print("Creating UMI list")
	umis=df['umi'].unique().tolist()
	
	#print(type(umis))
	
	print("Looping over UMIs")
	for umi in umis:
	
		print()
		print("Building flexible UMI regex")
		print(umi)
		r=umi
		for i in range(len(umi)):
			cs=list(umi)
			cs[i]='.'
			r+="|"
			r+="".join(cs)
	
		print("Creating sub dataframe with matching UMIs")
		sdf=df[df['umi'].str.contains(r)].copy()
		#sdf['ave_q'] = sdf.apply(lambda row: sum([ord(c)-33 for c in [*row['qualities']]])/len([*row['qualities']]), axis=1)
	
		print("Sub dataframe length :"+str(len(sdf)))
		print(sdf.index.values)
	
		#print(df[df['umi'].str.contains(r)].index.values)
		#print(sdf)
	
		if len(sdf) > 1:
			print(umi)
	#		print(sdf)
	
			maxlen=max(sdf['sequence'].str.len())
	
	
			#	rather than make sdf, just extract indexes? and loop over them?
			#	then can check if the index is found each iteration? rather than keep comparing?
	
			for i1, r1 in sdf.iterrows():
				#print(r1)
				for i2, r2 in sdf.iterrows():
					#print(r2)
					print("Comparing ",i1," and ",i2)
					if i1 == i2:
						print('Skipping self comparison')
						continue
					if not(i1 in sdf.index):
						print('i1 already dropped. Skipping.')
						continue
					if not(i2 in sdf.index):
						print('i2 already dropped. Skipping.')
						continue
					ld=Levenshtein.distance(r1['sequence'], r2['sequence'])
					if ld < ( 0.1 * maxlen ):
						print("Comparing average quality")
						if r1['ave_q'] == r2['ave_q']:
							print("Comparing length")
							if len(r1['sequence']) == len(r2['sequence']):
								print("Comparing arbitrary index value")
								min_r= r1 if i1 < i2 else r2
							elif len(r1['sequence']) < len(r2['sequence']):
								min_r = r1
							else:
								min_r = r2
						elif r1['ave_q'] < r2['ave_q']:
							min_r = r1
						else:
							min_r = r2
	
						#min_r= r1 if r1['ave_q'] < r2['ave_q'] else r2
	
						print(str(r1['ave_q']) + " " + str(r2['ave_q']) )
						print("Dropping "+ str(min_r.name))
						print("Dropping "+ min_r['name'])
						#print(min_r['name'])
						#print(df[df['name']==min_r['name']].index.values)
						#print(sdf[sdf['name']==min_r['name']].index.values)
						sdf.drop(sdf[sdf['name']==min_r['name']].index.values,axis='index',inplace=True)	#,errors='ignore')
						df.drop(df[df['name']==min_r['name']].index.values,axis='index',inplace=True,errors='ignore')
	
	#print(df)
	print("Deduped Dataframe length :"+str(len(df)))
	
	with gzip.open(filename+".deduped.fastq.gz", 'wt') as f:
		for i, r in df.iterrows():
			f.write(r['name']+"\n")
			f.write(r['sequence']+"\n")
			f.write(r['sep']+"\n")
			f.write(r['qualities']+"\n")
	
#	with open(filename+".deduped.fastq", 'w') as f:
#		for i, r in df.iterrows():
#			f.write(r['name']+"\n")
#			f.write(r['sequence']+"\n")
#			f.write(r['sep']+"\n")
#			f.write(r['qualities']+"\n")
	
