#!/usr/bin/env python3

import sys
k = sys.argv[1]

print(k)


import numpy as np
import pandas as pd

dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf/'+str(k)+'/kmers.rescaled.tsv.gz',sep="\t",header=[0,1],index_col=[0]).transpose()

dataset=dataset[dataset.index.get_level_values("group").isin(['IDH-WT', 'IDH-MT'])]

print(dataset.size)
print(dataset.head())

x = dataset.reset_index().set_index("level_0").drop(columns=['group'])
print(x.head())

y = dataset.reset_index().set_index("level_0")['group']
print(y.head())

y = y.replace(['IDH-WT','IDH-MT'],[0,1])

print(y.head())


train_ids=pd.read_csv("train_ids.tsv",sep="\t",header=None)[0].to_numpy()

test_ids=pd.read_csv("test_ids.tsv",sep="\t",header=None)[0].to_numpy()



#train_ids=["SFHH005ae","SFHH005n","SFHH005j","SFHH005ad","SFHH005p","SFHH005l","SFHH005f","SFHH005ab","SFHH005ah","SFHH005x","SFHH005al","SFHH005ac","SFHH005b","SFHH005s","SFHH005ao","SFHH005ap","SFHH005c","SFHH005r","SFHH005af","SFHH005i","SFHH005z","SFHH005q","SFHH005w","SFHH005d","SFHH005u","SFHH005ai","SFHH005m","SFHH005a","SFHH005o","SFHH005an","SFHH005am","SFHH005h","SFHH011BJ","SFHH011BA","SFHH011X","SFHH011BG","SFHH011AW","SFHH011G","SFHH011AH","SFHH011AO","SFHH011AR","SFHH011BQ"]

#test_ids=["SFHH005y","SFHH005aq","SFHH005t","SFHH005g","SFHH005aj","SFHH005aa","SFHH005ak","SFHH005e","SFHH011BC","SFHH011K","SFHH011Z","SFHH011P","SFHH011J","SFHH011AF","SFHH011BK","SFHH011AX"]



#	Fails if not there
#x_train=x.loc[train_ids]
#x_test=x.loc[test_ids]
#y_train=y.loc[train_ids]
#y_test=y.loc[test_ids]


x_train=x.loc[x.index.isin(train_ids)]
x_test=x.loc[x.index.isin(test_ids)]
y_train=y.loc[y.index.isin(train_ids)]
y_test=y.loc[y.index.isin(test_ids)]



print("X Train")
print(x_train)

print("Y Train")
print(y_train)

print("X Test")
print(x_test)

print("Y Test")
print(y_test)











import tensorflow as tf

model = tf.keras.models.Sequential()

#print("1 layer of 512. 1 layer of 256")
print("1 layer of 128")

#	More neurons made the weight more even.

#model.add(tf.keras.layers.Dense(512, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
model.add(tf.keras.layers.Dense(128, activation='sigmoid'))
model.add(tf.keras.layers.Dense(1, activation='sigmoid'))

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

model.fit(x_train, y_train, batch_size=64, epochs=100)

model.evaluate(x_test, y_test)





#	https://www.linkedin.com/pulse/feature-importance-using-neural-network-python-made-simple-sen/

#	gradient based

#import tensorflow as tf
#import numpy as np

#model = tf.keras.models.load_model('your_model.h5') # Load your trained model
#X = np.load('your_input_data.npy') # Load your input data

# Compute gradients of the output with respect to the input
#input_tensor = tf.convert_to_tensor(X)
input_tensor = tf.convert_to_tensor(x_test)
with tf.GradientTape() as tape:
	tape.watch(input_tensor)
	output = model(input_tensor)

gradients = tape.gradient(output, input_tensor)

# Calculate feature importance as the absolute mean of the gradients
#feature_importance = np.mean(np.abs(gradients.numpy()), axis=0)

df = pd.DataFrame({'kmers':dataset.columns, 'feature_importance':np.mean(np.abs(gradients.numpy()), axis=0) })
print(df.sort_values('feature_importance'))



#	weight based

#import tensorflow as tf

#model = tf.keras.models.load_model('your_model.h5') # Load your trained model

# Get the weights from the model's layers
weights = model.get_weights()

# Calculate feature importance as the sum of absolute weights for each feature
feature_importance = np.sum(np.abs(weights[0]), axis=1)

df = pd.DataFrame({'kmers':dataset.columns, 'feature_importance':np.sum(np.abs(model.get_weights()[0]), axis=1)})
print(df.sort_values('feature_importance'))


#print(feature_importance.shape)
#print(feature_importance)
#print(max(feature_importance))
#print(np.median(feature_importance))
#print(min(feature_importance))







def feature_importance(model, x_test, y_test):
	baseline = model.evaluate(x_test, y_test)[1]
	importance = []
	for i in range(x_test.shape[1]):
		print(i)
		x_permuted = x_test.copy()
		#print(x_permuted.head())
		#np.random.shuffle(x_permuted[:, i])
		#Traceback (most recent call last):
		#  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/pandas/core/indexes/base.py", line 3802, in get_loc
		#    return self._engine.get_loc(casted_key)
		#  File "pandas/_libs/index.pyx", line 138, in pandas._libs.index.IndexEngine.get_loc
		#  File "pandas/_libs/index.pyx", line 144, in pandas._libs.index.IndexEngine.get_loc
		#TypeError: '(slice(None, None, None), 0)' is an invalid key
		#
		#During handling of the above exception, another exception occurred:
		#
		#Traceback (most recent call last):
		#  File "/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf_nn.test.py", line 163, in <module>
		#    importance = feature_importance(model, x_test)
		#  File "/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf_nn.test.py", line 158, in feature_importance
		#    np.random.shuffle(x_permuted[:, i])
		#  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/pandas/core/frame.py", line 3807, in __getitem__
		#    indexer = self.columns.get_loc(key)
		#  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/pandas/core/indexes/base.py", line 3809, in get_loc
		#    self._check_indexing_error(key)
		#  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/pandas/core/indexes/base.py", line 5925, in _check_indexing_error
		#    raise InvalidIndexError(key)
		#pandas.errors.InvalidIndexError: (slice(None, None, None), 0)
		#np.random.shuffle(x_permuted.iloc[:, i])
		#	<stdin>:6: UserWarning: you are shuffling a 'Series' object which is not a subclass of 'Sequence'; 
		#	`shuffle` is not guaranteed to behave correctly. 
		#	E.g., non-numpy array/tensor objects with view semantics may contain duplicates after shuffling.
		#	I think it does work fine, however, the following works and stops the warning.
		x_permuted.iloc[:,0]=np.random.permutation(x_permuted.iloc[:,0])
		score = model.evaluate(x_permuted, y_test)[1]
		importance.append(baseline - score)
	return importance

importance = feature_importance(model, x_test, y_test)
print(importance)



