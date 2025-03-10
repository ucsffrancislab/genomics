#!/usr/bin/env bash


#	Python memory management is challenging so building multiple tensorflow models end up sticking around

# doing it this way makes python exit between models



for i in 1 ; do

#for z in -1 0 1 2 3 5 10 ; do

for batch_size in 200 ; do

for n in 32 48 64 ; do

for activation in relu sigmoid ; do

for test_size in 0.15 0.2 0.25 ; do

for random_state in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do

for early_stop in 0 1 2 3 ; do

#for plates in '' '--plates 4' ; do
plates=''

cat select_species6.txt | while read species_and_range; do

	species=${species_and_range%:*} 
	range=${species_and_range#*:} 
	range1=${range%-*} 
	range2=${range#*-}

	echo predict.py -i $i -n $n --batch_size ${batch_size} --activation $activation \
		--species \"${species}\" --test_size ${test_size} -g "case" -g "control" \
		--range1 $[range1-1] --range2 ${range2} \
		${plates} --random_state ${random_state} --early_stop ${early_stop} \
		-f ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.x.csv 

done ; done ; done ; done ; done ; done ; done ; done
# ; done


#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash


#	./predict3.bash > commands
#	commands_array_wrapper.bash --array_file commands --time 1-0 --threads 2 --mem 15G 




