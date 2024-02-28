#!/usr/bin/env python3

print("Running nested neural net")

import os
import sys
import psutil
import numpy as np
import pandas as pd
import subprocess

import gc
gc.enable()

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
parser.add_argument('-V', '--version', help='show program version', action='store_true')
parser.add_argument('-i', '--iteration', nargs=1, type=int, default=[0], help='iteration to %(prog)s (default: %(default)s)')
parser.add_argument('--iterations', nargs=1, type=int, default=[10], help='total iterations to %(prog)s (default: %(default)s)')
parser.add_argument('--epochs', nargs=1, type=int, default=[20], help='model epochs to %(prog)s (default: %(default)s)')
parser.add_argument('-k', '--kmer_length', nargs=1, type=int, default=[9], help='k length to %(prog)s (default: %(default)s)')
parser.add_argument('--kmer_matrix', nargs=1, type=str, help='kmer matrix filename to %(prog)s (default: %(default)s)')
parser.add_argument('--train_ids', nargs=1, type=str, help='training ids filename to %(prog)s (default: %(default)s)')
parser.add_argument('--test_ids', nargs=1, type=str, help='testing ids filename to %(prog)s (default: %(default)s)')
parser.add_argument('--out_dir', nargs=1, type=str, help='out_dir to %(prog)s (default: %(default)s)')
parser.add_argument('--select_kmers', nargs=1, type=str, default=[''], help='select kmers filename to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

# check for --version or -V
if args.version:  
	print(os.path.basename(__file__), " 1.0")
	quit()

iterations = args.iterations[0]
print( "Using iterations: ", iterations )
epochs = args.epochs[0]
print( "Using epochs: ", epochs )
iteration = args.iteration[0]
print( "Using iteration: ", iteration )
kmer_length = args.kmer_length[0]
print( "Using kmer_length: ", kmer_length )
kmer_matrix_file = args.kmer_matrix[0]
print( "Using kmer_matrix_file: ", kmer_matrix_file )
train_ids_file = args.train_ids[0]
print( "Using train_ids_file: ", train_ids_file )
test_ids_file = args.test_ids[0]
print( "Using test_ids_file: ", test_ids_file )
out_dir = args.out_dir[0]
print( "Using out_dir: ", out_dir )
os.makedirs(out_dir, exist_ok=True)

#if args.select_kmers:
	#if isinstance(args.output,list):
select_kmers_file = args.select_kmers[0]
print( "Using select_kmers_file: ", select_kmers_file )


if iteration > 0:

	import tensorflow as tf

	print("Running iteration "+str(iteration))
	psutil.virtual_memory()

	dataset = pd.read_csv(kmer_matrix_file ,sep="\t",header=[0,1],index_col=[0]).transpose()
	
	dataset = dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]
	
	print("len(dataset.columns) : "+str(len(dataset.columns)))
	print(dataset.head())
	
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
	
	print("1 layer of 512")
	print("1 layer of 256")
	
	model.add(tf.keras.layers.Dense(512, activation="sigmoid"))
	model.add(tf.keras.layers.Dense(256, activation="sigmoid"))
	model.add(tf.keras.layers.Dense(1, activation="sigmoid"))
	
	print("Compile")
	model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])
	
	print("Fit")
	fit = model.fit(x_train, y_train, batch_size=64, epochs=epochs)
	
	#accuracies.append(fit.history["accuracy"][-1])
	
	print("Evaluate")
	model.evaluate(x_test, y_test)
	
	out = y_test.to_frame()
	out[iteration] = model.predict(x_test).flatten()
	out.to_csv(out_dir+"predictions."+str(iteration)+".tsv",index_label="sample",sep="\t")
	
	df = pd.DataFrame({"kmer":x_train.columns, iteration:np.sum(np.abs(model.get_weights()[0]), axis=1)})
	df.set_index("kmer").to_csv( out_dir+"feature_importances."+str(iteration)+".tsv",index_label="kmer",sep="\t")

else:

	print("Zeroth iteration. Running wrapper.")

	feature_importances = []
	predictions = []
	
	for i in range(1,iterations+1):

		print("Prepping iteration :"+str(i))

		command = ["python3", __file__,
			"--kmer_length", str(kmer_length),
			"--iteration", str(i),
			"--epochs", str(epochs),
			"--kmer_matrix", kmer_matrix_file,
			"--train_ids", train_ids_file,
			"--test_ids", test_ids_file,
			"--out_dir", out_dir ]
			#"--out_dir", out_dir + str(kmer_length) + "/"]

		if select_kmers_file:
			command.append( "--select_kmers" )
			command.append( select_kmers_file )

		subprocess.run(command)
	
		#	read predictions output
		#	append to predictions matrix
	
		predictions.append(
			pd.read_csv(out_dir+"predictions."+str(i)+".tsv",sep="\t",header=0,index_col=[0],usecols=[0,2]))
	
		#	read feature importance output
		#	append to feature importance matrix
		select_kmers_file = out_dir+"feature_importances."+str(i)+".tsv"
	
		feature_importances.append(
			pd.read_csv( select_kmers_file, sep="\t",header=0,index_col=[0]))



	
	#print("Accuracies")
	#print(accuracies)
	
	#	concat and save predictions
	pd.concat(predictions, axis=1, sort=True).to_csv(out_dir+"predictions.csv",index_label=["sample"])
	
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


