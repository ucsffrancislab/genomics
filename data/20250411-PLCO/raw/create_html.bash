#!/usr/bin/env bash

#	slurm-607725.out 

cat << EOF
<html>
<head>
<script>
EOF

cat sorttable.js

cat << EOF
</script>
</head>
<body>
<table class='sortable'>
EOF

#	protein,case_or_control,text1,text2,text3,text4,text5,
#	Overall_max,Overall_mean,Overall_std,Overall_kurtosis,Overall_skewness,
#	Red_max,Red_mean,Red_std,Red_kurtosis,Red_skewness,
#	Green_max,Green_mean,Green_std,Green_kurtosis,Green_skewness,
#	Blue_max,Blue_mean,Blue_std,Blue_kurtosis,Blue_skewness,
#	pdf_file,color_png_file,bw_png

#	,mean20,median20,stdev20,mean30,median30,stdev30,mean40,median40,stdev40,mean50,median50,stdev50

echo "<tr>"
echo "<th>Protein</th><th>Case Control</th>"
echo "<th>Sample Name</th>"
echo "<th>Slide Number</th>"
#echo "<th>text3</th>"
#echo "<th>text4</th>"
#echo "<th>text5</th>"
echo "<th>Slide Position</th>"
#echo "<th>SAS Value</th>"
echo "<th>image</th>"

#echo "<th>Mean 20</th><th>Median 20</th><th>Stdev 20</th>"
#echo "<th>Mean 30</th><th>Median 30</th><th>Stdev 30</th>"
#echo "<th>Mean 40</th><th>Median 40</th><th>Stdev 40</th>"
#echo "<th>Mean 50</th><th>Median 50</th><th>Stdev 50</th>"

#	HSB === HSV
#for c in HSB HSI HSL HSV ; do
#for c in HSB HSI HSL ; do
#for i in 30 40 50 60 70 80 ; do
for c in HSI ; do
for i in 30 40 50 ; do
echo "<th>${c} Mean ${i}</th><th>${c} Median ${i}</th><th>${c} Stdev ${i}</th>"
done
done

#echo "<th>Overall max</th><th>Overall mean</th><th>Overall Std</th><th>Overall kurtosis</th><th>Overall skewness</th>"
#echo "<th>Red max</th><th>Red mean</th><th>Red Std</th><th>Red kurtosis</th><th>Red skewness</th>"
#echo "<th>Green max</th><th>Green mean</th><th>Green Std</th><th>Green kurtosis</th><th>Green skewness</th>"
#echo "<th>Blue max</th><th>Blue mean</th><th>Blue Std</th><th>Blue kurtosis</th><th>Blue skewness</th>"
echo "<th>pdf_file</th><th>color_png_file</th><th>bw_png</th>"
echo "</tr>"

#while read protein case_or_control text1 text2 text3 text4 text5 Overall_max Overall_mean Overall_std Overall_kurtosis Overall_skewness Red_max Red_mean Red_std Red_kurtosis Red_skewness Green_max Green_mean Green_std Green_kurtosis Green_skewness Blue_max Blue_mean Blue_std Blue_kurtosis Blue_skewness pdf_file color_png_file bw_png ; do

#while IFS=, read protein case_or_control text1 text2 text3 text4 text5 Overall_max Overall_mean Overall_std Overall_kurtosis Overall_skewness Red_max Red_mean Red_std Red_kurtosis Red_skewness Green_max Green_mean Green_std Green_kurtosis Green_skewness Blue_max Blue_mean Blue_std Blue_kurtosis Blue_skewness pdf_file color_png_file bw_png SAS_value ; do
#while IFS=, read protein case_or_control text1 text2 text3 text4 text5 mean20 median20 stdev20 mean30 median30 stdev30 mean40 median40 stdev40 mean50 median50 stdev50 pdf_file color_png_file bw_png SAS_value ; do
#while IFS=, read protein case_or_control text1 text2 text3 text4 text5 mean20 median20 stdev20 mean30 median30 stdev30 mean40 median40 stdev40 mean50 median50 stdev50 pdf_file color_png_file bw_png ; do

#while IFS=,  read protein case_or_control text1 text2 text3 text4 text5 HSBmean30 HSBmedian30 HSBstdev30 HSBmean40 HSBmedian40 HSBstdev40 HSBmean50 HSBmedian50 HSBstdev50 HSBmean60 HSBmedian60 HSBstdev60 HSBmean70 HSBmedian70 HSBstdev70 HSBmean80 HSBmedian80 HSBstdev80 HSImean30 HSImedian30 HSIstdev30 HSImean40 HSImedian40 HSIstdev40 HSImean50 HSImedian50 HSIstdev50 HSImean60 HSImedian60 HSIstdev60 HSImean70 HSImedian70 HSIstdev70 HSImean80 HSImedian80 HSIstdev80 HSLmean30 HSLmedian30 HSLstdev30 HSLmean40 HSLmedian40 HSLstdev40 HSLmean50 HSLmedian50 HSLstdev50 HSLmean60 HSLmedian60 HSLstdev60 HSLmean70 HSLmedian70 HSLstdev70 HSLmean80 HSLmedian80 HSLstdev80 HSVmean30 HSVmedian30 HSVstdev30 HSVmean40 HSVmedian40 HSVstdev40 HSVmean50 HSVmedian50 HSVstdev50 HSVmean60 HSVmedian60 HSVstdev60 HSVmean70 HSVmedian70 HSVstdev70 HSVmean80 HSVmedian80 HSVstdev80 pdf_file color_png_file bw_png ; do

