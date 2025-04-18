#!/usr/bin/env bash


#	Python memory management is challenging so building multiple tensorflow models end up sticking around

# doing it this way makes python exit between models

for i in 1 2 3 ; do

	#for z in -1 0 1 2 3 5 10 ; do
	for z in 5 10 15 ; do
	 
		#for n in [32,64,128,256,512,1024,2048,4096,8192,16384,32768]:
		#for n in [32,64,128,256,512,1024,2048,4096,8192,16384]:
		for n in  64 128 256 512 1024 2048 4096 8192 ; do
	
			predict_pemphigus.py $i $z $n

		done
	done
done

echo "DONE"


#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict_pemphigus.bash



