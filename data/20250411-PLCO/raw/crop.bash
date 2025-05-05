#!/usr/bin/env bash


#	out/batch2_spot_plots_human_IgG_03/batch2_spot_plots_human_IgG_03-29426.png

#for img in $( find out/batch?_spot_plots_human_IgG_*/ -name \*.png ) ; do
for img in $( find out/batch?_spot_plots_human_IgG_*/ -name \*-*[0-9].png ) ; do

	#	widthxheight+left+top

	cropped_img=${img/out/out\/cropped18}
	mkdir -p $( dirname ${cropped_img} )

	echo $img
	#  -crop geometry       cut out a rectangular region of the image
	#convert ${img} -crop 16x16+17+19 ${img%%.png}-cropped.png
	#convert ${img} -crop 16x16+19+19 ${img%%.png}-cropped2.png
	convert ${img} -crop 18x18+18+18 ${cropped_img%%.png}-cropped.png

done

