
#	20231227-Illumina-PhIP


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
+-----------------------------------------+-----------+-----------+
```


```
bs download project -i 406413011
```

```
cd ..
mkdir fastq

ln -s ../download/Undetermined_ds.9cf516851e7e425e83675f54ac33b345/Undetermined_S0_L001_R1_001.fastq.gz fastq/S0.fastq.gz
ln -s ../download/L1-111623_ds.7ce790ccc48e4f409f3588d0d385a84b/L1-111623_S1_L001_R1_001.fastq.gz fastq/S1.fastq.gz
ln -s ../download/L2-111623_ds.50a2ece6df1f4704b33a4426bfb4c4d7/L2-111623_S2_L001_R1_001.fastq.gz fastq/S2.fastq.gz
ln -s ../download/L3-111623_ds.14574dd556b74936bd7ea811ec6903fa/L3-111623_S3_L001_R1_001.fastq.gz fastq/S3.fastq.gz
ln -s ../download/L4-111623_ds.18d17692b1a2416facfee9456dadb6fb/L4-111623_S4_L001_R1_001.fastq.gz fastq/S4.fastq.gz
```



