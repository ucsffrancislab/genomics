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

echo "<tr>"
echo "<th>protein</th><th>case control</th>"
echo "<th>text1</th>"
echo "<th>text2</th>"
echo "<th>text3</th>"
echo "<th>text4</th>"
echo "<th>text5</th>"
echo "<th>SAS Value</th>"
echo "<th>image</th>"
echo "<th>Overall max</th><th>Overall mean</th><th>Overall Std</th><th>Overall kurtosis</th><th>Overall skewness</th>"
echo "<th>Red max</th><th>Red mean</th><th>Red Std</th><th>Red kurtosis</th><th>Red skewness</th>"
echo "<th>Green max</th><th>Green mean</th><th>Green Std</th><th>Green kurtosis</th><th>Green skewness</th>"
echo "<th>Blue max</th><th>Blue mean</th><th>Blue Std</th><th>Blue kurtosis</th><th>Blue skewness</th>"
echo "<th>pdf_file</th><th>color_png_file</th><th>bw_png</th>"
echo "</tr>"

#while read protein case_or_control text1 text2 text3 text4 text5 Overall_max Overall_mean Overall_std Overall_kurtosis Overall_skewness Red_max Red_mean Red_std Red_kurtosis Red_skewness Green_max Green_mean Green_std Green_kurtosis Green_skewness Blue_max Blue_mean Blue_std Blue_kurtosis Blue_skewness pdf_file color_png_file bw_png ; do

while IFS=, read protein case_or_control text1 text2 text3 text4 text5 Overall_max Overall_mean Overall_std Overall_kurtosis Overall_skewness Red_max Red_mean Red_std Red_kurtosis Red_skewness Green_max Green_mean Green_std Green_kurtosis Green_skewness Blue_max Blue_mean Blue_std Blue_kurtosis Blue_skewness pdf_file color_png_file bw_png SAS_value ; do

echo "<tr>"
echo "<td>${protein}</td>"
echo "<td>${case_or_control}</td>"
echo "<td>${text1}</td>"
echo "<td>${text2}</td>"
echo "<td>${text3}</td>"
echo "<td>${text4}</td>"
echo "<td>${text5}</td>"
echo "<td>${SAS_value}</td>"
png=$( base64 out/${color_png_file} )
echo "<td><img src='data:image/png;base64,${png}' /></td>"
echo "<td>${Overall_max}</td><td>${Overall_mean}</td><td>${Overall_std}</td><td>${Overall_kurtosis}</td><td>${Overall_skewness}</td>"
echo "<td>${Red_max}</td><td>${Red_mean}</td><td>${Red_std}</td><td>${Red_kurtosis}</td><td>${Red_skewness}</td>"
echo "<td>${Green_max}</td><td>${Green_mean}</td><td>${Green_std}</td><td>${Green_kurtosis}</td><td>${Green_skewness}</td>"
echo "<td>${Blue_max}</td><td>${Blue_mean}</td><td>${Blue_std}</td><td>${Blue_kurtosis}</td><td>${Blue_skewness}</td>"
echo "<td>${pdf_file}</td><td>${color_png_file}</td><td>${bw_png}</td>"
echo "</tr>"
done < <( tail -n +2 $1 | head -10000 )	#| tr ',' '\t' )


cat << EOF
</table>
</body>
</html>
EOF

