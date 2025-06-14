#!/usr/bin/env python3
#
##	Tensorflow Prediction of Case/Control
#

#	from IPython import get_ipython
#	get_ipython().__class__.__name__
#	'NoneType' in terminal
#	'ZMQInteractiveShell' in browser
#	'ZMQInteractiveShell' in nbconvert
running_as_notebook=False
from IPython import get_ipython
if get_ipython().__class__.__name__ == 'ZMQInteractiveShell':
	running_as_notebook=True
running_as_notebook

if running_as_notebook:
	from IPython.display import display, HTML
	display(HTML('<style type="text/css">.jp-Cell-outputCollapser{ display: block; background-color: red};.jp-Cell-outputWrapper{max-height: 100px } </style>'))
else:
	print("This appears to be running as a script. Some code will not be run.")

# include standard modules
import os
import re


#n=128

activation=os.getenv('ACTIVATION','sigmoid')
print('ACTIVATION:',activation)


epochs=100


test_size=float(os.getenv('TEST_SIZE',0.25))
print('TEST_SIZE:',test_size)

random_state=int(os.getenv('RANDOM_STATE',15))
print('RANDOM_STATE:',random_state)

out_dir=os.getenv('OUT_DIR','/tmp')
print('OUT_DIR:',out_dir)

loop_number=int(os.getenv('LOOP_NUMBER',0))
print('LOOP_NUMBER:',loop_number)

early_stop=0
groups=['case','control']


#files=["/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv"]
#ids="IDNO,sex,age,Orf_S_L,Orf0,Orf1,Orf1_N,Orf11,Orf12,Orf12_C,Orf12_N,Orf13,Orf14,Orf14_N,Orf15_F,Orf15_N,Orf16,Orf17,Orf18,Orf18_C,Orf19,Orf2,Orf20,Orf21,Orf22_1,Orf22_2,Orf23,Orf24,Orf24_N,Orf25,Orf26,Orf27,Orf28,Orf3,Orf30,Orf31_C,Orf31_F,Orf31_M,Orf32,Orf33,Orf33_N,Orf33_5,Orf35,Orf36,Orf37,Orf38,Orf39,Orf39_N,Orf4,Orf40,Orf41,Orf42,Orf43,Orf43_C,Orf44,Orf45,Orf46,Orf47,Orf48,Orf49,Orf5,Orf5_F,Orf50,Orf50_C,Orf51,Orf52,Orf53,Orf55,Orf56,Orf56_C,Orf57,Orf58,Orf59,Orf6,Orf60,Orf60_C,Orf61,Orf62,Orf63,Orf64,Orf65,Orf65_N,Orf66,Orf67,Orf67_C,Orf67_N,Orf68,Orf68_C,Orf68_F,Orf7,Orf8,Orf9,Orf9a,Orf9a_N,case_AZ"


#files=["/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_cmv_plco.csv"]
#ids="IDNO,sex,age,IRS1,RL1,RL10,RL11,RL13,RL5A,RL6,TRS1,UL1,UL10,UL100,UL102,UL103,UL104,UL105,UL11,UL111A,UL112,UL114,UL115,UL116,UL117,UL119,UL120,UL121,UL122,UL123,UL124,UL128,UL13,UL130,UL131A,UL132,UL133,UL135,UL136,UL138,UL139,UL14,UL140,UL141,UL142,UL144,UL145,UL146,UL147,UL147A,UL148,UL148A,UL148B,UL148C,UL148D,UL150,UL154,UL15A,UL16,UL17,UL18,UL19,UL2,UL20,UL21A,UL22A,UL23,UL24,UL25,UL26,UL27,UL29,UL30,UL31,UL32,UL33,UL34,UL35,UL36,UL37,UL38,UL4,UL40,UL41A,UL42,UL43,UL44,UL45,UL46,UL47,UL48A,UL48N,UL49,UL5,UL50,UL51,UL52,UL53,UL54,UL55,UL56,UL57,UL6,UL69,UL7,UL70,UL71,UL72,UL73,UL74,UL74A,UL75,UL76,UL77,UL78,UL79,UL8,UL80,UL80_5,UL82,UL83,UL84,UL85,UL86,UL87,UL88,UL89,UL9,UL91,UL92,UL93,UL95,UL96,UL97,UL98,UL99,US1,US10,US11,US12,US13,US14,US15,US16,US17,US18,US19,US2,US20,US21,US22,US23,US24,US26,US27,US28,US29,US3,US30,US31,US32,US34,US34A,US6,US7,US8,US9,case_AZ"

