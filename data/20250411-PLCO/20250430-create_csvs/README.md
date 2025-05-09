
#	20250411-PLCO/20250430-create_csvs


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv234 --out="${PWD}/batch234.csv" ${PWD}/create_csv_batch234.bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=csv1 --out="${PWD}/batch1.csv" ${PWD}/create_csv_batch01.bash
```

```
head -1 batch1.csv batch234.csv 
==> batch1.csv <==
protein,case_or_control,sample,slide,pos1,pos2,pos3,HSImean30,HSImedian30,HSIstdev30,HSImean40,HSImedian40,HSIstdev40,HSImean50,HSImedian50,HSIstdev50,pdf_file,color_png_file

==> batch234.csv <==
protein,case_or_control,sample,slide,pos1,pos2,pos3,HSImean30,HSImedian30,HSIstdev30,HSImean40,HSImedian40,HSIstdev40,HSImean50,HSImedian50,HSIstdev50,pdf_file,color_png_file

wc -l batch1.csv batch234.csv 
   197231 batch1.csv
   577609 batch234.csv
   774840 total
```

```
./create_html.bash batch1.csv > batch1.html
./create_html.bash batch234.csv > batch234.html
```



```
./extract_and_pivot.bash
```



```
tail -q -n +2 /francislab/data1/raw/20250411-PLCO/ftp.box.com/Ring*/*2017.csv | cut -d, -f1,2 | sort -k1,1 | uniq | sed '1iidno,barcode' > idno.barcode.csv

join --header -t, idno.barcode.csv /francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_cmv_plco.csv > tmp.HCMV.csv
join --header -t, idno.barcode.csv /francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_human_plco.csv > tmp.Human.csv
join --header -t, idno.barcode.csv /francislab/data1/raw/20250411-PLCO/ftp.box.com/Signal_stats_updated_2016/signal_vzv_plco.csv > tmp.VZV.csv
```


```
awk -F, '(!/^VZV/&&!/^HCMV/&&FNR>1){print $1}' batch1.csv batch234.csv | uniq | sort | uniq | sed -e '1ibarcode' > Human.proteins.csv
awk -F, '(/^VZV/&&FNR>1){print $1}' batch1.csv batch234.csv | uniq | sort | uniq | sed -e 's/^VZV_//' -e '1ibarcode' > VZV.proteins.csv
awk -F, '(/^HCMV/&&FNR>1){print $1}' batch1.csv batch234.csv | uniq | sort | uniq | sed -e 's/^HCMV_//' -e '1ibarcode' > HCMV.proteins.csv
```


```
cat tmp.VZV.csv | datamash transpose -t, > tmp1.csv
head -2 tmp1.csv | tail -n 1 > tmp2.csv
head -1 tmp1.csv > tmp3.csv
tail -n +3 tmp1.csv >> tmp3.csv
#sort -t, -k1,1 tmp3.csv | sed -e 's/Orf22_1/Orf22.1/' -e 's/Orf22_2/Orf22.2/' -e 's/Orf33_5/Orf33.5/' -e 's/Orf_S_L/Orf_S\/L/' >> tmp2.csv
sort -t, -k1,1 tmp3.csv >> tmp2.csv
join -t, VZV.proteins.csv tmp2.csv > tmp4.csv
cat tmp4.csv | sed -e '2,$s/^/VZV-/' -e '1s/barcode/subject/' | datamash transpose -t, > tmp5.csv
head -1 tmp5.csv > SAS.VZV.matrix.csv
tail -n +2 tmp5.csv | sort -t, -k1,1 >> SAS.VZV.matrix.csv

cat tmp.HCMV.csv | datamash transpose -t, > tmp1.csv
head -2 tmp1.csv | tail -n 1 > tmp2.csv
head -1 tmp1.csv > tmp3.csv
tail -n +3 tmp1.csv >> tmp3.csv
#sort -t, -k1,1 tmp3.csv | sed -e 's/UL80_5/UL80.5/' >> tmp2.csv
sort -t, -k1,1 tmp3.csv >> tmp2.csv
join -t, HCMV.proteins.csv tmp2.csv > tmp4.csv
cat tmp4.csv | sed -e '2,$s/^/HCMV-/' -e '1s/barcode/subject/' | datamash transpose -t, > tmp5.csv
head -1 tmp5.csv > SAS.HCMV.matrix.csv
tail -n +2 tmp5.csv | sort -t, -k1,1 >> SAS.HCMV.matrix.csv

cat tmp.Human.csv | datamash transpose -t, > tmp1.csv
head -2 tmp1.csv | tail -n 1 > tmp2.csv
head -1 tmp1.csv > tmp3.csv
tail -n +3 tmp1.csv >> tmp3.csv
sort -t, -k1,1 tmp3.csv >> tmp2.csv
join -t, Human.proteins.csv tmp2.csv > tmp4.csv
cat tmp4.csv | sed -e '1s/barcode/subject/' | datamash transpose -t, > tmp5.csv
head -1 tmp5.csv > SAS.Human.matrix.csv
tail -n +2 tmp5.csv | sort -t, -k1,1 >> SAS.Human.matrix.csv
```





Merge the batches and compare to the SAS matrices to see if any "correlate"


```
for m in min median max ; do
for p in VZV HCMV Human ; do
merge_matrices.py --header_rows 1 --index_col subject --axis index \
  --output batch1234.${p}.med40.${m}.csv \
  batch1.${p}.med40.${m}.csv batch234.${p}.med40.${m}.csv
sed -i -e 's/VZV_/VZV-/g' -e 's/HCMV_/HCMV-/g' batch1234.${p}.med40.${m}.csv
done
done
```









Some missing subjects

```
sdiff -sd <( cut -d, -f1 SAS.VZV.matrix.csv ) <( cut -d, -f1 batch1234.VZV.med40.min.csv )
							      >	IR9374
							      >	KC0989

sdiff -sd <( cut -d, -f1 SAS.HCMV.matrix.csv ) <( cut -d, -f1 batch1234.HCMV.med40.min.csv )
							      >	IR9374
							      >	KC0989

sdiff -sd <( cut -d, -f1 SAS.Human.matrix.csv ) <( cut -d, -f1 batch1234.Human.med40.min.csv )
							      >	IR9374
							      >	KC0989
```

Some proteins not in VZV, HCMV or Human
```
diff <( head -1 SAS.VZV.matrix.csv | datamash transpose -t, ) <( head -1 batch1234.VZV.med40.min.csv | datamash transpose -t,)

diff <( head -1 SAS.HCMV.matrix.csv | datamash transpose -t, ) <( head -1 batch1234.HCMV.med40.min.csv | datamash transpose -t,)

diff <( head -1 SAS.Human.matrix.csv | datamash transpose -t, ) <( head -1 batch1234.Human.med40.min.csv | datamash transpose -t,)

HPV*, L*, pAnt7-cGST, pcite-HA
```






```
import pandas as pd
min=pd.read_csv('batch1234.VZV.med40.min.csv',index_col=[0])
min=min.drop(['IR9374','KC0989'])
med=pd.read_csv('batch1234.VZV.med40.median.csv',index_col=[0])
med=med.drop(['IR9374','KC0989'])
max=pd.read_csv('batch1234.VZV.med40.max.csv',index_col=[0])
max=max.drop(['IR9374','KC0989'])

sas=pd.read_csv('SAS.VZV.matrix.csv',index_col=[0])

min.corrwith(sas,axis='columns').min()
min.corrwith(sas,axis='index').min()
med.corrwith(sas,axis='columns').min()
med.corrwith(sas,axis='index').min()
max.corrwith(sas,axis='columns').min()
max.corrwith(sas,axis='index').min()

min.corrwith(sas,axis='columns').median()
min.corrwith(sas,axis='index').median()
med.corrwith(sas,axis='columns').median()
med.corrwith(sas,axis='index').median()
max.corrwith(sas,axis='columns').median()
max.corrwith(sas,axis='index').median()


>>> min.corrwith(sas,axis='columns').median()
np.float64(0.8535483764400509)
>>> min.corrwith(sas,axis='index').median()
np.float64(0.7449498951806823)
>>> med.corrwith(sas,axis='columns').median()
np.float64(0.8779392826650951)
>>> med.corrwith(sas,axis='index').median()
np.float64(0.7613738043510799)
>>> max.corrwith(sas,axis='columns').median()
np.float64(0.8342642353290795)
>>> max.corrwith(sas,axis='index').median()
np.float64(0.7217536425663232)
```




Normalize?

Get background intensity??



cp batch1.csv batch1234.csv 
tail -n +2 batch234.csv >> batch1234.csv



