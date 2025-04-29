
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
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 3-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv --wrap="${PWD}/create_csv_batch234.bash"
```





##	20250416


```
-nopgbrk gets rid of the Control-L

-raw seems to keep the titles, Cases and Controls in the correct order

pdftotext -raw -nopgbrk pdfs/batch2_spot_plots_human_IgG_02.pdf
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv3 --wrap="${PWD}/create_csv_batch234.bash"
```

should be 577608 samples




```
find out/batch?_spot_plots_human_IgG_0?/ -name \*cropped.png | tar cf - -T -  | gzip > cropped_images.tar.gz
chmod -w cropped_images.tar.gz
box_upload.bash cropped_images.tar.gz
```



##	20250417

```
wget --recursive "ftps://ftp.box.com/Ring_stats_updated_2017/"

wget --recursive "ftps://ftp.box.com/Signal_stats_updated_2016/"
```

```
for f in ftp.box.com/*_stats_updated*/*sas7bdat ; do
python3 -c "import pandas as pd;df=pd.read_sas(\""${f}"\", encoding='utf-8').to_csv(\""${f%.sas7bdat}.csv"\",index=False)"
done
```


Difference between Ring stats and Signal stats?

ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.sas7bdat columns
```
['IDNO', 'Batch', 'TGF_beta', 'IL13', 'TNF_a', 'Total_IgE', 'Total_IgE_cutoff', 'Phadiatop', 'Phadiatop_cutoff', 'lnphadiatop', 'lnil13', 'lntgf_beta', 'lntnf_a', 'lnige_quart', 'lnphadiatop_quart', 'lnil13_quart', 'lntgf_beta_quart', 'lntnf_a_quart', 'match_gender', 'match_agelevel', 'match_race7', 'is_case', 'match_draw_yr', 'match_draw_month', 'glio_icdtop', 'glio_icdmor_beh', 'glio_icdmor', 'glio_icdbeh', 'glio_icdgrd', 'glio_is_first_dx', 'glio_cstatus_cat', 'glio_type', 'glio_cancer', 'glio_candxdays', 'glio_exitstat', 'glio_exitage', 'glio_exitdays', 'educat', 'marital', 'bq_age', 'hispanic_f', 'cig_stat', 'cig_stop', 'cig_years', 'pack_years', 'bmi_20', 'bmi_50', 'bmi_curr', 'bmi_curc', 'glio_fh', 'glio_fh_cnt', 'glio_fh_age', 'is_dead', 'dth_cat', 'dth_days', 'bq_cohort_entryage', 'sex', 'age', 'agelevel', 'draw_to_dx_days', 'PLCO_master_barcode', 'Backtrack_barcode', '_NAME_', 'Orf_S_L', 'Orf0', 'Orf1', 'Orf1_N', 'Orf11', 'Orf12', 'Orf12_C', 'Orf12_N', 'Orf13', 'Orf14', 'Orf14_N', 'Orf15_F', 'Orf15_N', 'Orf16', 'Orf17', 'Orf18', 'Orf18_C', 'Orf19', 'Orf2', 'Orf20', 'Orf21', 'Orf22_1', 'Orf22_2', 'Orf23', 'Orf24', 'Orf24_N', 'Orf25', 'Orf26', 'Orf27', 'Orf28', 'Orf3', 'Orf30', 'Orf31_C', 'Orf31_F', 'Orf31_M', 'Orf32', 'Orf33', 'Orf33_N', 'Orf33_5', 'Orf35', 'Orf36', 'Orf37', 'Orf38', 'Orf39', 'Orf39_N', 'Orf4', 'Orf40', 'Orf41', 'Orf42', 'Orf43', 'Orf43_C', 'Orf44', 'Orf45', 'Orf46', 'Orf47', 'Orf48', 'Orf49', 'Orf5', 'Orf5_F', 'Orf50', 'Orf50_C', 'Orf51', 'Orf52', 'Orf53', 'Orf55', 'Orf56', 'Orf56_C', 'Orf57', 'Orf58', 'Orf59', 'Orf6', 'Orf60', 'Orf60_C', 'Orf61', 'Orf62', 'Orf63', 'Orf64', 'Orf65', 'Orf65_N', 'Orf66', 'Orf67', 'Orf67_C', 'Orf67_N', 'Orf68', 'Orf68_C', 'Orf68_F', 'Orf7', 'Orf8', 'Orf9', 'Orf9a', 'Orf9a_N', 'case_AZ']
```


```
for f in ftp.box.com/Ring_stats_updated*/*sas7bdat ; do
python3 -c "import pandas as pd;df=pd.read_sas(\""${f}"\", encoding='utf-8').replace('           .','0');df.set_index(list(df.columns[0:2])).astype(float).fillna(0.0).reset_index().to_csv(\""${f%.sas7bdat}.csv"\",index=False)"
done
```

```
head -1 ftp.box.com/Ring_stats_updated*/*csv
```


```
python3