#files=["/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_human_plco.csv"]
#ids="IDNO,sex,age,ACPP,ACRBP,ACTN4,ADAM17,ADD2,ADFP,AFP,AKAP13,ALDH1A1,ALK,ANKHD1,ANKRD20A1,ANXA2,APBB1,APC,ARHGAP18,ART4,ASAP1,ATIC,BAAT,BAGE4,BAGE5,BCAP31,BCL2,BCL2L1,BIRC5,BIRC7,BNIP1,BNIP2,BNIP3,BNIP3L,BNIPL,BRAF,BTBD2,C1D,C6orf89,CA9,CALR3,CASP5,CASP8,CCND1,CCNI,CD44,CDC27,CDK4,CDKN1A,CDKN2A,CEACAM5,CIAPIN1,CLCA2,COTL1,CPSF1,CSAG2,CSF1,CTAG2,CTAGE5,CTNNB1,CTSH,CXADR,CYP1B1,DCT,DDR1,DEK,DES,DKK1,DLD,DNAJC8,DPH7,DPYSL4,DST,DUSP3,EBI2,EBI3,EBLN2,EBNA,EEF1B2,EEF2,EFTUD2,EID3,EIF4EBP1,EPHA2,ERBB2,ERVFRDE1,ERVMER34_1,ERVV_2,ERVW_1,ETV5,ETV6,EZH2,FAM184A,FAU,FLVCR2,FMNL1,FMOD,FN1,FOLH1,FUT1,GAGE4,GAGE6,GAGE8,GAPDH,GFAP,GLIPR1L2,GPC3,GPD1,GPI,GPNMB,GPR143,H3F3A,HAVCR1,HAVCR2,HBXAP,HBXIP,HCLS1,HHAT,HIP1,HMMR,HMOX1,HPSE,HSP90AA1,HSPA1B,HSPH1,ICAM1,IFFO,IFFO1,IGF2BP3,IL13RA2,ING4,ITGB8,JUP,KAAG1,KIF2C,KLK3,KLK4,KM_HN_1,KRAS,KTN1,LAMR1,LCK,LDLR,LEPREL4,LGALS3BP,LPGAT1,MAGEA1,MAGEA10,MAGEA12,MAGEA2,MAGEA3,MAGEA6,MAGEA9,MAGEB1,MAGEB2,MAGEC2,MAGED4,MAP1LC3A,MC1R,ME1,MFI2,MLANA,MMP14,MMP2,MOK,MOV10,MOV10L1,MRPL28,MRVI1,MSLN,MUC1,MUM1,MYO1B,NAA15,NCAM1,NELFA,NFYC,NIT2,NME1,NME2,NPM1,NRAS,NUP214,OGT,OS9,PA2G4,PAFAH1B1,PAGE4,PAPOLG,PARP12,PAX3,PDAP1,PDGFRA,PGK1,PHF20,PIBF1,PMEL,PPIB,PRAME,PRDX5,PRTN3,PSCA,PTHLH,PTPRK,PVR,PVRIG,PVRL1,PVRL2,PVRL3,PVRL4,PXDNL,RAB38,RANBP2L1,RBBP6,RBM6,RBPSUH,RCV1,RFX4,RGS5,RNF43,RPA1,RPL10A,RPL5,RPS2,RPS8,RRP36,RTN4,RUNX1,RWDD1,SART1,SCGB2A2,SCP2,SCRN1,SDC1,SDCBP,SFMBT1,SIRT2,SLBP,SLC35A4,SLC45A3,SNRPD2,SOX10,SOX2,SOX6,SPA17,SPATA20,SPI1,SSX1,SSX2,SSX4,STAT1,STEAP1,STK33,STUB1,SYCP1,SYT1,TACSTD1,TAPBP,TAX1BP3,TBC1D4,TGFBR2,TNFRSF14,TNKS2,TOR3A,TP53,TPI1,TRAPPC1,TRIM68,TRMT1L,TRPM8,TSPYL1,TTK,TXNDC16,TXNRD1,TYMS,UBA2,UBE2A,UBE2V1,UBXN11,USP37,VIM,WDR46,WDR85,WT1,XBP1,XPR1,YBX1,ZNF324,ZNF395,case_AZ"


