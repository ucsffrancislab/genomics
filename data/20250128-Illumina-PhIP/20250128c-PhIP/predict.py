#!/usr/bin/env python3

# include standard modules
import os
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

parser.add_argument('-i', nargs=1, type=int, default=1,
	help='Loop counter to %(prog)s (default: %(default)s)')
parser.add_argument('-t','--test_size', nargs=1, type=float, default=[0.2],
	help='split test_size to %(prog)s (default: %(default)s)')
parser.add_argument('-z','--zscore', nargs=1, type=float, default=[3.5],
	help='zscore threshold to %(prog)s (default: %(default)s)')
parser.add_argument('-n', nargs=1, type=int, default=[128],
	help='First layer unit count to %(prog)s (default: %(default)s)')
parser.add_argument('-e','--early_stop', nargs=1, type=int, default=[2],
	help='Early stop function to %(prog)s (default: %(default)s)')
parser.add_argument('--epochs', nargs=1, type=int, default=[250],
	help='Epochs to %(prog)s (default: %(default)s)')

parser.add_argument('-f', '--files', type=str, action='append',
	help='Datafiles to %(prog)s (default: %(default)s)')
#	default=[
#		'/francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv',
#		'/francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv'],
parser.add_argument('-g', '--groups', type=str, action='append',default=[],
	help='Groups to %(prog)s (default: %(default)s)') #default=['case','control'], 
parser.add_argument('-r', '--random_state', nargs=1, type=int, default=[42],
	help='Random State to %(prog)s (default: %(default)s)')
parser.add_argument('-b', '--batch_size', nargs=1, type=int, default=[24],
	help='Batch Size to %(prog)s (default: %(default)s)')
parser.add_argument('-a', '--activation', nargs=1, type=str, default=['relu'],
	help='Activation to %(prog)s (default: %(default)s)')
parser.add_argument('-s', '--species', type=str, action='append', default=[],
	help='Limit to species to %(prog)s (default: %(default)s)')
parser.add_argument('-p', '--plates', type=int, action='append', default=[1,2,3],
	help='Plates to %(prog)s (default: %(default)s)')
# default=[1,2,3],
#default=[],

#parser.add_argument('--range1', nargs=1, type=int, default=[],
#	help='Range1 to %(prog)s (default: %(default)s)')
#parser.add_argument('--range2', nargs=1, type=int, default=[],
#	help='Range2 to %(prog)s (default: %(default)s)')

