


```
Add "machine gslanalyzer.qb3.berkeley.edu login ########## password ##########" to ~/.netrc

Then DO NOT USE the "ftp://" prefix or "-u username,password" in command 

So I put the username and password into my ~/.netrc and then downloaded all data.

lftp -c 'set ssl:verify-certificate no set ftp:ssl-protect-data true set ftp:ssl-force true; open -e "mirror -c; quit" gslanalyzer.qb3.berkeley.edu:990'
```





```
Before I really dig into this new data ...
RNA or DNA?
RNA
Is it blood EV data like before? Or pancreatic samples? Or has it always been pancreatic data?
the pancreatic data is from cyst fluid, but the poly-a is from blood EVs
Does it have UMIs? If so, where? And do you want them consolidated?
yes! UMIs should be in the exact position Mi previously sent.
Do you want it quality filtered? 10? 15? 20? 30? (I think 15 was best before. 10 did nothing. 20 removed 85%.)
lots more data here…. But is that figure before trimming? I wonder if the high quality reads increase after trimming?
Is it in a specific format like before? 8bp UMI + GTTT?
Yes
Same adapters? CTGTCTCTTATACACATCTC
yes
Trim off polyAs again?
Yes. Keep in mind we need to count the poly-a for the no -cyst fluid subjects.
Do you want me to filter out anything like phiX?
Yes.
Align to hg38 and then featureCounts
i think we will certainly need that down the line. We can hopefully find something interesting in the cyst data that predicts the group
I'm not sure if I have any metadata.
Then iMOKA
Preference on k?
nope- shorter seemed better before  right? Maybe try 15 and 25 first?
Anything else?

```




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20211208-EV/raw"
curl -netrc -X MKCOL "${BOX}/"

for f in *fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```






```
for l in 4 6 8 10 12 14 16 18 20 22 24 26 28 30 ; do
for s in A B ; do
for r in 1 2 ; do
A=$( printf %${l}s | tr " " "A" )
T=$( printf %${l}s | tr " " "T" )
f=$( ls SFHH009${s}*_L001_R${r}_001.fastq.gz )
echo ${r} - ${s} - ${l} - ${A} - ${f}
zcat $f | sed -n '2~4p' | egrep -c "${A}|${T}" > ${f}.${l}AT_count.txt
done ; done ; done

```



```
./polyAT.bash > polyAT.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' polyAT.md > polyAT.csv
```



