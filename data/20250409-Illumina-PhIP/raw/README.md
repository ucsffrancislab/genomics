
#	20250409-Illumina-PhIP


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
| 040225_192PhiP_L4                       | 450663390 | 21875638500  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 450663390
```

```
cd ..
ll download/*/*z >> README.md



-rw-r----- 1 gwendt francislab   86105591 Apr  9 07:35 download/1405701_040225_ds.e1d7a5b2d1e141ed8f70f20112e0e886/1405701_040225_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103222571 Apr  9 07:34 download/1405701dup_040225_ds.0cab4510e617458e855d04657601870b/1405701dup_040225_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83290241 Apr  9 07:33 download/1406601_040225_ds.1807da6768524c09baf3b6e00c4ebf12/1406601_040225_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99491266 Apr  9 07:33 download/1406601dup_040225_ds.186943606602470188218726a05d5cf6/1406601dup_040225_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94801466 Apr  9 07:36 download/1408201_040225_ds.3b89fa271d83452aae3f43f19acc3e9e/1408201_040225_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89896920 Apr  9 07:34 download/1408201dup_040225_ds.85188475ed5943078b39c7834ae55c74/1408201dup_040225_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94171654 Apr  9 07:34 download/1408301_040225_ds.53d789986aa944058aa7a9fe668eb43f/1408301_040225_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111936095 Apr  9 07:36 download/1408301dup_040225_ds.18d5450018a94e1faaff9019d3d097de/1408301dup_040225_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90676152 Apr  9 07:36 download/1413501_040225_ds.9a06df4f9feb477fb9f68080a4d4c894/1413501_040225_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92512454 Apr  9 07:33 download/1413501dup_040225_ds.dfbbf94f35b840e8848ae49922b199ff/1413501dup_040225_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109278318 Apr  9 07:36 download/1414001_040225_ds.6db85a1b4c4b4668a2599212356b5969/1414001_040225_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117865655 Apr  9 07:36 download/1414001dup_040225_ds.6e046039d4a2491bb76982aaca5363de/1414001dup_040225_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102556933 Apr  9 07:36 download/1418101_040225_ds.65205f824f0742f0805ee83129428815/1418101_040225_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107484271 Apr  9 07:33 download/1418101dup_040225_ds.ebf08331a908440991cbb217b1f88556/1418101dup_040225_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73513219 Apr  9 07:37 download/1421001_040225_ds.0add765cc83746d693c583f40cf0995a/1421001_040225_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107889486 Apr  9 07:36 download/1421001dup_040225_ds.9b75d4fd35f8469c8c4c20a0221010fd/1421001dup_040225_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92648845 Apr  9 07:35 download/1423301_040225_ds.bb633fb2ccd84e87a264ce19830179d6/1423301_040225_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97061107 Apr  9 07:35 download/1423301dup_040225_ds.32f218759b5c42619b2c833e7477d57f/1423301dup_040225_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100845340 Apr  9 07:33 download/1424302_040225_ds.9b46d6ebdcbe4610b67cd03c59eb58c6/1424302_040225_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90438169 Apr  9 07:36 download/1424302dup_040225_ds.38596aa005014b649a2750c64e7a0490/1424302dup_040225_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116809411 Apr  9 07:37 download/1425001_040225_ds.31880d05881c4d7c82faa787cf336a4b/1425001_040225_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120254070 Apr  9 07:34 download/1425001dup_040225_ds.8971d90ae6274b0cbee62d65cebb8884/1425001dup_040225_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104626701 Apr  9 07:33 download/1425601_040225_ds.da1ab8848c2541d89ce1fcce991fe599/1425601_040225_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103621640 Apr  9 07:33 download/1425601dup_040225_ds.a11f02648b664a9d9e708011bcca3a06/1425601dup_040225_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102494453 Apr  9 07:34 download/1426401_040225_ds.1c2857872ef64389a5eee9800c07ccbf/1426401_040225_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102004329 Apr  9 07:36 download/1426401dup_040225_ds.5af26cbd72c149479dfec35185c6eaa2/1426401dup_040225_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   72936510 Apr  9 07:34 download/1426601_040225_ds.7ed7576d053c46a999ffe2ebcf74a44c/1426601_040225_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107692794 Apr  9 07:34 download/1426601dup_040225_ds.0bdbcb8d792147c5835957540fcb725d/1426601dup_040225_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129095962 Apr  9 07:34 download/1427101_040225_ds.8057123a62fe45e69c7104f76f6e23d2/1427101_040225_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128870116 Apr  9 07:36 download/1427101dup_040225_ds.bd34c1377f054ef99ce617ea65caad51/1427101dup_040225_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101405538 Apr  9 07:33 download/1428801_040225_ds.b5dc0b25491a47b4876e9752e5ee02f9/1428801_040225_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111743767 Apr  9 07:34 download/1428801dup_040225_ds.e104beae74ed4d0bb63246066b95f2c9/1428801dup_040225_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88349539 Apr  9 07:36 download/1431401_040225_ds.f04bdec5448041a782d1ca61c82f9082/1431401_040225_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105617933 Apr  9 07:35 download/1431401dup_040225_ds.9f27a129ab9248b9af76a9b8436d5eca/1431401dup_040225_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   64542417 Apr  9 07:33 download/1432801_040225_ds.400b0e2b301945c1a0fceb04b6d03a85/1432801_040225_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91222441 Apr  9 07:33 download/1432801dup_040225_ds.5091876e02d3491487ba6fa093a63408/1432801dup_040225_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90322614 Apr  9 07:33 download/1433501_040225_ds.79ea28ac22d5413f8eeb45506da31685/1433501_040225_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109380564 Apr  9 07:33 download/1433501dup_040225_ds.c8d06462887b485b9dce225bf0a7ebbb/1433501dup_040225_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98492331 Apr  9 07:36 download/1434701_040225_ds.224b1219dc1f4a968a682c3e46516496/1434701_040225_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73911890 Apr  9 07:35 download/1434701dup_040225_ds.9ffe0e72e74043dd82022686d2b94d71/1434701dup_040225_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104128433 Apr  9 07:36 download/1439101_040225_ds.6bac71f22d364df694268ee706aea784/1439101_040225_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95783321 Apr  9 07:33 download/1439101dup_040225_ds.2ea97ee9dbc54ae28d44c9e2284fe581/1439101dup_040225_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98462319 Apr  9 07:37 download/1439301_040225_ds.90b8f77969054a888a4b4dd534756c8d/1439301_040225_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83558427 Apr  9 07:35 download/1439301dup_040225_ds.8cbf91cc7d64428e8a9886e4738dcd32/1439301dup_040225_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99182490 Apr  9 07:37 download/1439701_040225_ds.2bbb50f355fd427393f6b1f27d37e29f/1439701_040225_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93350800 Apr  9 07:37 download/1439701dup_040225_ds.8f0323fb986b42bda91121f7ff9b3f61/1439701dup_040225_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104873036 Apr  9 07:33 download/1440901_040225_ds.5f944cc7badd45fda69136cbaf802509/1440901_040225_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82234273 Apr  9 07:33 download/1440901dup_040225_ds.feab3a645bfb42bca7510e14eb6b0fd6/1440901dup_040225_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127438679 Apr  9 07:34 download/1441601_040225_ds.5cd5fc614b724310b5e1ac79965b610c/1441601_040225_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98609044 Apr  9 07:33 download/1441601dup_040225_ds.1626eafda35a4befa14f1e3d54166c0a/1441601dup_040225_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78623602 Apr  9 07:32 download/1443001_040225_ds.58aee2928a68473fbcdbdd0946c9fcb1/1443001_040225_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92055876 Apr  9 07:34 download/1443001dup_040225_ds.196541720c744716a8cd88a40735a273/1443001dup_040225_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88351983 Apr  9 07:34 download/1443901_040225_ds.6ef774b30ff94921a4963321a2afeac6/1443901_040225_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94280696 Apr  9 07:36 download/1443901dup_040225_ds.63dca221825e4fb2894beca50c5e8552/1443901dup_040225_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78925127 Apr  9 07:34 download/1446901_040225_ds.48e65c7ae2d84e9f881887790a0897aa/1446901_040225_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100886402 Apr  9 07:34 download/1446901dup_040225_ds.d4b5804ea546469e83d0e3ba17af7959/1446901dup_040225_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  119966784 Apr  9 07:32 download/1448401_040225_ds.417b5e69f5fb41eea5d69af3f261d7a9/1448401_040225_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  118654166 Apr  9 07:36 download/1448401dup_040225_ds.8a4a6932194b41659dc8977534c5b7db/1448401dup_040225_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120160320 Apr  9 07:33 download/1449301_040225_ds.dd0b3fc406354d07a262404a0bdda576/1449301_040225_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107995417 Apr  9 07:36 download/1449301dup_040225_ds.2435d4f8330f4cecad8edf38de5a5511/1449301dup_040225_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101895190 Apr  9 07:34 download/1453601_040225_ds.0c259b78e0cf4ec0b0b20192f0c0d6c4/1453601_040225_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73957661 Apr  9 07:36 download/1453601dup_040225_ds.3cf6468cc76f4e9e848b3723fb04b5a1/1453601dup_040225_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115473084 Apr  9 07:35 download/1453801_040225_ds.06fc4a0d10794f5e8890251d21f71481/1453801_040225_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105714134 Apr  9 07:35 download/1453801dup_040225_ds.0a443fde45844f589fe183601c957ae6/1453801dup_040225_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94569239 Apr  9 07:32 download/1454201_040225_ds.d0906cb3b5e34d0e8b5c8df034c96976/1454201_040225_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65079193 Apr  9 07:34 download/1454201dup_040225_ds.7a9a2d7959414681976b1b0b7830c3a7/1454201dup_040225_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90685214 Apr  9 07:32 download/1455501_040225_ds.b3cffdbb76ea4f139e073c0c06eb15e0/1455501_040225_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93177410 Apr  9 07:35 download/1455501dup_040225_ds.52da054e0f7143f0ad299dfb3de626ef/1455501dup_040225_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106546335 Apr  9 07:34 download/1457701_040225_ds.43bc9a4debf5483998ed7efb3fdc725e/1457701_040225_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111005833 Apr  9 07:33 download/1457701dup_040225_ds.9076566116e94ab0949f468b1ba965a8/1457701dup_040225_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100323986 Apr  9 07:35 download/1461501_040225_ds.9693fab7d24a460690fe980150cba89b/1461501_040225_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108622989 Apr  9 07:34 download/1461501dup_040225_ds.7842d3c6ea6043cda3bc41ff9c1953ba/1461501dup_040225_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90817935 Apr  9 07:35 download/1465401_040225_ds.bc63ec8b87154395acf8b8bfbf237eef/1465401_040225_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90330712 Apr  9 07:33 download/1465401dup_040225_ds.8599a418313f43eda5abffe7cb1b63fb/1465401dup_040225_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91159297 Apr  9 07:36 download/1468001_040225_ds.630cdf933ad0414f858d008df56d71fe/1468001_040225_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93562304 Apr  9 07:37 download/1468001dup_040225_ds.0c3b5d4f894d40c093bf23951f3c8f96/1468001dup_040225_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107132688 Apr  9 07:37 download/1473701_040225_ds.8d58e73e23d54c388d69d333d0cb9c27/1473701_040225_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112008586 Apr  9 07:33 download/1473701dup_040225_ds.029207e06e4548e1a9c55168c194319e/1473701dup_040225_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113135128 Apr  9 07:37 download/1491301_040225_ds.1eb04d09a3464d2f92dc8fbaa2689248/1491301_040225_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113327388 Apr  9 07:37 download/1491301dup_040225_ds.2e3e6485083846ed96d785c53cde4731/1491301dup_040225_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95694927 Apr  9 07:35 download/1498401_040225_ds.69f58654b1474d108150ddd167fa94f7/1498401_040225_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102025257 Apr  9 07:37 download/1498401dup_040225_ds.f80976dc3e504e3e8c39fbaa3633f6cc/1498401dup_040225_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100544131 Apr  9 07:33 download/1800801_040225_ds.1ae95f1e03bf4c86bfb43cd8b3c70be4/1800801_040225_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89587596 Apr  9 07:35 download/1800801dup_040225_ds.b831dcded8b04d7ca5af7650fa9d2ebd/1800801dup_040225_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104816964 Apr  9 07:35 download/20066_040225_ds.35e5ee21750342b0b52eef9e11523f89/20066_040225_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101889096 Apr  9 07:35 download/20066dup_040225_ds.a8616fa2e3214c2980a336a60b803a2b/20066dup_040225_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92218768 Apr  9 07:35 download/20078_040225_ds.a22ebebdfc1b49c08b0253a7bb0a9d97/20078_040225_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89485289 Apr  9 07:34 download/20078dup_040225_ds.b4308c57497f406fa6f37a18fc700813/20078dup_040225_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113955770 Apr  9 07:33 download/20156_040225_ds.f1a57bf250e348fbab11c060fa169277/20156_040225_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95238583 Apr  9 07:34 download/20156dup_040225_ds.18eb110a25084f60b7b00316449f10b8/20156dup_040225_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94564145 Apr  9 07:35 download/20167_040225_ds.8a418ac3c8704e64a89047aaa0d512ef/20167_040225_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96934251 Apr  9 07:33 download/20167dup_040225_ds.8837f5ded53c429ea24d9ba805da7116/20167dup_040225_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94921215 Apr  9 07:33 download/20191_040225_ds.48795a0223f640798f41ce973fefd2c7/20191_040225_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91310320 Apr  9 07:32 download/20191dup_040225_ds.45f4371684064386b76bf13b5224b964/20191dup_040225_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95462308 Apr  9 07:35 download/20202_040225_ds.3881c5e87d3041329bf81f3f45cb2069/20202_040225_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92000059 Apr  9 07:37 download/20202dup_040225_ds.38731a810936470399db2889bd309e2e/20202dup_040225_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114181472 Apr  9 07:36 download/20225_040225_ds.6549c2ea9ba04fa8b72cf3b1fe837f10/20225_040225_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115286940 Apr  9 07:36 download/20225dup_040225_ds.5f5cbba071e045e8ba8ea5c09c5d03cc/20225dup_040225_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106775462 Apr  9 07:34 download/20226_040225_ds.9bd1cf582e544600896ebfa4b0b64110/20226_040225_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109199004 Apr  9 07:35 download/20226dup_040225_ds.0e3b99f580ee48368c2709c8c26a93d9/20226dup_040225_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91816259 Apr  9 07:36 download/20248_040225_ds.c6f5f3e05fff44dc99870202687d8565/20248_040225_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104362801 Apr  9 07:34 download/20248dup_040225_ds.d6d148a94b3d4013b2316674dc0dad01/20248dup_040225_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88716649 Apr  9 07:34 download/20457_040225_ds.d7885d9073334f128766da6b53ea7d7c/20457_040225_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86881286 Apr  9 07:34 download/20457dup_040225_ds.178ae61b3652467eada16927595ea7b3/20457dup_040225_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94437794 Apr  9 07:36 download/20471_040225_ds.730b89df0ba94d15a4a29110a0c973cd/20471_040225_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   60254537 Apr  9 07:35 download/20471dup_040225_ds.678597cd21b1419e9865735b501230e3/20471dup_040225_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127743010 Apr  9 07:36 download/21026_040225_ds.4abc41f912c54a78821200d0da5ca1be/21026_040225_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100783958 Apr  9 07:35 download/21026dup_040225_ds.3f6ffa1743764bedb7c6d487ef6f676b/21026dup_040225_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93603016 Apr  9 07:36 download/21060_040225_ds.a6d6c3df734c4d29a906c14c74208ee2/21060_040225_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95036166 Apr  9 07:33 download/21060dup_040225_ds.26aa7957b15f4a459f3b5cb1baa29c3e/21060dup_040225_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108331018 Apr  9 07:35 download/21092_040225_ds.87c75df2fdc34e46b47e4f77c66c8e3a/21092_040225_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115627698 Apr  9 07:34 download/21092dup_040225_ds.0bb2424d1be44a789e5c998de20ce2f3/21092dup_040225_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103228598 Apr  9 07:33 download/21105_040225_ds.85b927f939ce49e4a999902c32b16269/21105_040225_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97927952 Apr  9 07:33 download/21105dup_040225_ds.a0806c96364446e58e669e9cccebf54f/21105dup_040225_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112969719 Apr  9 07:35 download/21125_040225_ds.217a1556f8d04c348908be83bbd47a1c/21125_040225_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95468107 Apr  9 07:37 download/21125dup_040225_ds.cff4f17ffe8248d9beb285191f410a50/21125dup_040225_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106948992 Apr  9 07:37 download/21129_040225_ds.e5f586601b7940118cfa8bce77bdd878/21129_040225_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86614647 Apr  9 07:33 download/21129dup_040225_ds.31aacae50a1b4310bf5e01317689f298/21129dup_040225_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102498811 Apr  9 07:36 download/21247_040225_ds.4292e8322bbe49de8beb3131e3bf37a2/21247_040225_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105499184 Apr  9 07:36 download/21247dup_040225_ds.d42a30d9618244a0a84b6df00574e378/21247dup_040225_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88125304 Apr  9 07:36 download/21283_040225_ds.456ab08faa634b709b9b1dc718d96694/21283_040225_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95086425 Apr  9 07:37 download/21283dup_040225_ds.c3851f24f0a64ceb89986ab683d01388/21283dup_040225_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113582650 Apr  9 07:34 download/21314_040225_ds.25d08fd47d6d4bf3a728095ad81b58ae/21314_040225_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105244529 Apr  9 07:33 download/21314dup_040225_ds.e98519a9d1f84315ba1a148e29d2a01b/21314dup_040225_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88919610 Apr  9 07:34 download/3414_040225_ds.9c53f598b32c476a8b567a2f29242389/3414_040225_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103226263 Apr  9 07:33 download/3414dup_040225_ds.e69c7c82ad0e49fbb04cf6d0e1d06468/3414dup_040225_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85724884 Apr  9 07:35 download/3458_040225_ds.9cf2719063ee44149223e3e4664eebfc/3458_040225_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111827358 Apr  9 07:33 download/3458dup_040225_ds.6ae89e18b49945d48231f5a64f16b3fc/3458dup_040225_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98941832 Apr  9 07:36 download/4033_040225_ds.0e5a508fc8f94242aae173cdf08fd30a/4033_040225_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96723292 Apr  9 07:35 download/4033dup_040225_ds.fdf7487bb99f4146893a0d5d8f27c5de/4033dup_040225_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110367804 Apr  9 07:35 download/4045_040225_ds.1afcb7f95e1b497790477460e5d07847/4045_040225_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82549032 Apr  9 07:34 download/4045dup_040225_ds.5618627f41ff4cf2a40d7892cbc5ffe5/4045dup_040225_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108234008 Apr  9 07:36 download/4082_040225_ds.4e7fb2f689054f78acae94ad0221eb76/4082_040225_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110375271 Apr  9 07:37 download/4082dup_040225_ds.d0989df27b1c44dd87ab02723b9aad5f/4082dup_040225_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94715693 Apr  9 07:36 download/4148_040225_ds.6ca7fae8fe714902b4e4290803401d6d/4148_040225_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114936264 Apr  9 07:37 download/4148dup_040225_ds.b37acffc6eb74c538cb531c2f0069598/4148dup_040225_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113812678 Apr  9 07:32 download/4199_040225_ds.00915340b41744488a96bff5e4b666b4/4199_040225_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82957055 Apr  9 07:35 download/4199dup_040225_ds.9c52d1a57cfc40d084fbe7e6275a38fc/4199dup_040225_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74778301 Apr  9 07:35 download/4223_040225_ds.606a15083fc54c0db1f3faeb28f1d4d0/4223_040225_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98007973 Apr  9 07:35 download/4223dup_040225_ds.d3e6fe8c07884f11b56f20248adf514d/4223dup_040225_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107062499 Apr  9 07:33 download/4227_040225_ds.8c8d7d90c09949e780f30af37bd392cf/4227_040225_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100849058 Apr  9 07:33 download/4227dup_040225_ds.693229d3639c4ef88991feb9d81aac69/4227dup_040225_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108211933 Apr  9 07:35 download/4274_040225_ds.015b3acc05d243339ffe89b591375604/4274_040225_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93346859 Apr  9 07:32 download/4274dup_040225_ds.d3588dc974294d39a5ed1012d88b121f/4274dup_040225_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  122880011 Apr  9 07:36 download/4359_040225_ds.49098031f852446c9ff7a5fda5645380/4359_040225_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103070117 Apr  9 07:35 download/4359dup_040225_ds.67b85e99c0e7429bb2882e86a75243ae/4359dup_040225_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104947697 Apr  9 07:33 download/4380_040225_ds.7f40d96fced2489a899b0fce1be4744d/4380_040225_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106522688 Apr  9 07:34 download/4380dup_040225_ds.ca0f2e5be8ad4aa48619109222076303/4380dup_040225_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112941609 Apr  9 07:36 download/4416_040225_ds.a9bd2e6bf96846fd8aca7fdf8adc7ea6/4416_040225_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  118126858 Apr  9 07:33 download/4416dup_040225_ds.e790d127d1784e4483d3ed042100901d/4416dup_040225_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108115505 Apr  9 07:34 download/4418_040225_ds.0398469318b24a9da59a5c9ba254251b/4418_040225_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110386975 Apr  9 07:35 download/4418dup_040225_ds.d0d46c603afa429d92605fd8b5643629/4418dup_040225_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95577000 Apr  9 07:34 download/4439_040225_ds.0552d342414a45edb213e4f69c512c3b/4439_040225_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101605977 Apr  9 07:34 download/4439dup_040225_ds.ef4bcf073ee14c4c8851d2df8dbcfd89/4439dup_040225_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87110381 Apr  9 07:36 download/4465_040225_ds.2d16f60f4ad44c3f81366dbc9b4e91c7/4465_040225_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105273577 Apr  9 07:33 download/4465dup_040225_ds.7b69df0c1eed4ecea8648683b97792b6/4465dup_040225_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105821614 Apr  9 07:36 download/4466_040225_ds.81366ce817e645f490d6d2a8b8449a31/4466_040225_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81680501 Apr  9 07:35 download/4466dup_040225_ds.a6eefded8db94995a96f41b423cd13f4/4466dup_040225_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99051775 Apr  9 07:36 download/4489_040225_ds.a6584fa4692f42388c825f9ef7b0e485/4489_040225_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100431797 Apr  9 07:34 download/4489dup_040225_ds.11859e28cc3943fe958a578f3a96133d/4489dup_040225_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89539449 Apr  9 07:35 download/4507_040225_ds.02c23b3cfbdb4d158ee3534dc2b6fa56/4507_040225_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103427573 Apr  9 07:36 download/4507dup_040225_ds.47ac26994d6d433ebf8effe363a06308/4507dup_040225_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86243142 Apr  9 07:34 download/4528_040225_ds.d1268a652a6e4e598bb25edff56ff17d/4528_040225_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100495802 Apr  9 07:35 download/4528dup_040225_ds.58cc5bb311514a7ebd81df840c08171a/4528dup_040225_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100466897 Apr  9 07:35 download/4551_040225_ds.2ef9b86b514e49048333bff8e98b3e34/4551_040225_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78445642 Apr  9 07:33 download/4551dup_040225_ds.2c18f3a059d64777866f1b1054a7734a/4551dup_040225_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115267681 Apr  9 07:35 download/4604_040225_ds.606c9a0410fb4bc4a0261fc5314d178f/4604_040225_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104244106 Apr  9 07:36 download/4604dup_040225_ds.68f0427f66674e9db0dcb81df9e4bae2/4604dup_040225_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  121811646 Apr  9 07:33 download/Blank17_040225_ds.e2d14725ea464de5ba7dd468db8c9aa5/Blank17_040225_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94103054 Apr  9 07:34 download/Blank17dup_040225_ds.b7a1acadab19417b87712428d8d81470/Blank17dup_040225_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80813798 Apr  9 07:37 download/Blank18_040225_ds.cf27ca2d793947f09ea286157cc6ae92/Blank18_040225_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96071491 Apr  9 07:35 download/Blank18dup_040225_ds.1448e79d46df4c32af9d49512c641350/Blank18dup_040225_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101953475 Apr  9 07:35 download/Blank19_040225_ds.1bfa8354302143d8a6fc77c47bce03c5/Blank19_040225_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128178586 Apr  9 07:34 download/Blank19dup_040225_ds.707f00880b244feb861b748595224d5a/Blank19dup_040225_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132563528 Apr  9 07:33 download/Blank20_040225_ds.8e0bda5a10684fea8ce367aa3e58cc4a/Blank20_040225_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114309040 Apr  9 07:37 download/Blank20dup_040225_ds.59c5b85333e34572b9d7972673b11af6/Blank20dup_040225_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110929255 Apr  9 07:33 download/Blank21_040225_ds.cfe6f46d8ce745fb9c36df2b558f2e9b/Blank21_040225_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73372020 Apr  9 07:34 download/Blank21dup_040225_ds.8e62807145d848d98189414ac46a87f1/Blank21dup_040225_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116276615 Apr  9 07:34 download/Blank22_040225_ds.193d598659364db8a25745975a413c91/Blank22_040225_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116892611 Apr  9 07:37 download/Blank22dup_040225_ds.5ac332337fb740bbb673fcd880a8a645/Blank22dup_040225_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85052315 Apr  9 07:35 download/Blank23_040225_ds.67ab601aa7e841789361a81e7691102b/Blank23_040225_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107556300 Apr  9 07:33 download/Blank23dup_040225_ds.d31c0511878e40e49d1533a94e6ba1a2/Blank23dup_040225_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  175991726 Apr  9 07:36 download/Blank24_040225_ds.aa1454c14c6c49d0b3e3acbde6e2af5b/Blank24_040225_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      18890 Apr  9 07:34 download/Blank24dup_040225_ds.8db0210b9a1e446391cb12fd0bc3a016/Blank24dup_040225_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97665072 Apr  9 07:37 download/CSE05_040225_ds.cdb45470cbcf4c499a4339d0e9927264/CSE05_040225_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96277514 Apr  9 07:34 download/CSE05dup_040225_ds.d8584cddea124f369f85aba5dba6ecab/CSE05dup_040225_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97590563 Apr  9 07:33 download/CSE06_040225_ds.a8dcfcc981c64ac4aac1aeb2bf3e5916/CSE06_040225_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82351796 Apr  9 07:35 download/CSE06dup_040225_ds.197b27a2540e47aaaa6dbce679b47a9f/CSE06dup_040225_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   84215232 Apr  9 07:35 download/PLib05_040225_ds.2cce8d845247424d89fe54cc42761708/PLib05_040225_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92229717 Apr  9 07:37 download/PLib05dup_040225_ds.6d9de0b635c8413c96155e7539b99516/PLib05dup_040225_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75527725 Apr  9 07:36 download/PLib06_040225_ds.a4646c9a33824573aeea586b6e412a3e/PLib06_040225_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   45821680 Apr  9 07:36 download/PLib06dup_040225_ds.e4efc1925dc64783980a646349c2bc61/PLib06dup_040225_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 2784020451 Apr  9 07:39 download/Undetermined_from_040825_192PhiP_L4_ds.b757c03ed2cd4047946355d41cc5db97/Undetermined_S0_L001_R1_001.fastq.gz
```

Note that there is STILL no "Undetermined"?

We actually got an Undetermined and a bunch of misc files this time too.


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
x=${x%_040225_S*}
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
for z in download/*/*z; do f=$( basename $z _L001_R1_001.fastq.gz ); f=${f/_040225_/,}; echo $f; done | sort -t, -k1,1 > sample_s_number.csv
sed -i '1isample,s' sample_s_number.csv 
```
















```
dos2unix L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv
```

edit `L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv`

remove commas from some field for ease of use later

remove new lines from header fields



This set is plate 5 and 6

```
#head -1 L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv > manifest.csv
#grep "^2," L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv >> manifest.csv
#grep "^14," L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv >> manifest.csv

\rm -f manifest.csv
cp L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv manifest.csv
sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```