parser.add_argument('--protein', type=str, action='append', default=[],
	help='Protein to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()


print(args)

#Namespace(i=[1], z=[20.0], n=[1024], groups=['case', 'control'], batch_size=[12], activation=['relu'])

#protein=args.protein[0]
#range1=args.range1[0]
#range2=args.range2[0]
i=args.i[0]
z=args.zscore[0]
n=args.n[0]
activation=args.activation[0]
batch_size=args.batch_size[0]
test_size=args.test_size[0]
#species=args.species	#[0]
random_state=args.random_state[0]
early_stop=args.early_stop[0]
groups=args.groups
if( len(groups) == 0 ):
	groups=['case','control']
plates=args.plates
if( len(plates) == 0 ):
	plates=[1,2,3]


import pandas as pd
import numpy as np
#import tensorflow as tf
#from tensorflow import keras
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
#from keras.models import Sequential
#from keras.layers import Dense, Dropout
from sklearn.metrics import accuracy_score, confusion_matrix

# Correct way to import Keras
#from tensorflow import keras

# Example using layers module
from tensorflow.keras import layers
from tensorflow.keras import models
from tensorflow.keras import utils
from tensorflow.keras import callbacks


#hc 20250226/Counts.normalized.subtracted.trim.plus.mins.csv 
#subject,group,plate,type,1,10,100,1000,10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,1
#3056,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3108,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.60825873023148
#3209,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3211,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3275,control,3,glioma serum,0.0,0.0,0.0,0.0,0.0,0.2480143352285762,0.0,0.0,0.0,0.0,0.269037062545736

#	sbatch --nodes=1 --ntasks=2 --mem=30G --export=None --wrap="python3 -c \"import pandas as pd; pd.read_csv('20250226/Counts.normalized.subtracted.trim.plus.csv', header=[0],index_col=[0,1,2,3,4],low_memory=False).groupby(['subject','group','plate','type'],dropna=False).min().to_csv('20250226/Counts.normalized.subtracted.trim.plus.mins.csv')\""

datasets = []

for file in args.files:
	#d = pd.read_csv(file, index_col=0,header=[0,1],dtype={0:str})
	#d = pd.read_csv(file, index_col=[0,1,2,3],header=[0],dtype={0:str})
	#d = pd.read_csv(file, index_col=0,header=[0],dtype={0:str})	#	only keep the subject id as the index
	#d = pd.read_csv(file, header=[0,1], low_memory=False)	#	only keep the subject id as the index
	d = pd.read_csv(file, header=[0,1,2], low_memory=False)	#	only keep the subject id as the index
	print(d.iloc[:5,:5])
	#subject group   plate type            1   10  100  1000  10000
	#3056    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3108    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3209    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3211    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3275    control 3     glioma serum  0.0  0.0  0.0   0.0    0.0
	print("D shape")
	print(d.shape)
	#	(84, 106663)
	datasets.append(d)
	del d

df = pd.concat(datasets)
del datasets


#	hc 20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv 
#	subject,group,plate,type,1,10,100,1000,10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,1
#	subject,group,plate,species,Papiine herpesvirus 2,Vaccinia virus,Human herpesvirus 3,Hepatitis B vir
#	subject,group,plate,protein,Glycoprotein J,VACV-DUKE-045,Putative uncharacterized protein (Fragment)
#	3056,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#	3108,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.60825873023148
#	3209,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#	3211,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#	3275,control,3,glioma serum,0.0,0.0,0.0,0.0,0.0,0.2480143352285762,0.0,0.0,0.0,0.0,0.269037062545736
#	3314,control,4,glioma serum,0.0,0.0,6.0038244361658375,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0
#	3397,control,1,glioma serum,0.0,0.0,0.0469144105288203,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0


print("Filter only in given species")
if ( len(args.species)>0 ):
	print(args.species)
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','species']+args.species)]
df = df.droplevel([1],axis=1)
print(df.iloc[:5,:5])

print("Filter only in given proteins")
if ( len(args.protein)>0 ):
	print(args.protein)
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','protein']+args.protein)]
df = df.droplevel([1],axis=1)
print(df.iloc[:5,:5])


#		df.columns=df.columns.droplevel(1)		#	<<<-------------- Drop the virus species
#		
#		#df = df[df['z']=='pemphigus serum']
#		
#		df = df[ df['id'].isin(args.groups) ]
#		num_classes = len(args.groups)
#		df = df.drop(columns=["z"])
#		df = df.rename(columns={'id':'group'})
#		
#		print("Merged shape")
#		print(df.shape)
#		
#		df.fillna(0, inplace=True)
#		df.replace( np.inf,  9999999, inplace=True)
#		df.replace(-np.inf, -9999999, inplace=True)
#		
#		#print(x.head())
#			
#		print("Unfiltered shape")
#		print(x.shape)
#		
#		#	Remove any tile that doesn't include an entry above the z threshold?
#		#print("Filter x any >",z)
#		#x = x.loc[:, (x > z).any()]
#		
#		#	booleanize at the z threshold?
#		#print("Hit calling at >=",z)
#		x[x < z] = 0
#		x[x >= z] = 1
#		
#		y = df["group"]
#		#print(y.head())



print(df.iloc[:5,:5])

#      group plate    type         1   10  100  1000  10000
#subject 
#3056 control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
#3108 control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
#3209 control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
#3211 control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
#3275 control 3     glioma serum  0.0  0.0  0.0   0.0    0.0


#	y                       z               id  ...             10                 100
#	subject              type            group  ... Vaccinia virus Human herpesvirus 3
#	043MPL    pemphigus serum       NonEndemic  ...      -0.809725           -0.369451
#	101VKC    pemphigus serum       NonEndemic  ...      -0.600650           -0.531691
#	1301     meningioma serum    Merlin-intact  ...      -0.792386           -0.613376
#	1302     meningioma serum  Immune-enriched  ...      -0.658769           -0.066700
#	1303     meningioma serum  Immune-enriched  ...      -0.745436           -0.335026

print("Filter groups")
num_classes = len(groups)
#df = df[ df[('id','group')].isin(args.groups) ]
df = df[ df['group'].isin(groups) ]
print(df.iloc[:5,:5])

#df = df.drop(columns=[('z','type')])
df = df.drop(columns=['type'])
print("Drop the type column")
print(df.iloc[:5,:5])

print("Filter plates ",plates)
#df = df[ df['plate'].isin([1,2,3]) ]
df = df[ df['plate'].isin(plates) ]
df = df.drop(columns=['plate'])		#	<------------- I think that I should leave plate here, but maybe later
print("Drop the plate column?")
print(df.iloc[:5,:5])

df = df.drop(columns=['subject'])
print("Drop the subject column")
print(df.iloc[:5,:5])



#df = df.drop(columns=['type'])
##df = df.droplevel('subject', axis=1)
#print("DF")
#print(df.iloc[:5,:5])


#DF
#     group    1   10  100  1000
#0  control  0.0  0.0  0.0   0.0
#1  control  0.0  0.0  0.0   0.0
#2  control  0.0  0.0  0.0   0.0
#3  control  0.0  0.0  0.0   0.0
#4  control  0.0  0.0  0.0   0.0




#x = df.drop(columns=[('id','group')])

x = df.drop(columns=['group'])
print("X = drop the group column")
print(x.shape)
print(x.iloc[:5,:5])
#X
#     1   10  100  1000  10000
#0  0.0  0.0  0.0   0.0    0.0
#1  0.0  0.0  0.0   0.0    0.0
#2  0.0  0.0  0.0   0.0    0.0
#3  0.0  0.0  0.0   0.0    0.0
#4  0.0  0.0  0.0   0.0    0.0



#if ( args.species and len(args.range1)>0 and len(args.range2)>0 ):
#	print("Selecting subset of tiles")
#	x=x.iloc[:,args.range1[0]:args.range2[0]]
#	print(x.columns)
#	print("X")
#	print(x.shape)
#	print(x.iloc[:5,:5])


#datfile$peptide <- ifelse(datfile$peptide <= 0, 0.001, datfile$peptide)
#datfile$peptide <- log(datfile$peptide)


#print("Log transform.") # made no difference in testing
#x[x <= 0] = 0.001
#x = x.apply(np.log)





#	Filter?
#x[x < z] = 0
#x[x >= z] = 1
#x = x.T.groupby(level=1).sum().T
#x[x < 5] = 0
#x[x >= 5] = 1

#df=df.loc[:,df.columns[df.max()>10]]
#df=df.loc[:,df.columns[df.mean()>10]]
#df=df.loc[:, df.columns[(df > 10).sum() >= 5] ]
#y = df[('id','group')]



y = df['group']






print("Filtered shape")
print(x.shape)

#x = pd.DataFrame(x, dtype=int)	#	doesn't seem to matter
print(x.iloc[:5,:5])

#Filtered shape
#(168, 112689)
#     1   10  100  1000  10000
#0  0.0  0.0  0.0   0.0    0.0
#1  0.0  0.0  0.0   0.0    0.0
#2  0.0  0.0  0.0   0.0    0.0
#3  0.0  0.0  0.0   0.0    0.0
#4  0.0  0.0  0.0   0.0    0.0







#print("Scaling the values")	#	doesn't seem to make any difference despite so many that say its required
#sc = StandardScaler()
#x = sc.fit_transform(x)
#print(x[:2])






print("Encoding the groups to integers")
#	apparently y NEEDS to be an integer
le = LabelEncoder()
y = le.fit_transform(y)
#print(y[:5])

print(le.classes_)
#['case' 'control']


y = utils.to_categorical(y, num_classes=num_classes)
#print(y[:5])

print("Splitting into training and testing")

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=test_size, shuffle=True,random_state=random_state)
actual = np.argmax(y_test, axis=-1)

