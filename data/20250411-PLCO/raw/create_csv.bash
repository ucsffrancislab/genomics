#!/usr/bin/env bash

#	create a csv by parsing pdf -> text files and analyzing image file

#echo protein,case_or_control,text1,text2,text3,text4,text5,Overall_max,Overall_mean,Overall_std,Overall_kurtosis,Overall_skewness,Red_max,Red_mean,Red_std,Red_kurtosis,Red_skewness,Green_max,Green_mean,Green_std,Green_kurtosis,Green_skewness,Blue_max,Blue_mean,Blue_std,Blue_kurtosis,Blue_skewness,pdf_file,color_png_file,bw_png
#echo protein,case_or_control,text1,text2,text3,text4,text5,HSBmean30,HSBmedian30,HSBstdev30,HSBmean40,HSBmedian40,HSBstdev40,HSBmean50,HSBmedian50,HSBstdev50,HSBmean60,HSBmedian60,HSBstdev60,HSBmean70,HSBmedian70,HSBstdev70,HSBmean80,HSBmedian80,HSBstdev80,HSImean30,HSImedian30,HSIstdev30,HSImean40,HSImedian40,HSIstdev40,HSImean50,HSImedian50,HSIstdev50,HSImean60,HSImedian60,HSIstdev60,HSImean70,HSImedian70,HSIstdev70,HSImean80,HSImedian80,HSIstdev80,HSLmean30,HSLmedian30,HSLstdev30,HSLmean40,HSLmedian40,HSLstdev40,HSLmean50,HSLmedian50,HSLstdev50,HSLmean60,HSLmedian60,HSLstdev60,HSLmean70,HSLmedian70,HSLstdev70,HSLmean80,HSLmedian80,HSLstdev80,HSVmean30,HSVmedian30,HSVstdev30,HSVmean40,HSVmedian40,HSVstdev40,HSVmean50,HSVmedian50,HSVstdev50,HSVmean60,HSVmedian60,HSVstdev60,HSVmean70,HSVmedian70,HSVstdev70,HSVmean80,HSVmedian80,HSVstdev80,pdf_file,color_png_file,bw_png

echo -n "protein,case_or_control,text1,text2,text3,text4,text5"
#for cs in HSB HSI HSL HSV ; do
for cs in HSI ; do
for top in 30 40 50 ; do
#echo -n ",${mean},${median},${stdev}"
echo -n ",${cs}mean${top},${cs}median${top},${cs}stdev${top}"
done
done
echo ",pdf_file,color_png_file,bw_png"

#	All global variables except case/control
function print_sample {
	ci=$( printf "%03d" $i )
	i=$[i+1]
	bi=$( printf "%03d" $i )
	i=$[i+1]
	echo -n "${protein},$1,${sample}"

#	id_out=$( identify -verbose out/${base}/${base}-${ci}-cropped.png )
#	omax=$( echo "${id_out}" | grep -A 7 Overall | grep max | awk '{print $2}' )
#	omean=$( echo "${id_out}" | grep -A 7 Overall | grep mean | awk '{print $2}' )
#	ostd=$( echo "${id_out}" | grep -A 7 Overall | grep deviation | awk '{print $3}' )
#	okurt=$( echo "${id_out}" | grep -A 7 Overall | grep kurtosis | awk '{print $2}' )
#	oskew=$( echo "${id_out}" | grep -A 7 Overall | grep skewness | awk '{print $2}' )
#	rmax=$( echo "${id_out}" | \grep -A 7 Red | grep max | awk '{print $2}' )
#	rmean=$( echo "${id_out}" | \grep -A 7 Red | grep mean | awk '{print $2}' )
#	rstd=$( echo "${id_out}" | \grep -A 7 Red | grep deviation | awk '{print $3}' )
#	rkurt=$( echo "${id_out}" | \grep -A 7 Red | grep kurtosis | awk '{print $2}' )
#	rskew=$( echo "${id_out}" | \grep -A 7 Red | grep skewness | awk '{print $2}' )
#	gmax=$( echo "${id_out}" | \grep -A 7 Green | grep max | awk '{print $2}' )
#	gmean=$( echo "${id_out}" | \grep -A 7 Green | grep mean | awk '{print $2}' )
#	gstd=$( echo "${id_out}" | \grep -A 7 Green | grep deviation | awk '{print $3}' )
#	gkurt=$( echo "${id_out}" | \grep -A 7 Green | grep kurtosis | awk '{print $2}' )
#	gskew=$( echo "${id_out}" | \grep -A 7 Green | grep skewness | awk '{print $2}' )
#	bmax=$( echo "${id_out}" | \grep -A 7 Blue | grep max | awk '{print $2}' )
#	bmean=$( echo "${id_out}" | \grep -A 7 Blue | grep mean | awk '{print $2}' )
#	bstd=$( echo "${id_out}" | \grep -A 7 Blue | grep deviation | awk '{print $3}' )
#	bkurt=$( echo "${id_out}" | \grep -A 7 Blue | grep kurtosis | awk '{print $2}' )
#	bskew=$( echo "${id_out}" | \grep -A 7 Blue | grep skewness | awk '{print $2}' )
#	echo -n ",${omax},${omean},${ostd},${okurt},${oskew}"
#	echo -n ",${rmax},${rmean},${rstd},${rkurt},${rskew}"
#	echo -n ",${gmax},${gmean},${gstd},${gkurt},${gskew}"
#	echo -n ",${bmax},${bmean},${bstd},${bkurt},${bskew}"


#	for cs in HSB HSI HSL HSV ; do
#	for top in 30 40 50 60 70 80 ; do
	for cs in HSI ; do
	for top in 30 40 50 ; do
		out=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace ${cs} -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -n ${top}  | datamash mean 1 median 1 sstdev 1 )
		mean=$( echo ${out} | cut -d' ' -f1 )
		median=$( echo ${out} | cut -d' ' -f2 )
		stdev=$( echo ${out} | cut -d' ' -f3 )
		echo -n ",${mean},${median},${stdev}"
	done
	done

