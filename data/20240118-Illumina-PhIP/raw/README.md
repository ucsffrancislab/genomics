
#	20240118-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects


+-----------------------------------------+-----------+-----------+
|                  Name                   |    Id     | TotalSize |
+-----------------------------------------+-----------+-----------+
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506 |
| 122123_HH_4PhIP_2                       | 406413011 | 337928588 |
| 011624_HH_4PhIP                         | 407886485 | 379654096 |
+-----------------------------------------+-----------+-----------+
```


```
bs download project -i 407886485
```

```
cd ..
mkdir fastq

ln -s ../download/L1-111623_ds.250bdfefbf52454aba7c241d0dfbf77b/L1-111623_S1_L001_R1_001.fastq.gz fastq/S1.fastq.gz
ln -s ../download/L2-111623_ds.5bf59afb421c41e08ee62afb14721493/L2-111623_S2_L001_R1_001.fastq.gz fastq/S2.fastq.gz
ln -s ../download/L3-111623_ds.81f2735497094ff58b63d707d6c18041/L3-111623_S3_L001_R1_001.fastq.gz fastq/S3.fastq.gz
ln -s ../download/L4-111623_ds.911642c2c19d4a92b33a1ce0077ef0fb/L4-111623_S4_L001_R1_001.fastq.gz fastq/S4.fastq.gz
ln -s ../download/Undetermined_ds.9ddf647559a649b7a02ac2d2539abc98/Undetermined_S0_L001_R1_001.fastq.gz fastq/S0.fastq.gz
```