import pandas as pd
sas=pd.read_sas("ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.sas7bdat", encoding='utf-8').replace('           .','0')
sas=sas.set_index(list(sas.columns[0:2])).astype(float).fillna(0.0).reset_index()


#	Initially used spaces in my csv (spaces are bad)
sas.columns = list(sas.columns[0:2])+["VZV-"+s for s in [s.replace('_', ' ') for s in list(sas.columns[2:len(sas.columns)-1])]]+['case-AZ']


#	then used dashes in my csv so had to convert the underscores to match
#	sas.columns = list(sas.columns[0:2])+["VZV-"+s for s in [s.replace('_', '-') for s in list(sas.columns[2:len(sas.columns)-1])]]+['case-AZ']
#	Recreating with underscores so don't need to do that
#	sas.columns = list(sas.columns[0:2])+["VZV-"+s for s in list(sas.columns[2:len(sas.columns)-1])]+['case-AZ']


#	Probably gonna need some specialized adjustments
sas.columns = [s.replace('VZV-Orf S L', 'VZV-Orf S/L') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf22 1', 'VZV-Orf22.1') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf22 2', 'VZV-Orf22.2') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf33 5', 'VZV-Orf33.5') for s in sas.columns]


sas=sas.drop('idno',axis='columns')

#pd.melt(sas, id_vars=[sas.columns[0:2]], value_vars=[sas.columns[2:]], ignore_index=False)

sasmelt=pd.melt(sas, id_vars=[sas.columns[0]] + [sas.columns[len(sas.columns)-1]], value_vars=list(sas.columns[1:len(sas.columns)-1]), ignore_index=False)

sasmelt
    barcode  case-AZ     variable  value
0    IA0152      1.0  VZV-Orf S/L    0.0
1    IA0219      0.0  VZV-Orf S/L    0.0
2    IA0223      0.0  VZV-Orf S/L    0.0
3    IA0478      0.0  VZV-Orf S/L    0.0
4    IA0660      0.0  VZV-Orf S/L    0.0
..      ...      ...          ...    ...
655  UX7920      0.0  VZV-Orf9a N    0.0
656  UX8002      0.0  VZV-Orf9a N    0.0
657  UX8884      0.0  VZV-Orf9a N    0.0
658  UX8918      0.0  VZV-Orf9a N    0.0
659  UX8930      0.0  VZV-Orf9a N    0.0


sasmelt['case-AZ']=sasmelt['case-AZ'].astype(str)
sasmelt.loc[sasmelt['case-AZ'] == '1.0', 'case-AZ'] = 'case'
sasmelt.loc[sasmelt['case-AZ'] == '0.0', 'case-AZ'] = 'control'


sasmelt['case-AZ'].value_counts()
case-AZ
control    48048
case       12012


sasmelt['x']=sasmelt['barcode']+':'+sasmelt['variable']

sasmelt=sasmelt[['x','case-AZ','value']]
sasmelt.columns=['id','SAS-case','SAS-value']

sasmelt.to_csv('SAS_VZV_extraction.csv',index=False)


head -1 SAS_VZV_extraction.csv > SAS_VZV_extraction.sorted.csv
tail -n +2 SAS_VZV_extraction.csv | sort -t, -k1,1 >> SAS_VZV_extraction.sorted.csv


tail -n +2 SAS_VZV_extraction.sorted.csv | cut -d: -f2 | cut -d, -f1 | sort | uniq | wc -l
91

awk -F, '{id=$3":"$1;print id","$0}' slurm-607421.out-space_delimited > slurm-607421.out-space_delimited.id

head -1 slurm-607421.out-space_delimited.id > slurm-607421.out-space_delimited.id.sorted
tail -n +2 slurm-607421.out-space_delimited.id | sort -t, -k1,1 >> slurm-607421.out-space_delimited.id.sorted


join -t, --header SAS_VZV_extraction.sorted.csv slurm-607421.out-space_delimited.id.sorted > slurm-607421.out-space_delimited.id.sorted.sas.csv

