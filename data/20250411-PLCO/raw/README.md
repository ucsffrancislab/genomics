
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
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=pdftotext --wrap="pdftotext -raw -nopgbrk ${pdf} out/${b}.raw.txt"
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


Create a limited html file to look at things
```
create_html.bash
```


```
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | sed -e 's/[)(]//g' -e 's/[-:]/\t/g' | head
```

Looks like 492 subjects each with 1174 datapoints.
```
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq -c
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq -c | wc -l
492
```



##	20250414


```
find out/ -name \*png | wc -l
1155216
```


Some pdfs are multi-page, multi-protein, with multiple Case and Control chunks.
Sadly, Control is the last item on each line?

widthxheight+left+top

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=crop --wrap="${PWD}/crop.bash"
```


Hmmm? Expecting 1155216
```
find out/ -name \*-cropped.png | wc -l
1195925
```


More pngs than expected. Gonna try to figure out why.
```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 3-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=find --wrap="find out/batch?_spot_plots_human_IgG_0?/ -name \*.png" --output=find_all_pngs


wc -l find_all_pngs 
2391850 find_all_pngs
```

```
had some strays

find out/batch?_spot_plots_human_IgG_0?/ -name \*16x16+17+19\*.png -exec rm {} \;

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 3-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=find --wrap="find out/batch?_spot_plots_human_IgG_0?/ -name \*.png" --output=find_all_pngs2


wc -l find_all_pngs2 
2310432 find_all_pngs2

cat find_all_pngs2.sorted | paste - - | wc -l
1155216
```
Perfect



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 3-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv --wrap="${PWD}/create_csv.bash"
```





##	20250416


```
-nopgbrk gets rid of the Control-L

-raw seems to keep the titles, Cases and Controls in the correct order

pdftotext -raw -nopgbrk pdfs/batch2_spot_plots_human_IgG_02.pdf
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv3 --wrap="${PWD}/create_csv3.bash"
```

should be 577608 samples


