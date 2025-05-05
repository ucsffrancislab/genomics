#!/usr/bin/env bash

#	create a csv by parsing pdf -> text files and analyzing image file

full_image_base_dir="/francislab/data1/raw/20250411-PLCO/out"
cropped_image_base_dir="/francislab/data1/raw/20250411-PLCO/out/cropped18"


echo -n "protein,case_or_control,sample,slide,pos1,pos2,pos3"
#for cs in HSB HSI HSL HSV ; do
for cs in HSI ; do
for top in 30 40 50 ; do
#echo -n ",${mean},${median},${stdev}"
echo -n ",${cs}mean${top},${cs}median${top},${cs}stdev${top}"
done
done
echo ",pdf_file,color_png_file"
#,bw_png"

#	All global variables except case/control
function print_sample {
	ci=$( printf "%03d" $i )
	i=$[i+1]

#	check that image is Color
#	identify -verbose out/batch4_spot_plots_human_IgG_01/batch4_spot_plots_human_IgG_01-000.png | grep "  Type: "
#  Type: TrueColor (cropped images are "Palette" ???
#	identify -verbose out/batch4_spot_plots_human_IgG_01/batch4_spot_plots_human_IgG_01-001.png | grep "  Type: "
#  Type: Grayscale

#for f in out/cropped18/batch1_spot_plots_human_IgG_07/batch1_spot_plots_human_IgG_07-4????-cropped.png ; do identify -verbose ${f} | grep "  Type: " | sed 's/  Type: //' ; done | sort | uniq -c
#     12 Bilevel
#   5029 Grayscale
#   4959 Palette
# even thats not right. some of the grayscales are bilevel

# the crops are too small. get the type of the uncropped image


	colortype=$( identify -verbose ${full_image_base_dir}/${base}/${base}-${ci}.png | grep "  Type: " | sed 's/  Type: //' )

	#if [ "${colortype}" == "Palette" -o "${colortype}" == "Bilevel" ] ; then
	if [ "${colortype}" == "TrueColor" ] ; then
		echo -n "${protein},$1,${sample}"

		for cs in HSI ; do
		for top in 30 40 50 ; do
			out=$( convert ${cropped_image_base_dir}/${base}/${base}-${ci}-cropped.png -colorspace ${cs} -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -n ${top}  | datamash mean 1 median 1 sstdev 1 )
			mean=$( echo ${out} | cut -d' ' -f1 )
			median=$( echo ${out} | cut -d' ' -f2 )
			stdev=$( echo ${out} | cut -d' ' -f3 )
			echo -n ",${mean},${median},${stdev}"
		done
		done

		#echo ",${base}.pdf,${base}/${base}-${ci}-cropped.png"
		echo ",${base}.pdf,${base}-${ci}-cropped.png"
		#,${base}/${base}-${bi}-cropped.png"
	fi
}


for txt in /francislab/data1/raw/20250411-PLCO/out/batch[1]_spot_plots_human_IgG_*raw.txt ; do
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


