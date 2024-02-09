
#	20220610-EV/20240208-TensorFlow



```
ln -s ../20240201-iMOKA/in
ln -s ../20240201-iMOKA/out
ln -s ../20240201-iMOKA/20210428.metadata.csv
ln -s ../20240201-iMOKA/20220610.metadata.csv
```



```
awk -F, '{print $2,$3}' 20210428.metadata.csv | sort | uniq -c
      1 blank1-(C1) 
      1 blank-2-(C1) 
     10 Diffuse-Astrocytoma IDH-mutant
     10 GBM IDH1R132H-WT
     10 GBM IDH-mutant
     10 Oligodendroglioma IDH-mutant
      2 V01-control-(S1) 
```



```
awk 'BEGIN{FS=",";OFS="\t"}($2=="Diffuse-Astrocytoma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="Oligodendroglioma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH-mutant"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH1R132H-WT"){print $1,"IDH-WT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
```


```
awk -F, '{print $7,$8,$9}' 20220610.metadata.csv | sort | uniq -c
     18 case control control control
     18 case control GBM Primary
     17 case control GBM Recurrent
      6 longitudinal GBM pre-progression
      6 longitudinal GBM pre-surg
      6 longitudinal GBM progression
      5 longitudinal GBM stable
      1 Panattoni GBM post-recurrence
      1 Panattoni GBM recurence
      1 Panattoni LrGG primary
      1 Panattoni LrGG(?) scan
      6 Test-SE Test-SE Test-SE
```


```

awk 'BEGIN{FS=",";OFS="\t"}($7=="case control" && $8=="GBM" && $9=="Primary"){print $1,"IDH-WT"}' 20220610.metadata.csv | shuf|shuf|shuf | tee >(head -10 >> train_ids.tsv) | tail -n 8 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($7=="case control" && $8=="control" && $9=="control"){print $1,"control"}' 20220610.metadata.csv | shuf|shuf|shuf | tee >(head -10 >> train_ids.tsv) | tail -n 8 >> test_ids.tsv

```




