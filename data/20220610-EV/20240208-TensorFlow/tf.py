#!/usr/bin/env python3

import sys
k = sys.argv[1]

print(k)



import pandas as pd

#	All kmers
#dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240201-iMOKA/tf/'+str(k)+'/kmers.rescaled.tsv.gz',sep="\t",header=[0,1],index_col=[0]).transpose()

#	those kmers selected by iMOKA for IDH-MT and IDH-WT classification
#dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240201-iMOKA/out/IDH-'+str(k)+'/aggregated.kmers.matrix',sep="\t",header=[0,1],index_col=[0]).transpose()

#	FAILS as this matrix only contains the training data
#dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240201-iMOKA/zscores_filtered/'+str(k)+'/aggregated.kmers.matrix',sep="\t",header=[0,1],index_col=[0]).transpose()


#	Note that the kmer count for a particular kmer isn't always the same?


#	All kmers
dataset = pd.read_csv('/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf/'+str(k)+'/kmers.rescaled.tsv.gz',sep="\t",header=[0,1],index_col=[0]).transpose()

#	select specific
#kmers = pd.read_csv('/francislab/data1/working/20220610-EV/20240201-iMOKA/zscores_filtered/'+str(k)+'/aggregated.kmers.matrix',sep="\t",header=[0,1],index_col=[0]).transpose()

#dataset=dataset[kmers.columns.to_numpy()]




print(dataset.size)
print(dataset.head())

x = dataset.reset_index().set_index("level_0").drop(columns=['group'])
print(x.head())

y = dataset.reset_index().set_index("level_0")['group']
print(y.head())

y = y.replace(['IDH-WT','IDH-MT','control'],[0,1,2])
print(y.head())

#	for some reason, y needs to be a number




train_ids=pd.read_csv("train_ids.tsv",sep="\t",header=None)[0].to_numpy()

test_ids=pd.read_csv("test_ids.tsv",sep="\t",header=None)[0].to_numpy()

x_train=x.loc[train_ids]
x_test=x.loc[test_ids]
y_train=y.loc[train_ids]
y_test=y.loc[test_ids]


#from sklearn.model_selection import train_test_split
#x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2)

print("X Train")
print(x_train.head())

print("Y Train")
print(y_train.head())

print("X Test")
print(x_test.head())

print("Y Test")
print(y_test.head())











import tensorflow as tf

model = tf.keras.models.Sequential()

#    ValueError: Input 0 of layer "sequential" is incompatible with the layer: expected shape=(None, 455, 30), found shape=(None, 30)


#model.add(tf.keras.layers.Dense(256, input_shape=x_train.shape, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(256, input_shape=(None, 455, 30), activation='sigmoid'))



#	Is passing shape better?
#	Why does shape from previous demo fail?
#	How many layers? Why?
#	Why 256?
#	Why sigmoid?
#	What are alternatives?
#	Why Dense?
#	What are alternatives?
#	Why is the last layer 1? Why not 2? Why does 1 even work?




#model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(1, activation='sigmoid'))

#model.add(tf.keras.layers.Dense(1024, activation='relu'))
#model.add(tf.keras.layers.Dense(512, activation='relu'))
#model.add(tf.keras.layers.Dense(256, activation='relu'))
#model.add(tf.keras.layers.Dense(128, activation='relu'))

model.add(tf.keras.layers.Dense(2048, activation='relu',
                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
model.add(tf.keras.layers.Dropout(0.5))
model.add(tf.keras.layers.Dense(1024, activation='relu',
                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
model.add(tf.keras.layers.Dropout(0.5))
model.add(tf.keras.layers.Dense(512, activation='relu',
                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
model.add(tf.keras.layers.Dropout(0.5))
#model.add(tf.keras.layers.Dense(256, activation='relu',
#                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
#model.add(tf.keras.layers.Dropout(0.5))
#model.add(tf.keras.layers.Dense(128, activation='relu',
#                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
#model.add(tf.keras.layers.Dropout(0.5))
#model.add(tf.keras.layers.Dense(64, activation='relu',
#                 kernel_regularizer=tf.keras.regularizers.l2(0.001)))
#model.add(tf.keras.layers.Dropout(0.5))
model.add(tf.keras.layers.Dense(3, activation='softmax'))






#model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])



#	Why adam?
#	What are alternatives?

#	Why binary_crossentropy?
#	What are alternatives?

#	What other options exist?






model.fit(x_train, y_train, batch_size=64, epochs=100)

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



#	steps are determined by sample count and batch size (default 32)



#Epoch 1000/1000
#2/2 [==============================] - 1s 383ms/step - loss: 0.0017 - accuracy: 1.0000
#1/1 [==============================] - 0s 199ms/step - loss: 3.7917 - accuracy: 0.5833




model.evaluate(x_test, y_test)



