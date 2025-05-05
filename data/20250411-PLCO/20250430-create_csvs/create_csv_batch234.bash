#!/usr/bin/env bash

#	create a csv by parsing pdf -> text files and analyzing image file

image_base_dir="/francislab/data1/raw/20250411-PLCO/out/cropped18"

echo -n "protein,case_or_control,text1,text2,text3,text4,text5"
#for cs in HSB HSI HSL HSV ; do
for cs in HSI ; do
for top in 30 40 50 ; do
#echo -n ",${mean},${median},${stdev}"
echo -n ",${cs}mean${top},${cs}median${top},${cs}stdev${top}"
done
done
echo ",pdf_file,color_png_file"
#	bw_png_file

#	All global variables except case/control
function print_sample {
	ci=$( printf "%03d" $i )
	i=$[i+1]
	#bi=$( printf "%03d" $i )
	i=$[i+1]
	echo -n "${protein},$1,${sample}"

#	for cs in HSB HSI HSL HSV ; do
	for cs in HSI ; do
	for top in 30 40 50 ; do
		out=$( convert ${image_base_dir}/${base}/${base}-${ci}-cropped.png -colorspace ${cs} -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -n ${top}  | datamash mean 1 median 1 sstdev 1 )
		mean=$( echo ${out} | cut -d' ' -f1 )
		median=$( echo ${out} | cut -d' ' -f2 )
		stdev=$( echo ${out} | cut -d' ' -f3 )
		echo -n ",${mean},${median},${stdev}"
	done
	done

	#echo ",${base}.pdf,${base}/${base}-${ci}-cropped.png"
	echo ",${base}.pdf,${base}-${ci}-cropped.png"
	#,${base}/${base}-${bi}-cropped.png"
}


for txt in /francislab/data1/raw/20250411-PLCO/out/batch[234]_spot_plots_human_IgG_0?.raw.txt ; do
	#echo $txt
	base=$( basename $txt .raw.txt )
	i=0	#	<- pdfimages image counter

	for case_line in $( grep -n "^Case" "${txt}" | cut -d: -f1 ) ; do
		protein=$( sed -n -e "$[case_line-1]s/ (.*)//p" "${txt}" | sed 's/[.\/ -]/_/g' )	#	some have spaces, dots, dashes or slashes
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


