#!/usr/bin/env python3

print("Running nested neural net", flush=True)

import os
import sys
import psutil
import numpy as np
import pandas as pd

import gc
gc.enable()

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-i', '--iteration', nargs=1, type=int, default=[0], help='iteration to %(prog)s (default: %(default)s)')
parser.add_argument('--iterations', nargs=1, type=int, default=[100], help='total iterations to %(prog)s (default: %(default)s)')
parser.add_argument('--epochs', nargs=1, type=int, default=[25], help='model epochs to %(prog)s (default: %(default)s)')
parser.add_argument('-k', '--kmer_length', nargs=1, type=int, default=[9], help='k length to %(prog)s (default: %(default)s)', required=True)
parser.add_argument('--kmer_matrix', nargs=1, type=str, help='kmer matrix filename to %(prog)s (default: %(default)s)', required=True)
parser.add_argument('--train_ids', nargs=1, type=str, help='training ids filename to %(prog)s (default: %(default)s)', required=True)
parser.add_argument('--test_ids', nargs=1, type=str, help='testing ids filename to %(prog)s (default: %(default)s)', required=True)
parser.add_argument('--out_dir', nargs=1, type=str, help='out_dir to %(prog)s (default: %(default)s)', required=True)
parser.add_argument('--select_kmers', nargs=1, type=str, default=[''], help='select kmers filename to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print(os.path.basename(__file__), " 1.0")
	quit()

iterations = args.iterations[0]
print( "Using iterations: ", iterations , flush=True)
epochs = args.epochs[0]
print( "Using epochs: ", epochs , flush=True)
iteration = args.iteration[0]
print( "Using iteration: ", iteration , flush=True)
kmer_length = args.kmer_length[0]
print( "Using kmer_length: ", kmer_length , flush=True)
kmer_matrix_file = args.kmer_matrix[0]
print( "Using kmer_matrix_file: ", kmer_matrix_file , flush=True)
train_ids_file = args.train_ids[0]
print( "Using train_ids_file: ", train_ids_file , flush=True)
test_ids_file = args.test_ids[0]
print( "Using test_ids_file: ", test_ids_file , flush=True)
out_dir = args.out_dir[0]
print( "Using out_dir: ", out_dir , flush=True)
os.makedirs(out_dir, exist_ok=True)

#if args.select_kmers:
	#if isinstance(args.output,list):
select_kmers_file = args.select_kmers[0]
print( "Using select_kmers_file: ", select_kmers_file, flush=True)


if iteration > 0:

	#	python3 -m pip install --user --upgrade "tensorflow[and-cuda]" didn't stop the warnings
	import tensorflow as tf

	class CustomCallback(tf.keras.callbacks.Callback):
		def on_epoch_begin(self, epoch, logs=None):
			#Epoch 10/20
			#2/2 - 4s - loss: 0.4300 - accuracy: 0.8261 - 4s/epoch - 2s/step
			#keys = list(logs.keys())
			#print("End epoch {} of training; got log keys: {}".format(epoch, keys))
			#End epoch 10 of training; got log keys: ['loss', 'accuracy']
			#Epoch 16/20
			#End epoch 15 of training; got log keys: ['loss', 'accuracy']
			#2/2 - 24s - loss: 0.4241 - accuracy: 0.8261 - 24s/epoch - 12s/step
			# Getting % usage of virtual_memory ( 3rd field)
			print("RAM memory % used:", psutil.virtual_memory()[2])
			# Getting usage of virtual_memory in GB ( 4th field)
			print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
			psutil.virtual_memory()

	print("Running iteration "+str(iteration))
	psutil.virtual_memory()

	dataset = pd.read_csv(kmer_matrix_file ,sep="\t",header=[0,1],index_col=[0]).transpose()
	
	dataset = dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]
	
	print("len(dataset.columns) : "+str(len(dataset.columns)))
	print(dataset.head())

	#Running iteration 1
	#len(dataset.columns) : 46589080
	#                  AAAAAAAACCAAAAAAATTAG  ...  TTTTTTTTTTTTTTTTTGTTT
	#          group                          ...                       
	#SFHH005a  IDH-WT                    0.0  ...                316.850
	#SFHH005aa IDH-MT                    0.0  ...                  0.000
	#SFHH005ab IDH-MT                    0.0  ...                231.488
	#SFHH005ac IDH-MT                    0.0  ...               1094.230
	#SFHH005ad IDH-MT                    0.0  ...                  0.000









	#tmp1=dataset[dataset.index.get_level_values("group")=='IDH-WT'].reset_index()
	#tmp2=dataset[dataset.index.get_level_values("group")=='IDH-WT'].reset_index()
	#tmp1['level_0']=tmp1['level_0'].astype('str')+'_dup1'
	#tmp2['level_0']=tmp2['level_0'].astype('str')+'_dup2'
	#dataset=dataset.reset_index()
	#dataset = pd.concat([dataset,tmp1,tmp2])
	#dataset = dataset.set_index(['level_0','group'])
	#print("len(dataset.columns) : "+str(len(dataset.columns)))
	#print(dataset.head())







	
	# select specific
	if select_kmers_file:
		print("Selecting the top 90% of kmers from the last round")
		#	kmer - score
		kmers = pd.read_csv(select_kmers_file,sep="\t",header=[0],index_col=[0])
		kmers = kmers.sort_values(kmers.columns[0])
		print(kmers.head())
		#print("Drop the bottom 10%")
		ten_percent = int(0.1*len(kmers))
		dataset = dataset.loc[:,kmers.iloc[ten_percent:].index.to_list()]
		del kmers
	
	print("len(dataset.columns) : "+str(len(dataset.columns)))
	print(dataset.head())
	
	x = dataset.reset_index().set_index("level_0").drop(columns=["group"])
	print("x.head()")
	print(x.head())
	
	y = dataset.reset_index().set_index("level_0")["group"]
	print("y.head()")
	print(y.head())
	
	y = y.replace(["IDH-WT","IDH-MT"],[0,1])
	#y = y.replace(["LoNo","HiAd"],[0,1])
	
	print("y.head()")
	print(y.head())

	#x.head()
	#           AAAAAAAACCAAAAAAATTAG  ...  TTTTTTTTTTTTTTTTTGTTT
	#level_0                           ...                       
	#SFHH005a                     0.0  ...                316.850
	#SFHH005aa                    0.0  ...                  0.000
	#SFHH005ab                    0.0  ...                231.488
	#SFHH005ac                    0.0  ...               1094.230
	#SFHH005ad                    0.0  ...                  0.000
	#
	#[5 rows x 46589080 columns]
	#y.head()
	#level_0
	#SFHH005a     IDH-WT
	#SFHH005aa    IDH-MT
	#SFHH005ab    IDH-MT
	#SFHH005ac    IDH-MT
	#SFHH005ad    IDH-MT
	#Name: group, dtype: object
	#y.head()
	#level_0
	#SFHH005a     0
	#SFHH005aa    1
	#SFHH005ab    1
	#SFHH005ac    1
	#SFHH005ad    1

	
	del dataset
	
	train_ids = pd.read_csv(train_ids_file,sep="\t",header=None)[0].to_numpy()
	test_ids = pd.read_csv(test_ids_file,sep="\t",header=None)[0].to_numpy()
	
	x_train = x.loc[x.index.isin(train_ids)]
	x_test = x.loc[x.index.isin(test_ids)]
	y_train = y.loc[y.index.isin(train_ids)]
	y_test = y.loc[y.index.isin(test_ids)]
	
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
	
	
	model = tf.keras.models.Sequential()


	#	be nice if I could work in a simple algorithm rather than a series of conditions
	#	let's see how this goes first

	#	3716249 used ~150GB with 1024/512 so could be much bigger
	#	2194410 use 125 with 1024/512
	#	 9 -   262081
	#	10 -  1048483
	#	11 -  4188536
	#	12 - 15365415
	#	13 - 40830160
	#	14 - 59614139
	#	15 - 52831905
	#	16 - 47735612
	#	17 - 46289631
	#	18 - 46064901
	#	19 - 46188058
	#	20 - 46387613
	#	21 - 46589082
	#	25 - 46944044
	#	31 - 45559612


	#	if len(x.columns) > 30000000:
	#
	#		print("1 layer of 128")
	#		model.add(tf.keras.layers.Dense(128, activation="relu", name="primary"))
	#
	#		print("1 layer of 128")
	#		model.add(tf.keras.layers.Dense(128, activation="relu", name="secondary"))
	#
	#	elif len(x.columns) > 25000000:
	#
	#		print("1 layer of 256")
	#		model.add(tf.keras.layers.Dense(256, activation="relu", name="primary"))
	#
	#		print("1 layer of 128")
	#		model.add(tf.keras.layers.Dense(128, activation="relu", name="secondary"))
	#
	#	elif len(x.columns) > 20000000:
	#
	#		print("1 layer of 256")
	#		model.add(tf.keras.layers.Dense(256, activation="relu", name="primary"))
	#
	#		print("1 layer of 256")
	#		model.add(tf.keras.layers.Dense(256, activation="relu", name="secondary"))
	#
	#	elif len(x.columns) > 15000000:
	#
	#		print("1 layer of 512")
	#		model.add(tf.keras.layers.Dense(512, activation="relu", name="primary"))
	#
	#		print("1 layer of 256")
	#		model.add(tf.keras.layers.Dense(256, activation="relu", name="secondary"))
	#
	#	elif len(x.columns) > 10000000:
	#
	#		print("1 layer of 512")
	#		model.add(tf.keras.layers.Dense(512, activation="relu", name="primary"))
	#
	#		print("1 layer of 512")
	#		model.add(tf.keras.layers.Dense(512, activation="relu", name="secondary"))
	#	
	#	elif len(x.columns) >  5000000:
	#
	#		print("1 layer of 1024")
	#		model.add(tf.keras.layers.Dense(1024, activation="relu", name="primary"))
	#
	#		print("1 layer of 512")
	#		model.add(tf.keras.layers.Dense(512, activation="relu", name="secondary"))
	#	
	#	elif len(x.columns) >  2500000:
	#
	#		print("1 layer of 1024")
	#		model.add(tf.keras.layers.Dense(1024, activation="relu", name="primary"))
	#
	#		print("1 layer of 1024")
	#		model.add(tf.keras.layers.Dense(1024, activation="relu", name="secondary"))
	#	
	#	elif len(x.columns) >  2000000:
	#
	#		print("1 layer of 2048")
	#		model.add(tf.keras.layers.Dense(2048, activation="relu", name="primary"))
	#
	#		print("1 layer of 1024")
	#		model.add(tf.keras.layers.Dense(1024, activation="relu", name="secondary"))
	#	
	#	elif len(x.columns) >  1500000:
	#
	#		print("1 layer of 2048")
	#		model.add(tf.keras.layers.Dense(2048, activation="relu", name="primary"))
	#
	#		print("1 layer of 2048")
	#		model.add(tf.keras.layers.Dense(2048, activation="relu", name="secondary"))
	#	
	#	elif len(x.columns) >  1000000:
	#
	#		print("1 layer of 4096")
	#		model.add(tf.keras.layers.Dense(4096, activation="relu", name="primary"))
	#
	#		print("1 layer of 2048")
	#		model.add(tf.keras.layers.Dense(2048, activation="relu", name="secondary"))
	#	
	#	else:
	#
	#		print("1 layer of 4096")
	#		model.add(tf.keras.layers.Dense(4096, activation="relu", name="primary"))
	#
	#		print("1 layer of 4096")
	#		model.add(tf.keras.layers.Dense(4096, activation="relu", name="secondary"))


	#	50,000,000 => 100
	#	 1,000,000 => 2000
	#	     1,000 => 4000

	#	194493 - 
	#	1 layer of 25707.866092867094
	#	1 layer of 12853.933046433547

	#	>>> 500000/np.log10(40000000)**4
	#	149.70793996304846
	#	>>> 500000/np.log10(2000)**4
	#	4210.872789957378

	#l1=int(4000000000/len(x.columns))
	l1=int(700000/np.log10(len(x.columns))**4)
	print("1 layer of "+str(l1))
	model.add(tf.keras.layers.Dense(l1, activation="sigmoid", name="primary"))

	#l2=int(2000000000/len(x.columns))
	l2=int(350000/np.log10(len(x.columns))**4)
	print("1 layer of "+str(l2))
	model.add(tf.keras.layers.Dense(l2, activation="sigmoid", name="secondary"))



	#	activation relu or sigmoid?
	#	changes output from float to be just 0.0 or 1.0



	print("Add Dropout")
	model.add(tf.keras.layers.Dropout(0.5))




	#	https://www.tensorflow.org/tutorials/structured_data/imbalanced_data

	neg, pos = np.bincount(y_train)
	total = neg + pos
	print('Examples:\n    Total: {}\n    Positive: {} ({:.2f}% of total)\n'.format(
		total, pos, 100 * pos / total))
	#1 layer of 256
	#1 layer of 128
	#Add Dropout
	#Examples:
	#    Total: 32
	#    Positive: 24 (75.00% of total)

	# Scaling by total/2 helps keep the loss to a similar magnitude.
	# The sum of the weights of all examples stays the same.
	weight_for_0 = (1 / neg) * (total / 2.0)
	weight_for_1 = (1 / pos) * (total / 2.0)
	class_weight = {0: weight_for_0, 1: weight_for_1}
	print('Weight for class 0: {:.2f}'.format(weight_for_0))
	print('Weight for class 1: {:.2f}'.format(weight_for_1))
	#Weight for class 0: 2.00
	#Weight for class 1: 0.67

	model.add(tf.keras.layers.Dense(1, activation="sigmoid", name="final",
		bias_initializer=tf.keras.initializers.Constant(np.log([pos/neg]))
	))
	
	print("Compile")
	model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])
	
	# Getting % usage of virtual_memory ( 3rd field)
	print("RAM memory % used:", psutil.virtual_memory()[2])
	# Getting usage of virtual_memory in GB ( 4th field)
	print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
	psutil.virtual_memory()
	
	print("Fit")
	#fit = model.fit(x_train, y_train, batch_size=64, epochs=epochs, verbose=2)
	fit = model.fit(x_train, y_train, epochs=epochs, verbose=2, callbacks=[CustomCallback()], class_weight=class_weight)
	print("Model after fit")
	print(model.summary())

	#Model after fit
	#Model: "sequential"
	#_________________________________________________________________
	# Layer (type)                Output Shape              Param #   
	#=================================================================
	# primary (Dense)             (32, 1024)                2496751616
	#                                                                 
	# secondary (Dense)           (32, 512)                 524800    
	#                                                                 
	# dropout (Dropout)           (32, 512)                 0         
	#                                                                 
	# final (Dense)               (32, 1)                   513       
	#                                                                 
	#=================================================================
	#Total params: 2497276929 (9.30 GB)
	#Trainable params: 2497276929 (9.30 GB)
	#Non-trainable params: 0 (0.00 Byte)
	#_________________________________________________________________

	#accuracies.append(fit.history["accuracy"][-1])
	
	print("Evaluate")
	model.evaluate(x_test, y_test)
	
	#out = y_test.to_frame()
	out = y.to_frame()
	out[iteration] = model.predict(x).flatten()
	out.to_csv(out_dir+"predictions."+str(iteration)+".tsv",index_label="sample",sep="\t")
	
	df = pd.DataFrame({"kmer":x_train.columns, iteration:np.sum(np.abs(model.get_weights()[0]), axis=1)})
	df.set_index("kmer").to_csv( out_dir+"feature_importances."+str(iteration)+".tsv",index_label="kmer",sep="\t")

