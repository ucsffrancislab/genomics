#!/usr/bin/python3

import pandas as pd

pgsdir = "/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/"
hladir = "/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/"
phipdir = "/francislab/data1/working/20250925-Illumina-PhIP/20251223-PhIP-MultiPlate/"


dfs = []
for dir in ['onco','i370','cidr']:
	print( dir )
	#dfs.append( pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.hla_dosage.csv",sep="\t",index_col=[0]).drop(['AF','R2'],axis='columns').T )
	tmp = pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.hla_dosage.csv",sep="\t",index_col=[0])
	tmp = tmp[tmp['R2'] >= 0.5]
	dfs.append( tmp.drop(['AF','R2'],axis='columns').T )

hla = pd.concat(dfs, axis='index', sort=True)
print("HLA dosage files")
#	print(len(hla.columns))
#	print(hla.columns)
#	print(len(hla.index))
#	print(hla.index)
#	
#	HLA dosage files
#	570
#	Index(['HLA_A*01', 'HLA_A*01:01', 'HLA_A*01:02', 'HLA_A*01:136', 'HLA_A*02',
#	       'HLA_A*02:01', 'HLA_A*02:02', 'HLA_A*02:03', 'HLA_A*02:04',
#	       'HLA_A*02:05',
#	       ...
#	       'HLA_DRB1*15', 'HLA_DRB1*15:01', 'HLA_DRB1*15:02', 'HLA_DRB1*15:03',
#	       'HLA_DRB1*15:04', 'HLA_DRB1*15:06', 'HLA_DRB1*15:13', 'HLA_DRB1*16',
#	       'HLA_DRB1*16:01', 'HLA_DRB1*16:02'],
#	      dtype='object', name='NAME', length=570)
#	9466
#	Index(['0_WG0238624-DNAA02-AGS51641', '0_WG0238624-DNAA03-AGS40548',
#	       '0_WG0238624-DNAA04-AGS44682', '0_WG0238624-DNAA05-AGS50011',
#	       '0_WG0238624-DNAA06-AGS47844', '0_WG0238624-DNAA07-AGS41323',
#	       '0_WG0238624-DNAA08-AGS48652', '0_WG0238624-DNAA09-AGS43439',
#	       '0_WG0238624-DNAA10-AGS43652', '0_WG0238624-DNAA11-AGS41120',
#	       ...
#	       '443_G444-1-0427561202', '444_G445-1-0427561203',
#	       '445_G446-1-0427561204', '446_G447-1-0427561219',
#	       'NA_NA06985-0427588099', 'NA_NA06991-0427588094',
#	       'NA_NA06993-3544045708', 'NA_NA18503-0427553200',
#	       'NA_NA18524-3544045704', 'NA_NA18942-3544095388'],
#	      dtype='object', length=9466)
#	



dfs = []
for dir in ['onco','i370','cidr']:
	print( dir )
	dfs.append(pd.read_csv(pgsdir+"pgs-"+dir+"-hg19/estimated-population.txt",sep="\t",index_col=[0]))
pcs = pd.concat(dfs, axis='index', sort=True)
print("PC files")
#	print(len(pcs.columns))
#	print(pcs.columns)
#	print(len(pcs.index))
#	print(pcs.index)
#	
#	PC files
#	11
#	Index(['PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'population',
#	       'voting', 'voting_popluation'],
#	      dtype='object')
#	9466
#	Index(['9_9', '98_98', '99_99', '987_987', '988_988', '989_989', '990_990',
#	       '992_992', '993_993', '994_994',
#	       ...
#	       '437_G438-1-0427561196', '438_G439-1-0427561197',
#	       '439_G440-1-0427561198', '440_G441-1-0427561199',
#	       '441_G442-1-0427561200', '442_G443-1-0427561201',
#	       '443_G444-1-0427561202', '444_G445-1-0427561203',
#	       '445_G446-1-0427561204', '446_G447-1-0427561219'],
#	      dtype='object', name='sample', length=9466)

