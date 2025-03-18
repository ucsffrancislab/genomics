#!/usr/bin/env python3
#
##	Tensorflow Prediction of Case/Control with HHV8
#

n=128
activation='sigmoid'
batch_size=250
epochs=100
test_size=0.25
random_state=15
early_stop=0
groups=['case','control']
plates=[1,2,3]

species=["Human herpesvirus 8"]
proteins=[]	#	["ORF 73","Orf73","ORF73","Protein ORF73"]
files=["/francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv"]


import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from keras import utils
#from tensorflow.keras import callbacks
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
from IPython.display import display, HTML



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
print(X.iloc[:5,:7])


X.shape


##	Create y by extracting the group column

y = df['group']
#y.iloc[60:66]
y[60:66]


##	Encoding the groups to integers

#	apparently y NEEDS to be an integer
le = LabelEncoder()
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

input_els

len(input_els)

encoded_els

len(encoded_els)

encoded_els = concatenate(encoded_els)
encoded_els

layer1 = Dropout(0.1)(Dense(int(n/2), activation=activation)(Dropout(0.1)(Dense(n, activation=activation)(encoded_els))))
layer1

out = Dense(1)(layer1)
out

model = Model(inputs=input_els, outputs=[out])

##	Compiling

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])


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
)


utils.plot_model(model, to_file='HHV8.png', show_shapes=True)


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

### Explain a single prediction

#Here we use a selection of 50 samples from the dataset to represent "typical" feature values, and then use 500 perterbation samples to estimate the SHAP values for a given prediction. Note that this requires 500 * 50 evaluations of the model.


explainer = shap.KernelExplainer(f, X.iloc[:50, :])
explainer

#shap_values = explainer.shap_values(X.iloc[299, :], nsamples=500)
shap_values = explainer.shap_values(X.iloc[99, :], nsamples=500)

shap_values

#shap.force_plot(explainer.expected_value, shap_values, X_display.iloc[299, :])
shap.force_plot(explainer.expected_value, shap_values, X.iloc[99, :])


### Explain many predictions

#Here we repeat the above explanation process for 50 individuals. Since we are using a sampling based approximation each explanation can take a couple seconds depending on your machine setup.

#shap_values50 = explainer.shap_values(X.iloc[280:330, :], nsamples=500)
shap_values50 = explainer.shap_values(X.iloc[40:90, :], nsamples=500)

shap_values50

#shap.force_plot(explainer.expected_value, shap_values50, X_display.iloc[40:90, :])
shap.force_plot(explainer.expected_value, shap_values50, X.iloc[40:90, :])




###	Explain all predictions


explainer = shap.KernelExplainer(f, shap.sample(X,30,random_state=42))	#	try using just 30 samples at first for speed


explanation = explainer(X)


shap.summary_plot( explanation, plot_type="bar")


shap.plots.beeswarm(explanation,max_display=20)


shap.plots.bar(explanation,max_display=20)


shap.plots.heatmap(explanation,max_display=20)


shap.plots.violin(explanation)


shap.plots.force(explanation)


for i in range(0,len(X)):
	print(i)
	display(shap.force_plot(explanation[i]))


for i in range(0,len(X)):
	print(i)
	shap.plots.waterfall(explanation[i])


