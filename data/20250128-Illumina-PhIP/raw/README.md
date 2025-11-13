
#	20250128-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects >> ../README.md 


+-----------------------------------------+-----------+--------------+
|                  Name                   |    Id     |  TotalSize   |
+-----------------------------------------+-----------+--------------+
| MEX_LEUK_2018                           | 60976917  | 132686382176 |
| Mex_leucemia_18                         | 61769708  | 66088939767  |
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506    |
| 012225_192PhiP_L3                       | 443475155 | 22362910155  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 443475155
```

```
cd ..
ll download/*/*z >> README.md

-rw-r----- 1 gwendt francislab 189137759 Jan 28 07:56 download/1403401_012225_ds.d6625366b92c4b40bfdf27c21b8b7d2d/1403401_012225_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 188497132 Jan 28 07:56 download/1403401dup_012225_ds.e23c48d1b4124fe5a7fe16fed809103c/1403401dup_012225_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 190291174 Jan 28 07:56 download/1403601_012225_ds.6c8e3097953143289bb72e4d924f7894/1403601_012225_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 170935866 Jan 28 07:56 download/1403601dup_012225_ds.2a59ce6d01f74c98ac588f114d3635fd/1403601dup_012225_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 171727556 Jan 28 07:56 download/1405501_012225_ds.d060ba25f83a4732939832ce1844dc11/1405501_012225_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193668346 Jan 28 07:56 download/1405501dup_012225_ds.80ef641143224fa185cb3a3e276f70be/1405501dup_012225_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11499378 Jan 28 07:56 download/1406701_012225_ds.cbcde0f797014d999ab16cfe726542bc/1406701_012225_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9234652 Jan 28 07:56 download/1406701dup_012225_ds.9be689ee952e4412a21b75cead40cc91/1406701dup_012225_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193276527 Jan 28 07:56 download/1408501_012225_ds.ff6d036a7e004ac0a58a9ced186b6859/1408501_012225_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 188778870 Jan 28 07:56 download/1408501dup_012225_ds.b70b83d1df494adb8dee33be023d83bd/1408501dup_012225_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15500722 Jan 28 07:56 download/1408801_012225_ds.9562840564d2471c84d506f309035524/1408801_012225_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14321157 Jan 28 07:56 download/1408801dup_012225_ds.e6f5e599206044f3a4f3a90e42144b17/1408801dup_012225_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 212335056 Jan 28 07:56 download/1408901_012225_ds.04846bb40c0445f48956561a0bee2d97/1408901_012225_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 197533940 Jan 28 07:56 download/1408901dup_012225_ds.c9b0f78317024a339b6d5693de23090f/1408901dup_012225_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12605539 Jan 28 07:56 download/1413004_012225_ds.f3646ecc770641999c073b943a044677/1413004_012225_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14530279 Jan 28 07:56 download/1413004dup_012225_ds.4073eca368bd4e5b9ffe7d3541560f7f/1413004dup_012225_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  38510497 Jan 28 07:56 download/1413801_012225_ds.13c56fa752ae4659b620d8c18430c137/1413801_012225_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12648000 Jan 28 07:56 download/1413801dup_012225_ds.98ab7dc1c59e4dc388b5ad83230b8ee4/1413801dup_012225_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 212817625 Jan 28 07:56 download/1414401_012225_ds.6876a647a836484798230b735c7fe568/1414401_012225_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182894896 Jan 28 07:56 download/1414401dup_012225_ds.dc0d32753e6142a9bdb855613ea42b04/1414401dup_012225_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  19455855 Jan 28 07:56 download/1414501_012225_ds.f2da5697da494727a1725d6a6162bef7/1414501_012225_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15190850 Jan 28 07:56 download/1414501dup_012225_ds.31b50f716966414f922a3d07dec45ae0/1414501dup_012225_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182617250 Jan 28 07:56 download/1417901_012225_ds.73019bca4c944eccb8676421fa7d3364/1417901_012225_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 208814317 Jan 28 07:56 download/1417901dup_012225_ds.d93d310efb27414b81e3fc71bd611ecf/1417901dup_012225_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9474031 Jan 28 07:56 download/1420401_012225_ds.cfd37bb502904ae4aad9e48fdaee8aff/1420401_012225_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9671238 Jan 28 07:56 download/1420401dup_012225_ds.5ed00df53e34441f949493dfb2dc230c/1420401dup_012225_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 174026753 Jan 28 07:56 download/1422701_012225_ds.5dbd820761664622a7534706f6afb13c/1422701_012225_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 197993007 Jan 28 07:56 download/1422701dup_012225_ds.d8e6af6e529244bb8849615a84840ef1/1422701dup_012225_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16435788 Jan 28 07:56 download/1427701_012225_ds.510f7e1e5526496a8880491439ff06f7/1427701_012225_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15252604 Jan 28 07:56 download/1427701dup_012225_ds.2aa1a3aa5893419da818305a5049c0a9/1427701dup_012225_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10096392 Jan 28 07:56 download/1428201_012225_ds.118f6d6a0daa4feea935e9b2088e4bf8/1428201_012225_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13854087 Jan 28 07:56 download/1428201dup_012225_ds.1175948879f34ccab05e89621bc9d825/1428201dup_012225_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13895132 Jan 28 07:56 download/1429001_012225_ds.c41833413728496b8626d92243c5be7d/1429001_012225_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  18200861 Jan 28 07:56 download/1429001dup_012225_ds.f56a5e3544b844f89d4a24a411075168/1429001dup_012225_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16729838 Jan 28 07:56 download/1435001_012225_ds.94311335df35416594e02dc0e4711a23/1435001_012225_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14552326 Jan 28 07:56 download/1435001dup_012225_ds.ea47e19e16b947d4a0cb2b8e622362b1/1435001dup_012225_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  26089600 Jan 28 07:56 download/1439401_012225_ds.ff0ea4dd10994657bc8374b1e900fc1c/1439401_012225_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16669869 Jan 28 07:56 download/1439401dup_012225_ds.2ee426162bb24835bf07e934fb18e3c6/1439401dup_012225_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 198217961 Jan 28 07:56 download/1442301_012225_ds.5250b4d4262b43e58d9a351b392c469d/1442301_012225_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 186674298 Jan 28 07:56 download/1442301dup_012225_ds.532b868d326646a6bb1efe219fa0b264/1442301dup_012225_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 192269087 Jan 28 07:56 download/1444101_012225_ds.2acfdfa600824ddd9128463a12b8f4a8/1444101_012225_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 216511897 Jan 28 07:56 download/1444101dup_012225_ds.8157ed71b1b84bf99f1881376f1967ae/1444101dup_012225_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 190184074 Jan 28 07:56 download/1445201_012225_ds.be03ce757f554e3b8e62d0fa33d94013/1445201_012225_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 225397081 Jan 28 07:56 download/1445201dup_012225_ds.7e6e55b529fc42e1a8a85a7c5da7604a/1445201dup_012225_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 191225141 Jan 28 07:56 download/1445601_012225_ds.d5642eaa1a5444f2862b092ac068831d/1445601_012225_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 181896711 Jan 28 07:56 download/1445601dup_012225_ds.b35c6630cfb34d8184b7e524b8af6473/1445601dup_012225_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 176626275 Jan 28 07:56 download/1457901_012225_ds.73d813b9839e47a7a71f3d6503cb1cc8/1457901_012225_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 206501402 Jan 28 07:56 download/1457901dup_012225_ds.cc5cf9fcfd4b41cb8961e0ec77ce47e1/1457901dup_012225_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12999882 Jan 28 07:56 download/1459801_012225_ds.78ac5617bb2b42b7acac5a8a809e1c5a/1459801_012225_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11094063 Jan 28 07:56 download/1459801dup_012225_ds.0e634c0112f64474863ee52099dfcc93/1459801dup_012225_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 201685890 Jan 28 07:56 download/1465201_012225_ds.14c877c350af4459bfb5320326591498/1465201_012225_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 215974191 Jan 28 07:56 download/1465201dup_012225_ds.ef08cb6d86964d4c8dd418e7c9b2fb3b/1465201dup_012225_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13647422 Jan 28 07:56 download/1465701_012225_ds.b72059a35fa44018856030e1610843be/1465701_012225_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  19352261 Jan 28 07:56 download/1465701dup_012225_ds.6dedf69fc48c4b94b144b996767b3f5a/1465701dup_012225_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17241491 Jan 28 07:56 download/1472201_012225_ds.36c2c4d62b164bd4a91a220d19e8766a/1472201_012225_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17735938 Jan 28 07:56 download/1472201dup_012225_ds.f742bedd43bc40059c41bee80e4cc703/1472201dup_012225_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 179057298 Jan 28 07:56 download/1474101_012225_ds.a771c41eaffa4f99abb15df8ead8cbea/1474101_012225_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 167895914 Jan 28 07:56 download/1474101dup_012225_ds.94093d9cd45248e9b17fe7ef277f3d68/1474101dup_012225_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16540027 Jan 28 07:56 download/1474302_012225_ds.90be5457055a4788a43e20c9bb532aee/1474302_012225_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12495852 Jan 28 07:56 download/1474302dup_012225_ds.6f4ff02601f3484d9e481159d85db966/1474302dup_012225_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 186758164 Jan 28 07:56 download/1480601_012225_ds.2c902f56b63345ee96b54fb76012ea89/1480601_012225_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 203585310 Jan 28 07:56 download/1480601dup_012225_ds.8fa2c6cbcb6c46e2a18d5a01282c9265/1480601dup_012225_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 191877199 Jan 28 07:56 download/1481101_012225_ds.87dcbdf4a19940e48c1b832ec2cdfbe3/1481101_012225_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 162130124 Jan 28 07:56 download/1481101dup_012225_ds.01d678b9d4e74be39635e5ba74569265/1481101dup_012225_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  16981781 Jan 28 07:56 download/1486601_012225_ds.6d5ebc29a0714af2a677cfc00bc3c75c/1486601_012225_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  20260428 Jan 28 07:56 download/1486601dup_012225_ds.1921856367cc4c43b17a44bb1d4390b9/1486601dup_012225_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 206806464 Jan 28 07:56 download/1490801_012225_ds.7aad8da56471447b9516fcd13ea49057/1490801_012225_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 190136432 Jan 28 07:56 download/1490801dup_012225_ds.d47dba3fe5334f80bbf15a06c9f24cda/1490801dup_012225_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15519102 Jan 28 07:56 download/1491001_012225_ds.c2025c8f946c4c4eb13011970f1d95f6/1491001_012225_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12641945 Jan 28 07:56 download/1491001dup_012225_ds.b4d392d8f2b245de896d567e0962824e/1491001dup_012225_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12843794 Jan 28 07:56 download/1492201_012225_ds.34a10714a9164848bab49298bb6169df/1492201_012225_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  27260292 Jan 28 07:56 download/1492201dup_012225_ds.38e4540961094857b240e9268b17e157/1492201dup_012225_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15732274 Jan 28 07:56 download/1492501_012225_ds.5a49c803d56b40cda1a2b242073a2525/1492501_012225_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  22999315 Jan 28 07:56 download/1492501dup_012225_ds.8feb01254c8443c4b02e3d535d1e99af/1492501dup_012225_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 175782525 Jan 28 07:56 download/1499001_012225_ds.f606523b57e44087a136cb21236c105b/1499001_012225_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 159723122 Jan 28 07:56 download/1499001dup_012225_ds.5036fdb7234548ea9324c291940699d7/1499001dup_012225_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 189775190 Jan 28 07:56 download/1499701_012225_ds.2baa3ba15bf14f5e89e4b973383dc2ec/1499701_012225_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 207710903 Jan 28 07:56 download/1499701dup_012225_ds.73a85d7d4e3d4079905b6ec2f283a833/1499701dup_012225_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12970950 Jan 28 07:56 download/1499801_012225_ds.6931e57a61c14d379eed253cc045c601/1499801_012225_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  20684724 Jan 28 07:56 download/1499801dup_012225_ds.072f1114240c43fe9208618ecf0afaef/1499801dup_012225_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14345316 Jan 28 07:56 download/1801901_012225_ds.9bf92747562d46c998de154a4b2c2bf7/1801901_012225_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17456172 Jan 28 07:56 download/1801901dup_012225_ds.ddc9699e99dd4654b04b772f472e0bc8/1801901dup_012225_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 196703983 Jan 28 07:56 download/1802101_012225_ds.beb14b60602144f0a4dc537f9ccf6aee/1802101_012225_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 139805104 Jan 28 07:56 download/1802101dup_012225_ds.86a21ea547af415e99229ed621edab45/1802101dup_012225_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 202277611 Jan 28 07:56 download/20063_012225_ds.98804e097b004f62926449100ce226cf/20063_012225_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 178037756 Jan 28 07:56 download/20063dup_012225_ds.8fe6327efad84308a44d427562d17726/20063dup_012225_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 198549752 Jan 28 07:56 download/20108_012225_ds.30f80cc1f5dd4aa99e7113f3af860395/20108_012225_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 190022046 Jan 28 07:56 download/20108dup_012225_ds.a4fe0bbb35ec44279a7ed2abb709e2fb/20108dup_012225_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 183709835 Jan 28 07:56 download/20162_012225_ds.623ae9a2950d42c9932dfe052170607b/20162_012225_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 194803810 Jan 28 07:56 download/20162dup_012225_ds.6c3f4e6686ff4eb196b6a92c27067ac5/20162dup_012225_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 198407638 Jan 28 07:56 download/20180_012225_ds.f975993408f34a3983d262d1d5747337/20180_012225_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193652047 Jan 28 07:56 download/20180dup_012225_ds.3d2149813cb5459391e1d3d1abd25c53/20180dup_012225_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   6513985 Jan 28 07:56 download/20224_012225_ds.445de58afab74bee96075c5dc735ee98/20224_012225_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   5234061 Jan 28 07:56 download/20224dup_012225_ds.3f95c8ee02c94c56af296cd9a475e928/20224dup_012225_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9033819 Jan 28 07:56 download/20258_012225_ds.79d6ed8345be48df967f961a5ca8df5d/20258_012225_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10308930 Jan 28 07:56 download/20258dup_012225_ds.0a3491e68d3045a5b55a3f0226565393/20258dup_012225_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 153824230 Jan 28 07:56 download/20293_012225_ds.4e68aa93fd6d44c89b47ea215dee4b6f/20293_012225_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 154520033 Jan 28 07:56 download/20293dup_012225_ds.57bfa5fa9b0549a29b3caf9b619c023f/20293dup_012225_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 191905310 Jan 28 07:56 download/20307_012225_ds.cafba520bd6546219062a948884cc97c/20307_012225_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 175011287 Jan 28 07:56 download/20307dup_012225_ds.6e3d9e2824eb477a8750383c6b1bfacb/20307dup_012225_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 185312221 Jan 28 07:56 download/20371_012225_ds.31c065e3acf94154b204e49de9e9f54f/20371_012225_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 173970269 Jan 28 07:56 download/20371dup_012225_ds.1609a5c72b0446d4be74c68298126655/20371dup_012225_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10750469 Jan 28 07:56 download/20400_012225_ds.37cf05c6495f46258d115e9d928dab3b/20400_012225_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   8735621 Jan 28 07:56 download/20400dup_012225_ds.f58fc46a812f49e68e65358e8f205187/20400dup_012225_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 203743607 Jan 28 07:56 download/20419_012225_ds.eaaf26b4ceb744f1939330286e1e0133/20419_012225_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 190451605 Jan 28 07:56 download/20419dup_012225_ds.6201689fbad14395b07286affeea9e46/20419dup_012225_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 180673137 Jan 28 07:56 download/20432_012225_ds.cc6a9a00b8854e368a85b8766a94d5a4/20432_012225_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 197640981 Jan 28 07:56 download/20432dup_012225_ds.672509b5d17c46d9bf8acfeadcf4974e/20432dup_012225_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193048967 Jan 28 07:56 download/20458_012225_ds.28ec77e5bffd4ace9dfe508a810f09a9/20458_012225_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 183110921 Jan 28 07:56 download/20458dup_012225_ds.ed5359a89e144837ba954e3a960c3e94/20458dup_012225_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 178556523 Jan 28 07:56 download/20464_012225_ds.73f57b35fe04412a9f56826d077979e4/20464_012225_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 204101944 Jan 28 07:56 download/20464dup_012225_ds.77ab644d698f45b6b2f19b9b71393878/20464dup_012225_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12260668 Jan 28 07:56 download/20483_012225_ds.f79a49e952844322849c87d893f800bd/20483_012225_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15529668 Jan 28 07:56 download/20483dup_012225_ds.b74318d44f6145698cbf0cd4ea86b002/20483dup_012225_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 210083803 Jan 28 07:56 download/20489_012225_ds.d7da160899c046b98dd687058d89f259/20489_012225_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 177275582 Jan 28 07:56 download/20489dup_012225_ds.33ca3381f3c74c568c38c455f32cf6af/20489dup_012225_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14806292 Jan 28 07:56 download/20492_012225_ds.cf1f267f1636426587fff7ee29fa2c92/20492_012225_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13468065 Jan 28 07:56 download/20492dup_012225_ds.1d2d7c04a7cd4fbdb24f2a79ef64a370/20492dup_012225_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15280567 Jan 28 07:56 download/20493_012225_ds.3c5c8ff1a4514ad6904d7b610e5e8d0c/20493_012225_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  21921488 Jan 28 07:56 download/20493dup_012225_ds.5fc5afa2c80f4e429e46512379edf05f/20493dup_012225_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15891974 Jan 28 07:56 download/21035_012225_ds.d71f086fd8804e1d8deacbd3b6da6ade/21035_012225_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17240324 Jan 28 07:56 download/21035dup_012225_ds.d18fa9ddc453424c9892438e95d78729/21035dup_012225_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  19326061 Jan 28 07:56 download/21088_012225_ds.f4fbdf9da00149e3a0a1b90c9fafcc6b/21088_012225_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12176985 Jan 28 07:56 download/21088dup_012225_ds.cfd7863272f64519b8e6e57b50a71c2e/21088dup_012225_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 176116932 Jan 28 07:56 download/21122_012225_ds.1c5aa4f4b242431eb8e8801a87998512/21122_012225_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182342820 Jan 28 07:56 download/21122dup_012225_ds.45d0c4b81f1c4f09a5053cf07924db29/21122dup_012225_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 204298651 Jan 28 07:56 download/21164_012225_ds.3879583b879242d3a8c0156546dbb5bc/21164_012225_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 204340173 Jan 28 07:56 download/21164dup_012225_ds.e77d2ee19e464e48ba8bec01a960cb6d/21164dup_012225_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 184860085 Jan 28 07:56 download/21183_012225_ds.7b977d3bd0ae4eed9cbaa5e3081e8554/21183_012225_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 201567961 Jan 28 07:56 download/21183dup_012225_ds.99d73fadd17b4cffaf1da90536280629/21183dup_012225_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15740503 Jan 28 07:56 download/21204_012225_ds.2238e8063ed44740a7e7c9517b6f8cc7/21204_012225_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12141979 Jan 28 07:56 download/21204dup_012225_ds.cfd52efc0c7149c3911584faf88728ba/21204dup_012225_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11435207 Jan 28 07:56 download/21223_012225_ds.c0dd90e66f904e1a97cf1040d4534a1e/21223_012225_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9716363 Jan 28 07:56 download/21223dup_012225_ds.d2dab66fd9cc44c8a445e339207abf2d/21223dup_012225_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193596893 Jan 28 07:56 download/21239_012225_ds.a77062c765e94a25bd7e21f450a06019/21239_012225_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193502274 Jan 28 07:56 download/21239dup_012225_ds.361ee8bdcdb54a2cba033c19a96a7d13/21239dup_012225_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   8753592 Jan 28 07:56 download/3056_012225_ds.d398087f6faf48b3aee44b43fa6cf400/3056_012225_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   8737763 Jan 28 07:56 download/3056dup_012225_ds.e59b29604c4c4d929194db8338b5392f/3056dup_012225_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11464791 Jan 28 07:56 download/3211_012225_ds.90f68c2d1fa44b2d91e9c892be248f98/3211_012225_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9469953 Jan 28 07:56 download/3211dup_012225_ds.2d54ea3f4e7c4aa7a7e715be0c2027c2/3211dup_012225_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 184742670 Jan 28 07:56 download/3275_012225_ds.19041ec7c2824f83aa26c69670b9d710/3275_012225_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 178647041 Jan 28 07:56 download/3275dup_012225_ds.d588e798024749a39e9d9ff56c0162c4/3275dup_012225_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15754196 Jan 28 07:56 download/3314_012225_ds.374eccba25e64742a38c6967724ef02e/3314_012225_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17802660 Jan 28 07:56 download/3314dup_012225_ds.e9b7fbae6290435db64c01f5b83ffb8a/3314dup_012225_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 193318001 Jan 28 07:56 download/3439_012225_ds.bdd2a03ce67546bc9cfd0e60048e9b96/3439_012225_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 163420863 Jan 28 07:56 download/3439dup_012225_ds.3bc5344e09d049cbbe8763ba440eeb9b/3439dup_012225_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 204034722 Jan 28 07:56 download/4215_012225_ds.27167437062e42fe9285bd904ed57843/4215_012225_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 204400699 Jan 28 07:56 download/4215dup_012225_ds.adcdc2e1ccda4a4087f1c547dc39da50/4215dup_012225_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14819159 Jan 28 07:56 download/4310_012225_ds.5afe3c1b44f043e0bf6911d1e54e2264/4310_012225_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   8506570 Jan 28 07:56 download/4310dup_012225_ds.df40e0df2afd41a6a661c994ef9030a0/4310dup_012225_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9902996 Jan 28 07:56 download/4441_012225_ds.dfa2d81898eb4aa483445f3bcfa53206/4441_012225_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9170362 Jan 28 07:56 download/4441dup_012225_ds.e185c01f58284b7dacebb3531be9614c/4441dup_012225_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182844586 Jan 28 07:56 download/4462_012225_ds.e4c10757e2354fec89db529004d374dc/4462_012225_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 167137489 Jan 28 07:56 download/4462dup_012225_ds.470b9dbef44d4267be360e878d2ca9b6/4462dup_012225_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13050070 Jan 28 07:56 download/4471_012225_ds.2d7f6f4a654b4b39ba052cc13bcbdfde/4471_012225_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13047257 Jan 28 07:56 download/4471dup_012225_ds.536a7e91b31f4e9bb7dfd157ecab9fe9/4471dup_012225_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9892600 Jan 28 07:56 download/4474_012225_ds.e13ca094cf814cd380ebe6099af8d352/4474_012225_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12512106 Jan 28 07:56 download/4474dup_012225_ds.6e203acd886244df99aa635c16437ded/4474dup_012225_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14097862 Jan 28 07:56 download/4497_012225_ds.85781aeb9ff547daa198de598672ad33/4497_012225_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12922576 Jan 28 07:56 download/4497dup_012225_ds.78d866666f054d00aca74dc7b12749b8/4497dup_012225_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  19966730 Jan 28 07:56 download/4508_012225_ds.58ccb0eccee34189897d3db84b2af447/4508_012225_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11701240 Jan 28 07:56 download/4508dup_012225_ds.095b6ae9f2904f4c8183a1dbd9182c0f/4508dup_012225_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 185940532 Jan 28 07:56 download/4534_012225_ds.0221378340f947ff80bd5018790bb405/4534_012225_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 210665726 Jan 28 07:56 download/4534dup_012225_ds.326a1c962737455eab2fd01081941288/4534dup_012225_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  13012384 Jan 28 07:56 download/4547_012225_ds.3bce0510a23542d1a8428a634fd36810/4547_012225_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  18491389 Jan 28 07:56 download/4547dup_012225_ds.c5a2ed00c2334bb382697ed5fd9f0259/4547dup_012225_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  12644154 Jan 28 07:56 download/4554_012225_ds.f67ebf63c7df4166a88184d749ea8059/4554_012225_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  24462839 Jan 28 07:56 download/4554dup_012225_ds.bd227eda2e314ee2b5b3c9fdcc4e7127/4554dup_012225_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 217399985 Jan 28 07:56 download/Blank09_012225_ds.0c2ecf7a25784986a264eebac0c0e353/Blank09_012225_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182586579 Jan 28 07:56 download/Blank09dup_012225_ds.9a1279a8cb014eb3aaf509989d71a6b7/Blank09dup_012225_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 245713756 Jan 28 07:56 download/Blank10_012225_ds.f90dcf817e774cdc858ffdd1f772a488/Blank10_012225_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 188683781 Jan 28 07:56 download/Blank10dup_012225_ds.0fe6b2bc178c490f9e4baa7b66a07fd0/Blank10dup_012225_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 242900131 Jan 28 07:56 download/Blank11_012225_ds.e9db723921d840df9834eb7e84ce6a1e/Blank11_012225_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 220751299 Jan 28 07:56 download/Blank11dup_012225_ds.9dbd977b798843c3b15a6efaeb533314/Blank11dup_012225_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 237230585 Jan 28 07:56 download/Blank12_012225_ds.3f31f304ec394f0cbc3c0375fdd4202a/Blank12_012225_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 180384525 Jan 28 07:56 download/Blank12dup_012225_ds.eb8ec4b72c8c4b3bbfaaf4083066fba4/Blank12dup_012225_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  14161086 Jan 28 07:56 download/Blank13_012225_ds.3781f43ee41c4f939e9fc1d18f7aa4db/Blank13_012225_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   9949876 Jan 28 07:56 download/Blank13dup_012225_ds.a4a1ca3850674adc8fe1fbc9669c34d2/Blank13dup_012225_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11764046 Jan 28 07:56 download/Blank14_012225_ds.c505a5fac8fd4fce93709c72a71e9194/Blank14_012225_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  24576135 Jan 28 07:56 download/Blank14dup_012225_ds.f77c083dc6c74971a3bf36a655d86565/Blank14dup_012225_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10444144 Jan 28 07:56 download/Blank15_012225_ds.0d5300ada8c74acfb245298be1d98824/Blank15_012225_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10907902 Jan 28 07:56 download/Blank15dup_012225_ds.0e8dbc548ee94641b00ec7e2ff1b2f17/Blank15dup_012225_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  40805950 Jan 28 07:56 download/Blank16_012225_ds.4c79c549f8654a11b95ccbcb9c4da114/Blank16_012225_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  15229784 Jan 28 07:56 download/Blank16dup_012225_ds.7a6d1b936dd94644b7a9e55ae350b84d/Blank16dup_012225_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 175527163 Jan 28 07:56 download/CSE03_012225_ds.f97ec3b44ba54ff4b0416483e4e17ca5/CSE03_012225_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 192087563 Jan 28 07:56 download/CSE03dup_012225_ds.fd9e60573c9b48548a64a069d1b933fd/CSE03dup_012225_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  17551987 Jan 28 07:56 download/CSE04_012225_ds.3b39fafaa30849ca940872fe5a653fb8/CSE04_012225_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  11124670 Jan 28 07:56 download/CSE04dup_012225_ds.7c78fa911c68427d85dc40290b3f5f0d/CSE04dup_012225_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 195129194 Jan 28 07:56 download/PLib03_012225_ds.ece9a0ec59e44bb6beb6ac0d2f3206f7/PLib03_012225_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 197286117 Jan 28 07:56 download/PLib03dup_012225_ds.ccca9719c60f4847aa1436192a79e2cc/PLib03dup_012225_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   8613292 Jan 28 07:56 download/PLib04_012225_ds.e9a2742310f645dfbdf59d4f0392c65d/PLib04_012225_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  10678323 Jan 28 07:56 download/PLib04dup_012225_ds.90e0b59b970f4845a00c075d04d2faba/PLib04dup_012225_S138_L001_R1_001.fastq.gz


```

Note that there is STILL no "Undetermined"?

We actually got an Undetermined and a bunc of misc files this time.


```
mkdir fastq
cd fastq
for f in ../download/*/*fastq.gz ; do
echo $f
b=$( basename $f _L001_R1_001.fastq.gz ) 
b=$( echo $b | awk -F_ '{print $NF}' )
echo $b
ln -s ${f} ${b}.fastq.gz
done
cd ..
```

```
for f in download/*/*fastq.gz ; do
b=$( basename $f )
x=$( basename $f _L001_R1_001.fastq.gz )
s=$( echo $x | awk -F_ '{print $NF}' )
x=${x%_012225_S*}
echo ${s},${x},${b}
done | sort -t, -k1,1 > manifest.csv
sed -i '1isample,desc,fastq' manifest.csv
chmod a-w manifest.csv
```


Blanks are PBS blanks, there are eight on a plate in 4 pairs of 2.  There should be 16 total for this lane of sequencing

Plibs are the unprecipitated phage libraries

Not blank not serum

The rest of the samples are serums

There are two control serums wells per plate (ie 1 pair)

Besides that there are samples from 4 studies all with different naming conventions

Avera reformatted a little, replacing ‘.’ And spaces With underscores.




```
dos2unix Combined_table_for_sequencing_library_11-19-2024_Mi.csv
```

edit `Combined_table_for_sequencing_library_11-19-2024_Mi.csv`

remove commas from some field for ease of use later

remove new lines from header fields



```
for z in download/*/*z; do f=$( basename $z _L001_R1_001.fastq.gz ); f=${f/_012225_/,}; echo $f; done | sort -t, -k1,1 > sample_s_number.csv
sed -i '1isample,s' sample_s_number.csv 
```





```
head -1 Combined_table_for_sequencing_library_11-19-2024_Mi.csv > tmp
tail -n +2 Combined_table_for_sequencing_library_11-19-2024_Mi.csv | sort -t, -k5,5 >> tmp

join -t, --header -1 1 -2 5 sample_s_number.csv tmp | wc -l 
126
```


This set is plate 2 and 14

```
head -1 Combined_table_for_sequencing_library_11-19-2024_Mi.csv > manifest.csv
grep "^2," Combined_table_for_sequencing_library_11-19-2024_Mi.csv >> manifest.csv
grep "^14," Combined_table_for_sequencing_library_11-19-2024_Mi.csv >> manifest.csv
sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```


##	20250410

```
\rm -f manifest.csv
cp L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv manifest.csv
sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```



##	20251105

I noticed that the PLib, CSE and Blanks for plate's 1, 2, 13 and 14 have the sample names as subject names
so they include the _1 and _2. I don't think this is an issue during normal processing, but does
creep in when I have merged everything and expected the number of merged samples to be something.

20241204 and 20241224

Manually correcting.


