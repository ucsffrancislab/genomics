
#	20240328-Illumina-PhIP


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
| 030524_HH_4PhIP_L1                      | 412054646 | 282865337 |
| 032524_HH_4PhIP_P2                      | 413488296 | 364293052 |
+-----------------------------------------+-----------+-----------+
```


```
bs download project -i 413488296
```

```
cd ..
ll download/*/*z

-rw-r----- 1 gwendt francislab   3781204 Mar 28 10:56 download/L5_022224_L001_ds.509c8a969a3b4e269f295e19be359e63/L5-022224_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   3109620 Mar 28 10:56 download/L6_022224_L001_ds.c2c9d03bc22e4da8b9cec0e0a9a47375/L6-022224_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 175222239 Mar 28 10:57 download/L7_022224_L001_ds.bac668f3dccd41b9a268d60fb31b3405/L7-022224_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182179989 Mar 28 10:57 download/L8_022224_L001_ds.3485709ff07546609626cb4e4c81a73e/L8-022224_S4_L001_R1_001.fastq.gz

```



Note that there is no "Undetermine"?


```
mkdir fastq
cd fastq

for f in ../download/*/*fastq.gz ; do
echo $f
b=$( basename $f _L001_R1_001.fastq.gz ) 
echo $b
b=${b##*_}
echo $b
ln -s ${f} ${b}.fastq.gz
done
```