# 32768 - crashes on 120GB
# 32768 - crashes on 60GB
# 16384 - crashes on 120GB sometimes
# 16384 - crashes on 60GB sometimes
	
print("Creating new model")

model = models.Sequential()
#model.add(Dense(units=256, activation='sigmoid'))
#model.add(Dense(units=256, activation='relu'))
#model.add(Dropout(0.1))

#	20,000 + 10,000 takes about 40GB of memory
	
print("Adding layer with",n,"units")
model.add(layers.Dense(units=n, activation=activation))
model.add(layers.Dropout(0.1))
	
print("Adding layer with",int(n/2),"units")
model.add(layers.Dense(units=int(n/2), activation=activation))
model.add(layers.Dropout(0.1))
	
model.add(layers.Dense(units=num_classes, activation='softmax'))

print("Compiling")
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
#model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['accuracy'])


callback0 = callbacks.EarlyStopping()
callback1 = callbacks.EarlyStopping(
	monitor='loss',
	patience=3,
	start_from_epoch=20
)
callback2 = callbacks.EarlyStopping(
	monitor='accuracy', 
	min_delta=0.001,
	patience=3,
	mode='auto',
	verbose=2,
	baseline=None,
	start_from_epoch=20
)
callback3 = callbacks.EarlyStopping(
	monitor='accuracy', 
	min_delta=0.001,
	patience=5,
	mode='auto',
	verbose=2,
	baseline=None,
	start_from_epoch=25
)

