#!/usr/bin/env python3
#	---
#	title: "SHAP's Census income classification with Keras Example"
#	author: "JW"
#	date: "2025-03-12"
#	output: html_document
#	---

from keras.layers import (
    Dense,
    Dropout,
    Flatten,
    Input,
    concatenate,
)
from keras.layers import Embedding
from keras.models import Model
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
import numpy as np
import shap

# print the JS visualization code to the notebook
shap.initjs()


## Load dataset

X, y = shap.datasets.adult()
X.head()

y[:9]

# These are used in the SHAP plots

X_display, y_display = shap.datasets.adult(display=True)
X_display.head()

y_display[:9]

X.dtypes

X.dtypes.index

dtypes = list(zip(X.dtypes.index, map(str, X.dtypes)))
dtypes

X.head()

# normalize data (this is important for model convergence)

dtypes = list(zip(X.dtypes.index, map(str, X.dtypes)))
for k, dtype in dtypes:
    if dtype == "float32":
        X[k] -= X[k].mean()
        X[k] /= X[k].std()

X.head()

X.shape

X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.2, random_state=7)

X_train.iloc[:5, :]

y_train[:5]


## Train Keras model

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

layer1 = Dropout(0.5)(Dense(100, activation="relu")(encoded_els))
layer1

out = Dense(1)(layer1)
out

#	This is a "functional" model. Not sure if this level is complexity is truely needed.

# train model
regression = Model(inputs=input_els, outputs=[out])

regression.summary()

regression.compile(optimizer="adam", loss="binary_crossentropy", metrics=['accuracy'])

regression.summary()

#	>>> X_train
#	        Age  Workclass  Education-Num  Marital Status  Occupation  ...  Sex  Capital Gain  Capital Loss  Hours per week  Country
#	12011  51.0          4           10.0               0           6  ...    0           0.0           0.0            40.0       21
#	23599  51.0          1           14.0               6          12  ...    1           0.0           0.0            50.0        8
#	23603  21.0          4           11.0               4           3  ...    1           0.0           0.0            40.0       39
#	6163   25.0          4           10.0               4          12  ...    1           0.0           0.0            24.0       39
#	14883  48.0          4           13.0               0           1  ...    1           0.0           0.0            38.0       39
#	...     ...        ...            ...             ...         ...  ...  ...           ...           ...             ...      ...
#	5699   23.0          4            9.0               4          12  ...    1           0.0           0.0            40.0       39
#	10742  37.0          4            9.0               2           7  ...    1           0.0           0.0            40.0       39
#	16921  27.0          6            5.0               2           3  ...    1           0.0           0.0            40.0       39
#	25796  46.0          4           16.0               2          10  ...    1           0.0        2415.0            55.0       39
#	28847  55.0          4           10.0               0          13  ...    0           0.0           0.0            40.0       39
#	[26048 rows x 12 columns]
#	
#	>>> [X_train[k].values for k, t in dtypes]
#	[array([51., 51., 21., ..., 27., 46., 55.], dtype=float32), array([4, 1, 4, ..., 6, 4, 4], dtype=int8), array([10., 14., 11., ...,  5., 16., 10.], dtype=float32), array([0, 6, 4, ..., 2, 2, 0], dtype=int8), array([ 6, 12,  3, ...,  3, 10, 13], dtype=int8), array([0, 1, 3, ..., 4, 4, 0]), array([4, 4, 2, ..., 4, 4, 4], dtype=int8), array([0, 1, 1, ..., 1, 1, 0], dtype=int8), array([0., 0., 0., ..., 0., 0., 0.], dtype=float32), array([   0.,    0.,    0., ...,    0., 2415.,    0.], dtype=float32), array([40., 50., 40., ..., 40., 55., 40.], dtype=float32), array([21,  8, 39, ..., 39, 39, 39], dtype=int8)]
#	I'm guessing that have

regression.fit(
    [X_train[k].values for k, t in dtypes],
    y_train,
    epochs=50,
    batch_size=512,
    shuffle=True,
    validation_data=([X_valid[k].values for k, t in dtypes], y_valid),
)

import keras
#keras.utils.plot_model(regression, to_file='census.png', show_shapes=True)
keras.utils.plot_model(regression, show_shapes=True)

regression.summary()

X.iloc[1:9,:]

X.head()

#regression.predict(X.head())
#regression.predict(X.iloc[1:9,:])
#y[1:9]
#X[:,1]
#np.set_printoptions(threshold=sys.maxsize)
#	[False  True False ... False False False]
#print(y_valid)
#print((regression.predict([X_valid[k].values for k, t in dtypes]) > 0.5).flatten())
#print(accuracy_score(y_valid, (regression.predict([X_valid[k].values for k, t in dtypes]) > 0.5).flatten()))


print("Y train",y_train)
print("Predicted y train",(regression.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten())
print("Train accuracy score",accuracy_score(y_train, (regression.predict([X_train[k].values for k, t in dtypes]) > 0.5).flatten()))

print("Y valid",y_valid)
print("Predicted y valid",(regression.predict([X_valid[k].values for k, t in dtypes]) > 0.5).flatten())
print("Test accuracy score",accuracy_score(y_valid, (regression.predict([X_valid[k].values for k, t in dtypes]) > 0.5).flatten()))





## Explain predictions

#Here we take the Keras model trained above and explain why it makes different predictions for different individuals. SHAP expects model functions to take a 2D numpy array as input, so we define a wrapper function around the original Keras predict function.

def f(X):
    return regression.predict([X[:, i] for i in range(X.shape[1])]).flatten()


#print(X.iloc[:50, :])
#print(type(X.iloc[:50, :]))
#quit()

### Explain a single prediction

#Here we use a selection of 50 samples from the dataset to represent "typical" feature values, and then use 500 perterbation samples to estimate the SHAP values for a given prediction. Note that this requires 500 * 50 evaluations of the model.

explainer = shap.KernelExplainer(f, X.iloc[:50, :])
explainer

shap_values = explainer.shap_values(X.iloc[299, :], nsamples=500)
shap_values

shap.force_plot(explainer.expected_value, shap_values, X_display.iloc[299, :])


### Explain many predictions

#Here we repeat the above explanation process for 50 individuals. Since we are using a sampling based approximation each explanation can take a couple seconds depending on your machine setup.

shap_values50 = explainer.shap_values(X.iloc[280:330, :], nsamples=500)
shap_values50

shap.force_plot(explainer.expected_value, shap_values50, X_display.iloc[280:330, :])


