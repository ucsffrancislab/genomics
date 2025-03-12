#!/usr/bin/env bash


#	Python memory management is challenging so building multiple tensorflow models end up sticking around

# doing it this way makes python exit between models



for i in 1 ; do

#for z in -1 0 1 2 3 5 10 ; do

for batch_size in 200 ; do

for n in 64 128; do

for activation in relu sigmoid ; do

for test_size in 0.15 0.2 0.25 ; do

for random_state in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do

for early_stop in 0 1 2 3 ; do

for epochs in 75 100 150 200 ; do

#for plates in '' '--plates 4' ; do
plates=''

#cat select_species7.txt | while read species_and_protein ; do

#	species=${species_and_protein%,*}
#	protein=${species_and_protein#*,}

	echo predict.py -i $i -n $n --batch_size ${batch_size} --activation $activation \
		--test_size ${test_size} -g "case" -g "control" --epochs ${epochs} \
		--species \"Human herpesvirus 8\" --protein \"ORF 73\" --protein Orf73 --protein ORF73 --protein \"Protein ORF73\" \
		${plates} --random_state ${random_state} --early_stop ${early_stop} \
		-f ${PWD}/20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv 

#	predict.py -i 1 -n 64 --batch_size 200 --activation relu --test_size 0.2 -g case -g control --species "Human herpesvirus 8" --protein "ORF 73" --protein Orf73 --protein ORF73 --protein "Protein ORF73" --random_state 42 --early_stop 0 -f /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250226/Counts.normalized.subtracted.trim.plus.mins.xy.csv


done ; done ; done ; done ; done ; done ; done ; done
# ; done
# ; done


#	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=predict --time=14-0 --nodes=1 --ntasks=16 --mem=120GB --output=${PWD}/predict.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log ./predict.bash


#	./predict3.bash > commands
#	commands_array_wrapper.bash --array_file commands --time 1-0 --threads 2 --mem 15G 




