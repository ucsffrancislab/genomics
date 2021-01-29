#!/usr/bin/env bash


#for f in $( find /francislab/data1/ -type l ) ; do
while read f ; do
	link=$( readlink -m "$f" )
	if [[ ${link} == "/home/gwendt/github/ucsffrancislab/genomics"* ]] ; then
		#echo $f
		#echo $link
		echo chmod +w $( dirname "${f}" )
		echo rm -f "${f}"
		echo ln -s "/c4${link}" "${f}"
	fi
#done
#done < <( find /francislab/data1/refs/ -type l )
done < <( find -L /francislab/data1/ -type l )

#	using the while loop seems to work better than the for loop
#	I think that the for loop won't execute the first iteration until the find command completes.


#	Find dead links with ...
#		find . -xtype l
#			OR
#		find -L . -type l

