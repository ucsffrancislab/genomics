
#	20240802-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects

+-----------------------------------------+-----------+------------+
|                  Name                   |    Id     | TotalSize  |
+-----------------------------------------+-----------+------------+
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506  |
| 080124_HH_12PhIP                        | 426632328 | 1622846602 |
+-----------------------------------------+-----------+------------+
```


```
bs download project -i 426632328
```

```
cd ..
ll download/*/*z


-rw-r----- 1 gwendt francislab  92334059 Aug  2 10:47 download/PBS_1_1_L001_ds.64be65cecc6f4b6eb9482b97c3cc2dd8/PBS-1-1_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 154395450 Aug  2 10:47 download/PBS_1_2_L001_ds.382712ff997149eeae61d768ff00d885/PBS-1-2_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 125522921 Aug  2 10:47 download/PBS_2_1_L001_ds.bbb52209388049dcb8a685801b54199c/PBS-2-1_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 147436077 Aug  2 10:47 download/PBS_2_2_L001_ds.5e88f5dab9f1450e9696ea64de92252b/PBS-2-2_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 137908310 Aug  2 10:47 download/PBS_3_1_L001_ds.e9ae5686d4084030b722faead6acd662/PBS-3-1_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 132083853 Aug  2 10:47 download/PBS_3_2_L001_ds.132c1025d4ff47f8aa53207629da1ec0/PBS-3-2_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 133801361 Aug  2 10:47 download/SE_1_1_L001_ds.d5d48ef381864275bf9640866da04849/SE-1-1_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 148152449 Aug  2 10:47 download/SE_1_2_L001_ds.e103cc4f68a1467799f1fd8877cddf15/SE-1-2_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 134082750 Aug  2 10:47 download/SE_2_1_L001_ds.252ddb3f376949ce87c1ba6ffc0b20ca/SE-2-1_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 137322075 Aug  2 10:47 download/SE_2_2_L001_ds.9a9e3ac3310f46e7a754f4418ee3118f/SE-2-2_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 134859609 Aug  2 10:47 download/SE_3_1_L001_ds.36651357a23741d28849582677a7cfe7/SE-3-1_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 144947688 Aug  2 10:47 download/SE_3_2_L001_ds.5dc9798967ef401697a057a26ce0a4a1/SE-3-2_S10_L001_R1_001.fastq.gz

```



Note that there is no "Undetermined"?


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