#	1	Family ID ('FID')
#	2	Within-family ID ('IID'; cannot be '0')
#	3	Within-family ID of father ('0' if father isn't in dataset)
#	4	Within-family ID of mother ('0' if mother isn't in dataset)
#	5	Sex code ('1' = male, '2' = female, '0' = unknown)
#	6	Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)
dfs = []
for dir in ['onco','i370','cidr']:
	print( dir )
	df = pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.dose.fam",sep=' ',header=None,keep_default_na=False) # cidr fam has NA family id
	df = df.drop([2,3,4,5],axis='columns') # zero based columns
	df['both'] = df[0].astype(str) + '_' + df[1].astype(str)
	df = df.rename(columns={0: "FID", 1: "IID"})
	df['source'] = dir
	df = df.set_index('both')
	dfs.append(df)
fams = pd.concat(dfs, axis='index', sort=True)
print("FAM files")
#	print(len(fams.columns))
#	print(fams.columns)
#	print(len(fams.index))
#	print(fams.index)
#	FAM files
#	3
#	Index(['FID', 'IID', 'source'], dtype='object')
#	9466
#	Index(['0_WG0238624-DNAA02-AGS51641', '0_WG0238624-DNAA03-AGS40548',
#	       '0_WG0238624-DNAA04-AGS44682', '0_WG0238624-DNAA05-AGS50011',
#	       '0_WG0238624-DNAA06-AGS47844', '0_WG0238624-DNAA07-AGS41323',
#	       '0_WG0238624-DNAA08-AGS48652', '0_WG0238624-DNAA09-AGS43439',
#	       '0_WG0238624-DNAA10-AGS43652', '0_WG0238624-DNAA11-AGS41120',
#	       ...
#	       '443_G444-1-0427561202', '444_G445-1-0427561203',
#	       '445_G446-1-0427561204', '446_G447-1-0427561219',
#	       'NA_NA06985-0427588099', 'NA_NA06991-0427588094',
#	       'NA_NA06993-3544045708', 'NA_NA18503-0427553200',
#	       'NA_NA18524-3544045704', 'NA_NA18942-3544095388'],
#	      dtype='object', name='both', length=9466)


df = pd.concat([fams,pcs,hla], axis='columns').reset_index()
df = df.rename(columns={'index': 'FID_IID'})	#	don't really need it. I do to join with the molecular subtypes
#df = df.drop(['index'],axis='columns')
print("Merged files")
#	print(df.shape)
#	print(len(df.columns))
#	print(df.columns)
#	print(len(df.index))
#	print(df.index)
#	Merged files
#	(9466, 585)
#	585
#	Index(['index', 'FID', 'IID', 'source', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5',
#	       'PC6',
#	       ...
#	       'HLA_DRB1*15', 'HLA_DRB1*15:01', 'HLA_DRB1*15:02', 'HLA_DRB1*15:03',
#	       'HLA_DRB1*15:04', 'HLA_DRB1*15:06', 'HLA_DRB1*15:13', 'HLA_DRB1*16',
#	       'HLA_DRB1*16:01', 'HLA_DRB1*16:02'],
#	      dtype='object', length=585)
#	9466
#	RangeIndex(start=0, stop=9466, step=1)


