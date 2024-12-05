
#	20241203-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects

+-----------------------------------------+-----------+--------------+
|                  Name                   |    Id     |  TotalSize   |
+-----------------------------------------+-----------+--------------+
| MEX_LEUK_2018                           | 60976917  | 132686382176 |
| Mex_leucemia_18                         | 61769708  | 66088939767  |
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506    |
| 112024_192PhiP_L1                       | 438875584 | 6284810936   |
| 112024_192PhiP_L1_1                     | 439485058 | 9868294808   |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 439485058
```

```
cd ..
ll download/*/*z


-rw-r----- 1 gwendt francislab 100455320 Dec  3 11:24 download/043MPL_112024_1_ds.dd52f15ac9864ab78fb654234b3854c6/043MPL_112024_1_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     27592 Dec  3 11:23 download/043MPLdup_112024_1_ds.ce1defd8c2834f089cc5fbc40d906bb4/043MPLdup_112024_1_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     33102 Dec  3 11:23 download/101VKC_112024_1_ds.0c9bb7a9519f4b9db2d4fb296dd14653/101VKC_112024_1_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     18681 Dec  3 11:23 download/101VKCdup_112024_1_ds.29e1296e10a24bffbb1b6bf494e60930/101VKCdup_112024_1_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     26918 Dec  3 11:24 download/1301_112024_1_ds.e71466c2db78457da0f18f8b3d52993b/1301_112024_1_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  57654696 Dec  3 11:24 download/1301dup_112024_1_ds.7c4566de7ccc4487994fd7fa288d6549/1301dup_112024_1_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     27239 Dec  3 11:23 download/1302_112024_1_ds.7909ae6c8b9440f498b2fdd3ea8b9735/1302_112024_1_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     12653 Dec  3 11:23 download/1302dup_112024_1_ds.0564ff0f79914545a0fbffee93617dcd/1302dup_112024_1_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88798944 Dec  3 11:25 download/1303_112024_1_ds.d21d3151a7eb4530bae33adae2a9cb16/1303_112024_1_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73925750 Dec  3 11:23 download/1303dup_112024_1_ds.0e2d54f3cb7847a3987ea5d4d979b987/1303dup_112024_1_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78684046 Dec  3 11:24 download/1304_112024_1_ds.b03336383b3f4e27a4cbec9deb8e177d/1304_112024_1_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    113707 Dec  3 11:24 download/1304dup_112024_1_ds.69545c6307fc47ef8fe226e1b6d3f5f7/1304dup_112024_1_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     24980 Dec  3 11:23 download/1305_112024_1_ds.42cbc0f1b9144e0e9b432151a011081e/1305_112024_1_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     30952 Dec  3 11:23 download/1305dup_112024_1_ds.2d5ac37f452a4a048e5aa0f6e3488a6c/1305dup_112024_1_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88781414 Dec  3 11:24 download/1306_112024_1_ds.12cb30bbe77d4b7b8318f8613b7cb533/1306_112024_1_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85159358 Dec  3 11:24 download/1306dup_112024_1_ds.30b3350c62754e06b2bf3d79ed16d798/1306dup_112024_1_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     85146 Dec  3 11:23 download/1307_112024_1_ds.c7fb5b3ddbe24836a507d80d15855201/1307_112024_1_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79184133 Dec  3 11:24 download/1307dup_112024_1_ds.13966d4e57c44a24bb7544515dd95a20/1307dup_112024_1_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84212535 Dec  3 11:24 download/1308_112024_1_ds.14c3ed3097e4454a82f0f3e0ee063d01/1308_112024_1_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88032002 Dec  3 11:23 download/1308dup_112024_1_ds.8ae1018a8da245169b1c0326f559ac67/1308dup_112024_1_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82440260 Dec  3 11:24 download/1309_112024_1_ds.a7884173ad424960a39d78c8c1b4d000/1309_112024_1_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79169442 Dec  3 11:23 download/1309dup_112024_1_ds.99c18ab2bc15484181746e9bb72314d0/1309dup_112024_1_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73664838 Dec  3 11:23 download/1310_112024_1_ds.ea4f23d586ae4fefaa345d14cf22a31d/1310_112024_1_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  28642409 Dec  3 11:23 download/1310dup_112024_1_ds.60317c90fa0c4a559b3dcb887ac0213e/1310dup_112024_1_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      1500 Dec  3 11:23 download/1311_112024_1_ds.0825c17c2b634ae998630050dada7535/1311_112024_1_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81419596 Dec  3 11:23 download/1311dup_112024_1_ds.6b7857daa14148fa81432fb9d7075ffe/1311dup_112024_1_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     18778 Dec  3 11:23 download/1312_112024_1_ds.c5c6df53358d404ebfb5335bcae28674/1312_112024_1_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83093340 Dec  3 11:23 download/1312dup_112024_1_ds.5a496d83eeb84fb38348559d74d6d6da/1312dup_112024_1_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83552025 Dec  3 11:23 download/14078-01_112024_1_ds.4c941899dc0a49db916a431d0c58df0e/14078-01_112024_1_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67967380 Dec  3 11:23 download/14078-01dup_112024_1_ds.15472abb4ce44fd29824b4a6b0a3f815/14078-01dup_112024_1_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86905216 Dec  3 11:23 download/14118-01_112024_1_ds.41664a0021e64b7a905d24cb89a35533/14118-01_112024_1_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     18134 Dec  3 11:23 download/14118-01dup_112024_1_ds.11b07f4c6c4c44d0baca0d2912927cb7/14118-01dup_112024_1_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74490073 Dec  3 11:23 download/14127-01_112024_1_ds.a4be69dbb3554165a77d2d9eb7ef55ab/14127-01_112024_1_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  59783256 Dec  3 11:23 download/14127-01dup_112024_1_ds.8d27dd6cd19f44e987cad75c3555824d/14127-01dup_112024_1_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     70372 Dec  3 11:23 download/14142-01_112024_1_ds.8da7f01af18a44798ac1ce88c1447e40/14142-01_112024_1_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     23857 Dec  3 11:23 download/14142-01dup_112024_1_ds.537ef08d2cb54455a5c0a1822e4160fa/14142-01dup_112024_1_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      3365 Dec  3 11:23 download/14206-01_112024_1_ds.3807dba5d7134ed5a282947426ba91b2/14206-01_112024_1_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     53958 Dec  3 11:23 download/14206-01dup_112024_1_ds.1c057ed0d2b14046a8e1a082fe679c94/14206-01dup_112024_1_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     13150 Dec  3 11:23 download/14223-01_112024_1_ds.8b7380637c0140268a62d291350e524c/14223-01_112024_1_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     97120 Dec  3 11:23 download/14223-01dup_112024_1_ds.3571e501f53945cbb80cee0011fc5dc9/14223-01dup_112024_1_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76580072 Dec  3 11:23 download/14235-01_112024_1_ds.f273528c626641fb959f1f0afd3b8634/14235-01_112024_1_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94526003 Dec  3 11:24 download/14235-01dup_112024_1_ds.52f616a8b8074bc4b9927a31f845b359/14235-01dup_112024_1_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87999845 Dec  3 11:25 download/14337-01_112024_1_ds.605f81431de74a0e8bda3d0ef6eecc99/14337-01_112024_1_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87913361 Dec  3 11:23 download/14337-01dup_112024_1_ds.6ea4fdf439a34b6394361b361ddf3243/14337-01dup_112024_1_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88778149 Dec  3 11:23 download/14358-02_112024_1_ds.ac7c8bb9ad8440b1ad9685bb690f141e/14358-02_112024_1_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     82659 Dec  3 11:23 download/14358-02dup_112024_1_ds.4f99347cb8244d76a26de77af278fc39/14358-02dup_112024_1_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  66165060 Dec  3 11:23 download/14415-02_112024_1_ds.16e51799932545a198d87adbebbb22a2/14415-02_112024_1_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69518947 Dec  3 11:23 download/14415-02dup_112024_1_ds.5a478fefdf3d436e8f0396329273190c/14415-02dup_112024_1_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71656197 Dec  3 11:23 download/14431-01_112024_1_ds.2817a10acb874d1e81ccfd7066ba8d26/14431-01_112024_1_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    341445 Dec  3 11:23 download/14431-01dup_112024_1_ds.c55e4170808c44ae8724424467dc536c/14431-01dup_112024_1_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 127792630 Dec  3 11:24 download/14471-01_112024_1_ds.603a767fc317490e9da533fed4cbe8d0/14471-01_112024_1_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 136333066 Dec  3 11:24 download/14471-01dup_112024_1_ds.73982f0b1bed4ac88caf20605c10e084/14471-01dup_112024_1_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75322725 Dec  3 11:23 download/14566-01_112024_1_ds.a23b410a7334442188b82795e28b436a/14566-01_112024_1_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77949418 Dec  3 11:24 download/14566-01dup_112024_1_ds.eee4a4a491a1416eb15bfa890175d7c0/14566-01dup_112024_1_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     32013 Dec  3 11:23 download/14627-01_112024_1_ds.415fb33dc4a64d9da712b59a16619ac6/14627-01_112024_1_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  39805137 Dec  3 11:23 download/14627-01dup_112024_1_ds.eb94cac477aa4f97bf6bf3fc74663c0c/14627-01dup_112024_1_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     52223 Dec  3 11:23 download/14668-01_112024_1_ds.c9680b52d72b40ca845e2b6b2066f6a4/14668-01_112024_1_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     32354 Dec  3 11:24 download/14668-01dup_112024_1_ds.0075705f5afb4162a22ff6efebd7b265/14668-01dup_112024_1_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     19635 Dec  3 11:23 download/14719-01_112024_1_ds.ee00abb68c124717bd9d181809c1719b/14719-01_112024_1_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82922459 Dec  3 11:24 download/14719-01dup_112024_1_ds.22a817762e5d4918bfae8215e9de8f70/14719-01dup_112024_1_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88671543 Dec  3 11:23 download/14748-01_112024_1_ds.528e4533f8ac4da8b4d533c4035714a0/14748-01_112024_1_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      8317 Dec  3 11:23 download/14748-01dup_112024_1_ds.83e1184a12914ba995d58397d8a3d691/14748-01dup_112024_1_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     11638 Dec  3 11:23 download/14807-01_112024_1_ds.577485d4c2cc464d85ba6aaebc52f963/14807-01_112024_1_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91438149 Dec  3 11:24 download/14807-01dup_112024_1_ds.ec265c01f0334e83843e078c0ea807ed/14807-01dup_112024_1_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      1796 Dec  3 11:23 download/14879-01_112024_1_ds.f7bd5ce5944e4867b8ef0edcfdb032b9/14879-01_112024_1_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      7235 Dec  3 11:23 download/14879-01dup_112024_1_ds.b0e42f626d8e439097d9d4ccc5682551/14879-01dup_112024_1_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 103835830 Dec  3 11:23 download/14896-01_112024_1_ds.668e41194d6e4d70916235f588cf966b/14896-01_112024_1_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78651911 Dec  3 11:23 download/14896-01dup_112024_1_ds.2374f1f35ac84eafb334e444d90242b0/14896-01dup_112024_1_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83869912 Dec  3 11:23 download/14953-01_112024_1_ds.a888d552b89948ce86b162c92928a450/14953-01_112024_1_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 102254796 Dec  3 11:24 download/14953-01dup_112024_1_ds.16d521e2e7804df19ce79cd13e47608e/14953-01dup_112024_1_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     40345 Dec  3 11:23 download/20046_112024_1_ds.42bfd6ae4ae64ad782fd731514136625/20046_112024_1_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  47503438 Dec  3 11:24 download/20046dup_112024_1_ds.4205074bca0748508f78f05f8f5eb979/20046dup_112024_1_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78814312 Dec  3 11:23 download/20087_112024_1_ds.94fa1b7f97a74dc3a8a03b25bf3113b1/20087_112024_1_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84061509 Dec  3 11:23 download/20087dup_112024_1_ds.13f3b6a98a5e4931b69fb15c4d6e2249/20087dup_112024_1_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     28171 Dec  3 11:23 download/20178_112024_1_ds.97bceb6243644c099b1cec3970b7a2bf/20178_112024_1_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     42256 Dec  3 11:23 download/20178dup_112024_1_ds.6b5ddd9879624af189c81c73ac19f81d/20178dup_112024_1_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84911655 Dec  3 11:24 download/20265_112024_1_ds.fbb79bddbf5b42c5bf11f0f1bfdf1f1f/20265_112024_1_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90778138 Dec  3 11:23 download/20265dup_112024_1_ds.d8ca8e40308546f0bd91777003c867fd/20265dup_112024_1_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 107391123 Dec  3 11:23 download/20268_112024_1_ds.4620527918b94d1789ea7748fb24779a/20268_112024_1_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     53962 Dec  3 11:23 download/20268dup_112024_1_ds.54f9d5d086054b44810f88f87e5b4a28/20268dup_112024_1_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74277276 Dec  3 11:23 download/20469_112024_1_ds.ba4bade6201e47eb80e32946b0ee34a7/20469_112024_1_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      3842 Dec  3 11:23 download/20469dup_112024_1_ds.8c06a5556caa4e2cafce9a01df780cff/20469dup_112024_1_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74765392 Dec  3 11:23 download/20480_112024_1_ds.787fd590c21c49fd92ce5a15a5ee83b2/20480_112024_1_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83148992 Dec  3 11:24 download/20480dup_112024_1_ds.018c846cb88f40b8aab7657efcccc862/20480dup_112024_1_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88135028 Dec  3 11:24 download/20502_112024_1_ds.9d1e843f24844fbbb721d4d10294f712/20502_112024_1_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      6375 Dec  3 11:23 download/20502dup_112024_1_ds.caf0fec70f72473ab4e67e40740467f4/20502dup_112024_1_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     10868 Dec  3 11:23 download/21047_112024_1_ds.071b0b017310412cac4a95775b93b0ae/21047_112024_1_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86581911 Dec  3 11:25 download/21047dup_112024_1_ds.469c5cc97ddc4bf3a60ec1def42b38d1/21047dup_112024_1_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88162286 Dec  3 11:24 download/21095_112024_1_ds.6e91b265823644eda084cae47ef8bd8b/21095_112024_1_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65648846 Dec  3 11:23 download/21095dup_112024_1_ds.17f605d246a144b7892564427cfaa6d1/21095dup_112024_1_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     14842 Dec  3 11:23 download/21112_112024_1_ds.8c46b05f36d04983a03fe59ce8c2f9d2/21112_112024_1_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     86255 Dec  3 11:23 download/21112dup_112024_1_ds.10775409b257402ea50fdf28d5a2b518/21112dup_112024_1_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      5372 Dec  3 11:23 download/21197_112024_1_ds.31c9e8f8f85b40f1bd4d836990b1ec0e/21197_112024_1_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81051317 Dec  3 11:25 download/21197dup_112024_1_ds.833849650d6d45eebe087b0bccd9ce56/21197dup_112024_1_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 135606187 Dec  3 11:25 download/21198_112024_1_ds.db1624dd93d04e01840b9a65e9e027f5/21198_112024_1_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75628130 Dec  3 11:24 download/21198dup_112024_1_ds.f585878652454747929600e3a8d2e913/21198dup_112024_1_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  61909154 Dec  3 11:23 download/21293_112024_1_ds.384703775ac04a34a96c57d604cd2059/21293_112024_1_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  64339758 Dec  3 11:23 download/21293dup_112024_1_ds.89919e66692d4dd8a6777f5387d3fb8e/21293dup_112024_1_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 110759828 Dec  3 11:23 download/3397_112024_1_ds.359126cb6c16447f9cf212f840acd9c6/3397_112024_1_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87116103 Dec  3 11:23 download/3397dup_112024_1_ds.81c638f3fc504139b31e8e5585d244b8/3397dup_112024_1_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     10055 Dec  3 11:23 download/369GAC_112024_1_ds.348c725e905c407c86f298cf59f76c45/369GAC_112024_1_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76771744 Dec  3 11:24 download/369GACdup_112024_1_ds.8fcd16e023fe4d4690bc51024dff369b/369GACdup_112024_1_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  57896193 Dec  3 11:23 download/4129_112024_1_ds.03fe1c00489f48f8850289d65ea1e2eb/4129_112024_1_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92518741 Dec  3 11:25 download/4129dup_112024_1_ds.0649934b168d41c19bfb322f66ca2942/4129dup_112024_1_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76305761 Dec  3 11:24 download/4207_112024_1_ds.ab217954cb6340088a6b0c417c6be6b3/4207_112024_1_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85638459 Dec  3 11:24 download/4207dup_112024_1_ds.9a87feb97c2847d784dc5d1ea7a9b7e0/4207dup_112024_1_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78135943 Dec  3 11:23 download/4238_112024_1_ds.d5aeb896e620491da6219127c8d823f0/4238_112024_1_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     29181 Dec  3 11:23 download/4238dup_112024_1_ds.381583769e314b9ab48fd8c4d5233ba5/4238dup_112024_1_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84979819 Dec  3 11:24 download/4276_112024_1_ds.a820a4770b33452e9218f0231b1a4d61/4276_112024_1_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100276722 Dec  3 11:25 download/4276dup_112024_1_ds.b4322a55b4dd4a598521250151d2c3a8/4276dup_112024_1_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92362517 Dec  3 11:23 download/4460_112024_1_ds.1c392bfdf30d4b9f81795c7d5b15b9e7/4460_112024_1_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     24362 Dec  3 11:23 download/4460dup_112024_1_ds.ce70e90fdc824b6fa0d7bb865a5d9641/4460dup_112024_1_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85119134 Dec  3 11:24 download/4537_112024_1_ds.a400d84caca745458cbb070c84103d68/4537_112024_1_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 120027406 Dec  3 11:23 download/4537dup_112024_1_ds.cf1a2b8feb1f47fdb40680c35d9e94d2/4537dup_112024_1_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67079871 Dec  3 11:23 download/469MCM_112024_1_ds.1264c3c0776d4cae8233a0541e0bd38e/469MCM_112024_1_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     18216 Dec  3 11:23 download/469MCMdup_112024_1_ds.5c2f57919c4642538231b43aebdb9979/469MCMdup_112024_1_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76232607 Dec  3 11:24 download/472EKC_112024_1_ds.c7f4fc0b5c0745f881ea1c6d6bd1a8df/472EKC_112024_1_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    137353 Dec  3 11:23 download/472EKCdup_112024_1_ds.30e960ceecd54763a3b33bf5ea17dc3f/472EKCdup_112024_1_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68228713 Dec  3 11:23 download/473IRR_112024_1_ds.d3bb61511ff34a7fa3f5eb48b478c6b5/473IRR_112024_1_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      7445 Dec  3 11:23 download/473IRRdup_112024_1_ds.7d5d6eac46e84d97b5b819207d5e8d2c/473IRRdup_112024_1_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     31572 Dec  3 11:23 download/474RHI_112024_1_ds.11dab810b5694b768613153a78638b01/474RHI_112024_1_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67773451 Dec  3 11:23 download/474RHIdup_112024_1_ds.626c7b7ef8d648cd9bee66935dbf1c32/474RHIdup_112024_1_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     68093 Dec  3 11:23 download/478ZKA_112024_1_ds.5ea2cd8697a748269cf239a6724be0bb/478ZKA_112024_1_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65951885 Dec  3 11:24 download/478ZKAdup_112024_1_ds.a4fa42aac43d4bd1aa91acf128598189/478ZKAdup_112024_1_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85340068 Dec  3 11:24 download/480LCO_112024_1_ds.d7f2fec2728d45ad9400292b89eae8b2/480LCO_112024_1_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     22184 Dec  3 11:23 download/480LCOdup_112024_1_ds.c127b8973af84b13bdee16c4c99731f8/480LCOdup_112024_1_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83859076 Dec  3 11:23 download/616SFY_112024_1_ds.e31936267e4f4c18b635fb476d39e539/616SFY_112024_1_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76584177 Dec  3 11:24 download/616SFYdup_112024_1_ds.0b1e3430ceac40bab1e4f20fa68a62a5/616SFYdup_112024_1_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     20324 Dec  3 11:23 download/Blank01_1_112024_1_ds.5e3dc60196ff40cfb607ddd9a1b27d4a/Blank01_1_112024_1_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74534744 Dec  3 11:23 download/Blank01_2_112024_1_ds.2db3f16d72f04c3597ba5d440389025d/Blank01_2_112024_1_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     92746 Dec  3 11:23 download/Blank02_1_112024_1_ds.f75654c7843949cab996bde07ff22258/Blank02_1_112024_1_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    115804 Dec  3 11:23 download/Blank02_2_112024_1_ds.1d34e1c26a534ac5abcb81ad61f391fb/Blank02_2_112024_1_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87699328 Dec  3 11:24 download/Blank03_1_112024_1_ds.df1f604880b740ed859518a82dbfa1cf/Blank03_1_112024_1_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82006052 Dec  3 11:24 download/Blank03_2_112024_1_ds.c7529677594442319a0d93316409d8e2/Blank03_2_112024_1_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77967806 Dec  3 11:23 download/Blank04_1_112024_1_ds.ca9b40492d0e4689aa91d7bd580084dd/Blank04_1_112024_1_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 107207036 Dec  3 11:23 download/Blank04_2_112024_1_ds.c15c70ee5f004fbc87e32d203fad6858/Blank04_2_112024_1_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82673950 Dec  3 11:24 download/Blank49_1_112024_1_ds.f7299e0a6ea842a99022ba05a1d9cd8f/Blank49_1_112024_1_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75441268 Dec  3 11:23 download/Blank49_2_112024_1_ds.676bc7be7de54fff84ee3569aa820283/Blank49_2_112024_1_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     69052 Dec  3 11:23 download/Blank50_1_112024_1_ds.2616e095952d48f89deaf8bdc1a80aac/Blank50_1_112024_1_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     36524 Dec  3 11:24 download/Blank50_2_112024_1_ds.410fbfa950a04525bc05d171f2737933/Blank50_2_112024_1_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    100943 Dec  3 11:23 download/Blank51_1_112024_1_ds.9c6e75cea3204fa587e9f7be8d6930f0/Blank51_1_112024_1_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71564928 Dec  3 11:24 download/Blank51_2_112024_1_ds.4be3d2f8e9274797bad9e5bcaf10ef87/Blank51_2_112024_1_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 111582911 Dec  3 11:24 download/Blank52_1_112024_1_ds.0f01c1eef2f240e2a8a4e0835182b9db/Blank52_1_112024_1_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92704533 Dec  3 11:24 download/Blank52_2_112024_1_ds.813fffd46342456eac81dac340ea1d88/Blank52_2_112024_1_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65867783 Dec  3 11:23 download/C661MAA_112024_1_ds.5668298a292e463180264a88ad1f66d3/C661MAA_112024_1_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74126568 Dec  3 11:25 download/C661MAAdup_112024_1_ds.a8dd453fc7b14f9982d6814c66e5b0f0/C661MAAdup_112024_1_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 101309773 Dec  3 11:23 download/C670ESA_112024_1_ds.c29792def275456592338729ff4ab217/C670ESA_112024_1_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     42897 Dec  3 11:23 download/C670ESAdup_112024_1_ds.5e47ee4fc2f04fbdb5589ec05973bc30/C670ESAdup_112024_1_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      8677 Dec  3 11:23 download/C675WRB_112024_1_ds.bc7405dba0034ecc9a0e5a9d69a14b91/C675WRB_112024_1_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85085075 Dec  3 11:23 download/C675WRBdup_112024_1_ds.4f944bff6656427da3448d282d1c1ff8/C675WRBdup_112024_1_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67600125 Dec  3 11:23 download/C687KOA_112024_1_ds.77346ea43c4b4c5e852e52c21f4d172b/C687KOA_112024_1_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67287595 Dec  3 11:23 download/C687KOAdup_112024_1_ds.7b874c60b4c84c168451d822a1874f4d/C687KOAdup_112024_1_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75876041 Dec  3 11:25 download/C688SBA_112024_1_ds.c75375cc79044a97a819d1ed3ec1e2cc/C688SBA_112024_1_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81529682 Dec  3 11:24 download/C688SBAdup_112024_1_ds.1c2b94927c934dd397d71a0a6d9fd17c/C688SBAdup_112024_1_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      7672 Dec  3 11:23 download/C692LHF_112024_1_ds.6283b358221e45dd9d6af9beb6556bd6/C692LHF_112024_1_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79300461 Dec  3 11:24 download/C692LHFdup_112024_1_ds.bad2770b2e3c4cd0934f101907660c25/C692LHFdup_112024_1_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96051328 Dec  3 11:23 download/C697TEQ_112024_1_ds.bf55900e301b42c58639e3c6901c5938/C697TEQ_112024_1_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     12806 Dec  3 11:24 download/C697TEQdup_112024_1_ds.8e114c3d328942359b529bec86df3372/C697TEQdup_112024_1_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     13367 Dec  3 11:23 download/C699EYP_112024_1_ds.38cda24e132b4e1b921f0b5ae22562ca/C699EYP_112024_1_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87224191 Dec  3 11:24 download/C699EYPdup_112024_1_ds.a423a9fa94e04b759c4012cceddc5a7b/C699EYPdup_112024_1_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90189295 Dec  3 11:23 download/C707RSY_112024_1_ds.94ce842ba0c446508ae7c9550e714281/C707RSY_112024_1_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     25535 Dec  3 11:23 download/C707RSYdup_112024_1_ds.020e60c8ba684a9fb437103a75d2611a/C707RSYdup_112024_1_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76376110 Dec  3 11:23 download/C712ZAP_112024_1_ds.4611e94025e941a4b5ddecd3cd7918f5/C712ZAP_112024_1_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      2271 Dec  3 11:23 download/C712ZAPdup_112024_1_ds.744050f4d065469aa335eeb024e13f53/C712ZAPdup_112024_1_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100800163 Dec  3 11:24 download/CSE01_1_112024_1_ds.2d42ed1702dd469b90acf370baf1aab9/CSE01_1_112024_1_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     40962 Dec  3 11:23 download/CSE01_2_112024_1_ds.8bd58f3c50e64f28b14e5db42c5ad963/CSE01_2_112024_1_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90083501 Dec  3 11:25 download/CSE13_1_112024_1_ds.2004d285105d462980051626f8c8817b/CSE13_1_112024_1_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71551342 Dec  3 11:23 download/CSE13_2_112024_1_ds.c58c539789c345e7baadb9ee28d77a40/CSE13_2_112024_1_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91180816 Dec  3 11:23 download/P158CIS_112024_1_ds.a546c16bf134481fa514c7c2667c9dbe/P158CIS_112024_1_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     11267 Dec  3 11:23 download/P158CISdup_112024_1_ds.96d66ecb8e9f4f9fba22b3ccec794842/P158CISdup_112024_1_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84145802 Dec  3 11:23 download/P222LDC_112024_1_ds.4297af1758eb40d9877f76bf3e7e2333/P222LDC_112024_1_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81987871 Dec  3 11:23 download/P222LDCdup_112024_1_ds.82738981beb1488fb8f92a051d0ef641/P222LDCdup_112024_1_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     50256 Dec  3 11:23 download/P227TPC_112024_1_ds.07b51a94820f44919534f84051c43403/P227TPC_112024_1_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80167943 Dec  3 11:23 download/P227TPCdup_112024_1_ds.61e602202ed0456eb26464c5791ddf4a/P227TPCdup_112024_1_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95253415 Dec  3 11:23 download/P315LRS_112024_1_ds.cf916b7fc6204c52b0a879b466bfcb18/P315LRS_112024_1_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     43919 Dec  3 11:23 download/P315LRSdup_112024_1_ds.56d791e014a94d2da5edaa8d8d13cf88/P315LRSdup_112024_1_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83002651 Dec  3 11:23 download/P325CEA_112024_1_ds.890a51ab6ab145b3955ed590f9639575/P325CEA_112024_1_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  64930629 Dec  3 11:23 download/P325CEAdup_112024_1_ds.d69a7d4a266f4bf7afcd51e17681930d/P325CEAdup_112024_1_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     19531 Dec  3 11:24 download/P337APS_112024_1_ds.d61d037c535b4b279bf99e84b5b4870b/P337APS_112024_1_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  61916464 Dec  3 11:23 download/P337APSdup_112024_1_ds.3248b443119a4d49b536d03f956a8051/P337APSdup_112024_1_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84077461 Dec  3 11:23 download/P378YHP_112024_1_ds.21eddb9aabd545f484a2b556136a7a99/P378YHP_112024_1_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      7191 Dec  3 11:23 download/P378YHPdup_112024_1_ds.f94617a5a363433382b1bce4363e6049/P378YHPdup_112024_1_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80422322 Dec  3 11:23 download/P391XQG_112024_1_ds.cbd6cdd71df646d1bfce83a82948939a/P391XQG_112024_1_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67968159 Dec  3 11:23 download/P391XQGdup_112024_1_ds.01065259839442c089e2fe030e47f0ee/P391XQGdup_112024_1_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    290186 Dec  3 11:23 download/P414AIK_112024_1_ds.664b36022947432186cb5314aa94aa5a/P414AIK_112024_1_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82070737 Dec  3 11:23 download/P414AIKdup_112024_1_ds.a3a4568f5d4b454ea303bf971f5eb100/P414AIKdup_112024_1_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     64535 Dec  3 11:23 download/P432CUD_112024_1_ds.ca9457cecbb44283a0141fa6c64e067e/P432CUD_112024_1_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     87987 Dec  3 11:24 download/P432CUDdup_112024_1_ds.d5ee785264414c76ad9121dc41fdccde/P432CUDdup_112024_1_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      5735 Dec  3 11:23 download/PLib01_1_112024_1_ds.d108801410bb43159d8cbda68c965d7c/PLib01_1_112024_1_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83020881 Dec  3 11:24 download/PLib01_2_112024_1_ds.e8cd2318aca644a4b6a2b2e9198a1bbc/PLib01_2_112024_1_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      6163 Dec  3 11:23 download/PLib13_1_112024_1_ds.c1577d4452d2411eb598c9a3155aa8bc/PLib13_1_112024_1_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81726537 Dec  3 11:23 download/PLib13_2_112024_1_ds.90bd325b92584ffb829c607d0333e7ee/PLib13_2_112024_1_S139_L001_R1_001.fastq.gz



```

Note that there is no "Undetermined"?


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
```

```
for f in download/*/*fastq.gz ; do
b=$( basename $f )
x=$( basename $f _L001_R1_001.fastq.gz )
s=$( echo $x | awk -F_ '{print $NF}' )
x=${x%_112024_S*}
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
for f in fastq/S*fastq.gz ; do
echo $f
for i in $( zcat $f | sed -n '1~4p' | cut -d' ' -f2 | cut -d: -f4 | sort | uniq ) ; do
echo $i
grep $i manifest.tsv
done ; done > index_checking.txt 
```


```
for f in fastq/S*fastq.gz ; do
echo $f
s=$( basename $f .fastq.gz )
awk -F"\t" -v s=$s '( $1 == s )' manifest.tsv
while read count i ; do
echo $i $count
awk -F"\t" -v i=$i '( $3 == i )' manifest.tsv
done < <( zcat $f | sed -n '1~4p' | cut -d' ' -f2 | cut -d: -f4 | sort | uniq -c )
done > index_checking.2.txt 
```


```
mkdir indices
zcat fastq/*fastq.gz | paste - - - - | awk -F"\t" '{split($1,a,":"); print $1 >> "indices/"a[10]".fastq"; print $2 >> "indices/"a[10]".fastq"; print $3 >> "indices/"a[10]".fastq"; print $4 >> "indices/"a[10]".fastq"}'
```


```
mkdir merged
cd merged
while read sample index ; do
x11=0
x12=0
if [ -f /francislab/data1/raw/20241127-Illumina-PhIP/indices/$index.fastq.gz ] ; then
x11=$( stat -c %s /francislab/data1/raw/20241127-Illumina-PhIP/indices/$index.fastq.gz )
fi
if [ -f /francislab/data1/raw/20241203-Illumina-PhIP/indices/$index.fastq.gz ] ; then
x12=$( stat -c %s /francislab/data1/raw/20241203-Illumina-PhIP/indices/$index.fastq.gz )
fi
if [ $x11 -gt $x12 ] ; then
ln -s /francislab/data1/raw/20241127-Illumina-PhIP/indices/$index.fastq.gz $sample.fastq.gz
else
ln -s /francislab/data1/raw/20241203-Illumina-PhIP/indices/$index.fastq.gz $sample.fastq.gz
fi
echo $index $x11 $x12
done < <( awk -F"\t" '(NR>1){print $1,$6}' ../manifest.tsv )

```



