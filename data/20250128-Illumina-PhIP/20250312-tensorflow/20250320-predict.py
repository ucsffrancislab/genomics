#!/usr/bin/env python3
#
##	Tensorflow Prediction of Case/Control
#

from IPython.display import display, HTML

HTML('<style type="text/css">.jp-Cell-outputCollapser{ display: block; background-color: red; max-height: 100px } </style>')


# include standard modules
import os
import re

#n=128
activation='sigmoid'
batch_size=250
epochs=1000
test_size=0.25
random_state=15
early_stop=0
groups=['case','control']
plates=[1,2,3]

files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv"]

species=os.getenv('SPECIES','')
species

proteins=os.getenv('PROTEINS','')
proteins

modelname=re.sub(r'[^a-zA-Z0-9]','_',"model."+species+"."+proteins)
modelname

if( species == '' ):
	species=[]
else:
	species=species.split(',')

if( proteins == '' ):
	proteins=[]
else:
	proteins=proteins.split(',')


import pandas as pd
import numpy as np
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
	#df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','species']+species)]
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','species']+species)]
df = df.droplevel([1],axis=1)
df.iloc[:5,:7]


##	Filter only in given proteins

if ( len(proteins)>0 ):
	print(proteins)
	#df = df.loc[:, df.columns.get_level_values(1).isin(['subject','group','plate','protein']+proteins)]
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','protein']+proteins)]
df = df.droplevel([1],axis=1)
df.iloc[:5,:7]


#	subject,type,group,age,sex,plate

##	Filter groups

num_classes = len(groups)
df = df[ df['group'].isin(groups) ]
df.iloc[:5,:7]


#	why int8? Why not just int?
#	int8 later does some sort of Embedding. Not entirely sure what that's gonna do.
#	int is just int64

#df['age'] = df['age'].astype('int')
df = df.drop(columns=['age'])


df['sex'] = le.fit_transform(df['sex']).astype('int')
#df = df.drop(columns=['sex'])


print(df.iloc[:5,:7])

print(df.dtypes)

##	Drop the type column

df = df.drop(columns=['type'])
df.iloc[:5,:7]


##	Filter plates

df['plate'] = df['plate'].astype('int')
df = df[ df['plate'].isin(plates) ]
#print("Drop the plate column?")
#df = df.drop(columns=['plate'])		#	<------------- I think that I should leave plate here, but maybe later
df.iloc[:5,:7]


##	Drop the subject column

df = df.drop(columns=['subject'])
df.iloc[:5,:7]


#	we now have the tile ids, plate, plus age and sex


##	Create X by dropping the group column

X = df.drop(columns=['group'])
print(X.iloc[:5,:7])


print("X.shape")
print(X.shape)


x_columns=X.columns


##	Create y by extracting the group column

y = df['group']
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

#layer1 = Dropout(0.1)(Dense(int(n/2), activation=activation)(Dropout(0.1)(Dense(n, activation=activation)(encoded_els))))
#layer1 = Dropout(0.1)(Dense(int(len(x_columns)/4), activation=activation)(Dropout(0.1)(Dense(int(len(x_columns)/2), activation=activation)(encoded_els))))
#layer1 = Dropout(0.1)(Dense(int(len(x_columns)/2), activation=activation)(encoded_els))
#layer1 = Dropout(0.2)(Dense(int(len(x_columns)/2), activation=activation)(Dropout(0.2)(Dense(len(x_columns), activation=activation)(encoded_els))))
#	Need to put a max on these. Somehow they trigger memory or time issues that cause the kernel to crash
#	x_columns 3979 is too much, 1410 is ok.
layer1 = Dropout(0.2)( Dense(min(int(len(x_columns)/8),150), activation=activation)( Dropout(0.2)( Dense(min(int(len(x_columns)/4),300), activation=activation)(encoded_els))))
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

model.fit(
	[X_train[k].values for k, t in dtypes],
	y_train,
	epochs=epochs,
	batch_size=512,
	shuffle=True,
	validation_data=([X_test[k].values for k, t in dtypes], y_test),
	callbacks=[MyThresholdCallback(threshold=0.78)]
)


#utils.plot_model(model, to_file=modelname+'.png', show_shapes=True)


##	Model Summary

model.summary()

print("Y train",y_train)

print("Predicted y train",(model.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten())

print("Train accuracy score",accuracy_score(y_train, (model.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten())) 

score=accuracy_score(y_train, (model.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten())
HTML('<h1>Training Score {}</h1><br/>'.format(score))

print("Y test",y_test)

print("Predicted y test",(model.predict([X_test[k].values for k, t in dtypes]) > 0.5).flatten())

print("Test accuracy score",accuracy_score(y_test, (model.predict([X_test[k].values for k, t in dtypes]) > 0.5).flatten())) 

score=accuracy_score(y_test, (model.predict([X_test[k].values for k, t in dtypes]) > 0.5).flatten())
HTML('<h1>Testing Score {}</h1><br/>'.format(score))



## Explain predictions

import shap

# print the JS visualization code to the notebook
shap.initjs()


#Here we take the Keras model trained above and explain why it makes different predictions for different individuals. SHAP expects model functions to take a 2D numpy array as input, so we define a wrapper function around the original Keras predict function.

def f(X):
    return model.predict([X[:, i] for i in range(X.shape[1])]).flatten()


###	Explain all predictions


explainer = shap.KernelExplainer(f, shap.sample(X,30,random_state=42))	#	try using just 30 samples at first for speed


%%capture captured_explanation
explanation = explainer(X)


shap.summary_plot( explanation, plot_type="bar")


shap.plots.beeswarm(explanation,max_display=20)


shap.plots.bar(explanation,max_display=20)


shap.plots.heatmap(explanation,max_display=20)


shap.plots.violin(explanation)


shap.plots.force(explanation)


#	for i in range(0,len(X)):
#		print(i)
#		display(shap.force_plot(explanation[i]))
#	
#	
#	for i in range(0,len(X)):
#		print(i)
#		shap.plots.waterfall(explanation[i])


HTML("<script>const collapsers = document.querySelectorAll('.jp-Cell-outputCollapser'); collapsers.forEach(element => { element.parentElement.style['maxHeight']='100px'; element.addEventListener('click', function(event) { if(element.parentElement.style['maxHeight']==''){ element.parentElement.style['maxHeight']='100px' }else{ element.parentElement.style['maxHeight']='' } }); }); </script>")

