#!/usr/bin/env bash


#	Python memory management is challenging so building multiple tensorflow models end up sticking around

# doing it this way makes python exit between models

for i in 1 2 3 4 5 ; do

#for z in -1 0 1 2 3 5 10 ; do
#for z in 5 10 15 20 ; do
#for z in 10 15 20 ; do

#for batch_size in 40 100 200 ; do
for batch_size in 200 ; do

#for n in [32,64,128,256,512,1024,2048,4096,8192,16384,32768]:
#for n in [32,64,128,256,512,1024,2048,4096,8192,16384]:
#for n in  32 64 128 256 512 1024 2048 4096 8192 16384 32768; do
#for n in  32 64 128 256 512 ; do
#for n in  16 32 48 64 80 96 128 256 512 1024 ; do
#for n in 64 80 96 128 256 512 1024 ; do
#for n in 1024 2048 4096 8192 ; do
#for n in 16384 32768 ; do
#for n in 64 80 96 128 256 512 1024 2048 4096 8192 16384 32768 ; do
for n in 256 512 1024 2048 ; do

for activation in relu sigmoid ; do
#for activation in relu ; do

#for test_size in 0.1 0.15 0.2 0.25 0.3 ; do
for test_size in 0.2 0.25 0.3 ; do

for random_state in 1 2 3 4 5 ; do

for plates in '' '--plates 4' ; do

cat select_species2.txt | while read species; do

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

	#predict.py -i $i -z $z -n $n --batch_size ${batch_size} --activation $activation \

	predict.py -i $i -n $n --batch_size ${batch_size} --activation $activation \
		--species "${species}" --test_size ${test_size} -g "case" -g "control" \
		${plates} --random_state ${random_state} \
		-f ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.x.csv 

#hc 20250226/Counts.normalized.subtracted.trim.plus.mins.csv 
#subject,group,plate,type,1,10,100,1000,10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,1
#3056,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3108,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.60825873023148
#3209,control,2,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3211,control,4,glioma serum,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,
#3275,control,3,glioma serum,0.0,0.0,0.0,0.0,0.0,0.2480143352285762,0.0,0.0,0.0,0.0,0.269037062545736

#		-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate2/Zscores.select.minimums.csv
#		-f /francislab/data1/working/20241224-Illumina-PhIP/20250110-PhIP/out.plate1/Zscores.select.minimums.csv \
#done

done ; done ; done ; done ; done ; done ; done ; done


#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash


#	./predict.bash > commands
#	commands_array_wrapper.bash --array_file commands --time 1-0 --threads 8 --mem 60G 