ids=''
files=["/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv",
	"/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_cmv_plco.csv",
	"/francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_human_plco.csv"]
ids="IDNO,sex,age,Orf_S_L,Orf0,Orf1,Orf1_N,Orf11,Orf12,Orf12_C,Orf12_N,Orf13,Orf14,Orf14_N,Orf15_F,Orf15_N,Orf16,Orf17,Orf18,Orf18_C,Orf19,Orf2,Orf20,Orf21,Orf22_1,Orf22_2,Orf23,Orf24,Orf24_N,Orf25,Orf26,Orf27,Orf28,Orf3,Orf30,Orf31_C,Orf31_F,Orf31_M,Orf32,Orf33,Orf33_N,Orf33_5,Orf35,Orf36,Orf37,Orf38,Orf39,Orf39_N,Orf4,Orf40,Orf41,Orf42,Orf43,Orf43_C,Orf44,Orf45,Orf46,Orf47,Orf48,Orf49,Orf5,Orf5_F,Orf50,Orf50_C,Orf51,Orf52,Orf53,Orf55,Orf56,Orf56_C,Orf57,Orf58,Orf59,Orf6,Orf60,Orf60_C,Orf61,Orf62,Orf63,Orf64,Orf65,Orf65_N,Orf66,Orf67,Orf67_C,Orf67_N,Orf68,Orf68_C,Orf68_F,Orf7,Orf8,Orf9,Orf9a,Orf9a_N,IRS1,RL1,RL10,RL11,RL13,RL5A,RL6,TRS1,UL1,UL10,UL100,UL102,UL103,UL104,UL105,UL11,UL111A,UL112,UL114,UL115,UL116,UL117,UL119,UL120,UL121,UL122,UL123,UL124,UL128,UL13,UL130,UL131A,UL132,UL133,UL135,UL136,UL138,UL139,UL14,UL140,UL141,UL142,UL144,UL145,UL146,UL147,UL147A,UL148,UL148A,UL148B,UL148C,UL148D,UL150,UL154,UL15A,UL16,UL17,UL18,UL19,UL2,UL20,UL21A,UL22A,UL23,UL24,UL25,UL26,UL27,UL29,UL30,UL31,UL32,UL33,UL34,UL35,UL36,UL37,UL38,UL4,UL40,UL41A,UL42,UL43,UL44,UL45,UL46,UL47,UL48A,UL48N,UL49,UL5,UL50,UL51,UL52,UL53,UL54,UL55,UL56,UL57,UL6,UL69,UL7,UL70,UL71,UL72,UL73,UL74,UL74A,UL75,UL76,UL77,UL78,UL79,UL8,UL80,UL80_5,UL82,UL83,UL84,UL85,UL86,UL87,UL88,UL89,UL9,UL91,UL92,UL93,UL95,UL96,UL97,UL98,UL99,US1,US10,US11,US12,US13,US14,US15,US16,US17,US18,US19,US2,US20,US21,US22,US23,US24,US26,US27,US28,US29,US3,US30,US31,US32,US34,US34A,US6,US7,US8,US9,ACPP,ACRBP,ACTN4,ADAM17,ADD2,ADFP,AFP,AKAP13,ALDH1A1,ALK,ANKHD1,ANKRD20A1,ANXA2,APBB1,APC,ARHGAP18,ART4,ASAP1,ATIC,BAAT,BAGE4,BAGE5,BCAP31,BCL2,BCL2L1,BIRC5,BIRC7,BNIP1,BNIP2,BNIP3,BNIP3L,BNIPL,BRAF,BTBD2,C1D,C6orf89,CA9,CALR3,CASP5,CASP8,CCND1,CCNI,CD44,CDC27,CDK4,CDKN1A,CDKN2A,CEACAM5,CIAPIN1,CLCA2,COTL1,CPSF1,CSAG2,CSF1,CTAG2,CTAGE5,CTNNB1,CTSH,CXADR,CYP1B1,DCT,DDR1,DEK,DES,DKK1,DLD,DNAJC8,DPH7,DPYSL4,DST,DUSP3,EBI2,EBI3,EBLN2,EBNA,EEF1B2,EEF2,EFTUD2,EID3,EIF4EBP1,EPHA2,ERBB2,ERVFRDE1,ERVMER34_1,ERVV_2,ERVW_1,ETV5,ETV6,EZH2,FAM184A,FAU,FLVCR2,FMNL1,FMOD,FN1,FOLH1,FUT1,GAGE4,GAGE6,GAGE8,GAPDH,GFAP,GLIPR1L2,GPC3,GPD1,GPI,GPNMB,GPR143,H3F3A,HAVCR1,HAVCR2,HBXAP,HBXIP,HCLS1,HHAT,HIP1,HMMR,HMOX1,HPSE,HSP90AA1,HSPA1B,HSPH1,ICAM1,IFFO,IFFO1,IGF2BP3,IL13RA2,ING4,ITGB8,JUP,KAAG1,KIF2C,KLK3,KLK4,KM_HN_1,KRAS,KTN1,LAMR1,LCK,LDLR,LEPREL4,LGALS3BP,LPGAT1,MAGEA1,MAGEA10,MAGEA12,MAGEA2,MAGEA3,MAGEA6,MAGEA9,MAGEB1,MAGEB2,MAGEC2,MAGED4,MAP1LC3A,MC1R,ME1,MFI2,MLANA,MMP14,MMP2,MOK,MOV10,MOV10L1,MRPL28,MRVI1,MSLN,MUC1,MUM1,MYO1B,NAA15,NCAM1,NELFA,NFYC,NIT2,NME1,NME2,NPM1,NRAS,NUP214,OGT,OS9,PA2G4,PAFAH1B1,PAGE4,PAPOLG,PARP12,PAX3,PDAP1,PDGFRA,PGK1,PHF20,PIBF1,PMEL,PPIB,PRAME,PRDX5,PRTN3,PSCA,PTHLH,PTPRK,PVR,PVRIG,PVRL1,PVRL2,PVRL3,PVRL4,PXDNL,RAB38,RANBP2L1,RBBP6,RBM6,RBPSUH,RCV1,RFX4,RGS5,RNF43,RPA1,RPL10A,RPL5,RPS2,RPS8,RRP36,RTN4,RUNX1,RWDD1,SART1,SCGB2A2,SCP2,SCRN1,SDC1,SDCBP,SFMBT1,SIRT2,SLBP,SLC35A4,SLC45A3,SNRPD2,SOX10,SOX2,SOX6,SPA17,SPATA20,SPI1,SSX1,SSX2,SSX4,STAT1,STEAP1,STK33,STUB1,SYCP1,SYT1,TACSTD1,TAPBP,TAX1BP3,TBC1D4,TGFBR2,TNFRSF14,TNKS2,TOR3A,TP53,TPI1,TRAPPC1,TRIM68,TRMT1L,TRPM8,TSPYL1,TTK,TXNDC16,TXNRD1,TYMS,UBA2,UBE2A,UBE2V1,UBXN11,USP37,VIM,WDR46,WDR85,WT1,XBP1,XPR1,YBX1,ZNF324,ZNF395,case_AZ"


