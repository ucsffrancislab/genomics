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


#parser.add_argument('-f', '--features_file', nargs=1, type=str, default=['Select.txt'],

parser.add_argument('-f', '--features_file', nargs=1, type=str, default=[''],
	help='file containing list of columns to use %(prog)s (default: %(default)s)')

parser.add_argument('-o', '--outcome_column', nargs=1, type=str, default=['Survival_months'],
	help='predict this output column %(prog)s (default: %(default)s)')

parser.add_argument('-n', '--neuron_counts', nargs=1, type=str, default=['512,256'],
	help='comma separated list of neuron counts to %(prog)s (default: %(default)s)')

parser.add_argument('-a', '--attributes', nargs=1, type=str, default=['Age,sex'],
	help='comma separated list of other attributes to include %(prog)s (default: %(default)s)')


parser.add_argument('--final_layer', nargs=1, choices=['basic', 'continuous', 'category'], default=['basic'],
	help='choose how to work that final layer %(prog)s (default: %(default)s)')

parser.add_argument('--category_count', nargs=1, type=int, default=[5],
	help='number of final categories in predict column %(prog)s (default: %(default)s)')


#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz', help='output csv filename to %(prog)s (default: %(default)s)')

#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t', help='the separator to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true', help='convert values to ints to %(prog)s (default: %(default)s)')

#parser.add_argument('--seqint', action='store_true', help='items are ints so sort like it : %(prog)s (default: %(default)s)')


# read arguments from the command line
args = parser.parse_args()





features_file = args.features_file[0]
outcome_column = args.outcome_column[0]
neuron_counts = args.neuron_counts[0]
final_layer = args.final_layer[0]
category_count = args.category_count[0]


#attributes=['Age','sex','CDKN2A_re','EGFR_re',outcome_column]
#attributes=['Age','sex',outcome_column]
#for count in [int(ele) for ele in neuron_counts.split(',')]:

attributes = args.attributes[0].split(',')+[outcome_column]






#	python3 -m pip install --user --upgrade "tensorflow[and-cuda]" didn't stop the warnings
import tensorflow as tf

if features_file != "":
	with open(features_file) as f:
		features = f.read().splitlines()
else:
	features = []
print(features,flush=True)


def read_a_csv(filename):
	print("Reading : ", filename," : ", datetime.now().strftime("%H:%M:%S") , flush=True)
	df = pd.read_csv(filename,sep="\t",header=[0],index_col=[0])	#,nrows=100)
	print("Done : ", datetime.now().strftime("%H:%M:%S") , flush=True)

	if 'sex' in df.columns:
		df['sex'].replace(to_replace={'female':0, 'male':1}, inplace=True)
	if 'MGMT' in df.columns:
		df['MGMT'].replace(to_replace={'Unmethylated':0, 'Methylated':1}, inplace=True)
	if 'EGFR_re' in df.columns:
		df['EGFR_re'].replace(to_replace={"Wildtype":0, "Amplified":1}, inplace=True)
	if 'CDKN2A_re' in df.columns:
		df['CDKN2A_re'].replace(to_replace={"Wildtype":0, "Amplified":1, "Deleted":2}, inplace=True)

	return df


train_data = read_a_csv("gbm_train.tsv")
train_data = train_data[features+attributes]
train_outcome = train_data.pop(outcome_column)
print(train_data.head())
print(train_outcome.head())

test_data = read_a_csv("gbm_test.tsv")
test_data = test_data[features+attributes]
test_outcome = test_data.pop(outcome_column)
print(test_data.head())
print(test_outcome.head())


#	https://www.tensorflow.org/tutorials/keras/regression

model = tf.keras.models.Sequential()

#	Everything needs to be a number
#	ValueError: Failed to convert a NumPy array to a Tensor (Unsupported object type float).
#	Sadly, it doesn't say which field failed

normalizer = tf.keras.layers.Normalization()	#input_shape=[1,], axis=None)
normalizer.adapt(np.array(train_data))
model.add(normalizer)
#	Not sure how much impact the normalizing layer has on anything.
#	I've run with and without with very similar output.


#	too many neurons causes and issue with 2 layers. don't know exactly, but this works
#	bumping one up to 128 causes almost all predictions to be flat (7.959686)

for count in [int(ele) for ele in neuron_counts.split(',')]:
	model.add(tf.keras.layers.Dense(count, activation='relu'))

#	for just select 35 REs 2x 64 neuron layers worked decently


if final_layer == 'basic':

	#	Normal / Basic
	model.add(tf.keras.layers.Dense(1, activation='sigmoid'))
	model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

elif final_layer == 'continuous':

	#	Continuous range
	model.add(tf.keras.layers.Dense(1))
	#	tried learning rates 0.1 and 0.01. 0.001 is nice.
	model.compile(
		optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
		loss='mean_absolute_error')

elif final_layer == 'category':

	#	Classify 10 (category_count) different things
	#	https://www.tensorflow.org/tutorials/keras/classification
	model.add(tf.keras.layers.Dense(category_count))
	model.compile(optimizer='adam',
		loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
		metrics=['accuracy'])



model.fit(train_data, train_outcome, epochs=1000)


if final_layer in ['basic','category']:
	#	Not very useful for continuous variable
	model.evaluate(test_data, test_outcome)



model.predict(test_data).flatten()

out = test_outcome.to_frame()
out['prediction'] = model.predict(test_data).flatten().round(3)

print(out.to_string(), flush=True)



if final_layer in ['continuous']:

	from sklearn.metrics import mean_absolute_error, mean_squared_error

	mae = mean_absolute_error(out["prediction"], out[outcome_column])
	mse = mean_squared_error(out["prediction"], out[outcome_column], squared=True)

	print(f"mae:{round(mae,2)} mse:{round(mse,2)}")