tail -n +2 slurm-607421.out-space_delimited.id.sorted.sas.csv | cut -d: -f2 | cut -d, -f1 | sort | uniq | wc -l
91	#88

wc -l slurm-607421.out-space_delimited.id.sorted.sas.csv
92497 slurm-607421.out-space_delimited.id.sorted.sas.csv

awk -F, '( NR > 1 && $2 != $5 )' slurm-607421.out-space_delimited.id.sorted.sas.csv | wc -l 
0
```


Note that subjects have at least 2 entries per protein. Some have 4 or even 6, for some reason.

It appears that my case/control calls from the PDF are the same as the VZV SAS file so I can remove them.

After this, I can then remove the "id" column as it was only used for joining.

Then I need to move the "SAS-value" column to the end so I don't have to modify the create_html script


```
f=slurm-607421.out-space_delimited.id.sorted.sas.csv
paste -d, <( cut -d, -f4- ${f} ) <( cut -d, -f3 ${f} ) > slurm-607421.out-space_delimited.id.sorted.sas.reordered.csv
```


Not sure whether to use the space, dash or underscore version protein


```
./create_html.bash slurm-607421.out-space_delimited.id.sorted.sas.reordered.csv > vzv.html
```



##	20250418


I was just told that the Ring data is not really what I should be using.

I should be using the Signal data so here we go.


Signal data has a lot of meta data columns.
Signal data does NOT have the barcode used in the pdf so will require joining with other.



```
python3

import pandas as pd
#sas=pd.read_sas("ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.sas7bdat", encoding='utf-8')

import sas7bdat	#	not sure if its better or worse
sas = sas7bdat.SAS7BDAT("ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.sas7bdat").to_data_frame()

sas = sas[['IDNO']+list(sas.columns[63:154])]


#	Initially used spaces in my csv (spaces are bad)
sas.columns = list([sas.columns[0]])+["VZV-"+s for s in [s.replace('_', ' ') for s in list(sas.columns[1:len(sas.columns)])]]

#	then used dashes in my csv so had to convert the underscores to match
#	sas.columns = list(sas.columns[0:2])+["VZV-"+s for s in [s.replace('_', '-') for s in list(sas.columns[2:len(sas.columns)-1])]]+['case-AZ']
#	Recreating with underscores so don't need to do that
#	sas.columns = list(sas.columns[0:2])+["VZV-"+s for s in list(sas.columns[2:len(sas.columns)-1])]+['case-AZ']


#	Probably gonna need some specialized adjustments
sas.columns = [s.replace('VZV-Orf S L', 'VZV-Orf S/L') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf22 1', 'VZV-Orf22.1') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf22 2', 'VZV-Orf22.2') for s in sas.columns]
sas.columns = [s.replace('VZV-Orf33 5', 'VZV-Orf33.5') for s in sas.columns]


ids=pd.read_csv("ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.idno-barcode.csv")

#	SAS Signal data is missing
#	C_020280  IR9374 
#	C_106425  KC0989

sas=pd.merge(ids,sas,left_on='idno',right_on='IDNO')
sas=sas.drop('idno',axis='columns')
sas=sas.drop('IDNO',axis='columns')

#pd.melt(sas, id_vars=[sas.columns[0:2]], value_vars=[sas.columns[2:]], ignore_index=False)

sasmelt=pd.melt(sas, id_vars=[sas.columns[0]], value_vars=list(sas.columns[1:len(sas.columns)]), ignore_index=False)
sasmelt.head()
  barcode     variable     value
0  IX3436  VZV-Orf S/L  1.372000
1  KC5061  VZV-Orf S/L  1.643522
2  IE1418  VZV-Orf S/L  1.492030
3  IN3444  VZV-Orf S/L  1.557069
4  IJ4334  VZV-Orf S/L  1.154381

sasmelt['x']=sasmelt['barcode']+':'+sasmelt['variable']

sasmelt=sasmelt[['x','value']]
sasmelt.columns=['id','SAS-value']
sasmelt.to_csv('SAS_VZV_extraction.csv',index=False)


head -1 SAS_VZV_extraction.csv > SAS_VZV_extraction.sorted.csv
tail -n +2 SAS_VZV_extraction.csv | sort -t, -k1,1 >> SAS_VZV_extraction.sorted.csv


tail -n +2 SAS_VZV_extraction.sorted.csv | cut -d: -f2 | cut -d, -f1 | sort | uniq | wc -l
91