#ids=os.getenv('IDS','')
#print('IDS:',ids)

outfile=out_dir+'/three_signals'+'-A:'+activation+'-TS:'+str(test_size)+'-RS:'+str(random_state)+'-LN:'+str(loop_number)
print(outfile)

#modelname='signal_vzv_plco'
#print('MODEL NAME:',modelname)


if( ids == '' ):
	ids=[]
else:
	ids=ids.split(',')


import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder
from keras import utils
from keras import callbacks
from keras.layers import (
	Dense,
	Dropout,
	Flatten,
	Input,
	concatenate,
	Embedding
)
from keras.models import Model
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
le = LabelEncoder()


datasets = []

for file in files:


	#d = pd.read_csv(file, header=[0,1,2], low_memory=False)
	#d = pd.read_csv(file, header=[0,1], low_memory=False)

	#d = pd.read_csv(file, header=[0], low_memory=False)
	d = pd.read_csv(file, low_memory=False, index_col=['IDNO','sex','age','case_AZ'])

	print(d.iloc[:5,:5])
	#subject group   plate type            1   10  100  1000  10000
	#3056    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3108    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3209    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3211    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3275    control 3     glioma serum  0.0  0.0  0.0   0.0    0.0
	print("d shape")
	print(d.shape)
	#	(84, 106663)
	datasets.append(d)
	del d

