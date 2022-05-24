

Merge 

10-PAUBCB-09A-01R
10-PAUBCT-09A-01R
10-PAUBLL-09A-01R
10-PAUBPY-09A-01R
10-PAUBRD-09A-01R
10-PAUBTC-09A-01R
10-PAUBXP-09A-01R



20200914-REdiscoverTE - out/10-PAUBCB.salmon.REdiscoverTE/quant.sf / /francislab/data1/refs/REdiscoverTE/rollup_annotation/rmsk_annotation.csv

```
for d in ../20200914-REdiscoverTE/out/10-PAUB*.salmon.REdiscoverTE ; do
echo $d
f=${d}/quant.sf
awk '(FNR==NR){ split($0,a,","); hash_names[a[1]]=a[3]}
(FNR!=NR){ split($0,a,"\t"); if( a[1] in hash_names ){ hash_counts[a[1]]+=a[5] } }
END{for( h in hash_names){ if( hash_counts[h] > 0 ){ name_counts[hash_names[h]]+=hash_counts[h] } } 
for( n in name_counts ){ print n"\t"name_counts[n] }
}' /francislab/data1/refs/REdiscoverTE/rollup_annotation/rmsk_annotation.csv $f | sort -k1,1 > REdiscoverTE/$( basename $d .salmon.REdiscoverTE ) 
done
```



20220303-TEtranscripts-test/10-PAUBCB-09A-01R.cntTable
grep -c : ../20220303-TEtranscripts-test/10-PAUBCB-09A-01R.cntTable 
1180

```
for f in ../20220303-TEtranscripts-test/10-PAUB*.cntTable ; do
echo $f
awk '($1~/:/){
split($1,a,":")
print a[1]"\t"$2
}' $f | sort -k1,1 > TEtranscripts/$( basename $f -09A-01R.cntTable )
done
```



20220309-RepEnrich2-test/out/10-PAUBCB-09A-01R/10-PAUBCB-09A-01R_fraction_counts.txt
wc -l 20220309-RepEnrich2-test/out/10-PAUBCB-09A-01R/10-PAUBCB-09A-01R_fraction_counts.txt
1267
```
for f in ../20220309-RepEnrich2-test/out/10-PAUB*-09A-01R/10-PAUB*-09A-01R_fraction_counts.txt ; do
echo $f
awk '{
print $1"\t"$4
}' $f | sort -k1,1 > RepEnrich2/$( basename $f -09A-01R_fraction_counts.txt )
done
```


SQuIRE has some duplicate and ambiguous names (ie 
10-PAUBCB-09A-01R	67071045	LTR91:ERVL:LTR	331	6.28809804122	65	66.00	66	100.00
10-PAUBCB-09A-01R	67071045	LTR91:LTR:LTR	13	0	0	0.00	0	NA
)

SQuIRE subFcounts has uniq_counts	tot_counts	tot_reads (using tot_counts for the moment)

20220309-SQuIRE-test/counted/10-PAUBCB-09A-01R_subFcounts.txt
wc -l ../20220309-SQuIRE-test/counted/10-PAUBCB-09A-01R_subFcounts.txt
1281

```
for f in ../20220309-SQuIRE-test/counted/10-PAUB*-09A-01R_subFcounts.txt ; do
echo $f
awk -F"\t" '(NR>1){
split($3,a,":")
h[a[1]]+=$7
}END{
for( k in h ){
print k"\t"h[k]
} }' $f | sort -k1,1 > SQuIRE/$( basename $f -09A-01R_subFcounts.txt )
done
```




20220302-TEfinder-test - HERV only
20220302-xTea-test - DNA
20220317-TEtools-test - not run




```
python3 ./merge.py -o REdiscoverTE.csv REdiscoverTE/10-PAUB*
python3 ./merge.py -o RepEnrich2.csv RepEnrich2/10-PAUB*
python3 ./merge.py -o SQuIRE.csv SQuIRE/10-PAUB*
python3 ./merge.py -o TEtranscripts.csv TEtranscripts/10-PAUB*
for f in REdiscoverTE/10-PAUB* ; do
b=$( basename $f )
mkdir $b
ln -s ../REdiscoverTE/$b $b/REdiscoverTE
ln -s ../RepEnrich2/$b $b/RepEnrich2
ln -s ../SQuIRE/$b $b/SQuIRE
ln -s ../TEtranscripts/$b $b/TEtranscripts
done
for f in REdiscoverTE/10-PAUB* ; do
b=$( basename $f )
echo $b
python3 ./merge.py -o $b.csv $b/*
done
```





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200909-TARGET-ALL-P2-RNA_bam"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200909-TARGET-ALL-P2-RNA_bam/20220523-Merge-TE-test"
curl -netrc -X MKCOL "${BOX}/"

for f in *.csv ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```


