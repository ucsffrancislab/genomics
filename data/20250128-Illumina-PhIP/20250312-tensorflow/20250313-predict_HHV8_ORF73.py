#!/usr/bin/env python3
#	---
#	title: "Tensorflow Prediction of Case/Control with HHV8/ORF73"
#	author: "JW"
#	date: "2025-03-12"
#	output: html_document
#	---


n=128
activation='sigmoid'
batch_size=250
epochs=75
test_size=0.25
random_state=15
early_stop=0
groups=['case','control']
plates=[1,2,3]

species=["Human herpesvirus 8"]
proteins=["ORF 73","Orf73","ORF73","Protein ORF73"]
files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv"]


import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
from tensorflow.keras import layers
from tensorflow.keras import models
from tensorflow.keras import utils
from tensorflow.keras import callbacks


datasets = []

for file in files:
	d = pd.read_csv(file, header=[0,1,2], low_memory=False)
	#print(d.iloc[:5,:5])
	#subject group   plate type            1   10  100  1000  10000
	#3056    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3108    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3209    control 2     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3211    control 4     glioma serum  0.0  0.0  0.0   0.0    0.0
	#3275    control 3     glioma serum  0.0  0.0  0.0   0.0    0.0
	#print("D shape")
	#print(d.shape)
	#	(84, 106663)
	datasets.append(d)
	del d

df = pd.concat(datasets)
del datasets
df.iloc[:5,:7]


##	Filter only in given species

if ( len(species)>0 ):
	print(species)
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','species']+species)]
df = df.droplevel([1],axis=1)
df.iloc[:5,:7]


##	Filter only in given proteins

if ( len(proteins)>0 ):
	print(proteins)
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','protein']+proteins)]
df = df.droplevel([1],axis=1)
df.iloc[:5,:7]


##	Filter groups

num_classes = len(groups)
df = df[ df['group'].isin(groups) ]
df.iloc[:5,:7]


##	Drop the type column

df = df.drop(columns=['type'])
df.iloc[:5,:7]


##	Filter plates

df = df[ df['plate'].isin(plates) ]
##	df = df.drop(columns=['plate'])		#	<------------- I think that I should leave plate here, but maybe later
##	print("Drop the plate column?")
df.iloc[:5,:7]


##	Drop the subject column

df = df.drop(columns=['subject'])
df.iloc[:5,:7]


##	Create X by dropping the group column

X = df.drop(columns=['group'])
X.iloc[:5,:7]


X.shape


##	Create y by extracting the group column

y = df['group']
y.iloc[60:66]


##	Encoding the groups to integers

#	apparently y NEEDS to be an integer
le = LabelEncoder()
y = le.fit_transform(y)
le.classes_


y = utils.to_categorical(y, num_classes=num_classes)
y[60:66]


##	Splitting into training and testing

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, shuffle=True, random_state=random_state)
actual = np.argmax(y_test, axis=-1)
actual


#	This is a "sequential" model. Basic and simple.
#	The other tutorial creates a "functional" model.
#	I'm gonna try to keep things simple and not create a functional unless I completely understand why I'm doing it.
#	Not just monkey see, monkey do.

##	Creating new model

model = models.Sequential()
##	print("Adding layer with",n,"units")
model.add(layers.Dense(units=n, activation=activation))
model.add(layers.Dropout(0.1))
##	print("Adding layer with",int(n/2),"units")
model.add(layers.Dense(units=int(n/2), activation=activation))
model.add(layers.Dropout(0.1))
model.add(layers.Dense(units=num_classes, activation='softmax'))


##	Compiling

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
##	#model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['accuracy'])


##	Model Summary

model.summary()


##	Fitting

#model.fit(X_train, y_train, epochs=args.epochs[0], callbacks=[my_callbacks[early_stop]], verbose=2, batch_size=batch_size)
model.fit(X_train, y_train, epochs=epochs, verbose=2, batch_size=batch_size)
##	#model.fit(X_train, y_train, epochs=50, verbose=2, batch_size=batch_size)


import keras
keras.utils.plot_model(model, to_file='gbm.png', show_shapes=True)


##	Model Summary

model.summary()


prediction = model.predict(X_test)


prediction = np.argmax(prediction, axis=-1)


print("Prediction . ",prediction)
print("Actual ..... ",actual)


ac_score = accuracy_score(actual, prediction)
ac_score


##	Predict all samples

prediction2 = model.predict(X)


prediction2 = np.argmax(prediction2, axis=-1)
actual2 = np.argmax(y, axis=-1)


print("Prediction2 . ",prediction2)
print("Actual2 ..... ",actual2)


ac_score2 = accuracy_score(actual2, prediction2)
ac_score2

