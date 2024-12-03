
#	20241127-Illumina-PhIP


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
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 438875584
```

```
cd ..
ll download/*/*z



-rw-r----- 1 gwendt francislab    264914 Nov 27 12:05 download/043MPL_112024_ds.eae9d6ec92a247f19d2021a4e0c4ddd7/043MPL_112024_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71176747 Nov 27 12:05 download/043MPLdup_112024_ds.d9748a1e1e2542f8a7d1ea53e062cb08/043MPLdup_112024_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69491565 Nov 27 12:05 download/101VKC_112024_ds.152a17bce6c54e3f9195130a524c3d59/101VKC_112024_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73577801 Nov 27 12:05 download/101VKCdup_112024_ds.0c52a0dcf64046d6bcce15d0442b335a/101VKCdup_112024_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83690876 Nov 27 12:05 download/1301_112024_ds.59300e56144242fa9cfa4fe388b91894/1301_112024_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1200649 Nov 27 12:05 download/1301dup_112024_ds.2470999d6f9d4b2aa50e618317452d41/1301dup_112024_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72757964 Nov 27 12:05 download/1302_112024_ds.0cd3e36ad68440c6a6d29bf0e929a4fb/1302_112024_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75092402 Nov 27 12:05 download/1302dup_112024_ds.dc648d8d8b4f4907aeea89a18c1dc1ad/1302dup_112024_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     99615 Nov 27 12:05 download/1303_112024_ds.886d9e6889744dddb93fe3379f5e973e/1303_112024_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    205228 Nov 27 12:05 download/1303dup_112024_ds.7f151dedb10a4c54a866ce6e08f46661/1303dup_112024_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80765210 Nov 27 12:05 download/1304_112024_ds.cacde7ffeb454bf2a5d7adaa77c66033/1304_112024_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80249768 Nov 27 12:05 download/1304dup_112024_ds.8b9a4323ecc2456fb3fac7c6db760dae/1304dup_112024_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81534836 Nov 27 12:05 download/1305_112024_ds.b1613ea57aee4098ad1dbf1d3f594f05/1305_112024_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73488132 Nov 27 12:05 download/1305dup_112024_ds.56af918b836546a58071e276d820b0de/1305dup_112024_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    182286 Nov 27 12:05 download/1306_112024_ds.5572fac40fa24e1384c3d7a35440014d/1306_112024_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    199766 Nov 27 12:05 download/1306dup_112024_ds.b3742aab0eef490bae4b8a079ab4af8b/1306dup_112024_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95768304 Nov 27 12:05 download/1307_112024_ds.d04120cde09644e2993c219a0e80ea2e/1307_112024_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     34179 Nov 27 12:05 download/1307dup_112024_ds.e0d020b202ff45dd8e24e872da1685f6/1307dup_112024_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    527424 Nov 27 12:05 download/1308_112024_ds.7ecd39f7df9d40cf9f84f76e07c029d6/1308_112024_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     22288 Nov 27 12:05 download/1308dup_112024_ds.4df03463d5084aff91fe29b24e12877e/1308dup_112024_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    783558 Nov 27 12:05 download/1309_112024_ds.2321b0413f5f41daa2f9ca4aef6b6894/1309_112024_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     45142 Nov 27 12:05 download/1309dup_112024_ds.88f0175262064b62a094c267667aec50/1309dup_112024_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    697485 Nov 27 12:05 download/1310_112024_ds.4705dfa81bea43afaf34a3bdcb1ce619/1310_112024_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    195772 Nov 27 12:05 download/1310dup_112024_ds.e9d40c28aba74fa6b8add4032557da3f/1310dup_112024_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89610261 Nov 27 12:05 download/1311_112024_ds.83a0c9016b944290ab2a0ed94ba72488/1311_112024_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    477688 Nov 27 12:05 download/1311dup_112024_ds.106fdb331e494c3abd976fadde9c9472/1311dup_112024_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74653743 Nov 27 12:05 download/1312_112024_ds.fcfb1bc610c041fcaedac0b6c30d7d12/1312_112024_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    420319 Nov 27 12:05 download/1312dup_112024_ds.a20f82d17d7c4993815bdb22f5e66f76/1312dup_112024_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     90896 Nov 27 12:05 download/14078-01_112024_ds.cb1a5356bbbf41cbb3af60aee7721f5d/14078-01_112024_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1142007 Nov 27 12:05 download/14078-01dup_112024_ds.d11af9ade3344a9789f68c5a5d3d9477/14078-01dup_112024_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     96415 Nov 27 12:05 download/14118-01_112024_ds.683ece44f4d5442f822bbf4d8ad8b073/14118-01_112024_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 125708719 Nov 27 12:05 download/14118-01dup_112024_ds.6cadfbc505f34a3c817a5d663406ba6c/14118-01dup_112024_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    557353 Nov 27 12:05 download/14127-01_112024_ds.edad93a2dd0c454cbf1cf9e2a0f69268/14127-01_112024_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    278990 Nov 27 12:05 download/14127-01dup_112024_ds.1cf5310abf974f0fa28c36ee47d02007/14127-01dup_112024_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76885602 Nov 27 12:05 download/14142-01_112024_ds.aa7e618fbc6d417f9c381dc172fdc73f/14142-01_112024_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90509103 Nov 27 12:05 download/14142-01dup_112024_ds.0c7e544331f5489c9c9fff150682a6a2/14142-01dup_112024_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88432640 Nov 27 12:05 download/14206-01_112024_ds.996120fe9b184f64a15a938f9d72dc99/14206-01_112024_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93516508 Nov 27 12:05 download/14206-01dup_112024_ds.af04874cfdd14ca0af53d0d02582de47/14206-01dup_112024_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79725415 Nov 27 12:05 download/14223-01_112024_ds.0290801f3d4c40f1b9c7f6c66bddcce0/14223-01_112024_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97067983 Nov 27 12:05 download/14223-01dup_112024_ds.6e94dd1ea42f49b7852101e8ad7c3e1f/14223-01dup_112024_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     40318 Nov 27 12:05 download/14235-01_112024_ds.d86883513a4e40d1aff01614dcf1d65e/14235-01_112024_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    886654 Nov 27 12:05 download/14235-01dup_112024_ds.28b2b4aa8d204c7591e6a6f91810fa1a/14235-01dup_112024_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    445418 Nov 27 12:05 download/14337-01_112024_ds.7be07113753642bd8f003bf8c3409918/14337-01_112024_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    366894 Nov 27 12:05 download/14337-01dup_112024_ds.4c382578e10345baaa07dca4cf10396e/14337-01dup_112024_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    294622 Nov 27 12:05 download/14358-02_112024_ds.f669529bfe934ab290b4310d78d9972e/14358-02_112024_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88408966 Nov 27 12:05 download/14358-02dup_112024_ds.25dee84837bb459c847f939244b443bd/14358-02dup_112024_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    333019 Nov 27 12:05 download/14415-02_112024_ds.e68f817433aa47bca520bc912778727f/14415-02_112024_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    219045 Nov 27 12:05 download/14415-02dup_112024_ds.e5fb2433cc1f4dd8a0fc210c38d58398/14415-02dup_112024_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     19425 Nov 27 12:05 download/14431-01_112024_ds.c784d340ef6249a0b0f353f34ea622ae/14431-01_112024_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87345034 Nov 27 12:05 download/14431-01dup_112024_ds.085c2193068c4d17a31333798c0d729c/14431-01dup_112024_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     13399 Nov 27 12:05 download/14471-01_112024_ds.d5e5dab536e54f9fba15aff8972bbcae/14471-01_112024_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    620640 Nov 27 12:05 download/14471-01dup_112024_ds.31d609ce1fb9468486bc309b153f7bf9/14471-01dup_112024_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     25973 Nov 27 12:05 download/14566-01_112024_ds.2e61ef287d1e40b1be26e39dc6011ca5/14566-01_112024_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    300658 Nov 27 12:05 download/14566-01dup_112024_ds.8fae86b7c8744fb5be73864ec442461d/14566-01dup_112024_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87980772 Nov 27 12:05 download/14627-01_112024_ds.8fc5a72f67ed4c9ea7f8b69c9501c01f/14627-01_112024_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    614652 Nov 27 12:05 download/14627-01dup_112024_ds.2fcf6cdd289a42c5b00789259beed615/14627-01dup_112024_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81224288 Nov 27 12:05 download/14668-01_112024_ds.78576398a5ca4742a26c5435376744c0/14668-01_112024_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84289790 Nov 27 12:05 download/14668-01dup_112024_ds.bbbe6afee9cd484db286b3bf8398b302/14668-01dup_112024_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  64622184 Nov 27 12:05 download/14719-01_112024_ds.6620deb5058942f08745f567adc1f3dc/14719-01_112024_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    152546 Nov 27 12:05 download/14719-01dup_112024_ds.778fca63578244eab9d9a5ca5bb8305f/14719-01dup_112024_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     16061 Nov 27 12:05 download/14748-01_112024_ds.ddfb69524a7347ea8a224c1ed4ca4bf6/14748-01_112024_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84565977 Nov 27 12:05 download/14748-01dup_112024_ds.30cc51d4044048348735be17395d7672/14748-01dup_112024_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90309789 Nov 27 12:05 download/14807-01_112024_ds.bad1eece1851436081c46b91808a4265/14807-01_112024_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     46376 Nov 27 12:05 download/14807-01dup_112024_ds.d6bf2b1837f94c61be609b821c8762e5/14807-01dup_112024_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82505871 Nov 27 12:05 download/14879-01_112024_ds.6501bc72cef747e89b8d66f18407e7ec/14879-01_112024_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73458607 Nov 27 12:05 download/14879-01dup_112024_ds.1775a11c244c46108f4703f75a4753eb/14879-01dup_112024_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    395933 Nov 27 12:05 download/14896-01_112024_ds.24fda301422b44f4ab0dcddc4225a771/14896-01_112024_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    350202 Nov 27 12:05 download/14896-01dup_112024_ds.f2750ac0b88e41139bca26eadedd4297/14896-01dup_112024_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    149277 Nov 27 12:05 download/14953-01_112024_ds.839e5a2bf785423aa8b397592df72b1f/14953-01_112024_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    496675 Nov 27 12:05 download/14953-01dup_112024_ds.ddf0116fca7d4c03b47c16dc1c51161d/14953-01dup_112024_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84481053 Nov 27 12:05 download/20046_112024_ds.2113929d402644218e90ee46b99fa51c/20046_112024_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    894512 Nov 27 12:05 download/20046dup_112024_ds.7c7649f91ac64134b1b58f387c5f05e3/20046dup_112024_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     91093 Nov 27 12:05 download/20087_112024_ds.8438eb16905b40b580b0ad8293a0a647/20087_112024_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    982147 Nov 27 12:05 download/20087dup_112024_ds.786f0a6fe0ef477bb0af11b7b29e1278/20087dup_112024_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78897673 Nov 27 12:05 download/20178_112024_ds.740fd922423c485faefaaa2566bcaf94/20178_112024_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85703417 Nov 27 12:05 download/20178dup_112024_ds.17332a1ff7fb4a2494b44c3901f03c70/20178dup_112024_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      9297 Nov 27 12:05 download/20265_112024_ds.b5f3d40f0e5e416db7505ab09a2ea73e/20265_112024_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    962257 Nov 27 12:05 download/20265dup_112024_ds.b719911137124cff8389b69a84d58d9c/20265dup_112024_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    883122 Nov 27 12:05 download/20268_112024_ds.39e7a0064f2743e5ab8b622130c0dd19/20268_112024_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 111971503 Nov 27 12:05 download/20268dup_112024_ds.d24b4108d9c24b9e9b5c7ba80154299c/20268dup_112024_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    514212 Nov 27 12:05 download/20469_112024_ds.a40fcb07fc894223866fbc2519f63d68/20469_112024_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78172462 Nov 27 12:05 download/20469dup_112024_ds.a4f6763413914f3395d265de8fa24b2d/20469dup_112024_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     47306 Nov 27 12:05 download/20480_112024_ds.b50e871179e44ddb8e9c93099dc675ff/20480_112024_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    234429 Nov 27 12:05 download/20480dup_112024_ds.f8821905fa414c66bd5d2ce2c195811e/20480dup_112024_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    632379 Nov 27 12:05 download/20502_112024_ds.3b31fdbcc5c7406ca189d15ea33ec745/20502_112024_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91878523 Nov 27 12:05 download/20502dup_112024_ds.80f9ee93c4ed4a71a280e483c440ca3a/20502dup_112024_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77538965 Nov 27 12:05 download/21047_112024_ds.4dd8f9f59c8f4f3a8874ff48daf5203e/21047_112024_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    468826 Nov 27 12:05 download/21047dup_112024_ds.b4106a2664ff4811982bf5764cf0dbaa/21047dup_112024_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    436601 Nov 27 12:05 download/21095_112024_ds.e73dc1c761944ce0a19c4675f14a2d4b/21095_112024_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    507022 Nov 27 12:05 download/21095dup_112024_ds.a36ee3cb88f84015af2056e7bdaf3e1c/21095dup_112024_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92023867 Nov 27 12:05 download/21112_112024_ds.1113fb630f4d4c1489fbdaec69bd10a9/21112_112024_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84136786 Nov 27 12:05 download/21112dup_112024_ds.f994d0a608634644aca4f418554ad8a3/21112dup_112024_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69968684 Nov 27 12:05 download/21197_112024_ds.3452035d7b2e4f1aaab8a218768237bd/21197_112024_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1324800 Nov 27 12:05 download/21197dup_112024_ds.315b5783ee9a4bbe831ef33a502ab13f/21197dup_112024_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    913872 Nov 27 12:05 download/21198_112024_ds.6c9781ae6f01416f847687d5fc79a010/21198_112024_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    255114 Nov 27 12:05 download/21198dup_112024_ds.b5c903eab03b44bbb95261817bb1eb16/21198dup_112024_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    653969 Nov 27 12:05 download/21293_112024_ds.2c99ed06ec25412eab7df677f0d1bed1/21293_112024_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    569967 Nov 27 12:05 download/21293dup_112024_ds.69d5a60d9f254abb8f6f7ca9b1d4626e/21293dup_112024_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    662322 Nov 27 12:05 download/3397_112024_ds.992f33b97640487c90ec4f243fd3e0cb/3397_112024_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     43232 Nov 27 12:05 download/3397dup_112024_ds.b25476027bdf40e296ab791e233df2bc/3397dup_112024_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83858359 Nov 27 12:05 download/369GAC_112024_ds.867992d6d60f49b1bcb0afe234f0d817/369GAC_112024_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     90575 Nov 27 12:05 download/369GACdup_112024_ds.26df368b60fb4ea7b14bd6a789c88cc1/369GACdup_112024_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    240109 Nov 27 12:05 download/4129_112024_ds.282a9e793a174d37ab3a8556d66d83a3/4129_112024_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     68777 Nov 27 12:05 download/4129dup_112024_ds.975e249313a341e3811ae2f2454c7f6b/4129dup_112024_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    324097 Nov 27 12:05 download/4207_112024_ds.02f4e6c5535640fe82df21764a6bdf97/4207_112024_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    856090 Nov 27 12:05 download/4207dup_112024_ds.135412c83cb143ddb90c5d2169c22713/4207dup_112024_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     98714 Nov 27 12:05 download/4238_112024_ds.a0345c696cc342199e6abe677389f564/4238_112024_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89929744 Nov 27 12:05 download/4238dup_112024_ds.dc4102946c5b4633aa55d05861cfa023/4238dup_112024_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    753479 Nov 27 12:05 download/4276_112024_ds.7f5294830a7146f2ab0ab061dbec46bf/4276_112024_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    424621 Nov 27 12:05 download/4276dup_112024_ds.1bb7a4c688ab47ac97fb2c4faad342cc/4276dup_112024_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    129979 Nov 27 12:05 download/4460_112024_ds.ce02492f11cb4f2286476d99f56d3222/4460_112024_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83118036 Nov 27 12:05 download/4460dup_112024_ds.c612938ec3ba4cdbbdb83d3c34cb67d2/4460dup_112024_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    423508 Nov 27 12:05 download/4537_112024_ds.1f21c4dbb820449ca5cde839b64f69d6/4537_112024_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    385706 Nov 27 12:05 download/4537dup_112024_ds.318cfd3526624e8d914e06798c302577/4537dup_112024_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    159099 Nov 27 12:05 download/469MCM_112024_ds.c71e696db3344371afa2023e3a924b40/469MCM_112024_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74038604 Nov 27 12:05 download/469MCMdup_112024_ds.8cd548d674284386abf6eb19778d8b82/469MCMdup_112024_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    940714 Nov 27 12:05 download/472EKC_112024_ds.62a66462c81143978d1b7356e171246b/472EKC_112024_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    326558 Nov 27 12:05 download/472EKCdup_112024_ds.dd6a4b25439447d1a3c938e0ac79bdc4/472EKCdup_112024_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    427560 Nov 27 12:05 download/473IRR_112024_ds.1edbb5b27736497a83dd899d6c9baf26/473IRR_112024_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75381130 Nov 27 12:05 download/473IRRdup_112024_ds.45737f46f4be4f738fc9c839e2d6adbd/473IRRdup_112024_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87780930 Nov 27 12:05 download/474RHI_112024_ds.4c67afba091e4202b757eccfba2af179/474RHI_112024_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    560325 Nov 27 12:05 download/474RHIdup_112024_ds.21f0215b20724047bc34f3ce18c156f7/474RHIdup_112024_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92741969 Nov 27 12:05 download/478ZKA_112024_ds.a53ec72d9dbf40c18d1b4f1a7d60e0ff/478ZKA_112024_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    390547 Nov 27 12:05 download/478ZKAdup_112024_ds.99b1e2e305aa417fa67c0fe252b96e83/478ZKAdup_112024_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    368325 Nov 27 12:05 download/480LCO_112024_ds.62ac9ce19d284ac1bb440827206ab938/480LCO_112024_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88285137 Nov 27 12:05 download/480LCOdup_112024_ds.f6db36fb8c754fae8f23cb70121f6052/480LCOdup_112024_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    101672 Nov 27 12:05 download/616SFY_112024_ds.0a7cef351f5d45f1a1707065d2004cb8/616SFY_112024_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     13255 Nov 27 12:05 download/616SFYdup_112024_ds.5c096378e4cb4f50a3945bc1a72cb39c/616SFYdup_112024_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88616074 Nov 27 12:05 download/Blank01_1_112024_ds.bb54eea37bf141128c23550f9402ed85/Blank01_1_112024_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    164187 Nov 27 12:05 download/Blank01_2_112024_ds.31c2f38e18a840aa8cdc69173a445239/Blank01_2_112024_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90876257 Nov 27 12:05 download/Blank02_1_112024_ds.8d96398ac9cd4fccbc803337cdfff3cd/Blank02_1_112024_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  70557088 Nov 27 12:05 download/Blank02_2_112024_ds.769decd5edb64a13962ab015e0dfda39/Blank02_2_112024_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    778871 Nov 27 12:05 download/Blank03_1_112024_ds.916daee9fcb0431d84da13da11d9ebed/Blank03_1_112024_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    106308 Nov 27 12:05 download/Blank03_2_112024_ds.be3f1b592a2848dca61a9b80615b483d/Blank03_2_112024_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    101276 Nov 27 12:05 download/Blank04_1_112024_ds.9ff38768c501424e97e2d8baaf0ba716/Blank04_1_112024_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    242967 Nov 27 12:05 download/Blank04_2_112024_ds.d4534c1deb954f7d943e60da5533a236/Blank04_2_112024_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    563363 Nov 27 12:05 download/Blank49_1_112024_ds.258c55d8bdf5466bb183cc7be403e7e6/Blank49_1_112024_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1641862 Nov 27 12:05 download/Blank49_2_112024_ds.5c78e78098c4451c9e071cf03e078e1b/Blank49_2_112024_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84226933 Nov 27 12:05 download/Blank50_1_112024_ds.4d47da0f36be46a79911e73d20b2edd8/Blank50_1_112024_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92565081 Nov 27 12:05 download/Blank50_2_112024_ds.63adab7ab31d4fc7a03e8aacce59ed7d/Blank50_2_112024_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88644439 Nov 27 12:05 download/Blank51_1_112024_ds.5a919b4851c24771b70f68a4c9a47b70/Blank51_1_112024_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    362528 Nov 27 12:05 download/Blank51_2_112024_ds.bc73dfde3c6d44509d8e921f5a69c13d/Blank51_2_112024_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     35778 Nov 27 12:05 download/Blank52_1_112024_ds.ce920d0799f54c769f68e58f96ba8807/Blank52_1_112024_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    370800 Nov 27 12:05 download/Blank52_2_112024_ds.684e401214474f55bd6db8c274cbe80a/Blank52_2_112024_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  66976894 Nov 27 12:05 download/C661MAA_112024_ds.047746c85a2a481aad35c8723c6711d6/C661MAA_112024_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    182712 Nov 27 12:05 download/C661MAAdup_112024_ds.54f739ecd277496c82c4416bed78e3b6/C661MAAdup_112024_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    336324 Nov 27 12:05 download/C670ESA_112024_ds.675a7f63ff4d4a719465756857534373/C670ESA_112024_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73577993 Nov 27 12:05 download/C670ESAdup_112024_ds.99cb3fdfe8f64a67ae2912603465f4b2/C670ESAdup_112024_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77233876 Nov 27 12:05 download/C675WRB_112024_ds.759b597d1d464858b9f85ef3e252c7cd/C675WRB_112024_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    610571 Nov 27 12:05 download/C675WRBdup_112024_ds.2018842594a14bd79a4c539aed10efc2/C675WRBdup_112024_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     61982 Nov 27 12:05 download/C687KOA_112024_ds.4c85caa8d9f74fb2a92e78e456d81909/C687KOA_112024_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      4215 Nov 27 12:05 download/C687KOAdup_112024_ds.9d7b9154e0d04173b26be96f5e2a810d/C687KOAdup_112024_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    302914 Nov 27 12:05 download/C688SBA_112024_ds.808c91a794804186a2d6d533780d61eb/C688SBA_112024_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     54926 Nov 27 12:05 download/C688SBAdup_112024_ds.b8e00a664e6547d98ce54d5f83559ab6/C688SBAdup_112024_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90035731 Nov 27 12:05 download/C692LHF_112024_ds.f827f80dd50c45cfbc47847e51a9942f/C692LHF_112024_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     66815 Nov 27 12:05 download/C692LHFdup_112024_ds.95e7632001224da681c4bb448ad2a11d/C692LHFdup_112024_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    318336 Nov 27 12:05 download/C697TEQ_112024_ds.632956721b6a46fcb38500e9e8a6f1d8/C697TEQ_112024_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76433644 Nov 27 12:05 download/C697TEQdup_112024_ds.946e557240ee46aebbc2d0b5a272b941/C697TEQdup_112024_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81650060 Nov 27 12:05 download/C699EYP_112024_ds.9e30c156c5f04592ac34fde890c1dd8d/C699EYP_112024_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   3524325 Nov 27 12:05 download/C699EYPdup_112024_ds.c10c1ec02ae34463bf429fe82a0fa8cd/C699EYPdup_112024_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    310123 Nov 27 12:05 download/C707RSY_112024_ds.ac69458eaf954b45a00ffa57da8fc8ba/C707RSY_112024_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84793961 Nov 27 12:05 download/C707RSYdup_112024_ds.84719257d0134c4c887c390f0eff7662/C707RSYdup_112024_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    615389 Nov 27 12:05 download/C712ZAP_112024_ds.50f77b25e05c41a4b72cfbaf7d50939e/C712ZAP_112024_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77605866 Nov 27 12:05 download/C712ZAPdup_112024_ds.ba57c7a9f654491d9dd6feb573cd84d8/C712ZAPdup_112024_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    648252 Nov 27 12:05 download/CSE01_1_112024_ds.fb5a5f78e38649d3996cbee1d92424ca/CSE01_1_112024_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  59348259 Nov 27 12:05 download/CSE01_2_112024_ds.3bbb382b2c084ec5bffb03872038cb74/CSE01_2_112024_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92909104 Nov 27 12:05 download/CSE13_1_112024_ds.c31e1a17afe942799aa825610d0d5dc0/CSE13_1_112024_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    388805 Nov 27 12:05 download/CSE13_2_112024_ds.eda6b47bf1754b6292d2dfe038e9473c/CSE13_2_112024_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    196977 Nov 27 12:05 download/P158CIS_112024_ds.72e98810d0ef4f129da82479d726d63f/P158CIS_112024_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  39902003 Nov 27 12:05 download/P158CISdup_112024_ds.89cc838fb950423ba9deab3f6e323a49/P158CISdup_112024_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    527250 Nov 27 12:05 download/P222LDC_112024_ds.f2bd5dfce6804d09b17f014f1d30454a/P222LDC_112024_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   1088479 Nov 27 12:05 download/P222LDCdup_112024_ds.1249871057fd4b39adb63057f44d3671/P222LDCdup_112024_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81286678 Nov 27 12:05 download/P227TPC_112024_ds.12722ce820ee4641b8ca76c4bca2224a/P227TPC_112024_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81970341 Nov 27 12:05 download/P227TPCdup_112024_ds.422afe09146549d4af7f54c9cae5fd05/P227TPCdup_112024_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    380122 Nov 27 12:05 download/P315LRS_112024_ds.530aa478423d42f7b031f7e8b940c915/P315LRS_112024_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74116093 Nov 27 12:05 download/P315LRSdup_112024_ds.f11f0bbaacb141ad9716f59bf3d423e7/P315LRSdup_112024_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    636926 Nov 27 12:05 download/P325CEA_112024_ds.7ff0ec305cc345e48ad4e198fa5c6e5c/P325CEA_112024_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    123852 Nov 27 12:05 download/P325CEAdup_112024_ds.80a1490cd7414324a7e5d280f8ab0fa3/P325CEAdup_112024_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75331970 Nov 27 12:05 download/P337APS_112024_ds.306a4e78ebb04eb0834355d5d14b9935/P337APS_112024_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    381321 Nov 27 12:05 download/P337APSdup_112024_ds.a3cf063cbc304dcc9142fa89c5bbc3a1/P337APSdup_112024_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    251342 Nov 27 12:05 download/P378YHP_112024_ds.6d56761e9aff4de59a867a054dabb8ad/P378YHP_112024_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82905036 Nov 27 12:05 download/P378YHPdup_112024_ds.bcbc7efc861345129b1fbf8f669f856f/P378YHPdup_112024_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    294697 Nov 27 12:05 download/P391XQG_112024_ds.a17450a6eb9c48d2806dbe7e61dc8012/P391XQG_112024_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    614959 Nov 27 12:05 download/P391XQGdup_112024_ds.c5727bc1a641405d9193f35702e3f3a8/P391XQGdup_112024_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81952715 Nov 27 12:05 download/P414AIK_112024_ds.c90b0bd38e48453c9e5e95cc4d40f44f/P414AIK_112024_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83496816 Nov 27 12:05 download/P414AIKdup_112024_ds.f5982d5cfe014141b70b05f939b97892/P414AIKdup_112024_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68790777 Nov 27 12:05 download/P432CUD_112024_ds.cc67e52163b04fecbc46b8a4b0c06e33/P432CUD_112024_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81862673 Nov 27 12:05 download/P432CUDdup_112024_ds.6476c83e4fd34ae2a3fb9a8bf889246b/P432CUDdup_112024_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89078794 Nov 27 12:05 download/PLib01_1_112024_ds.e741950e852b4b708ae3eb3ac139c444/PLib01_1_112024_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab     44771 Nov 27 12:05 download/PLib01_2_112024_ds.4187056ba4ed42ae9b76016e6337f951/PLib01_2_112024_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71749753 Nov 27 12:05 download/PLib13_1_112024_ds.2361fe96d84b45b88ac09a2b4c0e3643/PLib13_1_112024_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    180053 Nov 27 12:05 download/PLib13_2_112024_ds.b84297584dac4813b87c7c7bb697b993/PLib13_2_112024_S139_L001_R1_001.fastq.gz
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




##	20241203


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


##	demultiplex the fastq

```
mkdir indices
zcat fastq/*fastq.gz | paste - - - - | awk -F"\t" '{split($1,a,":"); print $1 >> "indices/"a[10]".fastq"; print $2 >> "indices/"a[10]".fastq"; print $3 >> "indices/"a[10]".fastq"; print $4 >> "indices/"a[10]".fastq"}'


```


