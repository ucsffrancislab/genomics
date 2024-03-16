#!/usr/bin/env python3


import os
import sys
import psutil
import numpy as np
import pandas as pd

from datetime import datetime

import gc
gc.enable()

#	python3 -m pip install --user --upgrade "tensorflow[and-cuda]" didn't stop the warnings
import tensorflow as tf


#hc merged.tsv 
#CHROM	POS	02-2483-01A-01D-1494	02-2483-10A-01D-1494	02-2485-01A-01D-1494	02-2485-10A-01D-1494	06-0125-01A-01D-1490	06-0125-02A-11D-2280	06-0125-10A-01
#chr1	10028	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10033	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10039	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10051	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10068	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10073	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10085	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
#chr1	10091	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00

print("Reading : ", datetime.now().strftime("%H:%M:%S") , flush=True)
df = pd.read_csv("merged.tsv.gz",sep="\t",header=[0],index_col=[0,1])	#,nrows=100)
print("Done : ", datetime.now().strftime("%H:%M:%S") , flush=True)
df.index=df.index.map('{0[0]}:{0[1]}'.format)
df=df.transpose()
print("Added tumor/normal column",flush=True)
df['tn']=df.index.str[8]
df=df.astype(int)

print(df.shape)
print("Dropping 02 samples",flush=True)
df=df.drop(df[df.index.str[8:10]=="02"].index,axis='index')
print(df.shape)
print("Dropping 11 samples",flush=True)
df=df.drop(df[df.index.str[8:10]=="11"].index,axis='index')
print(df.shape)
print("Dropping positions in less than 20 samples",flush=True)
df=df.loc[:,df.astype(bool).sum(axis='index') > 20]
print(df.shape)


print(df.head(), flush=True)

x = df.drop(columns=["tn"])
print(x.head(), flush=True)

y = df["tn"]
print(y.head(), flush=True)

print("Deleting source dataframe", flush=True)
del df

print("Splitting data into training and testing", flush=True)
from sklearn.model_selection import train_test_split
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2)


model = tf.keras.models.Sequential()

#model.add(tf.keras.layers.Dense(2048, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(1024, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(512, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
model.add(tf.keras.layers.Dense(128, activation='sigmoid'))
model.add(tf.keras.layers.Dense(1, activation='sigmoid'))
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

model.fit(x_train, y_train, epochs=100)	#, batch_size=500)

model.evaluate(x_test, y_test)

out = y.to_frame()
out['prediction'] = model.predict(x).flatten()
print(out.to_string(), flush=True)

