#!/usr/bin/env bash



echo batch,pdf_file,color_png_file,bw_png,text1,text2,text3,text4,text5,Overall_max,Overall_kurtosis,Red_max,Red_kurtosis,Green_max,Green_kurtosis,Blue_max,Blue_kurtosis

for txt in out/batch?_spot_plots_human_IgG_0?.txt ; do
	#echo $txt
	base=$( basename $txt .txt )
	batch=${base%_spot*}
	batch=${batch#batch}
	i=0
	while read a b c d e ; do
		ci=$( printf "%03d" $i )
		i=$[i+1]
		bi=$( printf "%03d" $i )
		i=$[i+1]
		echo -n "${batch},${base}.pdf,${base}/${base}-${ci}-cropped.png,${base}/${base}-${bi}-cropped.png,"
		id_out=$( identify -verbose out/${base}/${base}-${ci}-cropped.png )
		om=$( echo "${id_out}" | grep -A 7 Overall | grep max | awk '{print $2}' )
		ok=$( echo "${id_out}" | grep -A 7 Overall | grep kurtosis | awk '{print $2}' )
		rm=$( echo "${id_out}" | \grep -A 7 Red | grep max | awk '{print $2}' )
		rk=$( echo "${id_out}" | \grep -A 7 Red | grep kurtosis | awk '{print $2}' )
		gm=$( echo "${id_out}" | \grep -A 7 Green | grep max | awk '{print $2}' )
		gk=$( echo "${id_out}" | \grep -A 7 Green | grep kurtosis | awk '{print $2}' )
		bm=$( echo "${id_out}" | \grep -A 7 Blue | grep max | awk '{print $2}' )
		bk=$( echo "${id_out}" | \grep -A 7 Blue | grep kurtosis | awk '{print $2}' )
		echo "${a},${b},${c},${d},${e},${om},${ok},${rm},${rk},${gm},${gk},${bm},${bk}"
	done < <( grep -h -B2 "^(" ${txt} |grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' )
done


#	Add skewness, standard deviation and mean next time? Run takes about 12 hours.




#	
#	High kurtosis indicates a distribution with a sharp peak and heavy tails, meaning more data points are concentrated near the mean and fewer are in the extremes, while low kurtosis suggests a flatter peak and lighter tails
#	
#	Depending on the degree, distributions have three types of kurtosis:
#	
#	Mesokurtic distribution (kurtosis = 3, excess kurtosis = 0): perfect normal distribution or very close to it.
#	Leptokurtic distribution (kurtosis > 3, excess kurtosis > 0): sharp peak, heavy tails
#	Platykurtic distribution (kurtosis < 3, excess kurtosis < 0): flat peak, light tails
#	
#		Not sure if ImageMagick returns Kurtosis or Excess Kurtosis
#		it never says "excess kurtosis" so assuming just kurtosis
#		the values do go negative. not sure if that means anything


#	According to this convo, it is "-3" so "excess kurtosis"
#	https://imagemagick.org/discourse-server/viewtopic.php?t=25038



