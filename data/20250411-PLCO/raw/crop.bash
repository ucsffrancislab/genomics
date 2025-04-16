#!/usr/bin/env bash


for img in $( find out/batch?_spot_plots_human_IgG_0?/ -name \*.png ) ; do

	#	widthxheight+left+top

	echo $img
	convert ${img} -crop 16x16+17+19 ${img%%.png}-cropped.png

done

