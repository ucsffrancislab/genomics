#!/usr/bin/python3

import pandas as pd

pgsdir="/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/"
hladir="/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/"
phipdir="/francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/"


dfs=[]
for dir in ['onco','i370','cidr']:
	print( dir )
	dfs.append( pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.hla_dosage.csv",sep="\t",index_col=[0]).drop(['AF','R2'],axis='columns').T )
hla = pd.concat(dfs, axis='index', sort=True)

dfs=[]
for dir in ['onco','i370','cidr']:
	print( dir )
	dfs.append(pd.read_csv(pgsdir+"pgs-"+dir+"-hg19/estimated-population.txt",sep="\t",index_col=[0]))
pcs = pd.concat(dfs, axis='index', sort=True)

#	1	Family ID ('FID')
#	2	Within-family ID ('IID'; cannot be '0')
#	3	Within-family ID of father ('0' if father isn't in dataset)
#	4	Within-family ID of mother ('0' if mother isn't in dataset)
#	5	Sex code ('1' = male, '2' = female, '0' = unknown)
#	6	Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)
dfs=[]
for dir in ['onco','i370','cidr']:
	print( dir )
	df=pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.dose.fam",sep=' ',header=None,keep_default_na=False) # cidr fam has NA family id
	df=df.drop([2,3,4,5],axis='columns') # zero based columns
	df['both'] = df[0].astype(str) + '_' + df[1].astype(str)
	df=df.rename(columns={0: "FID", 1: "IID"})
	df['source']=dir
	df=df.set_index('both')
	dfs.append(df)
fams = pd.concat(dfs, axis='index', sort=True)

df=pd.concat([fams,pcs,hla], axis='columns').reset_index()
print(df.head())
print(df.index)
print(len(df.columns))



#'ONCO_AGS.csv', 'I370_AGS.csv', 
#for f in ['Gid_IPSid.csv', 'agsips_manifest.csv', 'agsips_datasets.csv', 'agsips_covars.csv', 
#		'PHIP_AGS.csv', 'ALL_AGS.csv', 'CIDR_gIPS.csv', 'CIDR_IPS.csv', 'PHIP_IPS.csv']:
#	print( f )
#	print(pd.read_csv( hladir+f ).iloc[:5,:5])
#


tmp=pd.read_csv(hladir+"ONCO_AGS.csv",dtype=object)
print(tmp.head())
#	ONCO_AGS.csv
#	        AGS                       ONCO
#	0  AGS40008  WG0238627-DNAE11-AGS40008
#	1  AGS40012  WG0238624-DNAG02-AGS40012
#	2  AGS40030  WG0238629-DNAE02-AGS40030
#	3  AGS40056  WG0238627-DNAF08-AGS40056
#	4  AGS40072  WG0238636-DNAC05-AGS40072
df = pd.merge(tmp,df, left_on='ONCO', right_on='IID', how='outer')
if ( df['IID'].equals(df['ONCO']) ):
	df=df.drop('ONCO', axis='columns')

print(df.head())


tmp=pd.read_csv(hladir+"CIDR_gIPS.csv",dtype=object)
print(tmp.head())
#	CIDR_gIPS.csv
#	   gIPS               CIDR
#	0  G001  G001-1-0427562767
#	1  G002  G002-1-0427562768
#	2  G003  G003-1-0427562769
#	3  G004  G004-1-0427562770
#	4  G005  G005-1-0427562771
df = pd.merge(tmp,df, left_on='CIDR', right_on='IID', how='outer')
if ( df['IID'].equals(df['CIDR']) ):
	df=df.drop('CIDR', axis='columns')
print(df.head())


tmp=pd.read_csv(hladir+"CIDR_IPS.csv",dtype=object)
print(tmp.head())
#	CIDR_IPS.csv
#	  subject_id     id
#	0       G317  14013
#	1       G227  14015
#	2       G228  14016
#	3       G318  14022
#	4       G315  14023
df = pd.merge(tmp,df, left_on='subject_id', right_on='gIPS', how='outer')
#df['id'] = df['id'].astype('str')
if ( df['gIPS'].equals(df['subject_id']) ):
	df=df.drop('subject_id', axis='columns')
df=df.rename(columns={'id': "IPS",'gIPS': "CIDR_short",'CIDR':'CIDR_long'})
print(df.head())


#tmp=pd.read_csv(hladir+"I370_AGS.csv")
#print(tmp.head())
#        AGS      I370
#0  AGS40011  AGS40011
#1  AGS40015  AGS40015
#2  AGS40020  AGS40020
#3  AGS40021  AGS40021
#4  AGS40050  AGS40050
#df = pd.merge(tmp,df, left_on='subject_id', right_on='gIPS', how='outer')

df['AGSIPS'] = df['AGS'].fillna('').astype(str) + df['IPS'].fillna('').astype(str)

tmp=pd.read_csv(hladir+"agsips_manifest.csv",dtype=object)
print(tmp.head())
#AGSIPSid,UCSFid,age,sex,plate
#14034,1403401,67,F,3
#14034,1403401dup,67,F,3
#14036,1403601,66,F,3
#14036,1403601dup,66,F,3
#AGS55801,21204,59,F,4
#AGS55801,21204dup,59,F,4
#AGS55876,21129,65,M,5
#AGS55876,21129dup,65,M,5
tmp['UCSFid'] = tmp['UCSFid'].str.rstrip('dup')
tmp = tmp.drop_duplicates()
df = pd.merge(tmp,df, left_on='AGSIPSid', right_on='AGSIPS', how='outer')
if ( df['AGSIPSid'].equals(df['AGSIPS']) ):
	df=df.drop('AGSIPSid', axis='columns')
print(df.head())



print("PhIPSeq")
##	drop the sample column and then unique
tmp=pd.read_csv(phipdir+"manifest.csv",sep=',',dtype=object).drop('sample', axis='columns').drop_duplicates()
print(tmp.head())
#tmp['UCSFid'] = tmp['UCSFid'].str.rstrip('dup')
#tmp = tmp.drop_duplicates()
df = pd.merge(tmp,df, left_on='subject', right_on='UCSFid', how='outer')
if ( df['subject'].equals(df['UCSFid']) ):
	df=df.drop('subject', axis='columns')
print(df.head())






#	seropositivity files

tmp=pd.read_csv(phipdir+"out.123456131415161718/seropositive.10.csv",sep=',',dtype=object)
print(tmp.head())
tmp = tmp[~tmp['species.2'].str.endswith('_B')]
tmp=tmp.drop('species.2', axis='columns')
df = pd.merge(df,tmp, left_on='UCSFid', right_on='species', how='outer')
if ( df['species'].equals(df['UCSFid']) ):
	df=df.drop('species', axis='columns')
print(df.head())



#reorder this mess.
#pop items out and move them to the front so they end up in a specific order?
columns=list(df.columns)

column_order=['UCSFid','subject','species','AGSIPSid','AGSIPS','AGS','IPS','type','species.1','study','group','age_x','age_y','sex_x','sex_y','plate_x','plate_y','ONCO','CIDR_short', 'CIDR_long']
for column in reversed(column_order):
	columns.insert(0, columns.pop(columns.index(column)))

df = df[columns]


#	add molecular subtypes

#	drop duplicate age, sex and plate columns





df.to_csv('PhIPseq_HLA.csv',index=False)