while IFS=,  read protein case_or_control sample slide pos1 pos2 pos3 HSImean30 HSImedian30 HSIstdev30 HSImean40 HSImedian40 HSIstdev40 HSImean50 HSImedian50 HSIstdev50 pdf_file color_png_file bw_png ; do

echo "<tr>"
echo "<td>${protein}</td>"
echo "<td>${case_or_control}</td>"
echo "<td>${sample}</td>"
echo "<td>${slide}</td>"
#echo "<td>${text3}</td>"
#echo "<td>${text4}</td>"
#echo "<td>${text5}</td>"
echo "<td>${pos1}-${pos2}:${pos3}</td>"
#echo "<td>${SAS_value}</td>"
png=$( base64 out/${color_png_file} )
echo "<td><img src='data:image/png;base64,${png}' /></td>"

#echo "<td>${HSBmean30}</td><td>${HSBmedian30}</td><td>${HSBstdev30}</td>"
#echo "<td>${HSBmean40}</td><td>${HSBmedian40}</td><td>${HSBstdev40}</td>"
#echo "<td>${HSBmean50}</td><td>${HSBmedian50}</td><td>${HSBstdev50}</td>"
#echo "<td>${HSBmean60}</td><td>${HSBmedian60}</td><td>${HSBstdev60}</td>"
#echo "<td>${HSBmean70}</td><td>${HSBmedian70}</td><td>${HSBstdev70}</td>"
#echo "<td>${HSBmean80}</td><td>${HSBmedian80}</td><td>${HSBstdev80}</td>"

echo "<td>${HSImean30}</td><td>${HSImedian30}</td><td>${HSIstdev30}</td>"
echo "<td>${HSImean40}</td><td>${HSImedian40}</td><td>${HSIstdev40}</td>"
echo "<td>${HSImean50}</td><td>${HSImedian50}</td><td>${HSIstdev50}</td>"
#echo "<td>${HSImean60}</td><td>${HSImedian60}</td><td>${HSIstdev60}</td>"
#echo "<td>${HSImean70}</td><td>${HSImedian70}</td><td>${HSIstdev70}</td>"
#echo "<td>${HSImean80}</td><td>${HSImedian80}</td><td>${HSIstdev80}</td>"

#echo "<td>${HSLmean30}</td><td>${HSLmedian30}</td><td>${HSLstdev30}</td>"
#echo "<td>${HSLmean40}</td><td>${HSLmedian40}</td><td>${HSLstdev40}</td>"
#echo "<td>${HSLmean50}</td><td>${HSLmedian50}</td><td>${HSLstdev50}</td>"
#echo "<td>${HSLmean60}</td><td>${HSLmedian60}</td><td>${HSLstdev60}</td>"
#echo "<td>${HSLmean70}</td><td>${HSLmedian70}</td><td>${HSLstdev70}</td>"
#echo "<td>${HSLmean80}</td><td>${HSLmedian80}</td><td>${HSLstdev80}</td>"

#	HSV and HSB are the same
#echo "<td>${HSVmean30}</td><td>${HSVmedian30}</td><td>${HSVstdev30}</td>"
#echo "<td>${HSVmean40}</td><td>${HSVmedian40}</td><td>${HSVstdev40}</td>"
#echo "<td>${HSVmean50}</td><td>${HSVmedian50}</td><td>${HSVstdev50}</td>"
#echo "<td>${HSVmean60}</td><td>${HSVmedian60}</td><td>${HSVstdev60}</td>"
#echo "<td>${HSVmean70}</td><td>${HSVmedian70}</td><td>${HSVstdev70}</td>"
#echo "<td>${HSVmean80}</td><td>${HSVmedian80}</td><td>${HSVstdev80}</td>"


#echo "<td>${Overall_max}</td><td>${Overall_mean}</td><td>${Overall_std}</td><td>${Overall_kurtosis}</td><td>${Overall_skewness}</td>"
#echo "<td>${Red_max}</td><td>${Red_mean}</td><td>${Red_std}</td><td>${Red_kurtosis}</td><td>${Red_skewness}</td>"
#echo "<td>${Green_max}</td><td>${Green_mean}</td><td>${Green_std}</td><td>${Green_kurtosis}</td><td>${Green_skewness}</td>"
#echo "<td>${Blue_max}</td><td>${Blue_mean}</td><td>${Blue_std}</td><td>${Blue_kurtosis}</td><td>${Blue_skewness}</td>"
echo "<td>${pdf_file}</td><td>${color_png_file}</td><td>${bw_png}</td>"
echo "</tr>"
done < <( tail -n +2 $1 | head -5000 )	#| tr ',' '\t' )


cat << EOF
</table>
</body>
</html>
EOF

