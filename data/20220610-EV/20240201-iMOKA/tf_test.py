#!/usr/bin/env python3

import sys
k = sys.argv[1]

print(k)

#	quit()


import pandas as pd

#dataset = pd.read_csv('cancer.csv')
#x = dataset.drop(columns=["diagnosis(1=m, 0=b)"])
#y = dataset["diagnosis(1=m, 0=b)"]


dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240201-iMOKA/tf_test/'+str(k)+'/kmers.rescaled.tsv.gz',sep="\t",header=[0,1],index_col=[0]).transpose()
print(dataset.head())

x = dataset.reset_index().set_index("level_0").drop(columns=['group'])
print(x.head())



y = dataset.reset_index().set_index("level_0")['group']
print(y.head())


#	for some reason, it needs to be a number
y = y.replace(['IDH-WT','IDH-MT'],[0,1])

print(y.head())










from sklearn.model_selection import train_test_split

#x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.4)
#x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.5)

print(x_train.head())
print(y_train.head())


import tensorflow as tf

model = tf.keras.models.Sequential()

#    ValueError: Input 0 of layer "sequential" is incompatible with the layer: expected shape=(None, 455, 30), found shape=(None, 30)


#model.add(tf.keras.layers.Dense(256, input_shape=x_train.shape, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(256, input_shape=(None, 455, 30), activation='sigmoid'))

model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
model.add(tf.keras.layers.Dense(1, activation='sigmoid'))

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])


model.fit(x_train, y_train, epochs=100)

#	the cancer.csv run 
#	showed 15/15
#15/15 [==============================] - 0s 3ms/step - loss: 0.0610 - accuracy: 0.9714
#Epoch 994/1000
#15/15 [==============================] - 0s 3ms/step - loss: 0.0931 - accuracy: 0.9670
#Epoch 995/1000
#15/15 [==============================] - 0s 3ms/step - loss: 0.0708 - accuracy: 0.9670

#	but this shows 2/2
#Epoch 998/1000
#2/2 [==============================] - 1s 397ms/step - loss: 0.0017 - accuracy: 1.0000
#Epoch 999/1000
#2/2 [==============================] - 1s 389ms/step - loss: 0.0017 - accuracy: 1.0000

#	not sure what 2 or 15 actually is



#Epoch 1000/1000
#2/2 [==============================] - 1s 383ms/step - loss: 0.0017 - accuracy: 1.0000
#1/1 [==============================] - 0s 199ms/step - loss: 3.7917 - accuracy: 0.5833




model.evaluate(x_test, y_test)



