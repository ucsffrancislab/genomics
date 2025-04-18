#!/usr/bin/env bash


#	Python memory management is challenging so building multiple tensorflow models end up sticking around

# doing it this way makes python exit between models

for i in 1 2 3 4 5 ; do

#for z in -1 0 1 2 3 5 10 ; do
#for z in 5 10 15 20 ; do
for z in 10 15 20 ; do

for batch_size in 10 20 30 40 100 ; do

#for n in [32,64,128,256,512,1024,2048,4096,8192,16384,32768]:
#for n in [32,64,128,256,512,1024,2048,4096,8192,16384]:
#for n in  32 64 128 256 512 1024 2048 4096 8192 16384 32768; do
#for n in  32 64 128 256 512 ; do
for n in  16 32 48 64 80 96 ; do

#for activation in relu sigmoid ; do
for activation in relu ; do

for test_size in 0.1 0.15 0.2 0.25 0.3 ; do
	
	#predict.py -i $i -z $z -n $n --batch_size ${batch_size} -g "case" -g control --activation $activation \
	#	--file /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv \
	#	--file /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz/Zscores.minimums.filtered.csv

	#predict.py -i $i -z $z -n $n --batch_size ${batch_size} --activation $activation \
	#	-g "PF Patient" -g "Endemic Control" -g "Non Endemic Control" \
	#	-f /francislab/data1/working/20241224-Illumina-PhIP/20250107-PhIP/out.all/Zscores.minimums.filtered.csv

	#echo predict.py -i $i -z $z -n $n --batch_size ${batch_size} --activation $activation \
	#	--test_size ${test_size} -g "Endemic" -g "NonEndemic" \
	#	-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate13.endemic/Zscores.select.minimums.csv \
	#	-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate14.endemic/Zscores.select.minimums.csv

	echo predict.py -i $i -z $z -n $n --batch_size ${batch_size} --activation $activation \
		--test_size ${test_size} -g "case" -g "control" \
		-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate1/Zscores.select.minimums.csv \
		-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate2/Zscores.select.minimums.csv

done ; done ; done ; done ; done ; done


#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash


#	./predict.bash > commands
#	commands_array_wrapper.bash --array_file commands --time 1-0 --threads 8 --mem 60G 