df = pd.concat(datasets,axis='columns')
del datasets
print(df.iloc[:5,:10])

df=df.reset_index()

print("df.shape")
print(df.shape)

print("df.columns")
print(df.columns)




###	Filter only in given ids

if ( len(ids)>0 ):
	print(ids)
	#df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','plate']+ids)]
	#df = df.loc[:, df.columns.isin(['subject','type','group','age','sex','plate']+ids)]
	df = df.loc[:, df.columns.isin(ids)]

##df = df.droplevel([1],axis=1)	#	don't want to drop the last "index"
df.iloc[:5,:10]




#	subject,type,group,age,sex,plate

##	Filter groups

#num_classes = len(groups)
#df = df[ df['group'].isin(groups) ]
#df.iloc[:5,:10]


#	why int8? Why not just int?
#	int8 later does some sort of Embedding. Not entirely sure what that's gonna do.
#	int is just int64

#df['age'] = df['age'].astype('int')
#df = df.drop(columns=['age'])


df['sex'] = le.fit_transform(df['sex']).astype('int')
#df = df.drop(columns=['sex'])


print(df.iloc[:5,:10])

print(df.dtypes)

##	Drop the type column

#df = df.drop(columns=['type'])
#df.iloc[:5,:10]



##	Drop the subject column

#df = df.drop(columns=['subject'])
df = df.drop(columns=['IDNO'])
df.iloc[:5,:10]


#	we now have the tile ids, plate, plus age and sex


##	Create X by dropping the group column

X = df.drop(columns=['case_AZ'])
print(X.iloc[:5,:10])


print("X.shape")
print(X.shape)


x_columns=X.columns


##	Create y by extracting the group column

#y = df['group']
y = df['case_AZ']
#y.iloc[60:66]
y[60:66]


##	Encoding the groups to integers

#	apparently y NEEDS to be an integer
y = le.fit_transform(y)
y = le.fit_transform(y).astype(bool)
print(y[60:66])


##	Create a FUNCTIONAL model for SHAP

# normalize data (this is important for model convergence)

dtypes = list(zip(X.dtypes.index, map(str, X.dtypes)))
for k, dtype in dtypes:
    if dtype == "float32":
        X[k] -= X[k].mean()
        X[k] /= X[k].std()

##	Splitting into training and testing

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, shuffle=True, random_state=random_state)


