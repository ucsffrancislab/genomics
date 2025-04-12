
#	20250411-PLCO


```
wget --recursive "ftps://ftp.box.com/Francis _Lab_Share/PLCO"
```

```
cd "ftp.box.com/Francis _Lab_Share/PLCO/PLCO NAPPA spot plots/Batch 3/"
mkdir pdfs
for f in ../spot_plots_Human\ IgG_0* ; do ln -s "$f" ;done
```

```
mkdir pdfs
cd pdfs
for i in 2 3 4 ; do
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ ${i}/*/*pdf  ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//Human/human}
ln -s "$pdf" "batch${i}_${l}"
done
done
cd ..
```


```
mkdir out
for pdf in pdfs/*pdf ; do
echo $pdf
b=$( basename ${pdf} .pdf )
mkdir out/${b}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=pdftoimages --wrap="pdfimages -png ${pdf} out/${b}/${b}"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=pdftotext --wrap="pdftotext ${pdf} out/${b}.txt"
done
```


```
find out/ -name \*png | wc -l
1155216
```

```
echo $[1155216/2]
577608
```

```
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | wc -l
577608
```

`pdfimages` uses a minimum of 3 digits with leading zeroes. No control.
So it is 000-999, 1000-9999, 10000-99999, etc.



Create csv

```
text, batch, pdf path, color png path, b&w png path
IN531	151204010	(1:52-21), 2, pdfs/batch2_spot_plots_human_IgG_01.pdf, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-000.png, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-001.png
IN531	151204010	(1:52-6), 2, pdfs/batch2_spot_plots_human_IgG_01.pdf, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-002.png, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-003.png
IN531	151204010	(1:52-7), 2, pdfs/batch2_spot_plots_human_IgG_01.pdf, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-004.png, out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-005.png

```




identify -verbose out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-037.png


```
cat << EOF > test.html
<html>
<body>
<table>
EOF
```
echo "<tr><td>$a</td><td>$b</td><td>$c</td><td><img src='out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}.png'/></td></tr>"

```
i=0
while read a b c d e ; do
fi=$( printf "%03d" $i )
png=$( base64 out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}.png )
echo "<tr><td>$a</td><td>$b</td><td>$c</td><td>$d</td><td>$e</td><td><img src='data:image/png;base64,${png}' /></td>"
stats=$( identify -verbose out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-${fi}.png | grep -A 8 "Image statistics:" )
echo "<td>${stats}</td></tr>"
i=$[i+2]
done < <( grep -h -B2 "^(" out/batch2_spot_plots_human_IgG_01.txt |grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' | head -100 ) >> test.html


```

```
cat << EOF >> test.html
</table>
</body>
</html>
EOF
```



grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' | head