awk -F, '{id=$3":"$1;print id","$0}' slurm-607421.out-space_delimited > slurm-607421.out-space_delimited.id

head -1 slurm-607421.out-space_delimited.id > slurm-607421.out-space_delimited.id.sorted
tail -n +2 slurm-607421.out-space_delimited.id | sort -t, -k1,1 >> slurm-607421.out-space_delimited.id.sorted


join -t, --header SAS_VZV_extraction.sorted.csv slurm-607421.out-space_delimited.id.sorted > slurm-607421.out-space_delimited.id.sorted.sas2.csv

tail -n +2 slurm-607421.out-space_delimited.id.sorted.sas2.csv | cut -d: -f2 | cut -d, -f1 | sort | uniq | wc -l
91

wc -l slurm-607421.out-space_delimited.id.sorted.sas2.csv
92121 slurm-607421.out-space_delimited.id.sorted.sas2.csv
```

```
f=slurm-607421.out-space_delimited.id.sorted.sas2.csv
paste -d, <( cut -d, -f3- ${f} ) <( cut -d, -f2 ${f} ) > slurm-607421.out-space_delimited.id.sorted.sas2.reordered.csv
```


Not sure whether to use the space, dash or underscore version protein


```
./create_html.bash slurm-607421.out-space_delimited.id.sorted.sas2.reordered.csv > vzv2.html
box_upload.bash vzv2.html
```










convert out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-000-cropped.png -colorspace LAB -format %c histogram:info:- 
L\* (Lightness):
Represents the brightness or darkness of the color, ranging from 0 (black) to 100 (white).
a\* (Red-Green):
Indicates the color's position along the red-green axis. Negative values represent green, and positive values represent red.
b\* (Yellow-Blue):
Indicates the color's position along the yellow-blue axis. Negative values represent blue, and positive values represent yellow.


convert out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-000-cropped.png -colorspace LAB -format %c histogram:info:- 

HSI
Hue (H): 
Represents the color's angle in a color wheel, ranging from 0 to 360 degrees.
0 degrees is typically red, 120 degrees is green, and 240 degrees is blue.
Saturation (S):
Indicates how much the color is mixed with white. 
Ranges from 0 to 1, where 0 is a shade of gray and 1 is a pure, saturated color. 
Intensity (I): 
Represents the overall brightness or darkness of the color.
Ranges from 0 to 1, where 0 is black and 1 is white.



HSB
Hue (H):
Represents the pure color or pigment of a color, measured in degrees from 0 to 360. For example, red is typically 0°, green is 120°, and blue is 240°.
Saturation (S):
Describes the purity or intensity of the color. It's measured as a percentage from 0% to 100%, with 100% representing a fully saturated, vibrant color and 0% representing a grayscale color.
Brightness (B):
Represents the lightness or darkness of the color. It's also measured as a percentage from 0% to 100%, with 0% being black and 100% being white.



HSL
Hue: Hue represents the base color, and for Gemini, it's primarily yellow.
Saturation: Saturation controls the intensity or purity of the color. For Gemini, a high saturation would create a vibrant, lively yellow, while a lower saturation would make it more muted or pastel.
Lightness: Lightness determines how bright or dark the color is. A high lightness would make the yellow appear lighter, closer to white, while a lower lightness would make it darker, closer to gray.




HSI: uses intensity, which is a measure of the average luminance of a color. A fully saturated color with maximum intensity would correspond to a bright, pure color. 
HSB: uses brightness, which is a measure of how light or dark a color appears. A fully saturated color with maximum brightness would correspond to a bright, pure color. 


```
convert out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-000-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -40 | datamash mean 1 median 1 sstdev 1 skurt 1
84.5490025	89.8039	11.187015939059	-0.75002670574665

convert out/batch2_spot_plots_human_IgG_01/batch2_spot_plots_human_IgG_01-016-cropped.png -colorspace HSB -format %c histogram:info:- | sort -t, -gr -k 3 | tr : , | tr % , | awk -F, '{for(i=1;i<=$1;i++)print $5}' | head -50 | datamash mean 1 median 1 sstdev 1 
71.599996	67.0588	12.851762890906
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv --wrap="${PWD}/create_csv_batch234.bash"
```




HSL not right

HSI Median 40 - good

HSI Median 30 - too small?


Sample Name
Slide Number
Position on Slide (three numbers)





Some sample/protein pairs have multiple entries. How to combine? Max? Median? Mean? Min? Checking sas matrices.




Using existing matrices, try tensorflow


```
#protein,case_or_control,text1,text2,text3,text4,text5,HSImean30,HSImedian30,HSIstdev30,HSImean40,HSImedian40,HSIstdev40,HSImean50,HSImedian50,HSIstdev50,pdf_file,color_png_file,bw_png
awk 'BEGIN{FS=OFS=","}{print $2,$3,$1,$12}' slurm-611911.out | head

