
#	20240311-Illumina-PhIP


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
| 030524_HH_4PhIP_L1                      | 412054646 | 282865337 |
+-----------------------------------------+-----------+-----------+
```


```
bs download project -i 412054646
```

```
cd ..
ll download/*/*z
-rw-r----- 1 gwendt francislab   2413535 Mar 11 10:54 download/L1-022224_ds.62d0bc3aafcc45088e79cecc45f6e42f/L1-022224_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1704130 Mar 11 10:54 download/L2-022224_ds.62643abf17bc4c02a8761604ae2cd965/L2-022224_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 139030427 Mar 11 10:55 download/L3-022224_ds.555386deceeb4e4090677f50efb66af4/L3-022224_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 122899762 Mar 11 10:55 download/L4-022224_ds.35d4e315b81b4a35b46a06ac47bf10d4/L4-022224_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16817483 Mar 11 10:54 download/Undetermined_ds.5b99167432eb48b9bfae328ab8557182/Undetermined_S0_L001_R1_001.fastq.gz
```


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





