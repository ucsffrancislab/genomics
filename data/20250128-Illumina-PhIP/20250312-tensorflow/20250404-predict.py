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

#batch_size=64	#250
#epochs=250								#	early stopping didn't work so 1000 is too long
#epochs=200
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
plates=[1,2,3]

#Counts.normalized.subtracted.protein.select.t.mins.reorder.csv"]
files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250404/Counts.normalized.subtracted.select3.protein.sum.t.min.123.csv"]
#files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250404/Counts.normalized.subtracted.select4.protein.sum.t.min.1234.csv"]
#files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250404/Counts.normalized.subtracted.select4.protein.sum.t.min.1234.ORF73.csv"]

species=os.getenv('SPECIES','')
print('SPECIES:',species)

proteins=os.getenv('PROTEINS','')
print('PROTEINS:',proteins)

#ids=os.getenv('IDS','')
#print('IDS:',ids)

outfile=out_dir+'/'+re.sub(r'[^a-zA-Z0-9]','_',species+"."+proteins)+'-A:'+activation+'-TS:'+str(test_size)+'-RS:'+str(random_state)+'-LN:'+str(loop_number)
print(outfile)

modelname=re.sub(r'[^a-zA-Z0-9]','_',"model."+species+"."+proteins)
print('MODEL NAME:',modelname)

if( species == '' ):
	species=[]
else:
	species=species.split(',')

if( proteins == '' ):
	proteins=[]
else:
	proteins=proteins.split(',')

#if( ids == '' ):
#	ids=[]
#else:
#	ids=ids.split(',')
#

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
	d = pd.read_csv(file, header=[0,1], low_memory=False)


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
df.iloc[:5,:10]


##	Filter only in given species

if ( len(species)>0 ):
	print(species)
	df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','species']+species)]
df = df.droplevel([1],axis=1)
df.iloc[:5,:10]


##	Filter only in given proteins

if ( len(proteins)>0 ):
	print(proteins)
	#df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','protein']+proteins)]
	df = df.loc[:, df.columns.isin(['subject','type','group','age','sex','protein']+proteins)]
#df = df.droplevel([1],axis=1)
df.iloc[:5,:10]


###	Filter only in given ids
#
#if ( len(ids)>0 ):
#	print(ids)
#	#df = df.loc[:, df.columns.get_level_values(1).isin(['subject','type','group','age','sex','plate']+ids)]
#	df = df.loc[:, df.columns.isin(['subject','type','group','age','sex','plate']+ids)]
##df = df.droplevel([1],axis=1)	#	don't want to drop the last "index"
#df.iloc[:5,:10]




#	subject,type,group,age,sex,plate

##	Filter groups

num_classes = len(groups)
df = df[ df['group'].isin(groups) ]
df.iloc[:5,:10]


#	why int8? Why not just int?
#	int8 later does some sort of Embedding. Not entirely sure what that's gonna do.
#	int is just int64

#df['age'] = df['age'].astype('int')
df = df.drop(columns=['age'])


df['sex'] = le.fit_transform(df['sex']).astype('int')
#df = df.drop(columns=['sex'])


print(df.iloc[:5,:10])

print(df.dtypes)

##	Drop the type column

df = df.drop(columns=['type'])
df.iloc[:5,:10]


##	Filter plates

df['plate'] = df['plate'].astype('int')
df = df[ df['plate'].isin(plates) ]
#print("Drop the plate column?")
#df = df.drop(columns=['plate'])		#	<------------- I think that I should leave plate here, but maybe later
df.iloc[:5,:10]


##	Drop the subject column

df = df.drop(columns=['subject'])
df.iloc[:5,:10]


#	we now have the tile ids, plate, plus age and sex


##	Create X by dropping the group column

X = df.drop(columns=['group'])
print(X.iloc[:5,:10])


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

#max_nodes=min(int(len(x_columns)/2),500)
max_nodes=min(len(x_columns),500)
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
batch_size=int(len(X)/2+0.5)
print("Using batch size",batch_size)

model.fit(
	[X_train[k].values for k, t in dtypes],
	y_train,
	epochs=epochs,
	batch_size=batch_size,
	shuffle=True,
	validation_data=([X_test[k].values for k, t in dtypes], y_test),
	callbacks=[MyThresholdCallback(threshold=0.75)]
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

if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	# print the JS visualization code to the notebook
	display(shap.initjs())


#Here we take the Keras model trained above and explain why it makes different predictions for different individuals. SHAP expects model functions to take a 2D numpy array as input, so we define a wrapper function around the original Keras predict function.

def f(X):
    return model.predict([X[:, i] for i in range(X.shape[1])]).flatten()


###	Explain all predictions


#if running_as_notebook:
#	#explainer = shap.KernelExplainer(f, shap.sample(X,30,random_state=42))	#	try using just 30 samples at first for speed
#	explainer = shap.KernelExplainer(f, X)
if train_score>=0.75 and test_score>=0.75:
	explainer = shap.KernelExplainer(f, X)


#%%capture captured_explanation
#	CANNOT have a comment after a capture line
#	not sure if this is needed when this is in a condition
#	This is a syntax error outside of notebook
#	%%capture must be the first line of the cell in Jupyter in order for it to be recognized correctly.
#	Add apparently, it can be commented out and still work. Or jupytext uncommented it for me.
#if running_as_notebook:
#	explanation = explainer(X)
if train_score>=0.75 and test_score>=0.75:
	explanation = explainer(X)


#	could do something like this to universally shut this up
#	it produces many lines that are ~400,000 chars long filled with ^H backspaces for its progressbar
#import os, sys
#sys.stdout, sys.stderr = open(os.devnull, 'w'), open(os.devnull, 'w')
#explanation = explainer(X)
#sys.stdout, sys.stderr = sys.__stdout__, sys.__stderr__


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	display(explanation.shape)


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	display(explanation[1])


##	Extract shap values and sort by absolute overall impact (values from summary plot)

if train_score>=0.75 and test_score>=0.75:
	df = pd.DataFrame(index=X.columns,
			data={'value':[round(num, 3) for num in np.abs(explanation.values).mean(axis=0)]}
			).sort_values(by='value', ascending=False, key=abs)
	if running_as_notebook:
		display(df)
	else:
		print(df)
		df.to_csv(outfile, sep=',')


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.summary_plot( explanation, plot_type="bar")


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.plots.beeswarm(explanation,max_display=20)


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.plots.bar(explanation,max_display=20)


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.plots.heatmap(explanation,max_display=20)


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.plots.violin(explanation)


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	shap.plots.force(explanation)


#	for i in range(0,len(X)):
#		print(i)
#		display(shap.force_plot(explanation[i]))
#	
#	
#	for i in range(0,len(X)):
#		print(i)
#		shap.plots.waterfall(explanation[i])


if train_score>=0.75 and test_score>=0.75 and running_as_notebook:
	display(HTML("<script>const collapsers = document.querySelectorAll('.jp-Cell-outputCollapser'); collapsers.forEach(element => { element.parentElement.style['maxHeight']='100px'; element.addEventListener('click', function(event) { if(element.parentElement.style['maxHeight']==''){ element.parentElement.style['maxHeight']='100px' }else{ element.parentElement.style['maxHeight']='' } }); }); </script>"))