tmp = pd.read_csv(hladir+"ONCO_AGS.csv",dtype=object).fillna('')
print("ONCO_AGS.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
#	ONCO_AGS.csv
#	        AGS                       ONCO
#	0  AGS40008  WG0238627-DNAE11-AGS40008
#	1  AGS40012  WG0238624-DNAG02-AGS40012
#	2  AGS40030  WG0238629-DNAE02-AGS40030
#	3  AGS40056  WG0238627-DNAF08-AGS40056
#	4  AGS40072  WG0238636-DNAC05-AGS40072
#	2
#	Index(['AGS', 'ONCO'], dtype='object')
#	1339
#	RangeIndex(start=0, stop=1339, step=1)
#	
#	ONCO_AGS.csv
#	        AGS                       ONCO
#	0  AGS40008  WG0238627-DNAE11-AGS40008
#	1  AGS40012  WG0238624-DNAG02-AGS40012
#	2  AGS40030  WG0238629-DNAE02-AGS40030
#	3  AGS40056  WG0238627-DNAF08-AGS40056
#	4  AGS40072  WG0238636-DNAC05-AGS40072
df = pd.merge(tmp,df, left_on='ONCO', right_on='IID', how='outer').fillna('')
#if ( df['IID'].equals(df['ONCO']) ):	#	it won't cause its a subset
#	df = df.drop('ONCO', axis='columns')

#print(df.head())

print(df.shape)
#	(9466, 587)



tmp = pd.read_csv(hladir+"I370_AGS.csv",dtype=object).fillna('')
print("I370_AGS.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
#        AGS      I370
#0  AGS40011  AGS40011
#1  AGS40015  AGS40015
#2  AGS40020  AGS40020
#3  AGS40021  AGS40021
#4  AGS40050  AGS40050
df = pd.merge(tmp,df, left_on='I370', right_on='IID', how='outer').fillna('')
#if ( df['IID'].equals(df['I370']) ):	#	it won't cause its a subset
#	df = df.drop('I370', axis='columns')

print(df.shape)
#	(9466, 587)



#	merge AGS_x and AGS_y
df['AGS'] = df['AGS_x'].fillna('').astype(str) + df['AGS_y'].fillna('').astype(str)


df = df.drop(['AGS_x','AGS_y','I370','ONCO'],axis='columns')



tmp = pd.read_csv(hladir+"CIDR_gIPS.csv",dtype=object).fillna('')
print("CIDR_gIPS.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
#	CIDR_gIPS.csv
#	   gIPS               CIDR
#	0  G001  G001-1-0427562767
#	1  G002  G002-1-0427562768
#	2  G003  G003-1-0427562769
#	3  G004  G004-1-0427562770
#	4  G005  G005-1-0427562771
#	2
#	Index(['gIPS', 'CIDR'], dtype='object')
#	446
#	RangeIndex(start=0, stop=446, step=1)
df = pd.merge(tmp,df, left_on='CIDR', right_on='IID', how='outer').fillna('')
#if ( df['IID'].equals(df['CIDR']) ):
#	df = df.drop('CIDR', axis='columns')
#print(df.head())
print(df.shape)
#	(9466, 589)



tmp = pd.read_csv(hladir+"CIDR_IPS.csv",dtype=object).fillna('')
print("CIDR_IPS.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
#	CIDR_IPS.csv
#	  subject_id     id
#	0       G317  14013
#	1       G227  14015
#	2       G228  14016
#	3       G318  14022
#	4       G315  14023
#	2
#	Index(['subject_id', 'id'], dtype='object')
#	446
#	RangeIndex(start=0, stop=446, step=1)
df = pd.merge(tmp,df, left_on='subject_id', right_on='gIPS', how='outer').fillna('')
if ( df['gIPS'].equals(df['subject_id']) ):	#	perfect match so will go away
	df = df.drop('subject_id', axis='columns')
df = df.rename(columns={'id': "IPS",'gIPS': "CIDR",'CIDR':'CIDR_long'})
print(df.shape)
#	(9466, 590)

df = df.drop(['CIDR_long'],axis='columns')



		
		
		
		
		
df['AGSIPS'] = df['AGS'].fillna('').astype(str) + df['IPS'].fillna('').astype(str)


tmp = pd.read_csv(hladir+"agsips_manifest.csv",dtype=object).fillna('')
#AGSIPSid,UCSFid,age,sex,plate
tmp['UCSFid'] = tmp['UCSFid'].str.rstrip('dup')
tmp = tmp.drop_duplicates()
print("agsips_manifest.csv")
tmp = tmp.drop(['age','sex','plate'], axis='columns')
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
#	
#	agsips_manifest.csv
#	  AGSIPSid    UCSFid age sex plate
#	0    14034   1403401  67   F     3
#	2    14036   1403601  66   F     3
#	4    14055   1405501  33   M     3
#	6    14057   1405701  29   M     6
#	8    14061  14061_01  66   M     2
#	5
#	Index(['AGSIPSid', 'UCSFid', 'age', 'sex', 'plate'], dtype='object')
#	252
#	Index([  0,   2,   4,   6,   8,  10,  12,  14,  16,  18,
#	       ...
#	       484, 486, 488, 490, 492, 494, 496, 498, 500, 502],
#	      dtype='int64', length=252)
df = pd.merge(tmp,df, left_on='AGSIPSid', right_on='AGSIPS', how='outer').fillna('')
#if ( df['AGSIPSid'].equals(df['AGSIPS']) ):
#	df = df.drop('AGSIPSid', axis='columns')
#print(df.head())

print(df.shape)
#	(9581, 596)


#	Copy AGSIPSid into IPS if blank and doesn't start with AGS
#	Copy AGSIPSid into AGS if blank and does start with AGS

df.loc[df['AGSIPS'] == '', 'AGSIPS'] = df['AGSIPSid']

# For rows where B is blank and A starts with "AGS"
df.loc[(df['AGS'] == '') & df['AGSIPSid'].str.startswith('AGS'), 'AGS'] = df['AGSIPSid']

# For rows where C is blank and A does NOT start with "AGS"
df.loc[(df['IPS'] == '') & ~df['AGSIPSid'].str.startswith('AGS'), 'IPS'] = df['AGSIPSid']


df = df.drop('AGSIPSid', axis='columns')










print("PhIPSeq")
##	drop the sample column and then unique
tmp = pd.read_csv(phipdir+"manifest.csv",sep=',',dtype=object).drop('sample', axis='columns').drop_duplicates()
#	subject,sample,type,study,group,age,sex,plate
tmp = tmp[tmp['type'] != 'Phage Library']
tmp = tmp[tmp['type'] != 'input']
print("PhIPseq manifest.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)


#	PhIPseq manifest.csv
#	  subject                type study                group  age sex plate
#	0  024JCM     pemphigus serum  PEMS  Non Endemic Control   62   M    14
#	2  043MPL     pemphigus serum  PEMS  Non Endemic Control   61   F    13
#	4  074KBP     pemphigus serum  PEMS  Non Endemic Control   44   F    14
#	6  101VKC     pemphigus serum  PEMS  Non Endemic Control   46   F    13
#	8  108741  ALL maternal serum   PRN              control  NaN   F    16
#	7
#	Index(['subject', 'type', 'study', 'group', 'age', 'sex', 'plate'], dtype='object')
#	598
#	Index([   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,
#	       ...
#	       1133, 1135, 1137, 1138, 1139, 1140, 1141, 1143, 1145, 1147],
#	      dtype='int64', length=598)
df = pd.merge(tmp,df, left_on='subject', right_on='UCSFid', how='outer')
if ( df['subject'].equals(df['UCSFid']) ):
	df = df.drop('subject', axis='columns')
#print(df.head())


print(df.shape)
#	(9927, 603)




#	seropositivity files

tmp = pd.read_csv(phipdir+"out.123456131415161718/seropositive.10.csv",sep=',',dtype=object)
tmp = tmp[~tmp['species.2'].str.endswith('_B')]
tmp = tmp.drop('species.2', axis='columns')
tmp = tmp.rename(columns={'species': 'serosubject', 'species.1': "phipsamplegroup"})
tmp = tmp[tmp['phipsamplegroup'] != 'Phage Library']
print("seropositive.10.csv")
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
#print(tmp.index)
#	
#	seropositive.10.csv
#	  serosubject         phipsamplegroup Aichivirus A Alphapapillomavirus 10  ... Tanapox virus Torque teno virus Variola virus Venezuelan equine encephalitis virus
#	0  043MPL   pemphigus serum            3                      0  ...             0                 0             0                                    0
#	2  101VKC   pemphigus serum            0                      0  ...             0                 0             0                                    0
#	4    1301  meningioma serum            0                      0  ...             0                 0             0                                    0
#	6    1302  meningioma serum            0                      0  ...             0                 2             0                                    0
#	8    1303  meningioma serum            0                      0  ...             0                 2             0                                    0
#	
#	[5 rows x 64 columns]
#	64
#	Index(['serosubject', 'phipsamplegroup', 'Aichivirus A', 'Alphapapillomavirus 10',
#	       'Alphapapillomavirus 2', 'Alphapapillomavirus 3',
#	       'Alphapapillomavirus 7', 'Alphapapillomavirus 9', 'Bat coronavirus 1B',
#	       'Betapapillomavirus 1', 'Betapapillomavirus 2', 'Chikungunya virus',
#	       'Cowpox virus', 'Eastern equine encephalitis virus', 'Enterovirus A',
#	       'Enterovirus B', 'Enterovirus C', 'Hepatitis A virus',
#	       'Hepatitis B virus', 'Hepatitis C virus', 'Hepatitis E virus',
#	       'Human adenovirus A', 'Human adenovirus B', 'Human adenovirus C',
#	       'Human adenovirus D', 'Human adenovirus E', 'Human adenovirus F',
#	       'Human coronavirus HKU1', 'Human coronavirus NL63',
#	       'Human herpesvirus 1', 'Human herpesvirus 2', 'Human herpesvirus 3',
#	       'Human herpesvirus 4', 'Human herpesvirus 5', 'Human herpesvirus 6A',
#	       'Human herpesvirus 6B', 'Human herpesvirus 7', 'Human herpesvirus 8',
#	       'Human immunodeficiency virus 1', 'Human immunodeficiency virus 2',
#	       'Human metapneumovirus', 'Human parainfluenza virus 1',
#	       'Human parainfluenza virus 3', 'Human parainfluenza virus 4',
#	       'Human parvovirus B19', 'Human respiratory syncytial virus',
#	       'Influenza A virus', 'Influenza B virus', 'Influenza C virus',
#	       'Macacine herpesvirus 1', 'Mamastrovirus 1', 'Measles virus',
#	       'Norwalk virus', 'Orf virus', 'Papiine herpesvirus 2', 'Rhinovirus A',
#	       'Rhinovirus B', 'Ross River virus', 'Rotavirus A', 'Rubella virus',
#	       'Tanapox virus', 'Torque teno virus', 'Variola virus',
#	       'Venezuelan equine encephalitis virus'],
#	      dtype='object')
#	536
#	Index([   0,    2,    4,    6,    8,   10,   12,   14,   16,   18,
#	       ...
#	       1052, 1054, 1056, 1058, 1060, 1062, 1064, 1066, 1068, 1070],
#	      dtype='int64', length=536)
#	


#df = pd.merge(df,tmp, left_on='UCSFid', right_on='serosubject', how='outer')
#if ( df['serosubject'].equals(df['UCSFid']) ):
df = pd.merge(df,tmp, left_on='subject', right_on='serosubject', how='outer')
if ( df['serosubject'].equals(df['subject']) ):
	df = df.drop('serosubject', axis='columns')
#print(df.head())


print(df.shape)
#	(10211, 667)



#	add molecular subtypes


#covs=[]
#
##	/francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv
#tmp = pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.hla_dosage.csv",sep="\t",index_col=[0]).drop(['AF','R2'],axis='columns').T )
#
#tmp = pd.read_csv(pgsdir+"lists/cidr_covariates.tsv",sep="\t")
#tmp = tmp[['IID']]
#
#tmp = pd.read_csv(pgsdir+"lists/i370_covariates.tsv",sep="\t")
#
#tmp = pd.read_csv(pgsdir+"lists/onco_covariates.tsv",sep="\t")
#
##	print( dir )
##	dfs.append( pd.read_csv(hladir+"hla-"+dir+"-hg19/chr6.hla_dosage.csv",sep="\t",index_col=[0]).drop(['AF','R2'],axis='columns').T )
##hla = pd.concat(dfs, axis='index', sort=True)
##print("HLA dosage files")
#
##==> /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/lists/cidr_covariates.tsv <==
##IID	age_ucsf_surg	age_first_surg	sex	ethnicity	race	bmi	dxgroup	grade	who2021	pq	idhmut	bldyear	timept	dex	surgtype	deceased	survdays	ucsf_surg_year	first_surg_year	mgmt	mgmtindex
##
##==> /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/lists/i370_covariates.tsv <==
##IID	Age	sex	case	idhmut	pqimpute	tert	idhmut_gwas	idhmut_1p19qnoncodel_gwas	trippos_gwas	idhwt_gwas	idhmut_1p19qcodel_gwas	idhwt_1p19qnoncodel_TERTmut_gwas	idhmut_only_gwas	tripneg_gwas	idhwt_1p19qnoncodel_gwas	vstatus	survdays	VZVsr	dxcode	WHO2016type	temodar	dxyear	hospname	ngrade	chemo	rad	PC1	PC2	PC3	PC4	PC5	PC6	PCPC8	PC9	PC10	PC11	PC12	PC13	PC14	PC15	PC16	PC17	PC18	PC19	PC20
##
##==> /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/lists/onco_covariates.tsv <==
##IID	case	sex	age_group	idh	pq	tert	vstatus	survdays	source	VZVsr	age	dxcode	WHO2016type	temodar	dxyear	hospname	ngrade	chemo	rad	idhmut_gwas	idhmut_1p19qnoncodel_gwas	trippos_gwas	idhwt_gwas	idhmut_1p19qcodel_gwas	idhwt_1p19qnoncodel_TERTmut_gwas	idhwt_1p19qnoncodel_gwas	idhmut_only_gwas	tripneg_gwas	PC1	PC2	PC3	PCPC5	PC6	PC7	PC8	PC9	PC10	PC11	PC12	PC13	PC14	PC15	PC16	PC17	PC18	PC19	PC20
##
#




import glob
import os

# List your files
files = glob.glob(pgsdir+"lists/cidr*_cases.txt")
# Build a dict of sets for fast lookup
id_sets = {}
for f in files:
    col_name = os.path.splitext(os.path.basename(f))[0]  # or parse however you want
    with open(f) as fh:
        id_sets[col_name] = set(line.strip() for line in fh)
# Get all unique IDs across all files
all_ids = set().union(*id_sets.values())
# Build the dataframe
df_flags = pd.DataFrame(index=sorted(all_ids))
for col_name, ids in id_sets.items():
    df_flags[col_name] = df_flags.index.isin(ids).astype(int)
print(df_flags)

# Then merge with your main df
df = df.merge(df_flags, left_on='FID_IID', right_index=True, how='outer')
df[list(id_sets.keys())] = df[list(id_sets.keys())].astype('Int64')


# List your files
files = glob.glob(pgsdir+"lists/i370*_cases.txt")
# Build a dict of sets for fast lookup
id_sets = {}
for f in files:
    col_name = os.path.splitext(os.path.basename(f))[0]  # or parse however you want
    with open(f) as fh:
        id_sets[col_name] = set(line.strip() for line in fh)
# Get all unique IDs across all files
all_ids = set().union(*id_sets.values())
# Build the dataframe
df_flags = pd.DataFrame(index=sorted(all_ids))
for col_name, ids in id_sets.items():
    df_flags[col_name] = df_flags.index.isin(ids).astype(int)
print(df_flags)

# Then merge with your main df
df = df.merge(df_flags, left_on='FID_IID', right_index=True, how='outer')
df[list(id_sets.keys())] = df[list(id_sets.keys())].astype('Int64')


# List your files
files = glob.glob(pgsdir+"lists/onco*_cases.txt")
# Build a dict of sets for fast lookup
id_sets = {}
for f in files:
    col_name = os.path.splitext(os.path.basename(f))[0]  # or parse however you want
    with open(f) as fh:
        id_sets[col_name] = set(line.strip() for line in fh)
# Get all unique IDs across all files
all_ids = set().union(*id_sets.values())
# Build the dataframe
df_flags = pd.DataFrame(index=sorted(all_ids))
for col_name, ids in id_sets.items():
    df_flags[col_name] = df_flags.index.isin(ids).astype(int)
print(df_flags)

# Then merge with your main df
df = df.merge(df_flags, left_on='FID_IID', right_index=True, how='outer')
df[list(id_sets.keys())] = df[list(id_sets.keys())].astype('Int64')







#UCSFid,AGSid,age,sex,plate,CMV,EBV,HSV,XVZV2

tmp = pd.read_csv("/francislab/data1/refs/AGS/AGS.csv",dtype=object).fillna('')
print("AGS.csv")
tmp = tmp.drop(['AGSid','age','sex','plate'], axis='columns')
tmp['UCSFid'] = tmp['UCSFid'].str.rstrip('dup')
tmp = tmp.drop_duplicates()
print(tmp.head())
print(len(tmp.columns))
print(tmp.columns)
print(len(tmp.index))
print(tmp.index)
tmp = tmp.rename(columns={ 'CMV': 'ELISA_CMV', 'EBV': 'ELISA_EBV', 'HSV': 'ELISA_HSV', 'XVZV2': 'ELISA_VZV' })

df = pd.merge(df,tmp, left_on='UCSFid', right_on='UCSFid', how='outer')
#if ( df['serosubject'].equals(df['subject']) ):
#	df = df.drop('serosubject', axis='columns')



df = df.drop('UCSFid', axis='columns')	#	subject is identical and more populated




pd.set_option('display.max_seq_items', None)

#	reorder this mess.
#	pop items out and move them to the front so they end up in a specific order?
columns = list(df.columns)
column_order = [ 'subject','type', 'study', 'phipsamplegroup', 'group', 'age', 'sex', 'plate',
'ELISA_CMV','ELISA_EBV','ELISA_HSV','ELISA_VZV',
'AGSIPS','AGS','IPS','CIDR','FID_IID',
'cidr_IDHwt_meta_cases',
       'cidr_LrGG_IDHwt_meta_cases', 'cidr_HGG_IDHmut_meta_cases',
       'cidr_LrGG_IDHmut_meta_cases', 'cidr_LrGG_IDHmut_1p19qcodel_meta_cases',
       'cidr_ALL_meta_cases', 'cidr_HGG_IDHwt_meta_cases',
       'cidr_IDHmut_meta_cases', 'cidr_LrGG_IDHmut_1p19qintact_meta_cases',
       'i370_glioma_cases', 'i370_ALL_meta_cases',
       'i370_HGG_IDHmut_meta_cases', 'i370_HGG_IDHwt_meta_cases',
       'i370_IDHmut_meta_cases', 'i370_IDHwt_meta_cases',
       'i370_LrGG_IDHmut_1p19qcodel_meta_cases',
       'i370_LrGG_IDHmut_1p19qintact_meta_cases',
       'i370_LrGG_IDHmut_meta_cases', 'i370_LrGG_IDHwt_meta_cases',
       'onco_glioma_cases', 'onco_ALL_meta_cases',
       'onco_HGG_IDHmut_meta_cases', 'onco_HGG_IDHwt_meta_cases',
       'onco_IDHmut_meta_cases', 'onco_IDHwt_meta_cases',
       'onco_LrGG_IDHmut_1p19qcodel_meta_cases',
       'onco_LrGG_IDHmut_1p19qintact_meta_cases',
       'onco_LrGG_IDHmut_meta_cases', 'onco_LrGG_IDHwt_meta_cases']
for column in reversed(column_order):
	columns.insert(0, columns.pop(columns.index(column)))
df = df[columns]
print(df.columns)







#	'agsips_datasets.csv'
#	'agsips_covars.csv'
#	'PHIP_AGS.csv'
#	'ALL_AGS.csv'
#	'PHIP_IPS.csv'


#pd.set_option('display.max_rows', None)
#print(df[['hlaage','phipage']])

#import csv

#	for whatever reason, Numbers converts 473IRR to IRR 473 to be "helpful". Something special about IRR.

df.to_csv('PhIPseq_HLA.csv',index=False)	#,quoting=csv.QUOTE_ALL)

