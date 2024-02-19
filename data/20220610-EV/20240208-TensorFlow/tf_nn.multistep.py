#!/usr/bin/env python3

import sys
k = sys.argv[1]

print(k)

import gc
gc.enable()

d=dir()

import psutil
psutil.virtual_memory()

import numpy as np
import pandas as pd

dataset = pd.read_csv("/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf/"+str(k)+"/kmers.rescaled.tsv.gz",sep="\t",header=[0,1],index_col=[0]).transpose()

dataset=dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]

print(dataset.size)
print(dataset.head())

x = dataset.reset_index().set_index("level_0").drop(columns=["group"])
print(x.head())

y = dataset.reset_index().set_index("level_0")["group"]
print(y.head())

y = y.replace(["IDH-WT","IDH-MT"],[0,1])

print(y.head())


del dataset


train_ids=pd.read_csv("train_ids.tsv",sep="\t",header=None)[0].to_numpy()
test_ids=pd.read_csv("test_ids.tsv",sep="\t",header=None)[0].to_numpy()

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


low_kmers=[]
feature_importances=[]
accuracies=[]

# Getting % usage of virtual_memory ( 3rd field)
print("RAM memory % used:", psutil.virtual_memory()[2])
# Getting usage of virtual_memory in GB ( 4th field)
print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
psutil.virtual_memory()

for i in range(10):


	#	I am going to need to make this a subprocess somehow


	import tensorflow as tf

	x_train=x_train.drop(columns=low_kmers)
	x_test=x_test.drop(columns=low_kmers)

	print("Round "+str(i))

	model = tf.keras.models.Sequential()

	print("1 layer of 256")

	model.add(tf.keras.layers.Dense(256, activation="sigmoid"))
	model.add(tf.keras.layers.Dense(1, activation="sigmoid"))

	print("Compile")
	model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])

	print("Fit")
	fit=model.fit(x_train, y_train, batch_size=64, epochs=10)

	accuracies.append(fit.history["accuracy"][-1])

	print("Evaluate")
	model.evaluate(x_test, y_test)

	out=y_test.to_frame()
	out["prediction"]=model.predict(x_test).flatten()
	print(out)

	df = pd.DataFrame({"kmers":x_train.columns, "feature_importance":np.sum(np.abs(model.get_weights()[0]), axis=1)}).sort_values("feature_importance")
	feature_importances.append(df.set_index("kmers").rename(columns={"feature_importance": str(i)}))
	print(df.sort_values("feature_importance"))

	ten_percent=int(0.1*len(x_test.columns))
	low_kmers=df.iloc[0:ten_percent]["kmers"].to_numpy()

	# Getting % usage of virtual_memory ( 3rd field)
	print("RAM memory % used:", psutil.virtual_memory()[2])
	# Getting usage of virtual_memory in GB ( 4th field)
	print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
	psutil.virtual_memory()


	#print("Dir")
	#print(d)

	#print("Globals")
	#print(globals())

	#You'll need to check for user-defined variables in the directory
	#for obj in d:
	#	#checking for built-in variables/functions
	#	if not obj.startswith('__'):
	#		print(obj)
	#		#deleting the said obj, since a user-defined function
	#		#del globals()[obj]

	print("Deleting model to clear memory")
	del model
	del df
	tf.keras.backend.clear_session()
	del tf

	gc.collect()
	gc.collect()
	gc.collect()
	gc.collect()
	gc.collect()

	# Getting % usage of virtual_memory ( 3rd field)
	print("RAM memory % used:", psutil.virtual_memory()[2])
	# Getting usage of virtual_memory in GB ( 4th field)
	print("RAM Used (GB):", psutil.virtual_memory()[3]/1000000000)
	psutil.virtual_memory()



#	WARNING:tensorflow:5 out of the last 5 calls to <function Model.make_test_function.<locals>.test_function at 0x7efd67125280> triggered 
#		tf.function retracing. Tracing is expensive and the excessive number of tracings could be due to (1) creating @tf.function repeatedly 
#		in a loop, (2) passing tensors with different shapes, (3) passing Python objects instead of tensors. For (1), please define your 
#		@tf.function outside of the loop. For (2), @tf.function has reduce_retracing=True option that can avoid unnecessary retracing. 
#		For (3), please refer to https://www.tensorflow.org/guide/function#controlling_retracing and 
#		https://www.tensorflow.org/api_docs/python/tf/function for  more details.


print("Accuracies")
print(accuracies)

pd.concat(feature_importances, axis=1, sort=True).to_csv("/francislab/data1/working/20220610-EV/20240208-TensorFlow/feature_importances.test.csv",index_label=["kmer"])



#	c4-n37 - always seems to run out of memory?
#	c4-n38 - has a GPU but not big enough so crashes


#	Fit
#	Epoch 1/100
#	2024-02-16 16:13:21.692009: W tensorflow/core/framework/op_kernel.cc:1839] OP_REQUIRES failed at matmul_op_impl.h:921 : RESOURCE_EXHAUSTED: OOM when allocating tensor with shape[22436962,512] and type float on /job:localhost/replica:0/task:0/device:CPU:0 by allocator cpu
#	Traceback (most recent call last):
#	  File "/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf_nn.multistep.py", line 74, in <module>
#	    model.fit(x_train, y_train, batch_size=64, epochs=100)
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/utils/traceback_utils.py", line 70, in error_handler
#	    raise e.with_traceback(filtered_tb) from None
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/tensorflow/python/eager/execute.py", line 53, in quick_execute
#	    tensors = pywrap_tfe.TFE_Py_Execute(ctx._handle, device_name, op_name,
#	tensorflow.python.framework.errors_impl.ResourceExhaustedError: Graph execution error:
#	
#	Detected at node gradient_tape/sequential_1/dense_2/MatMul/MatMul defined at (most recent call last):
#	  File "/francislab/data1/working/20220610-EV/20240208-TensorFlow/tf_nn.multistep.py", line 74, in <module>
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/utils/traceback_utils.py", line 65, in error_handler
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/engine/training.py", line 1807, in fit
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/engine/training.py", line 1401, in train_function
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/engine/training.py", line 1384, in step_function
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/engine/training.py", line 1373, in run_step
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/engine/training.py", line 1154, in train_step
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/optimizers/optimizer.py", line 543, in minimize
#	
#	  File "/c4/home/gwendt/.local/lib/python3.9/site-packages/keras/src/optimizers/optimizer.py", line 276, in compute_gradients
#	
#	OOM when allocating tensor with shape[22436962,512] and type float on /job:localhost/replica:0/task:0/device:CPU:0 by allocator cpu
#		 [[{{node gradient_tape/sequential_1/dense_2/MatMul/MatMul}}]]
#	Hint: If you want to see a list of allocated tensors when OOM happens, add report_tensor_allocations_upon_oom to RunOptions for current allocation info. This isn't available when running in Eager mode.
#	 [Op:__inference_train_function_3594]
#	
