#!/bin/sh

for file in *q; do
#	apparently, you don't actually need to ls, it is auto-globbed.
#for file in `ls -1 *q`; do

	echo $file
	base=${file%.*}		#	drop the extension
	name=${base#*/}	#	just in case given path
	echo $name

	mkdir $name
	cd $name
	ln -s ../$file
	cd ..

done
