#!/usr/bin/env bash


cat << EOF
<html>
<body>
<table>
EOF


i=0
while read a b c d e ; do
fi=$( printf "%03d" $i )
png=$( base64 out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}.png )
echo "<tr><td>$a</td><td>$b</td><td>$c</td><td>$d</td><td>$e</td><td><img src='data:image/png;base64,${png}' /></td>"
png=$( base64 out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}-16x16+17+19.png )
echo "<td><img src='data:image/png;base64,${png}' /></td>"
stats=$( identify -verbose out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}-16x16+17+19.png | grep -A 8 "Image statistics:" | sed 's/$/<br\/>/' )
echo "<td>${stats}</td>"
stats=$( identify -verbose out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}-16x16+17+19.png | grep -B 10 "Colormap entries" | sed 's/$/<br\/>/' )
echo "<td>${stats}</td>"
echo "</tr>"
i=$[i+2]
done < <( grep -h -B2 "^(" out/batch2_spot_plots_human_IgG_01.txt |grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' | head -100 )

cat << EOF
</table>
</body>
</html>
EOF

