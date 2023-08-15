


```
Add "machine gslanalyzer.qb3.berkeley.edu login ########## password ##########" to ~/.netrc

Then DO NOT USE the "ftp://" prefix or "-u username,password" in command 

So I put the username and password into my ~/.netrc and then downloaded all data.

lftp -c 'set ssl:verify-certificate no set ftp:ssl-protect-data true set ftp:ssl-force true; open -e "mirror -c; quit" gslanalyzer.qb3.berkeley.edu:990'
```



MANUALLY EDIT THE COVARIATE FILE
CHANGE "post recurrence" to "post-recurrence"





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/raw"
curl -netrc -X MKCOL "${BOX}/"

for f in *fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```



```
python3 -m pip install --user --upgrade fastq-statistic
```


```
for r1 in SFHH011*_S*_R1_0*.fastq.gz; do
echo $r1
r2=${r1/_R1_/_R2_}
#base=${r1%_R1*}
base=${r1%_S*}
fastq-statistic --sampleid ${base} --no-plot ${r1} ${r2}
done
```




```
head -1q *_statistic.csv | head -1 > fastq-statistics.csv
tail -n 1 -q *_statistic.csv >> fastq-statistics.csv

box_upload.bash fastq-statistics.csv 
```





##	20230814

```
mkdir fastq
for f in SFH*_S*_R*.fastq.gz ; do
b=$( basename ${f} _001.fastq.gz )
l=${b%%_*}
r=${b##*_}
ln -s ../${f} fastq/${l}_${r}.fastq.gz
done
```



