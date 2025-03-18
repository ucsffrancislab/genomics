#!/usr/bin/env python3
#
#SHAP README snippets
#

import xgboost
import shap

# train an XGBoost model
X, y = shap.datasets.california()
model = xgboost.XGBRegressor().fit(X, y)

# explain the model's predictions using SHAP
# (same syntax works for LightGBM, CatBoost, scikit-learn, transformers, Spark, etc.)
explainer = shap.Explainer(model)
shap_values = explainer(X)

# visualize the first prediction's explanation
shap.plots.waterfall(shap_values[0])

#	---

# visualize the first prediction's explanation with a force plot
shap.plots.force(shap_values[0])

#	---

# visualize all the training set predictions
shap.plots.force(shap_values[:500])

#	---

# create a dependence scatter plot to show the effect of a single feature across the whole dataset
shap.plots.scatter(shap_values[:, "Latitude"], color=shap_values)

#	---

# summarize the effects of all the features
shap.plots.beeswarm(shap_values)

#	---

shap.plots.bar(shap_values)

#	---

import transformers
import shap

# load a transformers pipeline model
model = transformers.pipeline('sentiment-analysis', return_all_scores=True)

# explain the model on two sample inputs
explainer = shap.Explainer(model)
shap_values = explainer(["What a great movie! ...if you have no taste."])

# visualize the first prediction's explanation for the POSITIVE output class
shap.plots.text(shap_values[0, :, "POSITIVE"])

#	---





#	# ...include code from https://github.com/keras-team/keras/blob/master/examples/demo_mnist_convnet.py
#	
#	import shap
#	import numpy as np
#	
#	# select a set of background examples to take an expectation over
#	background = x_train[np.random.choice(x_train.shape[0], 100, replace=False)]
#	
#	# explain predictions of the model on four images
#	e = shap.DeepExplainer(model, background)
#	# ...or pass tensors directly
#	# e = shap.DeepExplainer((model.layers[0].input, model.layers[-1].output), background)
#	shap_values = e.shap_values(x_test[1:5])
#	
#	# plot the feature attributions
#	shap.image_plot(shap_values, -x_test[1:5])
#	
#	
#	
#	
#	
#	
#	from keras.applications.vgg16 import VGG16
#	from keras.applications.vgg16 import preprocess_input
#	import keras.backend as K
#	import numpy as np
#	import json
#	import shap
#	
#	# load pre-trained model and choose two images to explain
#	model = VGG16(weights='imagenet', include_top=True)
#	X,y = shap.datasets.imagenet50()
#	to_explain = X[[39,41]]
#	
#	# load the ImageNet class names
#	url = "https://s3.amazonaws.com/deep-learning-models/image-models/imagenet_class_index.json"
#	fname = shap.datasets.cache(url)
#	with open(fname) as f:
#	    class_names = json.load(f)
#	
#	# explain how the input to the 7th layer of the model explains the top two classes
#	def map2layer(x, layer):
#	    feed_dict = dict(zip([model.layers[0].input], [preprocess_input(x.copy())]))
#	    return K.get_session().run(model.layers[layer].input, feed_dict)
#	e = shap.GradientExplainer(
#	    (model.layers[7].input, model.layers[-1].output),
#	    map2layer(X, 7),
#	    local_smoothing=0 # std dev of smoothing noise
#	)
#	shap_values,indexes = e.shap_values(map2layer(to_explain, 7), ranked_outputs=2)
#	
#	# get the names for the classes
#	index_names = np.vectorize(lambda x: class_names[str(x)][1])(indexes)
#	
#	# plot the explanations
#	shap.image_plot(shap_values, to_explain, index_names)
#	
#	
#	
#	
#	
#	
#	import sklearn
#	import shap
#	from sklearn.model_selection import train_test_split
#	
#	# print the JS visualization code to the notebook
#	shap.initjs()
#	
#	# train a SVM classifier
#	X_train,X_test,Y_train,Y_test = train_test_split(*shap.datasets.iris(), test_size=0.2, random_state=0)
#	svm = sklearn.svm.SVC(kernel='rbf', probability=True)
#	svm.fit(X_train, Y_train)
#	
#	# use Kernel SHAP to explain test set predictions
#	explainer = shap.KernelExplainer(svm.predict_proba, X_train, link="logit")
#	shap_values = explainer.shap_values(X_test, nsamples=100)
#	
#	# plot the SHAP values for the Setosa output of the first instance
#	shap.force_plot(explainer.expected_value[0], shap_values[0][0,:], X_test.iloc[0,:], link="logit")
#	
#	
#	
#	
#	
#	
#	# plot the SHAP values for the Setosa output of all instances
#	shap.force_plot(explainer.expected_value[0], shap_values[0], X_test, link="logit")
#	
#	
#	
#	
#	
#	
