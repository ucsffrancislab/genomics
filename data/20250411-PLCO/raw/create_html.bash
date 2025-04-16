#!/usr/bin/env bash


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

echo "<tr>"
echo "<th>text1</th>"
echo "<th>text2</th>"
echo "<th>text3</th>"
echo "<th>text4</th>"
echo "<th>text5</th>"
echo "<th>image</th>"
echo "<th>Overall max</th><th>Overall kurtosis</th><th>Red max</th><th>Red kurtosis</th><th>Green max</th><th>Green kurtosis</th><th>Blue max</th><th>Blue kurtosis</th>"
echo "</tr>"

while read batch pdf_file color_png_file bw_png text1 text2 text3 text4 text5 Overall_max Overall_kurtosis Red_max Red_kurtosis Green_max Green_kurtosis Blue_max Blue_kurtosis ; do
echo "<tr>"
echo "<td>${text1}</td>"
echo "<td>${text2}</td>"
echo "<td>${text3}</td>"
echo "<td>${text4}</td>"
echo "<td>${text5}</td>"
png=$( base64 out/${color_png_file} )
echo "<td><img src='data:image/png;base64,${png}' /></td>"
echo "<td>${Overall_max}</td><td>${Overall_kurtosis}</td><td>${Red_max}</td><td>${Red_kurtosis}</td><td>${Green_max}</td><td>${Green_kurtosis}</td><td>${Blue_max}</td><td>${Blue_kurtosis}</td>"

echo "</tr>"
done < <( tail -n +2 slurm-606376.out | head -10000 | tr ',' '\t' )


cat << EOF
</table>
</body>
</html>
EOF

