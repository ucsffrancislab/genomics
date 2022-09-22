#!/usr/bin/env bash


#	add the trailing .tsv so that it exclusivly selects the correct sample

#mkdir -p sample_selection/
#if [ ! -f sample_selection/Primary ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Primary" ){print $2".tsv"}' > sample_selection/Primary
#	shuf --head-count 14 sample_selection/Primary > sample_selection/Primary.14a
#	shuf --head-count 14 sample_selection/Primary > sample_selection/Primary.14b
#	shuf --head-count 14 sample_selection/Primary > sample_selection/Primary.14c
#fi
#if [ ! -f sample_selection/Recurrent ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "Recurrent" ){print $2".tsv"}' > sample_selection/Recurrent
#	shuf --head-count 14 sample_selection/Recurrent > sample_selection/Recurrent.14a
#	shuf --head-count 14 sample_selection/Recurrent > sample_selection/Recurrent.14b
#	shuf --head-count 14 sample_selection/Recurrent > sample_selection/Recurrent.14c
#fi
#if [ ! -f sample_selection/control ] ; then
#	cat 11/create_matrix.tsv | awk -F"\t" '( $3 == "control" ){print $2".tsv"}' > sample_selection/Control
#	shuf --head-count 14 sample_selection/Control > sample_selection/Control.14a
#	shuf --head-count 14 sample_selection/Control > sample_selection/Control.14b
#	shuf --head-count 14 sample_selection/Control > sample_selection/Control.14c
#fi
#
#cat sample_selection/*.14a > sample_selection/14a
#cat sample_selection/*.14b > sample_selection/14b
#cat sample_selection/*.14c > sample_selection/14c

ln -s ../20220915-iMOKA/sample_selection



for k in 11 16 21 31 ; do

	for s in 14a 14b 14c ; do

		#	not sure why I needed "uniq"

		mkdir -p PrimaryRecurrent/${k}/${s}
		ln -s ../../../${k}/preprocess PrimaryRecurrent/${k}/${s}/preprocess
		cat ${k}/create_matrix.tsv | \grep -E "Primary|Recurrent" | grep -f sample_selection/${s} | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrent/${k}/${s}/create_matrix.tsv

		mkdir -p PrimaryRecurrentControl/${k}/${s}
		ln -s ../../../${k}/preprocess PrimaryRecurrentControl/${k}/${s}/preprocess
		cat ${k}/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | grep -f sample_selection/${s} | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' | sort | uniq > PrimaryRecurrentControl/${k}/${s}/create_matrix.tsv

		mkdir -p TumorControl/${k}/${s}
		ln -s ../../../${k}/preprocess TumorControl/${k}/${s}/preprocess
		cat ${k}/create_matrix.tsv | \grep -E "Primary|Recurrent|control" | grep -f sample_selection/${s} | sed -E 's/Primary|Recurrent/tumor/' | awk -F"\t" '(system("test -f " $1".sorted.bin")==0)' > TumorControl/${k}/${s}/create_matrix.tsv

	done

done


