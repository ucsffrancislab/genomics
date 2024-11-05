
#	netMHCIIpan


```
ln -s ~/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat
sort -k1,1 pseudosequence.2023.all.X.dat > pseudosequence.2023.all.X.join_sorted.dat 
```



Creating a list with just those alleles in the AGS list



The MHC Class II data file a clear HLA-DRB naming convention, however, the DPB and DQB are labeled as such existing in the list several times and not always with the same sequence.
HLA-DPA10103-DPB



cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DPA


grep HLA-DQA pseudosequence.2023.all.X.dat | head -2
HLA-DQA10101-DQB10201 CNYHEGGGARVAHIMYFGLSSFAIRKARVHLETT
HLA-DQA10101-DQB10202 CNYHEGGGARVAHIMYFGLSSFAIRKARVHLETT

grep HLA-DPA pseudosequence.2023.all.X.dat | head -2
HLA-DPA10103-DPB10101 YAFFMFSGGAILNTLYGQFEYFAIEKVRVHLDVT
HLA-DPA10103-DPB10201 YAFFMFSGGAILNTLFGQFEYFDIEEVRMHLGMT



```
cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DPA | sed -e 's/^HLA_//' -e 's/_//' | cut -f1 | grep '........'
DPA10103
DPA10104
DPA10105
DPA10201
DPA10202
DPA10301
DPA10401

```




```
cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DPA | sed -e 's/^HLA_//' -e 's/_//' | cut -f1 > AGS_DPA

cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DPB | sed -e 's/^HLA_//' -e 's/_//' | cut -f1 > AGS_DPB

cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DQA | sed -e 's/^HLA_//' -e 's/_//' | cut -f1 > AGS_DQA

cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DQB | sed -e 's/^HLA_//' -e 's/_//' | cut -f1 > AGS_DQB

chmod -w AGS_D??

```



```

awk '(NR==FNR){ a[$1]=1 }(NR!=FNR){ for(x in a){print "HLA-"x"-"$1} }' AGS_DPA AGS_DPB | sort > AGS_DPABChains
awk '(NR==FNR){ a[$1]=1 }(NR!=FNR){ for(x in a){print "HLA-"x"-"$1} }' AGS_DQA AGS_DQB | sort > AGS_DQABChains
chmod -w AGS_D?ABChains
```

Sadly, they use different formats

```
cat AGS41970_HLA.tsv | datamash transpose | grep HLA_DRB | sed -e 's/^HLA_//' | cut -f1 | sort > AGS_DRB
chmod -w AGS_DRB
```


Create "exists lists"

Use join?


```

join AGS_DRB pseudosequence.2023.all.X.join_sorted.dat | cut -d' ' -f1 > AGS_DRB.exists

join AGS_DPABChains pseudosequence.2023.all.X.join_sorted.dat | cut -d' ' -f1 > AGS_DPABChains.exists
join AGS_DQABChains pseudosequence.2023.all.X.join_sorted.dat | cut -d' ' -f1 > AGS_DQABChains.exists

chmod -w *exists


cat *exists | sort > AGS_select
chmod -w AGS_select

```

```
wc -l pseudosequence.2023.all.X.join_sorted.dat AGS_select
join AGS_select pseudosequence.2023.all.X.join_sorted.dat | wc -l
join AGS_select pseudosequence.2023.all.X.join_sorted.dat | awk '{if(!seen[$2]){seen[$2]=1;print}}' | wc -l
join AGS_select pseudosequence.2023.all.X.join_sorted.dat | awk '{if(!seen[$2]){seen[$2]=1;print}}' | cut -d' ' -f1 > AGS_select.firsts
chmod -w AGS_select.firsts
```

```
wc -l pseudosequence.2023.all.X.join_sorted.dat AGS_select AGS_select.firsts
```

```
 11048 pseudosequence.2023.all.X.join_sorted.dat
   433 AGS_select
   319 AGS_select.firsts
 11800 total
```


