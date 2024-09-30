
#	20240925-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects

o
+-----------------------------------------+-----------+--------------+
|                  Name                   |    Id     |  TotalSize   |
+-----------------------------------------+-----------+--------------+
| MEX_LEUK_2018                           | 60976917  | 132686382176 |
| Mex_leucemia_18                         | 61769708  | 66088939767  |
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506    |
| 09242024_HH_24PhIP1                     | 433007598 | 6338796247   |
+-----------------------------------------+-----------+--------------+

```


```
bs download project -i 433007598
```

```
cd ..
ll download/*/*z


-r--r----- 1 gwendt francislab 257342752 Sep 25 14:54 download/L10_091124_ds.984daa8a746a429eae642a2deee4f311/L10_091124_S10_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 276434368 Sep 25 14:49 download/L1_091124_ds.b532488b6d214116a33297007ed1b10d/L1_091124_S1_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 350218504 Sep 25 15:10 download/L11_091124_ds.7e139864d38a4b5d868355086db9c61c/L11_091124_S11_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 282333837 Sep 25 15:01 download/L12_091124_ds.3dd62c555792478fa2318b2ce4eb60fb/L12_091124_S12_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 317442803 Sep 25 15:20 download/L13_091124_ds.57cef9146e8a4b7f9357073ddd2e031b/L13_091124_S13_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 331590057 Sep 25 15:33 download/L14_091124_ds.83e8df65a8f844ca910c58c8db2b47d7/L14_091124_S14_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 304984529 Sep 25 15:12 download/L15_091124_ds.ae8b6a6e89ca4d61a3dcac8c9e313882/L15_091124_S15_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 280496725 Sep 25 15:08 download/L16_091124_ds.3fa81f2a8aa04d8bb4f23f7f4c86e422/L16_091124_S16_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 305896830 Sep 25 15:20 download/L17_091124_ds.6181f22cef4644b4baef36c56c4b1721/L17_091124_S17_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 263707878 Sep 25 14:56 download/L18_091124_ds.b8c78cb1cca44691ae8b816e0a5862ca/L18_091124_S18_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 298429279 Sep 25 15:09 download/L19_091124_ds.f64c1c407ee64bfd9ee85080a1489caf/L19_091124_S19_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 266756314 Sep 25 14:59 download/L20_091124_ds.56eca5888e8f48fe884c8108aeb03387/L20_091124_S20_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 285776591 Sep 25 15:27 download/L2_091124_ds.5405a8bbb626447fb09121082977148d/L2_091124_S2_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 271091487 Sep 25 15:13 download/L21_091124_ds.32befd1465d240f7b7f3a32c49b8ebfd/L21_091124_S21_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 289095599 Sep 25 15:02 download/L22_091124_ds.70b95cead728465a89b24cb01169878b/L22_091124_S22_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 243100405 Sep 25 14:57 download/L23_091124_ds.e6c3132f93774bbfbcd2efc80a0af834/L23_091124_S23_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 140769420 Sep 25 14:18 download/L24_091124_ds.8c039f0efe5947979e7fc9da1e647fa1/L24_091124_S24_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 262450969 Sep 25 15:00 download/L3_091124_ds.c1e76059a5c04fc289f449a217efccc0/L3_091124_S3_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 169819264 Sep 25 14:29 download/L4_091124_ds.0d33c22ba7e24d6db92089fefc4715a7/L4_091124_S4_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 259458289 Sep 25 14:55 download/L5_091124_ds.94bbd2cc880b4c6ebf5b4e5476079f71/L5_091124_S5_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 102073071 Sep 25 14:15 download/L6_091124_ds.ad6a57fd26d54523b167bbf32f4689b2/L6_091124_S6_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 243930354 Sep 25 14:44 download/L7_091124_ds.40289941fa244f7181e2313166e68eef/L7_091124_S7_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 273489529 Sep 25 15:03 download/L8_091124_ds.c135298ed36044c68d4f1ff08375e260/L8_091124_S8_L001_R1_001.fastq.gz
-r--r----- 1 gwendt francislab 262107393 Sep 25 15:02 download/L9_091124_ds.c1fa916d5236412797252bc5351d6a8d/L9_091124_S9_L001_R1_001.fastq.gz

```



Note that there is no "Undetermined"?


```
mkdir fastq
cd fastq

for f in ../download/*/*fastq.gz ; do
echo $f
b=$( basename $f _L001_R1_001.fastq.gz ) 
echo $b
b=${b%%_*}
echo $b
ln -s ${f} ${b}.fastq.gz
done
```



