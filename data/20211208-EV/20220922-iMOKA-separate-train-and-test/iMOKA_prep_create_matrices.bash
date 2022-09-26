#!/usr/bin/env bash


#	add the trailing .tsv so that it exclusivly selects the correct sample

mkdir -p sample_selection/


if [ ! -f sample_selection/High ] ; then
	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "High" ){print $2".tsv"}' > sample_selection/High
	count=$( cat sample_selection/High | wc -l )
	count=$((count-1))
	shuf --head-count ${count} sample_selection/High > sample_selection/High.a
	shuf --head-count ${count} sample_selection/High > sample_selection/High.b
	shuf --head-count ${count} sample_selection/High > sample_selection/High.c
fi
if [ ! -f sample_selection/Low ] ; then
	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Low" ){print $2".tsv"}' > sample_selection/Low
	count=$( cat sample_selection/Low | wc -l )
	count=$((count-1))
	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.a
	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.b
	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.c
fi
if [ ! -f sample_selection/Adenocarcinoma ] ; then
	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Adenocarcinoma" ){print $2".tsv"}' > sample_selection/Adenocarcinoma
	count=$( cat sample_selection/Adenocarcinoma | wc -l )
	count=$((count-1))
	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.a
	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.b
	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.c
fi
cat sample_selection/*.a > sample_selection/a
cat sample_selection/*.b > sample_selection/b
cat sample_selection/*.c > sample_selection/c








#if [ ! -f sample_selection/HighLow ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 ~ /High|Low/ ){print $2".tsv"}' > sample_selection/HighLow
#	count=$( cat sample_selection/HighLow | wc -l )
#	count=$((count-1))
#	shuf --head-count ${count} sample_selection/HighLow > sample_selection/HighLow.a
#	shuf --head-count ${count} sample_selection/HighLow > sample_selection/HighLow.b
#	shuf --head-count ${count} sample_selection/HighLow > sample_selection/HighLow.c
#fi
#if [ ! -f sample_selection/HighAdeno ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 ~ /High|Adenocarcinoma/ ){print $2".tsv"}' > sample_selection/HighAdeno
#	count=$( cat sample_selection/HighAdeno | wc -l )
#	count=$((count-1))
#	shuf --head-count ${count} sample_selection/HighAdeno > sample_selection/HighAdeno.a
#	shuf --head-count ${count} sample_selection/HighAdeno > sample_selection/HighAdeno.b
#	shuf --head-count ${count} sample_selection/HighAdeno > sample_selection/HighAdeno.c
#fi
#
#if [ ! -f sample_selection/Low ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Low" ){print $2".tsv"}' > sample_selection/Low
#	count=$( cat sample_selection/Low | wc -l )
#	count=$((count-1))
#	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.a
#	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.b
#	shuf --head-count ${count} sample_selection/Low > sample_selection/Low.c
#fi
#if [ ! -f sample_selection/Adenocarcinoma ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Adenocarcinoma" ){print $2".tsv"}' > sample_selection/Adenocarcinoma
#	count=$( cat sample_selection/Adenocarcinoma | wc -l )
#	count=$((count-1))
#	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.a
#	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.b
#	shuf --head-count ${count} sample_selection/Adenocarcinoma > sample_selection/Adenocarcinoma.c
#fi
#cat sample_selection/{HighLow,Adenocarcinoma}.a > sample_selection/HLvA.a
#cat sample_selection/{HighLow,Adenocarcinoma}.b > sample_selection/HLvA.b
#cat sample_selection/{HighLow,Adenocarcinoma}.c > sample_selection/HLvA.c
#cat sample_selection/{HighAdeno,Low}.a > sample_selection/HAvL.a
#cat sample_selection/{HighAdeno,Low}.b > sample_selection/HAvL.b
#cat sample_selection/{HighAdeno,Low}.c > sample_selection/HAvL.c



for k in 11 16 21 26 31 ; do

	for s in a b c ; do

		mkdir -p HAvL/${k}/${s}
		ln -s ../../../${k}/preprocess HAvL/${k}/${s}/preprocess
		#cat ${k}/create_matrix.tsv | grep -f sample_selection/HAvL.${s} | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/${k}/${s}/create_matrix.tsv
		cat ${k}/create_matrix.tsv | grep -f sample_selection/${s} | sed -E 's/High|Adenocarcinoma/HighAdeno/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HAvL/${k}/${s}/create_matrix.tsv

		mkdir -p HLvA/${k}/${s}
		ln -s ../../../${k}/preprocess HLvA/${k}/${s}/preprocess
		#cat ${k}/create_matrix.tsv | grep -f sample_selection/HLvA.${s} | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/${k}/${s}/create_matrix.tsv
		cat ${k}/create_matrix.tsv | grep -f sample_selection/${s} | sed -E 's/High|Low/HighLow/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > HLvA/${k}/${s}/create_matrix.tsv

	done

done


