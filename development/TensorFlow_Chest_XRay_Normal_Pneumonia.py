#!/usr/bin/env python3

import kagglehub
paultimothymooney_chest_xray_pneumonia_path = kagglehub.dataset_download('paultimothymooney/chest-xray-pneumonia')
print(paultimothymooney_chest_xray_pneumonia_path)

#	.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/val/PNEUMONIA/person1949_bacteria_4880.jpeg


print('Data source import complete.')

import os
import glob
import numpy as np
from tensorflow.keras.preprocessing import image
from tensorflow.keras import models

#	.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/

# Set the paths to your dataset
#train_dir = 'kaggle/input/chest-xray-pneumonia/chest_xray/train'
train_dir = '.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/train'
os.makedirs(train_dir, exist_ok=True)
#test_dir = 'kaggle/input/chest-xray-pneumonia/chest_xray/test'
test_dir = '.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/test'
os.makedirs(test_dir, exist_ok=True)
#val_dir = 'kaggle/input/chest-xray-pneumonia/chest_xray/val'
val_dir = '.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/val'
os.makedirs(val_dir, exist_ok=True)




model_path = 'kaggle/working/cnn_model.keras'

if not os.path.exists(model_path):
	#import tensorflow as tf
	from tensorflow.keras.preprocessing.image import ImageDataGenerator
	from tensorflow.keras.applications import VGG16
	from tensorflow.keras import layers, optimizers
	from tensorflow.keras import Model
	
	# Image dimensions and batch size
	image_size = (224, 224)
	batch_size = 32
	
	
	# Data augmentation for the training dataset
	train_datagen = ImageDataGenerator(
	    rescale=1.0/255,
	    rotation_range=20,
	    width_shift_range=0.2,
	    height_shift_range=0.2,
	    shear_range=0.2,
	    zoom_range=0.2,
	    horizontal_flip=True,
	    fill_mode='nearest'
	)
	
	
	# Preprocess and augment the training data
	train_generator = train_datagen.flow_from_directory(
	    train_dir,
	    target_size=image_size,
	    batch_size=batch_size,
	    class_mode='binary'
	)
	
	
	
	# Preprocess the test and validation data
	test_datagen = ImageDataGenerator(rescale=1.0/255)
	
	test_generator = test_datagen.flow_from_directory(
	    test_dir,
	    target_size=image_size,
	    batch_size=batch_size,
	    class_mode='binary'
	)
	
	
	val_generator = test_datagen.flow_from_directory(
	    val_dir,
	    target_size=image_size,
	    batch_size=batch_size,
	    class_mode='binary'
	)
	
	
	#	Found 5216 images belonging to 2 classes.
	#	Found 624 images belonging to 2 classes.
	#	Found 16 images belonging to 2 classes.
	
	
	base_model = VGG16(include_top=False, weights='imagenet', input_shape=(224, 224, 3))
	for layer in base_model.layers:
	    layer.trainable = False
	
	x = layers.Flatten()(base_model.output)
	x = layers.Dense(512, activation='relu')(x)
	x = layers.Dropout(0.5)(x)
	x = layers.Dense(1, activation='sigmoid')(x)
	
	model = Model(base_model.input, x)
	
	
	# Compile the model
	#model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001), loss='binary_crossentropy', metrics=['accuracy'])
	model.compile(optimizer=optimizers.Adam(learning_rate=0.0001), loss='binary_crossentropy', metrics=['accuracy'])
	
	
	# Train the model
	history = model.fit(train_generator, epochs=10, validation_data=val_generator)
	
	#	/c4/home/gwendt/.local/lib/python3.11/site-packages/keras/src/trainers/data_adapters/py_dataset_adapter.py:121: UserWarning: Your `PyDataset` class should call `super().__init__(**kwargs)` in its constructor. `**kwargs` can include `workers`, `use_multiprocessing`, `max_queue_size`. Do not pass these arguments to `fit()`, as they will be ignored.
	
	
	# Evaluate the model on the test set
	test_loss, test_accuracy = model.evaluate(test_generator)
	print(f'Test accuracy: {test_accuracy * 100:.2f}%')
	
	
	# Save the model
	os.makedirs('kaggle/working', exist_ok=True)
	model.save(model_path)



#/c4/home/gwendt/.local/lib/python3.11/site-packages/keras/src/saving/saving_lib.py:757: UserWarning: Skipping variable loading for optimizer 'adam', because it has 10 variables whereas the saved optimizer has 2 variables. 
#  saveable.load_own_variables(weights_store.get(inner_path))
#WARNING:absl:Compiled the loaded model, but the compiled metrics have yet to be built. `model.compile_metrics` will be empty until you train or evaluate the model.

# Load the trained model
model = models.load_model(model_path)

for filename in glob.glob('.cache/kagglehub/datasets/paultimothymooney/chest-xray-pneumonia/versions/2/chest_xray/val/*/*'):
	print( os.path.basename( filename ) )

	img = image.load_img(filename, target_size=(224, 224))
	img = image.img_to_array(img)
	img = np.expand_dims(img, axis=0)

	# Make prediction
	predictions = model.predict(img)

	# Interpret the prediction
	if predictions[0] < 0.5:
		print("The image is NORMAL.")
	else:
		print("The image indicates PNEUMONIA.")