# build model
input_els = []
encoded_els = []
for k, dtype in dtypes:
    input_els.append(Input(shape=(1,)))
    if dtype == "int8":
        e = Flatten()(Embedding(X_train[k].max() + 1, 1)(input_els[-1]))
    else:
        e = input_els[-1]
    encoded_els.append(e)

input_els[:5]

len(input_els)

encoded_els[:5]

len(encoded_els)

encoded_els = concatenate(encoded_els)
encoded_els

max_nodes=min(int(len(x_columns)/2),500)
#max_nodes=min(len(x_columns),500)
print("Max recommended nodes:",max_nodes)


#layer1 = Dropout(0.1)(Dense(int(n/2), activation=activation)(Dropout(0.1)(Dense(n, activation=activation)(encoded_els))))
#layer1 = Dropout(0.1)(Dense(int(len(x_columns)/4), activation=activation)(Dropout(0.1)(Dense(int(len(x_columns)/2), activation=activation)(encoded_els))))
#layer1 = Dropout(0.1)(Dense(int(len(x_columns)/2), activation=activation)(encoded_els))
#layer1 = Dropout(0.2)(Dense(int(len(x_columns)/2), activation=activation)(Dropout(0.2)(Dense(len(x_columns), activation=activation)(encoded_els))))
#	Need to put a max on these. Somehow they trigger memory or time issues that cause the kernel to crash
#	x_columns 3979 is too much, 1410 is ok.
layer1 = Dropout(0.3)( Dense(int(max_nodes/2), activation=activation)( Dropout(0.3)( Dense(max_nodes, activation=activation)(encoded_els))))
layer1

out = Dense(1)(layer1)
out

model = Model(inputs=input_els, outputs=[out])

##	Compiling

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])


class MyThresholdCallback(callbacks.Callback):
	def __init__(self, threshold):
		super(MyThresholdCallback, self).__init__()
		self.threshold = threshold

	def on_epoch_end(self, epoch, logs=None): 
		#val_acc = logs["val_acc"]
		#if val_acc >= self.threshold:
		if logs.get('accuracy') >= self.threshold and logs.get('val_accuracy') >= self.threshold:
			self.model.stop_training = True


##	Fitting

#model.fit(X_train, y_train, epochs=args.epochs[0], callbacks=[my_callbacks[early_stop]], verbose=2, batch_size=batch_size)
#model.fit(X_train, y_train, epochs=epochs, verbose=2, batch_size=batch_size)

print("And max epochs?")


#	all one run or multiple batches?
batch_size=int(len(X)/3+0.5)
#batch_size=int(len(X)/2+0.5)
#batch_size=len(X)+1
print("Using batch size",batch_size)

threshold=0.9

model.fit(
	[X_train[k].values for k, t in dtypes],
	y_train,
	epochs=epochs,
	batch_size=batch_size,
	shuffle=True,
	validation_data=([X_test[k].values for k, t in dtypes], y_test),
	callbacks=[MyThresholdCallback(threshold=threshold)]
)


#utils.plot_model(model, to_file=modelname+'.png', show_shapes=True)


##	Model Summary

model.summary()

print("Y train",y_train)

