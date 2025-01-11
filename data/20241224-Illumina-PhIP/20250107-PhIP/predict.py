#!/usr/bin/env python3

# include standard modules
import os
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

parser.add_argument('-i', nargs=1, type=int, default=1, help='Loop counter to %(prog)s (default: %(default)s)')
parser.add_argument('-z', nargs=1, type=float, default=3.5, help='zscore threshold to %(prog)s (default: %(default)s)')
parser.add_argument('-n', nargs=1, type=int, default=128, help='First layer unit count to %(prog)s (default: %(default)s)')

parser.add_argument('-f', '--files', type=str, action='append', help='Datafiles to %(prog)s (default: %(default)s)')
#	default=[
#		'/francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv',
#		'/francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv'],
parser.add_argument('-g', '--groups', type=str, action='append', help='Groups to %(prog)s (default: %(default)s)')
#default=['case','control'], 
parser.add_argument('-b', '--batch_size', nargs=1, type=int, default=[24], help='Batch Size to %(prog)s (default: %(default)s)')
parser.add_argument('-a', '--activation', nargs=1, type=str, default=['relu'], help='Activation to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()


print(args)

#Namespace(i=[1], z=[20.0], n=[1024], groups=['case', 'control'], batch_size=[12], activation=['relu'])

i=args.i[0]
z=args.z[0]
n=args.n[0]
activation=args.activation[0]
batch_size=args.batch_size[0]



import pandas as pd
import numpy as np
from tensorflow import keras
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import Dense, Dropout
from sklearn.metrics import accuracy_score, confusion_matrix


datasets = []

for file in args.files:
	d = pd.read_csv(file, index_col=0,header=[0,1])
	print(d.iloc[:5,:5])
	print("D shape")
	print(d.shape)
	#	(84, 106663)
	datasets.append(d)

df = pd.concat(datasets)









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



num_classes = len(args.groups)
df = df[ df[('id','group')].isin(args.groups) ]
df = df.drop(columns=[('z','type')])

x = df.drop(columns=[('id','group')])
x[x < z] = 0
x[x >= z] = 1
x = x.T.groupby(level=1).sum().T
x[x < 5] = 0
x[x >= 5] = 1

y = df[('id','group')]






print("Filtered shape")
print(x.shape)

#x = pd.DataFrame(x, dtype=int)	#	doesn't seem to matter
print(x.iloc[:5,:5])


#print("Scaling the values")
#sc = StandardScaler()
#x = sc.fit_transform(x)
##print(x[:2])

print("Encoding the groups to integers")
#	apparently y NEEDS to be an integer
le = LabelEncoder()
y = le.fit_transform(y)
#print(y[:5])

print(le.classes_)

y = keras.utils.to_categorical(y, num_classes=num_classes)
#print(y[:5])

print("Splitting into training and testing")

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.20, shuffle=True)
actual = np.argmax(y_test, axis=-1)

# 32768 - crashes on 120GB
# 32768 - crashes on 60GB
# 16384 - crashes on 120GB sometimes
# 16384 - crashes on 60GB sometimes
	
print("Creating new model")

model = Sequential()
#model.add(Dense(units=256, activation='sigmoid'))
#model.add(Dense(units=256, activation='relu'))
#model.add(Dropout(0.1))

#	20,000 + 10,000 takes about 40GB of memory
	
print("Adding layer with",n,"units")
model.add(Dense(units=n, activation=activation))
model.add(Dropout(0.1))
	
print("Adding layer with",int(n/2),"units")
model.add(Dense(units=int(n/2), activation=activation))
model.add(Dropout(0.1))
	
model.add(Dense(units=num_classes, activation='softmax'))

print("Compiling")
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
#model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['accuracy'])


callback1 = keras.callbacks.EarlyStopping(monitor='loss', patience=3)
callback2 = keras.callbacks.EarlyStopping(
    monitor='accuracy', 
    min_delta=0.001,
    patience=3,
    mode='auto',
    verbose=2,
    baseline=None
)
callback3 = keras.callbacks.EarlyStopping(
    monitor='accuracy', 
    min_delta=0.001,
    patience=5,
    mode='auto',
    verbose=2,
    baseline=None,
		start_from_epoch=25
)


print("Fitting")
model.fit(x_train, y_train, epochs=50, callbacks=[callback3], verbose=2, batch_size=batch_size)
#model.fit(x_train, y_train, epochs=50, verbose=2, batch_size=batch_size)

prediction = model.predict(x_test)

prediction = np.argmax(prediction, axis=-1)
print("Prediction . ",prediction)

print("Actual ..... ",actual)

ac_score = accuracy_score(actual, prediction)
print("Accuracy",ac_score," loop:",i," z:",z," nodes:",n," batch_size:",batch_size," activation:",activation)






print("Python Done")