my_callbacks = [callback0, callback1, callback2, callback3]


print("Fitting")
model.fit(x_train, y_train, epochs=args.epochs[0], callbacks=[my_callbacks[early_stop]], verbose=2, batch_size=batch_size)
#model.fit(x_train, y_train, epochs=50, verbose=2, batch_size=batch_size)

prediction = model.predict(x_test)

prediction = np.argmax(prediction, axis=-1)
print("Prediction . ",prediction)

print("Actual ..... ",actual)

ac_score = accuracy_score(actual, prediction)
#print("Accuracy",ac_score," loop:",i," z:",z," nodes:",n," batch_size:",batch_size," activation:",activation," test_size:",test_size," species:",species)
#print("Accuracy",ac_score,"loop:",i,"nodes:",n,"batch_size:",batch_size,"activation:",activation,"test_size:",test_size,"species:",args.species,"range:",args.range1,"-",args.range2,"plates:",plates,"random_state:",random_state,"early_stop:",early_stop)
print("Accuracy",ac_score,"loop:",i,"nodes:",n,"batch_size:",batch_size,"activation:",activation,"test_size:",test_size,"species:",args.species,"plates:",plates,"random_state:",random_state,"early_stop:",early_stop)




print("Predict all samples")
prediction2 = model.predict(x)
prediction2 = np.argmax(prediction2, axis=-1)
print("Prediction2 . ",prediction2)
actual2 = np.argmax(y, axis=-1)
print("Actual2 ..... ",actual2)
ac_score2 = accuracy_score(actual2, prediction2)
#print("Accuracy2",ac_score2,"loop:",i,"nodes:",n,"batch_size:",batch_size,"activation:",activation,"test_size:",test_size,"species:",args.species,"range:",args.range1,"-",args.range2,"plates:",plates,"random_state:",random_state,"early_stop:",early_stop)
print("Accuracy2",ac_score2,"loop:",i,"nodes:",n,"batch_size:",batch_size,"activation:",activation,"test_size:",test_size,"species:",args.species,"plates:",plates,"random_state:",random_state,"early_stop:",early_stop)

#print("Accuracy3",ac_score,ac_score2,"loop:",i,"nodes:",n,"batch_size:",batch_size,"activation:",activation,"test_size:",test_size,"species:",args.species,"protein:",args.protein,"range:",args.range1,"-",args.range2,"plates:",plates,"random_state:",random_state,"early_stop:",early_stop)
print("Accuracy3",ac_score,ac_score2,",loop:",i,",nodes:",n,",batch_size:",batch_size,",activation:",activation,",test_size:",test_size,",species:",args.species,",proteins:",args.protein,",plates:",plates,",random_state:",random_state,",early_stop:",early_stop,",epochs:",args.epochs[0])






## Get the weights from the first layer
#weights = model.layers[0].get_weights()[0]
#
#print(len(weights))
#
## Calculate feature importance as the sum of absolute weights for each feature
#feature_importance = np.sum(np.abs(weights), axis=1)
#
## Print feature importances
#for i, importance in enumerate(feature_importance[:10]):
#    print(f"Feature {i}: {importance}")
#
#print("sorted(feature_importance)[:10]")
#print(sorted(feature_importance)[:10])
#
#print("sorted(feature_importance,reverse=True)[:10]")
#print(sorted(feature_importance,reverse=True)[:10])





## Get the weights from the first layer
#weights = model.layers[1].get_weights()[0]
#
## Calculate feature importance as the sum of absolute weights for each feature
#feature_importance = np.sum(np.abs(weights), axis=1)
#
## Print feature importances
#for i, importance in enumerate(feature_importance[:10]):
#    print(f"Feature {i}: {importance}")
#
#print("sorted(feature_importance)[:10]")
#print(sorted(feature_importance)[:10])
#
#print("sorted(feature_importance,reverse=True)[:10]")
#print(sorted(feature_importance,reverse=True)[:10])


#2
#103112
#512
#Weights for layer dense

#for layer in model.layers:
#	weights = layer.get_weights()
#	print(len(weights))
#	for w in weights:
#		print(len(w))
#	print(f"Weights for layer {layer.name}: {weights}") 







print("Python Done")