```






---

##	20250428


Find some examples in the SAS matrix. 

Extract all calls for subject / protein pairings and determine how they called.

Median? Average? Minimum? Maximum?

```
cat SAS_VZV_extraction.sorted.csv | datamash --headers -t, min 2 q1 2 median 2 q3 2 max 2
min(SAS-value),q1(SAS-value),median(SAS-value),q3(SAS-value),max(SAS-value)
-0.74978680123143,0.924642144948,1.2664819209876,1.666577887267,47.178710534984
```


```
head -1 slurm-611911.out
protein,case_or_control,text1,text2,text3,text4,text5,HSImean30,HSImedian30,HSIstdev30,HSImean40,HSImedian40,HSIstdev40,HSImean50,HSImedian50,HSIstdev50,pdf_file,color_png_file,bw_png
```


```
cut -d, -f1,3,12 slurm-611911.out | grep VZV-Orf5,IA0152
VZV-Orf5,IA0152,26.9276
VZV-Orf5,IA0152,26.9276
VZV-Orf5,IA0152,22.4842
VZV-Orf5,IA0152,27.58145

grep IA0152:VZV-Orf5, SAS_VZV_extraction.sorted.csv
IA0152:VZV-Orf5,0.7724305292220655





cut -d, -f1,3,12 slurm-611911.out | grep VZV-Orf14,IR519

We don't have IR519?

grep 47.178710534984 SAS_VZV_extraction.sorted.csv
IR519:VZV-Orf14 N,47.178710534984305




cut -d, -f1,3,12 slurm-611911.out | grep VZV | datamash -t, min 3 median 3 max 3
0.784314,36.6018,100


cut -d, -f1,3,12 slurm-611911.out | grep VZV- | sort -t, -k3n,3 | head
VZV-Orf44,IX3205,0.784314
VZV-Orf44,IX4766,0.784314
VZV-Orf44,KE5570,0.784314
VZV-Orf17,IN8034,1.176472
VZV-Orf44,IA5836,1.56863
VZV-Orf44,IN532,1.56863
VZV-Orf44,IW2587,1.56863
VZV-Orf44,IX3205,1.56863
VZV-Orf44,IX4049,1.56863
VZV-Orf44,IX4944,1.56863


cut -d, -f1,3,12 slurm-611911.out | grep VZV- | sort -t, -k3n,3 | tail
VZV-Orf68_C,IX4484,100
VZV-Orf68_C,UT9259,100
VZV-Orf68_C,UT9259,100
VZV-Orf68_F,IY5127,100
VZV-Orf6,IB1220,100
VZV-Orf6,IX4484,100
VZV-Orf6,KC4714,100
VZV-Orf6,KC64,100
VZV-Orf6,KD615,100
VZV-Orf6,UT9259,100



tail -n +2 SAS_VZV_extraction.sorted.csv | sort -t, -k2n,2 | head
IA689:VZV-Orf31 M,-0.749786801231425
IA689:VZV-Orf28,-0.7414971439296014
IA689:VZV-Orf60,-0.7401158169087845
IA689:VZV-Orf66,-0.734938262262032
IA689:VZV-Orf9,-0.727088140118481
IA689:VZV-Orf51,-0.564506870007174
IE1188:VZV-Orf39,-0.1820528234627855
IL398:VZV-Orf43 C,-0.04299573843755575
IE1188:VZV-Orf36,-0.037043020666071555
IX4944:VZV-Orf44,-0.025

tail -n +2 SAS_VZV_extraction.sorted.csv | sort -t, -k2n,2 | tail
IJ4550:VZV-Orf28,10.672760605995775
IR519:VZV-Orf61,10.77984450980873
IR519:VZV-Orf12 N,10.917983835254034
KE3968:VZV-Orf14 N,12.2076831292981
IZ3333:VZV-Orf14 N,12.7477318337214
IR5310:VZV-Orf14 N,12.9198160120769
IB3399:VZV-Orf14 N,13.418
IL5509:VZV-Orf14 N,18.10729183381575
IR519:VZV-Orf14,36.08020653687615
IR519:VZV-Orf14 N,47.178710534984305

