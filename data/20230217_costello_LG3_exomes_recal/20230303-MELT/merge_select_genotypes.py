#!/usr/bin/env python3

import os
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
parser.add_argument('-o', '--output', nargs=1, type=str, default='select_genotypes.tsv.gz', help='output tsv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')
#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')
parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?

if isinstance(args.output,list):
	output=args.output[0]
else:
	output=args.output
print( "Using output name: ", output )



patient_ids = pd.read_csv("patient_ID_conversions.2022.exists.covariates.sorted.csv",
	usecols=[0,1,5],
	sep=",")
patient_ids=patient_ids[patient_ids["tn"]=="Normal"]
patient_ids.drop(["tn"],axis='columns',inplace=True)
print(patient_ids.head())

select_patients = pd.read_csv("Costello_HM_status_IDs.txt", header=None,names=["patient_id"])
print(select_patients.head())

patient_ids=patient_ids[patient_ids['patient'].isin(select_patients['patient_id'])]
print(patient_ids.head())

select_positions = pd.read_csv("DNA_repair_SNPs_AGS_hg19.txt", header=None,sep=" ",names=["CHR","POS"])
print(select_positions.head())

#patient_ids=patient_ids.head()

data_frames = []

for index,row in patient_ids.iterrows():

	print("Processing "+str(index)+" - "+row['patient']+" : "+row['Z'])

	filename="vcfallq60region/"+row['patient']+"."+row['Z']+".regions.genotypes.gz"
	print(filename)

	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		basename=os.path.basename(filename)

		#sample=basename.split(".")[0]	#	everything before the first "."
		print(basename)
		sample=".".join(basename.split(".")[0:2])
		print(sample)

		print("Reading "+filename)

		d = pd.read_csv(filename,
			names=['CHR','POS','REF','ALT',sample],
			sep="\t")

		d.set_index(['CHR','POS'],inplace=True)
		print(d.head())

		d=d[ d.index.isin( list(select_positions.itertuples(index=False,name=None)) ) ]
		print(d.head())

		d['ALT1']=d['ALT'].str.split(',',expand=True)[0]

		altsplit=d['ALT'].str.split(',',expand=True)
		if(len(altsplit.columns)>1):
			d['ALT2']=altsplit[1]
		else:
			d['ALT2']=None

		altsplit=d['ALT'].str.split(',',expand=True)
		if(len(altsplit.columns)>2):
			d['ALT3']=altsplit[2]
		else:
			d['ALT3']=None

		print(d.head())

		print("Sample now has "+str(d.shape))

		print("Selecting only REF SNPs")
		d=d[d['REF'].str.len()==1]
		print("Sample now has "+str(d.shape))

		print("Selecting only ALT SNPs")
		d=d[d['ALT'].str.len()==1]
		print("Sample now has "+str(d.shape))

		d[sample]= d.apply(lambda x: 
			x[sample].replace('0', str(x['REF'])).replace('1',str(x['ALT1'])).replace('2',str(x['ALT2'])).replace('3',str(x['ALT3'])), axis=1)

		print(d.head())

		d.drop(['REF','ALT','ALT1','ALT2','ALT3'],axis='columns',inplace=True)

		print(d.head())

		print("Appending")
		data_frames.append(d)
	else:
		print(filename + " is empty")


if len(data_frames) > 0:
	print("Concating all")
	df = pd.concat(data_frames, axis=1, sort=True )
	data_frames = []

#	print("Replacing all NaN with 0")
#	df.fillna('0', inplace=True)
#	print(df.head())
#
##	if args.int:
##		print("Converting all counts back to integers")
##		df = pd.DataFrame(df, dtype=int)

	print("Writing CSV")
	df.to_csv(output,index_label=['CHR','POS'],sep="\t")

else:
	print("No data.")


