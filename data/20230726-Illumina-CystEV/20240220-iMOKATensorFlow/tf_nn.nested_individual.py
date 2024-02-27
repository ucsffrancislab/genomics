#!/usr/bin/env python3

import sys

i = sys.argv[1]
kmer_matrix_file = sys.argv[2]
train_ids_file = sys.argv[3]
test_ids_file = sys.argv[4]
out_dir = sys.argv[5]
kmers_file = sys.argv[6]

print("kmer_matrix_file : " + kmer_matrix_file )
print("train_ids_file : " + train_ids_file )
print("test_ids_file : " + test_ids_file )
print("out_dir : " + out_dir )
print("kmers_file : " + kmers_file )

#import gc
#gc.enable()

#d=dir()

import psutil
psutil.virtual_memory()

import numpy as np
import pandas as pd

dataset = pd.read_csv(kmer_matrix_file ,sep="\t",header=[0,1],index_col=[0]).transpose()

#dataset=dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]

print("len(dataset.columns) : "+str(len(dataset.columns)))
print(dataset.head())

# select specific
if kmers_file:
	print("Selecting the top 90% of kmers from the last round")
	#	kmer - score
	#kmers_file=out_dir+"feature_importances."+str(i)+".tsv"
	kmers = pd.read_csv(kmers_file,sep="\t",header=[0],index_col=[0])
	kmers = kmers.sort_values(kmers.columns[0])
	print(kmers.head())
	#print("Drop the bottom 10%")
	ten_percent=int(0.1*len(kmers))
	#dataset=pd.DataFrame(dataset,columns=kmers.iloc[ten_percent:].index.to_numpy())
	dataset=dataset.loc[:,kmers.iloc[ten_percent:].index.to_list()]
	del kmers





#	should also merge both of these scripts so all of the code is together
#	but call with different options (kinda like my array_wrapper scripts)




print("len(dataset.columns) : "+str(len(dataset.columns)))
print(dataset.head())


x = dataset.reset_index().set_index("level_0").drop(columns=["group"])
print("x.head()")
print(x.head())

y = dataset.reset_index().set_index("level_0")["group"]
print("y.head()")
print(y.head())

#y = y.replace(["IDH-WT","IDH-MT"],[0,1])
y = y.replace(["LoNo","HiAd"],[0,1])

print("y.head()")
print(y.head())


del dataset

train_ids=pd.read_csv(train_ids_file,sep="\t",header=None)[0].to_numpy()
test_ids=pd.read_csv(test_ids_file,sep="\t",header=None)[0].to_numpy()

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


# Getting % usage of virtual_memory ( 3rd field)
print("RAM memory % used:", psutil.virtual_memory()[2])
# Getting usage of virtual_memory in GB ( 4th field)
print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
psutil.virtual_memory()



import tensorflow as tf

model = tf.keras.models.Sequential()

print("1 layer of 512")

model.add(tf.keras.layers.Dense(512, activation="sigmoid"))
model.add(tf.keras.layers.Dense(1, activation="sigmoid"))

print("Compile")
model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])

print("Fit")
fit=model.fit(x_train, y_train, batch_size=64, epochs=20)




#accuracies.append(fit.history["accuracy"][-1])




print("Evaluate")
model.evaluate(x_test, y_test)

out=y_test.to_frame()
out[i]=model.predict(x_test).flatten()
out.to_csv(out_dir+"predictions."+str(i)+".tsv",index_label="sample",sep="\t")


df = pd.DataFrame({"kmer":x_train.columns, i:np.sum(np.abs(model.get_weights()[0]), axis=1)})
df.set_index("kmer").to_csv( out_dir+"feature_importances."+str(i)+".tsv",index_label="kmer",sep="\t")


#	WARNING:tensorflow:5 out of the last 5 calls to <function Model.make_test_function.<locals>.test_function at 0x7efd67125280> triggered 
#		tf.function retracing. Tracing is expensive and the excessive number of tracings could be due to (1) creating @tf.function repeatedly 
#		in a loop, (2) passing tensors with different shapes, (3) passing Python objects instead of tensors. For (1), please define your 
#		@tf.function outside of the loop. For (2), @tf.function has reduce_retracing=True option that can avoid unnecessary retracing. 
#		For (3), please refer to https://www.tensorflow.org/guide/function#controlling_retracing and 
#		https://www.tensorflow.org/api_docs/python/tf/function for  more details.



#print("Accuracies")
#print(accuracies)

#pd.concat(feature_importances, axis=1, sort=True).to_csv("/francislab/data1/working/20220610-EV/20240208-TensorFlow/feature_importances.test.csv",index_label=["kmer"])



#	c4-n37 - always seems to run out of memory?
#	c4-n38 - has a GPU but not big enough so crashes