```


We're missing IR519 and IL5509?


492 subjects in PDFs
```
tail -n +2 slurm-611911.out | cut -d, -f3 | uniq | sort | uniq | wc -l
492
```

658 subjects in the SAS files
```
tail -n +2 SAS_VZV_extraction.sorted.csv | cut -d: -f1 | uniq | sort | uniq | wc -l
658

tail -n +2 ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.csv | cut -d, -f2 | uniq | sort | uniq | wc -l
660


cat ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv | cut -d, -f1,2 > tmp.csv
head -1 tmp.csv > signal_vzv.idno.batch.csv
tail -n +2 tmp.csv | sort -k1,1 >> signal_vzv.idno.batch.csv

cat ftp.box.com/Ring_stats_updated_2017/new_vzv_ring_2017.csv | cut -d, -f1,2 > tmp.csv
head -1 tmp.csv > ring_vzv.idno.barcode.csv
tail -n +2 tmp.csv | sort -k1,1 >> ring_vzv.idno.barcode.csv

join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | cut -d, -f3 | uniq -c
     14 
      1 Batch
    170 1.0
    170 2.0
    168 3.0
    136 4.0
```

"Blank" batch is likely Batch 4 or maybe 3.

Missing Batch 1 PDFs.



```
cut -d, -f1,3,12 slurm-611911.out | grep "VZV-Orf14_N,IB3399" 
VZV-Orf14_N,IB3399,64.3137
VZV-Orf14_N,IB3399,64.3137

grep "IB3399:VZV-Orf14 N" SAS_VZV_extraction.sorted.csv
IB3399:VZV-Orf14 N,13.418
```


```
awk -F, '(/^VZV/){print $3":"$1","$12}' slurm-611911.out | sort -k1,1 | sed '1isubject_protein,med40' > VZV_med40.csv

sed 's/ /_/g' SAS_VZV_extraction.sorted.csv > VZV_score.csv

join --header -t, VZV_score.csv VZV_med40.csv | sort -t, -k2n,2 | head
```

```
python3 -c "import pandas as pd;df=pd.read_csv('VZV_med40.csv',sep=',',header=[0],low_memory=False).groupby('subject_protein',dropna=False).min().to_csv('VZV_med40.mins.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('VZV_med40.csv',sep=',',header=[0],low_memory=False).groupby('subject_protein',dropna=False).median().to_csv('VZV_med40.medians.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('VZV_med40.csv',sep=',',header=[0],low_memory=False).groupby('subject_protein',dropna=False).max().to_csv('VZV_med40.maxes.csv')"
python3 -c "import pandas as pd;df=pd.read_csv('VZV_med40.csv',sep=',',header=[0],low_memory=False).groupby('subject_protein',dropna=False).std().to_csv('VZV_med40.stds.csv')"

sort -t, -k2nr,2 VZV_med40.stds.csv | head
IO4021:VZV-Orf31_F,50.05205853154294
IK9121:VZV-Orf22.2,43.027412279862354
IO3822:VZV-Orf1_N,42.14907959161149
IB1220:VZV-Orf38,41.640917303311774
IB1220:VZV-Orf55,40.99352568979643
KC4714:VZV-Orf27,40.20803612191535
IO3786:VZV-Orf12,39.5611748384859
KC4714:VZV-Orf55,37.896892962946175
IY5127:VZV-Orf68_F,37.80518121342629
UT9259:VZV-Orf38,37.80518121342629

grep IO4021:VZV-Orf31_F VZV_med40.*
VZV_med40.csv:IO4021:VZV-Orf31_F,100
VZV_med40.csv:IO4021:VZV-Orf31_F,29.2157
VZV_med40.maxes.csv:IO4021:VZV-Orf31_F,100.0
VZV_med40.medians.csv:IO4021:VZV-Orf31_F,64.60785
VZV_med40.mins.csv:IO4021:VZV-Orf31_F,29.2157
VZV_med40.stds.csv:IO4021:VZV-Orf31_F,50.05205853154294

grep IO4021:VZV-Orf31_F VZV_score.csv 
IO4021:VZV-Orf31_F,1.498


grep IK9121:VZV-Orf22.2 VZV_med40.*
VZV_med40.csv:IK9121:VZV-Orf22.2,100
VZV_med40.csv:IK9121:VZV-Orf22.2,39.15005
VZV_med40.maxes.csv:IK9121:VZV-Orf22.2,100.0
VZV_med40.medians.csv:IK9121:VZV-Orf22.2,69.575025
VZV_med40.mins.csv:IK9121:VZV-Orf22.2,39.15005
VZV_med40.stds.csv:IK9121:VZV-Orf22.2,43.027412279862354

