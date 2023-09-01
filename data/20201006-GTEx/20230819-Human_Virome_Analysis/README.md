
#	20201006-GTEx/20230819-Human_Virome_Analysis




```

Human_Virome_Analysis_array_wrapper.bash --threads 4 --extension .Aligned.sortedByCoord.out.bam \
--out ${PWD}/out ${PWD}/../20230818-STAR-GRCh38/out/*.Aligned.sortedByCoord.out.bam 

```



How to tablify results to compare to paper

```
head ../Human_Virome_analysis/12915_2020_785_MOESM3_ESM.tsv 
Additional file 3: Table S3. Read count of the respective 39 viral species detected in this study.									
Run	Acute bee paralysis	Acyrthosiphon pisum virus	AAV2	Anopheles gambiae densonuclosis	mellifera filamentous virus	Bovine coronavirus	HCOSV-A	Deformed wing virus	GBV (HGV)	Gemycircularvirus_HV-GcV1	HCV	Hubei picorna virus	Hubei arthropod virus 1	HHV-6A	HCoV-229E	EBV (HHV-4)	HSV-1	HHV-3	CMV (HHV-5)	HHV-6B	HHV-7	Human parainfluenza virus 3	Lassa virus	MSSI2.225 virus	Merkel cell polyomavirus	Papiloma	RSV	TTV	Tomato spotted wilt virus
SRR1068687	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.000121038037326959	00
SRR1068788	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
SRR1068832	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
SRR1068855	0	0	0	0	0	0	0	0	0	0	0	0.000522880869233328	0	0	0	0.000189142443922233	0	0	0	0	0	0	0	0	0	0	0	0	0
```


```
cat out/*count.txt
```

```
cat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/SRR808614_R1.fastq.gz.read_count.txt
59085492
```


```
1000*160/(2*59085492)
```



```
head -1 /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | awk -F, '{for(i=1;i<=NF;i++){print i,$i}}'

cat /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$11}' | sort > body_site.csv


```



Not certain how they arrived at they're counts.  My transcripts per thousand is close, but not perfect.

```
for f in out/*.count.txt ; do
echo $f
srr=$( basename ${f} .count.txt )
rc=$( cat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/${srr}_R1.fastq.gz.read_count.txt )
o=${f%.txt}.normalized.txt
if [ ! -f ${o} ] ; then
awk -v rc=${rc} 'BEGIN{FS=OFS="\t"}(NR==1){print;next}(/^ID_/){print $1,(1000*$2/rc)}' ${f} > ${o}
fi
done

python3 ./merge.py --out merged.csv out/*.count.normalized.txt

( ( head -1 merged.csv ) && ( tail -n +2 merged.csv | sort -t, -k1,1 ) ) > merged.sorted.csv
( ( head -2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | tail -n 1 | sed 's/Refseq ID/Refseq_ID/' | sed $'s/\t/,/g' ) && ( tail -n +3 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | sed 's/[,"]//g' | sed $'s/\t/,/g' | sort -t, -k3 ) ) | awk 'BEGIN{FS=OFS=","}{print $1,$2,$3}' > 12915_2020_785_MOESM11_ESM.sorted.csv

join -t, --header -1 3 -2 1 12915_2020_785_MOESM11_ESM.sorted.csv merged.sorted.csv | datamash transpose -t, | tail -n +3 > transposed.csv
join -t, --header body_site.csv transposed.csv > transposed_with_body_site.csv

join -t, --header transposed.csv <( tail -n +2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM3_ESM.csv | sed -e 's/ /_/g' -e '1s/,/,ppr /g' )  > compared.csv

join -t, --header body_site.csv compared.csv > compared_with_body_site.csv

box_upload.bash transposed_with_body_site.csv compared_with_body_site.csv

```









These samples take a while ...
```

   1548391_[1284-1438%1] francislab, Human_Virome   gwendt PD     0:00    1    4  30000M (JobHeldUser)
            1556438_1431  francislab Human_Virome   gwendt  R 4-01:49:06    1    4  30000M c4-n17
            1556438_1422  francislab Human_Virome   gwendt  R 4-03:02:06    1    4  30000M c4-n17
            1556438_1420  francislab Human_Virome   gwendt  R 4-03:05:06    1    4  30000M c4-n17
            1556438_1412  francislab Human_Virome   gwendt  R 4-05:07:06    1    4  30000M c4-n17
            1556438_1385  francislab Human_Virome   gwendt  R 4-08:55:06    1    4  30000M c4-n17
            1556438_1370  francislab Human_Virome   gwendt  R 4-10:02:06    1    4  30000M c4-n17
             1547450_997      common Human_Virome   gwendt  R 5-15:03:03    1    4  30000M c4-n2
             1547450_782      common Human_Virome   gwendt  R 6-11:49:51    1    4  30000M c4-n2
            1548391_1088      common Human_Virome   gwendt  R 6-12:04:58    1    4  30000M c4-n38
            1548391_1087      common Human_Virome   gwendt  R 6-12:06:27    1    4  30000M c4-n5
            1548391_1086      common Human_Virome   gwendt  R 6-12:11:55    1    4  30000M c4-n38
            1548391_1085      common Human_Virome   gwendt  R 6-12:25:57    1    4  30000M c4-n38
            1548391_1084      common Human_Virome   gwendt  R 6-13:04:28    1    4  30000M c4-n38
            1548391_1083      common Human_Virome   gwendt  R 6-13:06:13    1    4  30000M c4-n38
            1548391_1082      common Human_Virome   gwendt  R 6-14:21:48    1    4  30000M c4-n5
            1548391_1081      common Human_Virome   gwendt  R 6-14:23:47    1    4  30000M c4-n38
             1547450_385      common Human_Virome   gwendt  R 7-07:08:04    1    4  30000M c4-n5
```




```
cat Human_Virome_Analysis_array_wrapper.bash.* | xargs -I% basename % .Aligned.sortedByCoord.out.bam | sort | uniq > input
ls -1 out/*count.txt | xargs -I% basename % .count.txt > output
for s in $( comm -23 input output ) ; do
echo $s
ll -tr out/${s}_*
done
```










After the shutdown, as these will likely have failed, ...


```
grep -vs -n -f output Human_Virome_Analysis_array_wrapper.bash.20230820172433271934742 | cut -d: -f1 | paste -sd,
782,1081,1082,1083,1084,1085,1086,1087,1088,1370,1385,1412,1420,1422,1431
```
