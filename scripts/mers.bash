#!/usr/bin/env bash

#k=$1
#m=$2
#
#function mers(){
#	k=$1
#	m=$2
#
#	if [ $k -gt 0 ] ; then
#		mers $[k-1] A$m
#		mers $[k-1] C$m
#		mers $[k-1] G$m
#		mers $[k-1] T$m
#	else
#		echo $m
#	fi
#}
#
#mers $1 $2


k=$1
m=$2
if [ $k -gt 0 ] ; then
	$0 $[k-1] A$m 
	$0 $[k-1] C$m
	$0 $[k-1] G$m
	$0 $[k-1] T$m
else 
	echo $m
fi