grep IK9121:VZV-Orf22.2 VZV_score.csv 
IK9121:VZV-Orf22.2,3.177


grep IO3786:VZV-Orf12 VZV_med40.csv
IO3786:VZV-Orf12,39.8688
IO3786:VZV-Orf12,95.81675
IO3786:VZV-Orf12_C,33.2021
IO3786:VZV-Orf12_C,34.7059
IO3786:VZV-Orf12_N,36.7979
IO3786:VZV-Orf12_N,38.0392

grep IO3786:VZV-Orf12 VZV_score.csv
IO3786:VZV-Orf12,2.547
IO3786:VZV-Orf12_C,1.254
IO3786:VZV-Orf12_N,1.513

```

Score seems to be based on the minimum.







---

##	20250428

On 20250428, I added what is thought to be Batch 1 and what I'll call Batch 0.

Re doing the following prep work so the layout and numbers will change.

```
mv pdfs pdfs1
mkdir pdfs
cd pdfs
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ 1\ need\ to\ confirm/spot_plots\ not\ part\ of\ Batch\ 1\ but\ precedes\ batch\ 1/*pdf ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//plots_/plots_human_}
l=${l//Human/human}
ln -s "$pdf" "batch0_${l}"
done
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ 1\ need\ to\ confirm/UCSFVZV_Set1_all_human\ IgG_spot_plots/*pdf ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//Human/human}
ln -s "$pdf" "batch1_${l}"
done
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ 2/UCSFVZV_Set2_all_human-IgG_spot_plots/*pdf ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//Human/human}
ln -s "$pdf" "batch2_${l}"
done
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ 3/*pdf ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//Human/human}
ln -s "$pdf" "batch3_${l}"
done
for pdf in ../ftp.box.com/Francis\ _Lab_Share/PLCO/PLCO\ NAPPA\ spot\ plots/Batch\ 4/UCSFVZV_Set4_all_Human\ IgG_spot_plots/*pdf ; do
l=$( basename "${pdf}" )
l=${l// /_}
l=${l//-/_}
l=${l//Human/human}
ln -s "$pdf" "batch4_${l}"
done
```


```
mv out out1
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
#	1155216	#	<- first run
1649400

find out/batch[1234]* -name \*png | wc -l
1549680

find out/batch0* -name \*png | wc -l
99720

find out/batch1* -name \*png | wc -l
394464

find out/batch2* -name \*png | wc -l
403856

find out/batch3* -name \*png | wc -l
399160

find out/batch4* -name \*png | wc -l
352200
```

```
echo $[1155216/2]
577608

echo $[394464/2]
197232

echo $[403856/2]
201928

echo $[399160/2]
199580

echo $[352200/2]
176100
```

```
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | wc -l
#577608 <- first run
1071762	#	different????

grep -h -B2 "^(" out/batch[1234]*txt |grep -vs "^--" | paste - - - | wc -l
972042

grep -h -B2 "^(" out/batch0*txt |grep -vs "^--" | paste - - - | wc -l
99720

grep -h -B2 "^(" out/batch1*txt |grep -vs "^--" | paste - - - | wc -l
394434

grep -h -B2 "^(" out/batch2*txt |grep -vs "^--" | paste - - - | wc -l
201928

grep -h -B2 "^(" out/batch3*txt |grep -vs "^--" | paste - - - | wc -l
199580

grep -h -B2 "^(" out/batch4*txt |grep -vs "^--" | paste - - - | wc -l
176100
```

The counts aren't meshing up this re-run. Not enough images?

Counted by batch. Batch 1 is a bit off.

Batch 0 is equal??

Batch 0 and 1 have a bit different layout which may be contributing to my "count" difference.

Batch 2, 3 and 4 are laid out

```
Subject    Subject   
TileID     TileID
Position   Position
-----      -----
Color      Color
Image      Image
-----      -----
BandW      BandW
Image      Image
-----      -----
```

1 label for both the color signal image and the black and white ring image.


Batch 0 and 1 are ...

```
Subject    Subject   
TileID     TileID
Position   Position
-----      -----
Color      Color
Image      Image
-----      -----

Subject    Subject   
TileID     TileID
Position   Position
-----      -----
BandW      BandW
Image      Image
-----      -----
```

So there should be the same number of images as labels

Batch 0 ...  99720 == 99720

However Batch 1 ... is off by 40?

```
find out/batch1* -name \*png | wc -l
394464

grep -h -B2 "^(" out/batch1*txt |grep -vs "^--" | paste - - - | wc -l
394434
```

```
for f in out/batch1_spot_plots_human_IgG_*.raw.txt ; do echo $f; grep -h -B2 "^(" ${f}|grep -vs "^--" | paste - - - | wc -l ;done
out/batch1_spot_plots_human_IgG_01.raw.txt
1986

for f in out/batch1_spot_plots_human_IgG_??/ ; do echo $f ; find $f -name \*png | wc -l ; done
out/batch1_spot_plots_human_IgG_01/
2016
```

The problem appears to be the first pdf. Counts differ 2016 and 1986.

The last line appears cut off.

I appended each subject with "Unknown / (0:0-0)" as the values aren't really important

Batch 0 and 1 are still a different layout than 2, 3 and 4 so will need to parse differently.            TODO TODO TODO


Looks like 492 subjects each with 1174 datapoints.
```
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq -c
grep -h -B2 "^(" out/batch*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq -c | wc -l
#492	#	<- first run
750	#	<- includes batch0

grep -h -B2 "^(" out/batch[1234]*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq -c | wc -l
660	#	<- this is what was in the data files from Joe like ... new_vzv_ring_2017
```

Batch 0 has only numbers as subject IDs. I understand these to be AGS subjects.

```
grep -h -B2 "^(" out/batch1*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq | head
```


```
join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | awk -F, '( $3 == 1.0 )'
```

Some differences 
```
sdiff -s -d <( grep -h -B2 "^(" out/batch1*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq ) <( join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | awk -F, '( $3 == 1.0 )' | cut -d, -f2 | sort )
							      >	IL916
							      >	IX9435
sdiff -s -d <( grep -h -B2 "^(" out/batch2*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq ) <( join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | awk -F, '( $3 == 2.0 )' | cut -d, -f2 | sort )
IL916							      <
IX9435							      <
sdiff -s -d <( grep -h -B2 "^(" out/batch3*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq ) <( join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | awk -F, '( $3 == 3.0 )' | cut -d, -f2 | sort )
IR9374							      <
KC0989							      <
sdiff -s -d <( grep -h -B2 "^(" out/batch4*txt |grep -vs "^--" | paste - - - | cut -f1 | sort | uniq ) <( join --header -t, ring_vzv.idno.barcode.csv signal_vzv.idno.batch.csv | sort -t, -k3n,3 | awk -F, '( $3 == 4.0 )' | cut -d, -f2 | sort )
IN3312							      <
IP259							      <
IQ515							      <
IR5157							      <
IX2213							      <
IX5624							      <
IX9579							      <
IY5001							      <
IZ5055							      <
KC2076							      <
KC3002							      <
KE5079							      <
KE6465							      <
KE6537							      <
```

These 2 subjects are labeled as in batch 1 in the SAS file, but are in batch 2 of the pdfs.

Let's combine all these things and see what differs.

```
tail -q -n +2 ftp.box.com/Signal*/*plco.csv | cut -d, -f1,2 | sort -k1,1 | uniq | sed '1iidno,batch' > signal.idno.batch.csv
tail -q -n +2 ftp.box.com/Ring*/*2017.csv | cut -d, -f1,2 | sort -k1,1 | uniq | sed '1iidno,barcode' > ring.idno.barcode.csv
join -a 1 -a 2 --header -t, ring.idno.barcode.csv signal.idno.batch.csv > idno.barcode.batch.csv

echo idno,barcode,sasbatch,pdfbatch > idno_barcode_sasbatch_pdfbatch.csv
while read idno barcode sas_batch ; do
pdf_batch=$( awk -v barcode=${barcode} '($0==barcode){split(FILENAME,a,"/");split(a[2],b,"_");print b[1]}' out/batch*txt | uniq )
echo ${idno},${barcode},${sas_batch%.0},${pdf_batch#batch}
done < <( cat idno.barcode.batch.csv | tail -n +2 | tr ',' ' ' ) >> idno_barcode_sasbatch_pdfbatch.csv
```


```
wc -l ring.idno.barcode.csv signal.idno.batch.csv idno.barcode.batch.csv idno_barcode_sasbatch_pdfbatch.csv

awk -F, '( $3 != $4 )' idno_barcode_sasbatch_pdfbatch.csv
```