#	out80=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -50 | datamash mean 1 median 1 sstdev 1 )
#	out70=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -50 | datamash mean 1 median 1 sstdev 1 )
#	out60=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -50 | datamash mean 1 median 1 sstdev 1 )
#	out50=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -50 | datamash mean 1 median 1 sstdev 1 )
#	out40=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -40 | datamash mean 1 median 1 sstdev 1 )
#	out30=$( convert out/${base}/${base}-${ci}-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -30 | datamash mean 1 median 1 sstdev 1 )
#	mean80=$( echo ${out80} | cut -d' ' -f1 )
#	median80=$( echo ${out80} | cut -d' ' -f2 )
#	stdev80=$( echo ${out80} | cut -d' ' -f3 )
#	mean70=$( echo ${out70} | cut -d' ' -f1 )
#	median70=$( echo ${out70} | cut -d' ' -f2 )
#	stdev70=$( echo ${out70} | cut -d' ' -f3 )
#	mean60=$( echo ${out60} | cut -d' ' -f1 )
#	median60=$( echo ${out60} | cut -d' ' -f2 )
#	stdev60=$( echo ${out60} | cut -d' ' -f3 )
#	mean50=$( echo ${out50} | cut -d' ' -f1 )
#	median50=$( echo ${out50} | cut -d' ' -f2 )
#	stdev50=$( echo ${out50} | cut -d' ' -f3 )
#	mean40=$( echo ${out40} | cut -d' ' -f1 )
#	median40=$( echo ${out40} | cut -d' ' -f2 )
#	stdev40=$( echo ${out40} | cut -d' ' -f3 )
#	mean30=$( echo ${out30} | cut -d' ' -f1 )
#	median30=$( echo ${out30} | cut -d' ' -f2 )
#	stdev30=$( echo ${out30} | cut -d' ' -f3 )
#	echo -n ",${mean30},${median30},${stdev30}"
#	echo -n ",${mean40},${median40},${stdev40}"
#	echo -n ",${mean50},${median50},${stdev50}"
#	echo -n ",${mean60},${median60},${stdev60}"
#	echo -n ",${mean70},${median70},${stdev70}"
#	echo -n ",${mean80},${median80},${stdev80}"
	echo ",${base}.pdf,${base}/${base}-${ci}-cropped.png,${base}/${base}-${bi}-cropped.png"
}


for txt in out/batch?_spot_plots_human_IgG_0?.raw.txt ; do
	#echo $txt
	base=$( basename $txt .raw.txt )
	i=0	#	<- pdfimages image counter

	for case_line in $( grep -n "^Case" "${txt}" | cut -d: -f1 ) ; do
		protein=$( sed -n -e "$[case_line-1]s/ (.*)//p" "${txt}" | sed 's/ /_/g' )	#	some have spaces
		control_line=$( tail -n +${case_line} "${txt}" | grep -m 1 -n "^Control" | cut -d: -f1 )

		for sample in $( sed -n "$[case_line+1],$[case_line+control_line-2]p" ${txt} | grep -h -B2 "^(" | grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' -e 's/\t/,/g' ) ; do
			print_sample "case"
		done

		stop_line=$( tail -n +$[case_line+1] "${txt}" | tail -n +${control_line} | grep -m 1 -n "^Case" | cut -d: -f1 )
		if [ -z "${stop_line}" ] ; then
			#	last set of the file
			stop_line=$( tail -n +$[case_line+1] "${txt}" | tail -n +${control_line} | wc -l )
			stop_line=$[stop_line+1]
		fi

		for sample in $( sed -n "$[case_line+control_line],$[case_line+control_line-2+stop_line]p" ${txt} | grep -h -B2 "^(" | grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' -e 's/\t/,/g' ) ; do
			print_sample "control"
		done

	done

done