else:

	print("Zeroth iteration. Running wrapper.", flush=True)

	feature_importances = []
	predictions = []
	
	for i in range(1,iterations+1):

		print("Prepping iteration :"+str(i), flush=True)

		command = ["python3", __file__,
			"--kmer_length", str(kmer_length),
			"--iterations", str(iterations),
			"--iteration", str(i),
			"--epochs", str(epochs),
			"--kmer_matrix", kmer_matrix_file,
			"--train_ids", train_ids_file,
			"--test_ids", test_ids_file,
			"--out_dir", out_dir ]

		if select_kmers_file:
			command.append( "--select_kmers" )
			command.append( select_kmers_file )
	
		# Getting % usage of virtual_memory ( 3rd field)
		print("RAM memory % used:", psutil.virtual_memory()[2], flush=True)
		# Getting usage of virtual_memory in GB ( 4th field)
		print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000, flush=True)
		psutil.virtual_memory()

		import subprocess
		print( subprocess.run(command), flush=True)
	
		# Getting % usage of virtual_memory ( 3rd field)
		print("RAM memory % used:", psutil.virtual_memory()[2], flush=True)
		# Getting usage of virtual_memory in GB ( 4th field)
		print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000, flush=True)
		psutil.virtual_memory()
	
		#	read predictions output
		#	append to predictions matrix
	
		predictions.append(
			pd.read_csv(out_dir+"predictions."+str(i)+".tsv",sep="\t",header=0,index_col=[0,1],usecols=[0,1,2]))
	
		#	read feature importance output
		#	append to feature importance matrix
		select_kmers_file = out_dir+"feature_importances."+str(i)+".tsv"
	
		feature_importances.append(
			pd.read_csv( select_kmers_file, sep="\t",header=0,index_col=[0]))



	
	#print("Accuracies")
	#print(accuracies)
	
	#	concat and save predictions
	pd.concat(predictions, axis=1, sort=True).to_csv(out_dir+"predictions.csv",index_label=["sample","group"])
	
	#	concat and save feature importances
	pd.concat(feature_importances, axis=1, sort=True).to_csv(out_dir+"feature_importances.csv",index_label=["kmer"])
	
	#	create a matrix of the select kmers and their counts
	dataset = pd.read_csv(kmer_matrix_file ,sep="\t",header=[0,1],index_col=[0]).transpose()
	dataset = dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]
	kmers = pd.read_csv(select_kmers_file,sep="\t",header=[0],index_col=[0])
	kmers = kmers.sort_values(kmers.columns[0])
	ten_percent = int(0.1*len(kmers))
	dataset = dataset.loc[:,kmers.iloc[ten_percent:].index.to_list()]
	dataset.to_csv(out_dir+"select_kmers_matrix.tsv",index_label="sample",sep="\t")












#	c4-n37 - always seems to run out of memory?
#	c4-n38 - has a GPU but not big enough so crashes
#	c4-n39 - has a GPU but not big enough so crashes


#	k=9 && sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested.py -k ${k} --kmer_matrix=${PWD}/tf/${k}/kmers.rescaled.tsv.gz --train_ids=${PWD}/train_ids.tsv --test_ids=${PWD}/test_ids.tsv --out_dir=${PWD}/tf_nn/${k}/"


