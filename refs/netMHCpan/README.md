
#	netMHCpan

```
ln -s ~/.local/netMHCpan-4.1/data/MHC_pseudo.dat

sort -k1,1 MHC_pseudo.dat > MHC_pseudo.join_sorted.dat
```


MHC Class I will not include the following which are in the AGS file but not in the script's data file ...


sdiff -Wsd AGS41970_HLA.ABC.txt MHC_pseudo.dat.ABC | cut -f1 | paste -s | sed 's/ \t/, /g'
HLA-A01, HLA-A02, HLA-A03, HLA-A11, HLA-A23, HLA-A24, HLA-A2401, HLA-A25, HLA-A26, HLA-A29, HLA-A30, HLA-A31, HLA-A32, HLA-A33, HLA-A34, HLA-A36, HLA-A66, HLA-A68, HLA-A69, HLA-A74, HLA-A80, HLA-B07, HLA-B08, HLA-B13, HLA-B14, HLA-B15, HLA-B1526, HLA-B18, HLA-B27, HLA-B35, HLA-B37, HLA-B38, HLA-B39, HLA-B40, HLA-B41, HLA-B42, HLA-B44, HLA-B45, HLA-B46, HLA-B47, HLA-B48, HLA-B49, HLA-B50, HLA-B51, HLA-B52, HLA-B53, HLA-B54, HLA-B55, HLA-B56, HLA-B57, HLA-B58, HLA-B73, HLA-B78, HLA-B81, HLA-C01, HLA-C02, HLA-C03, HLA-C04, HLA-C05, HLA-C06, HLA-C07, HLA-C08, HLA-C12, HLA-C14, HLA-C15, HLA-C16, HLA-C17, HLA-C18 



Select even fewer alleles based on whats in AGS. May include duplicates but so few, don't really care.

```
cat AGS41970_HLA.tsv | datamash transpose | grep "HLA_[ABC]" | sed -e 's/_/-/' -e 's/_//' | cut -f1 | sort > AGS_ABC
chmod -w AGS_ABC

```

```
join AGS_ABC MHC_pseudo.join_sorted.dat | cut -d' ' -f1 > AGS_ABC.exists
chmod -w AGS_ABC.exists
ln -s AGS_ABC.exists AGS_select
```

