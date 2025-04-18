#!/usr/bin/env python3

import sys

i=int(sys.argv[1])
z=int(sys.argv[2])
n=int(sys.argv[3])


import pandas as pd
import numpy as np
from tensorflow import keras
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import Dense, Dropout
from sklearn.metrics import accuracy_score, confusion_matrix



d1 = pd.read_csv(
	'/francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.menpem.multiz/Zscores.minimums.filtered.csv',
	index_col=0,header=[0,1])
#d1.columns=d1.columns.droplevel(1)
#d1 = d1[d1['z']=='glioma serum']
#d1 = d1.drop(columns=["z"])
#d1 = d1.rename(columns={'id':'group'})

print("D1 shape")
print(d1.shape)
#	(84, 106663)

d2 = pd.read_csv(
	'/francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.multiz/Zscores.minimums.filtered.csv',
	index_col=0,header=[0,1])
#d2.columns=d2.columns.droplevel(1)
#d2 = d2[d2['z']=='glioma serum']
#d2 = d2.drop(columns=["z"])
#d2 = d2.rename(columns={'id':'group'})

print("D2 shape")
print(d2.shape)
#	(84, 106663)

df = pd.concat([d1,d2])
df.columns=df.columns.droplevel(1)

df = df[df['z']=='pemphigus serum']


#['Endemic Control' 'Non Endemic Control' 'PF Patient']

#df = df[ df['id'].isin(['Endemic Control','Non Endemic Control']) ]
df = df[ df['id'].isin(['Endemic Control','PF Patient']) ]
num_classes = 2


df = df.drop(columns=["z"])
df = df.rename(columns={'id':'group'})

print("Merged shape")
print(df.shape)

df.fillna(0, inplace=True)
df.replace( np.inf,  9999999, inplace=True)
df.replace(-np.inf, -9999999, inplace=True)



#callback = keras.callbacks.EarlyStopping(monitor='loss', patience=3)

callback = keras.callbacks.EarlyStopping(
    monitor='accuracy', 
    min_delta=0.001,
    patience=3,
    mode='auto',
    verbose=2,
    baseline=None
)


#for i in [1,2,3]:

#	for z in [-1,0,1,2,3,5,10]:
	 
x = df.drop(columns=["group"])
#print(x.head())
	
print("Unfiltered shape")
print(x.shape)





#print("Filter x any >",z)
#x = x.loc[:, (x > z).any()]


#df.replace( np.inf,  9999999, inplace=True)
#df.loc[df['A'] > 5, 'A'] = 5
#df = df.applymap(lambda x: 0 if x > 5 else x)
#Very simply : df[df > 9] = 11
#df1['A'] = df1['A'].apply(lambda x: [y if y <= 9 else 11 for y in x])
#df.where(df <= 9, 11, inplace=True)

x[x < z] = 0
x[x >= z] = 1







print("Filtered shape")
print(x.shape)






y = df["group"]
#print(y.head())

#print("Scaling the values")
#sc = StandardScaler()
#x = sc.fit_transform(x)
##print(x[:2])

print("Encoding the groups to integers")
#	apparently y NEEDS to be an integer
le = LabelEncoder()
y = le.fit_transform(y)
#print(y[:5])

print(le.classes_)

y = keras.utils.to_categorical(y, num_classes=num_classes)
#print(y[:5])

print("Splitting into training and testing")

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.20, shuffle=True)
actual = np.argmax(y_test, axis=-1)

# 32768 - crashes on 120GB
# 32768 - crashes on 60GB
# 16384 - crashes on 120GB sometimes
# 16384 - crashes on 60GB sometimes
	
#for n in [32,64,128,256,512,1024,2048,4096,8192,16384,32768]:
#for n in [32,64,128,256,512,1024,2048,4096,8192,16384]:
#for n in [32,64,128,256,512,1024,2048,4096,8192]:
	
print("Creating new model")

model = Sequential()
#model.add(Dense(units=256, activation='sigmoid'))
#model.add(Dense(units=256, activation='relu'))
#model.add(Dropout(0.1))

#	20,000 + 10,000 takes about 40GB of memory
	
print("Adding layer with",n,"units")
model.add(Dense(units=n, activation='relu'))
model.add(Dropout(0.1))
	
print("Adding layer with",int(n/2),"units")
model.add(Dense(units=int(n/2), activation='relu'))
model.add(Dropout(0.1))
	
model.add(Dense(units=num_classes, activation='softmax'))

print("Compiling")
#model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['accuracy'])

print("Fitting")
model.fit(x_train, y_train, epochs=50, callbacks=[callback], verbose=2, batch_size=100)

prediction = model.predict(x_test)

prediction = np.argmax(prediction, axis=-1)
print("Prediction . ",prediction)

print("Actual ..... ",actual)

ac_score = accuracy_score(actual, prediction)
print("Accuracy",ac_score," loop:",i," z:",z," nodes:",n)


print("DONE")

#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict_pemphigus.py



