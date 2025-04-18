#!/usr/bin/env bash

#	create a csv by parsing pdf -> text files and analyzing image file


echo protein,case_or_control,text1,text2,text3,text4,text5,Overall_max,Overall_mean,Overall_std,Overall_kurtosis,Overall_skewness,Red_max,Red_mean,Red_std,Red_kurtosis,Red_skewness,Green_max,Green_mean,Green_std,Green_kurtosis,Green_skewness,Blue_max,Blue_mean,Blue_std,Blue_kurtosis,Blue_skewness,pdf_file,color_png_file,bw_png

#	All global variables except case/control
function print_sample {
	ci=$( printf "%03d" $i )
	i=$[i+1]
	bi=$( printf "%03d" $i )
	i=$[i+1]
	echo -n "${protein},$1,${sample}"

	id_out=$( identify -verbose out/${base}/${base}-${ci}-cropped.png )
	omax=$( echo "${id_out}" | grep -A 7 Overall | grep max | awk '{print $2}' )
	omean=$( echo "${id_out}" | grep -A 7 Overall | grep mean | awk '{print $2}' )
	ostd=$( echo "${id_out}" | grep -A 7 Overall | grep deviation | awk '{print $3}' )
	okurt=$( echo "${id_out}" | grep -A 7 Overall | grep kurtosis | awk '{print $2}' )
	oskew=$( echo "${id_out}" | grep -A 7 Overall | grep skewness | awk '{print $2}' )
	rmax=$( echo "${id_out}" | \grep -A 7 Red | grep max | awk '{print $2}' )
	rmean=$( echo "${id_out}" | \grep -A 7 Red | grep mean | awk '{print $2}' )
	rstd=$( echo "${id_out}" | \grep -A 7 Red | grep deviation | awk '{print $3}' )
	rkurt=$( echo "${id_out}" | \grep -A 7 Red | grep kurtosis | awk '{print $2}' )
	rskew=$( echo "${id_out}" | \grep -A 7 Red | grep skewness | awk '{print $2}' )
	gmax=$( echo "${id_out}" | \grep -A 7 Green | grep max | awk '{print $2}' )
	gmean=$( echo "${id_out}" | \grep -A 7 Green | grep mean | awk '{print $2}' )
	gstd=$( echo "${id_out}" | \grep -A 7 Green | grep deviation | awk '{print $3}' )
	gkurt=$( echo "${id_out}" | \grep -A 7 Green | grep kurtosis | awk '{print $2}' )
	gskew=$( echo "${id_out}" | \grep -A 7 Green | grep skewness | awk '{print $2}' )
	bmax=$( echo "${id_out}" | \grep -A 7 Blue | grep max | awk '{print $2}' )
	bmean=$( echo "${id_out}" | \grep -A 7 Blue | grep mean | awk '{print $2}' )
	bstd=$( echo "${id_out}" | \grep -A 7 Blue | grep deviation | awk '{print $3}' )
	bkurt=$( echo "${id_out}" | \grep -A 7 Blue | grep kurtosis | awk '{print $2}' )
	bskew=$( echo "${id_out}" | \grep -A 7 Blue | grep skewness | awk '{print $2}' )
	echo -n ",${omax},${omean},${ostd},${okurt},${oskew}"
	echo -n ",${rmax},${rmean},${rstd},${rkurt},${rskew}"
	echo -n ",${gmax},${gmean},${gstd},${gkurt},${gskew}"
	echo -n ",${bmax},${bmean},${bstd},${bkurt},${bskew}"
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


