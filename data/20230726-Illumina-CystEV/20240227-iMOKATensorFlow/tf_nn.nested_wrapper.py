#!/usr/bin/env python3

print("Running nested neural net wrapper")

import sys
k = sys.argv[1]

print(k)

import psutil
import pandas as pd

base_dir="/francislab/data1/working/20230726-Illumina-CystEV/20240227-iMOKATensorFlow/"
kmer_matrix_file=base_dir+"/tf/"+str(k)+"/kmers.rescaled.tsv.gz"

working_dir=base_dir+"/CF-SE/"+str(k)+"/"
train_ids_file=base_dir+"train_ids.tsv"
test_ids_file=base_dir+"test_ids.tsv"

#working_dir=base_dir+"/CF/"+str(k)+"/"
#train_ids_file=base_dir+"cf_train_ids.tsv"
#test_ids_file=base_dir+"cf_test_ids.tsv"

import os
os.makedirs(working_dir, exist_ok=True)


out_dir=working_dir
kmers_file=""

import subprocess

feature_importances=[]
predictions=[]

#for i in range(200):
for i in range(1):

	subprocess.run(["python3", base_dir+"tf_nn.nested_individual.py",
		str(i),kmer_matrix_file,train_ids_file,test_ids_file,out_dir,kmers_file])



	#	read predictions output
	#	append to predictions matrix

	predictions.append(
		pd.read_csv(
			working_dir+"predictions."+str(i)+".tsv",
				sep="\t",header=0,index_col=[0]))	#,usecols=[0,2]))


	#	read feature importance output
	#	append to feature importance matrix

	kmers_file=working_dir+"feature_importances."+str(i)+".tsv"

	feature_importances.append(
		pd.read_csv(
			working_dir+"feature_importances."+str(i)+".tsv",
				sep="\t",header=0,index_col=[0]))



#print("Accuracies")
#print(accuracies)

#	concat and save predictions

pd.concat(predictions, axis=1, sort=True).to_csv(
	working_dir+"predictions.csv",index_label=["sample"])

#	concat and save feature importances

pd.concat(feature_importances, axis=1, sort=True).to_csv(
	working_dir+"feature_importances.csv",index_label=["kmer"])



dataset = pd.read_csv(kmer_matrix_file ,sep="\t",header=[0,1],index_col=[0]).transpose()

#dataset=dataset[dataset.index.get_level_values("group").isin(["IDH-WT", "IDH-MT"])]

kmers = pd.read_csv(kmers_file,sep="\t",header=[0],index_col=[0])
kmers = kmers.sort_values(kmers.columns[0])
ten_percent=int(0.1*len(kmers))
dataset=dataset.loc[:,kmers.iloc[ten_percent:].index.to_list()]
dataset.to_csv(working_dir+"select_kmers_matrix.tsv",index_label="sample",sep="\t")






#	c4-n37 - always seems to run out of memory?
#	c4-n38 - has a GPU but not big enough so crashes


#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}t" --output="${PWD}/tf_nn.nested_wrapper.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n37,c4-n38 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf_nn.nested_wrapper.py ${k}"

