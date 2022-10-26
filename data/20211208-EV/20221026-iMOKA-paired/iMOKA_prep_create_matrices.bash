#!/usr/bin/env bash


for k in 11 16 21 31 ; do

		#	not sure why I needed "uniq"

		mkdir -p out/HAvL/${k}
		ln -s ../../${k}/preprocess out/HAvL/${k}/preprocess
		cat out/${k}/create_matrix.tsv | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > out/HAvL/${k}/create_matrix.tsv

		mkdir -p out/HLvA/${k}
		ln -s ../../${k}/preprocess out/HLvA/${k}/preprocess
		cat out/${k}/create_matrix.tsv | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > out/HLvA/${k}/create_matrix.tsv

done


