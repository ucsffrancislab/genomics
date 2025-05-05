#!/usr/bin/env bash

#	slurm-607725.out 

cat << EOF
<html>
<head>
<script>
EOF

cat /francislab/data1/raw/20250411-PLCO/sorttable.js

cat << EOF
</script>
</head>
<body>
<table class='sortable'>
EOF


echo "<tr>"
echo "<th>Protein</th><th>Case Control</th>"
echo "<th>Sample Name</th>"
echo "<th>Slide Number</th>"
echo "<th>Slide Position</th>"
#echo "<th>SAS Value</th>"
echo "<th>image</th>"

for c in HSI ; do
for i in 30 40 50 ; do
echo "<th>${c} Mean ${i}</th><th>${c} Median ${i}</th><th>${c} Stdev ${i}</th>"
done
done

echo "<th>pdf_file</th><th>color_png_file</th>"
echo "</tr>"

#while IFS=,  read protein case_or_control sample slide pos1 pos2 pos3 HSImean30 HSImedian30 HSIstdev30 HSImean40 HSImedian40 HSIstdev40 HSImean50 HSImedian50 HSIstdev50 pdf_file color_png_file SAS_value; do

while IFS=,  read protein case_or_control sample slide pos1 pos2 pos3 HSImean30 HSImedian30 HSIstdev30 HSImean40 HSImedian40 HSIstdev40 HSImean50 HSImedian50 HSIstdev50 pdf_file color_png_file ; do

echo "<tr>"
echo "<td>${protein}</td>"
echo "<td>${case_or_control}</td>"
echo "<td>${sample}</td>"
echo "<td>${slide}</td>"
echo "<td>${pos1}-${pos2}:${pos3}</td>"
#echo "<td>${SAS_value}</td>"
png=$( base64 /francislab/data1/raw/20250411-PLCO/out/${color_png_file%%-*}/${color_png_file} )
echo "<td><img src='data:image/png;base64,${png}' /></td>"

echo "<td>${HSImean30}</td><td>${HSImedian30}</td><td>${HSIstdev30}</td>"
echo "<td>${HSImean40}</td><td>${HSImedian40}</td><td>${HSIstdev40}</td>"
echo "<td>${HSImean50}</td><td>${HSImedian50}</td><td>${HSIstdev50}</td>"

echo "<td>${pdf_file}</td><td>${color_png_file}</td>"
echo "</tr>"
done < <( tail -n +2 $1 | head -1000 )


cat << EOF
</table>
</body>
</html>
EOF

