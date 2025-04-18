
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



##	20250418


I was just told that the Ring data is not really what I should be using.