y_train_pred = (model.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten()
print("Predicted y train",y_train_pred)

train_score=accuracy_score(y_train, y_train_pred)
print("Train accuracy score",train_score)

if running_as_notebook:
	display(HTML('<h1>Training Score {}</h1><br/>'.format(train_score)))

result = confusion_matrix(y_train, y_train_pred)
print("Confusion Matrix:")
print(result)

print("Y test",y_test)

y_test_pred = (model.predict([X_test[k].values for k, t in dtypes]) > 0.5).flatten()
print("Predicted y test",y_test_pred)

test_score=accuracy_score(y_test, y_test_pred)
print("Test accuracy score",test_score)

if running_as_notebook:
	display(HTML('<h1>Testing Score {}</h1><br/>'.format(test_score)))

result = confusion_matrix(y_test, y_test_pred)
print("Confusion Matrix:")
print(result)

print("Y all",y)

y_pred = (model.predict([X[k].values for k, t in dtypes]) > 0.5).flatten()
print("Predicted y",y_pred)

all_score=accuracy_score(y, y_pred)
print("All accuracy score",all_score)

if running_as_notebook:
	display(HTML('<h1>All Y Score {}</h1><br/>'.format(all_score)))

result = confusion_matrix(y, y_pred)
print("Confusion Matrix:")
print(result)


print("All stats",train_score,test_score,all_score,"random state",random_state,"test size",test_size,"activation",activation)


outfile=outfile+'-'+str(round(train_score, 3))+'-'+str(round(test_score, 3))+'-'+str(round(all_score, 3))+'.csv'


#	I could add a check here for accuracy. Not really interested in important features for failed models



## Explain predictions

import shap

if train_score>=threshold and test_score>=threshold and running_as_notebook:
	# print the JS visualization code to the notebook
	display(shap.initjs())


#Here we take the Keras model trained above and explain why it makes different predictions for different individuals. SHAP expects model functions to take a 2D numpy array as input, so we define a wrapper function around the original Keras predict function.

def f(X):
    return model.predict([X[:, i] for i in range(X.shape[1])]).flatten()


###	Explain all predictions


#if running_as_notebook:
#	#explainer = shap.KernelExplainer(f, shap.sample(X,30,random_state=42))	#	try using just 30 samples at first for speed
#	explainer = shap.KernelExplainer(f, X)
if train_score>=threshold and test_score>=threshold:
	explainer = shap.KernelExplainer(f, X)


#%%capture captured_explanation
#	CANNOT have a comment after a capture line
#	not sure if this is needed when this is in a condition
#	This is a syntax error outside of notebook
#	%%capture must be the first line of the cell in Jupyter in order for it to be recognized correctly.
#	Add apparently, it can be commented out and still work. Or jupytext uncommented it for me.
#if running_as_notebook:
#	explanation = explainer(X)
if train_score>=threshold and test_score>=threshold:
	explanation = explainer(X)


#	could do something like this to universally shut this up
#	it produces many lines that are ~400,000 chars long filled with ^H backspaces for its progressbar
#import os, sys
#sys.stdout, sys.stderr = open(os.devnull, 'w'), open(os.devnull, 'w')
#explanation = explainer(X)
#sys.stdout, sys.stderr = sys.__stdout__, sys.__stderr__


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	display(explanation.shape)


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	display(explanation[1])


##	Extract shap values and sort by absolute overall impact (values from summary plot)

if train_score>=threshold and test_score>=threshold:
	df = pd.DataFrame(index=X.columns,
			data={'value':[round(num, 3) for num in np.abs(explanation.values).mean(axis=0)]}
			).sort_values(by='value', ascending=False, key=abs)
	if running_as_notebook:
		display(df)
	else:
		print(df)
		df.to_csv(outfile, sep=',')


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.summary_plot( explanation, plot_type="bar")


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.plots.beeswarm(explanation,max_display=20)


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.plots.bar(explanation,max_display=20)


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.plots.heatmap(explanation,max_display=20)


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.plots.violin(explanation)


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	shap.plots.force(explanation)


#	for i in range(0,len(X)):
#		print(i)
#		display(shap.force_plot(explanation[i]))
#	
#	
#	for i in range(0,len(X)):
#		print(i)
#		shap.plots.waterfall(explanation[i])


if train_score>=threshold and test_score>=threshold and running_as_notebook:
	display(HTML("<script>const collapsers = document.querySelectorAll('.jp-Cell-outputCollapser'); collapsers.forEach(element => { element.parentElement.style['maxHeight']='100px'; element.addEventListener('click', function(event) { if(element.parentElement.style['maxHeight']==''){ element.parentElement.style['maxHeight']='100px' }else{ element.parentElement.style['maxHeight']='' } }); }); </script>"))

