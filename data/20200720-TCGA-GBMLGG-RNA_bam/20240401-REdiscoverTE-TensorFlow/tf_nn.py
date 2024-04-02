#!/usr/bin/env python3


import os
import sys
import psutil
import numpy as np
import pandas as pd

from datetime import datetime

import gc
gc.enable()



# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')


parser.add_argument('-f', '--features_file', nargs=1, type=str, default=['Select.txt'],
	help='file containing list of columns to use %(prog)s (default: %(default)s)')

parser.add_argument('-o', '--outcome_column', nargs=1, type=str, default=['Survival_months'],
	help='predict this output column %(prog)s (default: %(default)s)')


#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')

#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')


# read arguments from the command line
args = parser.parse_args()





features_file = args.features_file[0]
outcome_column = args.outcome_column[0]








#	python3 -m pip install --user --upgrade "tensorflow[and-cuda]" didn't stop the warnings
import tensorflow as tf


with open(features_file) as f:
	features = f.read().splitlines()
print(features,flush=True)


def read_a_csv(filename):
	print("Reading : ", filename," : ", datetime.now().strftime("%H:%M:%S") , flush=True)
	df = pd.read_csv(filename,sep="\t",header=[0],index_col=[0])	#,nrows=100)
	print("Done : ", datetime.now().strftime("%H:%M:%S") , flush=True)

	df.sex.replace(to_replace=dict(female=0, male=1), inplace=True)
	#df.MGMT.replace(to_replace=dict(Unmethylated=0, Methylated=1), inplace=True)
	return df


train_data = read_a_csv("gbm_train.tsv")
train_data = train_data[features+[outcome_column]]
train_outcome = train_data.pop(outcome_column)
print(train_data.head())

test_data = read_a_csv("gbm_test.tsv")
test_data = test_data[features+[outcome_column]]
test_outcome = test_data.pop(outcome_column)

print(test_data.head())




model = tf.keras.models.Sequential()

#model.add(tf.keras.layers.Dense(256, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(128, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(1))	#, activation='sigmoid'))
#model.add(tf.keras.layers.Dense(units=1))
#model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])


normalizer = tf.keras.layers.Normalization()	#input_shape=[1,], axis=None)
normalizer.adapt(np.array(train_data))
model.add(normalizer)

#	too many neurons causes and issue with 2 layers. don't know exactly, but this works
model.add(tf.keras.layers.Dense(64, activation='relu'))
model.add(tf.keras.layers.Dense(64, activation='relu'))

model.add(tf.keras.layers.Dense(1))

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.1),
    loss='mean_absolute_error')

model.fit(train_data, train_outcome, epochs=100)	#, batch_size=500)

#model.evaluate(test_data, test_outcome)

model.predict(test_data).flatten()

out = test_outcome.to_frame()
out['prediction'] = model.predict(test_data).flatten()
print(out.to_string(), flush=True)

