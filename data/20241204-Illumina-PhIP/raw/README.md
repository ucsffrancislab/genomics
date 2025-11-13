
#	20241204-Illumina-PhIP


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
| 112024_192PhiP_L1_2                     | 439633213 | 15642704216  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 439633213
```

```
cd ..
ll download/*/*z



-rw-r----- 1 gwendt francislab 100455320 Dec  4 12:18 download/043MPL_112024_2_ds.6a1d29cd13d74bf39e223d19feb4ac62/043MPL_112024_2_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80944796 Dec  4 12:18 download/043MPLdup_112024_2_ds.6b2da46748ec409480feec3d53982c8e/043MPLdup_112024_2_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87452186 Dec  4 12:18 download/101VKC_112024_2_ds.31d6370692e045aeaff62af0bb1d1db9/101VKC_112024_2_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87856443 Dec  4 12:18 download/101VKCdup_112024_2_ds.93eab648946a4191b751fbba7b8cd40a/101VKCdup_112024_2_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78682572 Dec  4 12:18 download/1301_112024_2_ds.484e646a8a65451085c384548a71f7e2/1301_112024_2_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  57654696 Dec  4 12:18 download/1301dup_112024_2_ds.8428f1798edf4611a64e91eda678f65a/1301dup_112024_2_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79143520 Dec  4 12:18 download/1302_112024_2_ds.87b06d1af3734c329119bb1316cec876/1302_112024_2_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82822464 Dec  4 12:17 download/1302dup_112024_2_ds.f64b5791cd804b799b6ab71ff1905194/1302dup_112024_2_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88798944 Dec  4 12:18 download/1303_112024_2_ds.fe5881096b13492b8b365f2df9c0f62f/1303_112024_2_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73925750 Dec  4 12:18 download/1303dup_112024_2_ds.25188b91017d498f98e6f13d8c01d9d9/1303dup_112024_2_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82070737 Dec  4 12:18 download/1304_112024_2_ds.d943b0fc763841b2b5f58bfa881fe097/1304_112024_2_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72115050 Dec  4 12:18 download/1304dup_112024_2_ds.c37e6ae84e86450a83b550e8553ab51a/1304dup_112024_2_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89197220 Dec  4 12:17 download/1305_112024_2_ds.2e97ebbbebc54b3bbd9e621283df25a7/1305_112024_2_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84021957 Dec  4 12:17 download/1305dup_112024_2_ds.07de44fe7d0041c08f80f47c0167c2dd/1305dup_112024_2_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88781414 Dec  4 12:18 download/1306_112024_2_ds.ddf554eac32a4c07a9397b9f740cbd12/1306_112024_2_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85159358 Dec  4 12:18 download/1306dup_112024_2_ds.9fa6491242624cffbbaf1cb86bbbfdf5/1306dup_112024_2_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83946142 Dec  4 12:18 download/1307_112024_2_ds.2b8a4ca71f1a43e485d2f40d5ce1e264/1307_112024_2_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79184133 Dec  4 12:18 download/1307dup_112024_2_ds.7b2032a38fa44661a6604247b150283a/1307dup_112024_2_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84212535 Dec  4 12:18 download/1308_112024_2_ds.6990ba6c41f04caca1c6266a9ce8e9ce/1308_112024_2_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88032002 Dec  4 12:18 download/1308dup_112024_2_ds.4f8e54471ba64a5d9c9becf67fbbda15/1308dup_112024_2_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82440260 Dec  4 12:18 download/1309_112024_2_ds.8b9daf6c2058401ea642b2822a661555/1309_112024_2_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79169442 Dec  4 12:18 download/1309dup_112024_2_ds.187455c8127c46ac9d574323e5a99e04/1309dup_112024_2_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73664838 Dec  4 12:17 download/1310_112024_2_ds.cf699718556e4b7c97cdb982089a74ee/1310_112024_2_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  28642409 Dec  4 12:18 download/1310dup_112024_2_ds.5cbf55f1683e4b238df62eea264bfa6d/1310dup_112024_2_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76880659 Dec  4 12:18 download/1311_112024_2_ds.636d167bc4f5486cb2a9c2a425a06913/1311_112024_2_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81419596 Dec  4 12:18 download/1311dup_112024_2_ds.f640564acbf1435da43489db7be5e1d4/1311dup_112024_2_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83224000 Dec  4 12:17 download/1312_112024_2_ds.2f86e0f6ba6648ee9768697b8692c019/1312_112024_2_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83093340 Dec  4 12:18 download/1312dup_112024_2_ds.9769161d8e154f8395005c0bd691fb52/1312dup_112024_2_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83552025 Dec  4 12:18 download/14078-01_112024_2_ds.9a11232904b8472fbf955d90bfea4e13/14078-01_112024_2_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67967380 Dec  4 12:18 download/14078-01dup_112024_2_ds.9a91fc1c4f7d48c6a6ee8d4121313b0f/14078-01dup_112024_2_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86905216 Dec  4 12:18 download/14118-01_112024_2_ds.bcd6294848434c63a131ee723f71eae3/14118-01_112024_2_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84419205 Dec  4 12:18 download/14118-01dup_112024_2_ds.0dc51645332948f5bdfb64b6599d299f/14118-01dup_112024_2_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74490073 Dec  4 12:17 download/14127-01_112024_2_ds.ed8102b16dee44e890baba5f4287321e/14127-01_112024_2_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  59783256 Dec  4 12:17 download/14127-01dup_112024_2_ds.ee13fc0a7126439f8d41358d1b627b12/14127-01dup_112024_2_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73704645 Dec  4 12:18 download/14142-01_112024_2_ds.b91d2a588ad54c6cb8e92ed159ea0333/14142-01_112024_2_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  39470551 Dec  4 12:17 download/14142-01dup_112024_2_ds.fb8b5f212df14c17be53a4aba97f2c56/14142-01dup_112024_2_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77865936 Dec  4 12:18 download/14206-01_112024_2_ds.94e0435865c14c3584f9e9e02b512a22/14206-01_112024_2_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69786500 Dec  4 12:18 download/14206-01dup_112024_2_ds.4c7f974da1a440ddb10d47a3fedeaead/14206-01dup_112024_2_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87944443 Dec  4 12:18 download/14223-01_112024_2_ds.1d5bf06882ae46a3b30a4214c425039c/14223-01_112024_2_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89856077 Dec  4 12:18 download/14223-01dup_112024_2_ds.04defc283a79444e9c6223e47f62de6d/14223-01dup_112024_2_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76580070 Dec  4 12:17 download/14235-01_112024_2_ds.6af6b763c3d540e797551f088a5523c2/14235-01_112024_2_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94526003 Dec  4 12:18 download/14235-01dup_112024_2_ds.85b2b4bc034340aebce72172c9b0ddf4/14235-01dup_112024_2_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87999845 Dec  4 12:18 download/14337-01_112024_2_ds.c8ae6685be964cbaa0d72bc90150280f/14337-01_112024_2_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87913361 Dec  4 12:18 download/14337-01dup_112024_2_ds.550a4d7de6a644558a0b609158fc0829/14337-01dup_112024_2_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88778149 Dec  4 12:18 download/14358-02_112024_2_ds.e97a2ca01d98407787e25d56e51a8757/14358-02_112024_2_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88691324 Dec  4 12:18 download/14358-02dup_112024_2_ds.fd15d35190d147f5a94292cff7b6bd59/14358-02dup_112024_2_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  66165060 Dec  4 12:18 download/14415-02_112024_2_ds.31953c0826124455ac93a04fe69e2cda/14415-02_112024_2_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69518947 Dec  4 12:18 download/14415-02dup_112024_2_ds.66eaffb015014989b0ca20c6bd4dceb6/14415-02dup_112024_2_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71656197 Dec  4 12:18 download/14431-01_112024_2_ds.47bc22d224474cc2a7ba2941307cf6d8/14431-01_112024_2_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68014566 Dec  4 12:18 download/14431-01dup_112024_2_ds.745a7af908a0463b864b8722a28c09f1/14431-01dup_112024_2_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 127792630 Dec  4 12:18 download/14471-01_112024_2_ds.e24f77e9a9b5493db5ca8c674dec1ba7/14471-01_112024_2_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 136333066 Dec  4 12:18 download/14471-01dup_112024_2_ds.ee8c0413e4a441a58fa762d279b27be4/14471-01dup_112024_2_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75322725 Dec  4 12:18 download/14566-01_112024_2_ds.ee2899cf4b7e45d5a1e55b13772e5d32/14566-01_112024_2_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77949418 Dec  4 12:18 download/14566-01dup_112024_2_ds.5fcdcbe4204944509a40d6c0b599a192/14566-01dup_112024_2_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  58833263 Dec  4 12:18 download/14627-01_112024_2_ds.ea301869e3134779b575c60f4ee264ed/14627-01_112024_2_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  39805137 Dec  4 12:18 download/14627-01dup_112024_2_ds.c1c9d2a4384743f6a4e44eee2c435900/14627-01dup_112024_2_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  70540596 Dec  4 12:18 download/14668-01_112024_2_ds.dd7cb4cbe6c246159e09a7061c3469f8/14668-01_112024_2_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79993228 Dec  4 12:18 download/14668-01dup_112024_2_ds.1afeb66597e04a2d996ba7c55a20dd00/14668-01dup_112024_2_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 111579375 Dec  4 12:18 download/14719-01_112024_2_ds.6f9f943b25bc410abfdec087ba521ea8/14719-01_112024_2_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82922459 Dec  4 12:18 download/14719-01dup_112024_2_ds.1086a650fec046cdb31c1e0aa07a964f/14719-01dup_112024_2_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88671543 Dec  4 12:17 download/14748-01_112024_2_ds.ebb7e0e2ac894371bcccfa1d9b78c128/14748-01_112024_2_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72916419 Dec  4 12:18 download/14748-01dup_112024_2_ds.422598997f7e4cbe823da6411ec398c4/14748-01dup_112024_2_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82409878 Dec  4 12:18 download/14807-01_112024_2_ds.9a60b94421b645c88d6fdbec0212c186/14807-01_112024_2_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91438149 Dec  4 12:18 download/14807-01dup_112024_2_ds.8ff11977a84d4e0a981d61bdff068151/14807-01dup_112024_2_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89012235 Dec  4 12:17 download/14879-01_112024_2_ds.9bba8df016c946019092b68bb00c33d6/14879-01_112024_2_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91108806 Dec  4 12:18 download/14879-01dup_112024_2_ds.15517a331c6f4f1d84907086375bb990/14879-01dup_112024_2_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 103835830 Dec  4 12:18 download/14896-01_112024_2_ds.96c619bd7c0a4111bb9d8621bf0b3ba3/14896-01_112024_2_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78651911 Dec  4 12:18 download/14896-01dup_112024_2_ds.f2a604db65564515aa0666bd27c8fc04/14896-01dup_112024_2_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83869912 Dec  4 12:18 download/14953-01_112024_2_ds.72b7c5c772c24e42a587192423e4849b/14953-01_112024_2_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 102254796 Dec  4 12:18 download/14953-01dup_112024_2_ds.8eb809819ff04a3c8e9dc33f15b1ad84/14953-01dup_112024_2_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95214924 Dec  4 12:18 download/20046_112024_2_ds.f4ebe520feb248e09fa507f6a7adbcb1/20046_112024_2_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  47503438 Dec  4 12:18 download/20046dup_112024_2_ds.1f191f1792b449bd8257cdc7e15cb5c6/20046dup_112024_2_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78814312 Dec  4 12:18 download/20087_112024_2_ds.bd75ab416efe431290b51a153c9482b1/20087_112024_2_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84061509 Dec  4 12:18 download/20087dup_112024_2_ds.efa827aa58bc4304b1f46371a61bc571/20087dup_112024_2_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83118148 Dec  4 12:18 download/20178_112024_2_ds.5243058e015e42e284f8648a8947ca85/20178_112024_2_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81550602 Dec  4 12:17 download/20178dup_112024_2_ds.9e3b76e1cce547f4be266acccf84bf72/20178dup_112024_2_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84911655 Dec  4 12:18 download/20265_112024_2_ds.372c64d4a3184ba4a9d9fdfde6bf178c/20265_112024_2_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90778138 Dec  4 12:18 download/20265dup_112024_2_ds.9b0ca15183ee4f328cbb2ed8b12eed0c/20265dup_112024_2_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 107391123 Dec  4 12:18 download/20268_112024_2_ds.bd0101573c214bbeacab89c10f118e98/20268_112024_2_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  63948618 Dec  4 12:18 download/20268dup_112024_2_ds.9cad81fe2215451480dbff3f1ab8dc72/20268dup_112024_2_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74277276 Dec  4 12:18 download/20469_112024_2_ds.ee208eb5bdb74f6795a1c878b83c2e15/20469_112024_2_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87939366 Dec  4 12:18 download/20469dup_112024_2_ds.31d21836b9b6469e83ff5dbffcf5ed39/20469dup_112024_2_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74765392 Dec  4 12:18 download/20480_112024_2_ds.5a01d94ebc404caa88d950bf81e43d37/20480_112024_2_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83148992 Dec  4 12:18 download/20480dup_112024_2_ds.229b3d5c205d41e69c4952fba0d34bd2/20480dup_112024_2_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88135028 Dec  4 12:18 download/20502_112024_2_ds.bdf2eac71c4540089affbea1bcd36cb3/20502_112024_2_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76424082 Dec  4 12:18 download/20502dup_112024_2_ds.06288d2086c04e2e83522534cc286421/20502dup_112024_2_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89029410 Dec  4 12:17 download/21047_112024_2_ds.912d8e3714ab40bca5bd45ebba663d52/21047_112024_2_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86581911 Dec  4 12:19 download/21047dup_112024_2_ds.4133318bdc2d42ac9090c0da2ce857a3/21047dup_112024_2_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88162286 Dec  4 12:18 download/21095_112024_2_ds.f757f218183347bcb2f5564d72911568/21095_112024_2_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65648846 Dec  4 12:17 download/21095dup_112024_2_ds.27b985fefcfa4eb78a5bb6c438633382/21095dup_112024_2_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72846596 Dec  4 12:18 download/21112_112024_2_ds.11f4da7930874a9fbc28c05c7f72c8c1/21112_112024_2_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74401007 Dec  4 12:18 download/21112dup_112024_2_ds.7e2c0aa5d17b41ce976a82803eaf76a9/21112dup_112024_2_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77345890 Dec  4 12:18 download/21197_112024_2_ds.6a33f2eca52945119467f4754306cea3/21197_112024_2_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81051317 Dec  4 12:18 download/21197dup_112024_2_ds.92931ddc6d9740a1ad2c3edfb0e8ada3/21197dup_112024_2_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 135606187 Dec  4 12:18 download/21198_112024_2_ds.28cc079114f94feca1500061b696b451/21198_112024_2_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75628130 Dec  4 12:18 download/21198dup_112024_2_ds.8b09220e62944b188d89bf3b5f5e5e60/21198dup_112024_2_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  61909154 Dec  4 12:18 download/21293_112024_2_ds.c25aba2b233a41628b8187341b3e46b8/21293_112024_2_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  64339758 Dec  4 12:17 download/21293dup_112024_2_ds.01b66232f6d345a1ace15ee4ea1edafe/21293dup_112024_2_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 110759828 Dec  4 12:18 download/3397_112024_2_ds.7efa365479b24feaa900d4b88e7aa273/3397_112024_2_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87116103 Dec  4 12:18 download/3397dup_112024_2_ds.6f117fa4e0804632925f558fb0531da9/3397dup_112024_2_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74749507 Dec  4 12:18 download/369GAC_112024_2_ds.d7d64fe592e64f14befeb36211698698/369GAC_112024_2_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76771744 Dec  4 12:18 download/369GACdup_112024_2_ds.dba86a25609a42dbab747355b4933754/369GACdup_112024_2_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  57896193 Dec  4 12:18 download/4129_112024_2_ds.18e99407e76c490189a86a34da42396c/4129_112024_2_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92518741 Dec  4 12:18 download/4129dup_112024_2_ds.af46c4b854c7472e9df662d245900eda/4129dup_112024_2_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76305761 Dec  4 12:18 download/4207_112024_2_ds.8782a45d707e420b87f3205b2c8179f5/4207_112024_2_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85638459 Dec  4 12:18 download/4207dup_112024_2_ds.6129fe918f1d4ae6bee46ef5647e5486/4207dup_112024_2_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78135943 Dec  4 12:18 download/4238_112024_2_ds.40d48099cbd2442d8fd29f4ae38e1ba1/4238_112024_2_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80998427 Dec  4 12:18 download/4238dup_112024_2_ds.0dc05146883b4848ae284372b42656b0/4238dup_112024_2_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84979819 Dec  4 12:18 download/4276_112024_2_ds.24692a12a31d428ab036a974cc014dc6/4276_112024_2_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100276722 Dec  4 12:18 download/4276dup_112024_2_ds.94eb63e54a5341e8a6b2ecc0989bdd0a/4276dup_112024_2_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92362517 Dec  4 12:18 download/4460_112024_2_ds.51c71b2a08a346fab0dc008b965b283a/4460_112024_2_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92452356 Dec  4 12:18 download/4460dup_112024_2_ds.3ed65c20b6404094866d1d39ef81cd2b/4460dup_112024_2_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85119134 Dec  4 12:18 download/4537_112024_2_ds.75461deae1f54f96a3265d5ec8b8497d/4537_112024_2_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 120027406 Dec  4 12:18 download/4537dup_112024_2_ds.9f3ea59381e640418736e860261bdda2/4537dup_112024_2_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67079871 Dec  4 12:18 download/469MCM_112024_2_ds.190ae70201cc481f9f1766fb9e4cc17a/469MCM_112024_2_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76498403 Dec  4 12:18 download/469MCMdup_112024_2_ds.e3aee2d041e94935be32e23827a8eb4d/469MCMdup_112024_2_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76232607 Dec  4 12:18 download/472EKC_112024_2_ds.d57daf51913e4f36a7781f41667aba77/472EKC_112024_2_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65867783 Dec  4 12:17 download/472EKCdup_112024_2_ds.99ea2aaf3cee419ba3caf4a6cadc5f22/472EKCdup_112024_2_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68228713 Dec  4 12:17 download/473IRR_112024_2_ds.94fc61feb4134466a9234438a9c7d763/473IRR_112024_2_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83482962 Dec  4 12:18 download/473IRRdup_112024_2_ds.76fbc7d71842474688b805245a12bf4a/473IRRdup_112024_2_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68659261 Dec  4 12:18 download/474RHI_112024_2_ds.40b004c4e5f042358874f2994526f8c2/474RHI_112024_2_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67773451 Dec  4 12:18 download/474RHIdup_112024_2_ds.236333e0afe4407e97088c8712a7c805/474RHIdup_112024_2_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82396529 Dec  4 12:18 download/478ZKA_112024_2_ds.26939b53084f41dab74cbd17f3904c1d/478ZKA_112024_2_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  65951885 Dec  4 12:18 download/478ZKAdup_112024_2_ds.b39fa5b02eb74727bce654b537cfc427/478ZKAdup_112024_2_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85340068 Dec  4 12:18 download/480LCO_112024_2_ds.40a8b14d19f140cd926825528ae94504/480LCO_112024_2_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75769431 Dec  4 12:18 download/480LCOdup_112024_2_ds.a012a686f34243909dd26f0e20b9d151/480LCOdup_112024_2_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83859076 Dec  4 12:18 download/616SFY_112024_2_ds.93bd8255d6fa4efbba36f182cf614901/616SFY_112024_2_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76584177 Dec  4 12:18 download/616SFYdup_112024_2_ds.579162957ed84c5faf9567d7a7fa8033/616SFYdup_112024_2_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71324392 Dec  4 12:18 download/Blank01_1_112024_2_ds.45a894a352e541bc8fa8bdcbd80e7fa5/Blank01_1_112024_2_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74534744 Dec  4 12:18 download/Blank01_2_112024_2_ds.41eaeaca0a60490bb4fa14334ab2c8e2/Blank01_2_112024_2_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95936609 Dec  4 12:19 download/Blank02_1_112024_2_ds.b14208f45e194bd3b608258537beb1b3/Blank02_1_112024_2_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92177340 Dec  4 12:18 download/Blank02_2_112024_2_ds.cfc7c432e9fd40a0b15a96ed194dffe5/Blank02_2_112024_2_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87699328 Dec  4 12:18 download/Blank03_1_112024_2_ds.54eb69cf9a784fdeb3cad463d5fbe1c9/Blank03_1_112024_2_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82006052 Dec  4 12:18 download/Blank03_2_112024_2_ds.d1868948252d4769bae4bda587935b34/Blank03_2_112024_2_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77967806 Dec  4 12:18 download/Blank04_1_112024_2_ds.fc64fdb5e23c4eb1885684f6945b3877/Blank04_1_112024_2_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 107207036 Dec  4 12:18 download/Blank04_2_112024_2_ds.8a3a1151f6c74a7985113c2c5fdb15cb/Blank04_2_112024_2_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82673950 Dec  4 12:18 download/Blank49_1_112024_2_ds.60016f4415a842648ca166ee2e829006/Blank49_1_112024_2_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75441268 Dec  4 12:18 download/Blank49_2_112024_2_ds.02659d32d989412eb5a183cb6b3dcf49/Blank49_2_112024_2_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75203930 Dec  4 12:18 download/Blank50_1_112024_2_ds.58256b1e73bb4a1ca6a7665f15ce8889/Blank50_1_112024_2_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87806210 Dec  4 12:18 download/Blank50_2_112024_2_ds.8eee58e708ab4e5da463b84be05cbccb/Blank50_2_112024_2_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79235134 Dec  4 12:18 download/Blank51_1_112024_2_ds.3ef920bcb148414886e4007a0165cdbb/Blank51_1_112024_2_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71564928 Dec  4 12:18 download/Blank51_2_112024_2_ds.bbf9288793834a65a70e077ee29287c6/Blank51_2_112024_2_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 111582911 Dec  4 12:18 download/Blank52_1_112024_2_ds.1455bc3c7deb4ab194fd8ce9da1d88c5/Blank52_1_112024_2_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92704533 Dec  4 12:19 download/Blank52_2_112024_2_ds.a030d9538fdc4eee896b4195fa07a2c0/Blank52_2_112024_2_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    137353 Dec  4 12:17 download/C661MAA_112024_2_ds.61c721041baf4b2cbcfeedc063de9a66/C661MAA_112024_2_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74126568 Dec  4 12:18 download/C661MAAdup_112024_2_ds.64b80ad4e11c4f76944c14902c02d481/C661MAAdup_112024_2_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 101309773 Dec  4 12:18 download/C670ESA_112024_2_ds.b8258dff81e64a6b8c88d4d33a769941/C670ESA_112024_2_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88687176 Dec  4 12:17 download/C670ESAdup_112024_2_ds.8f678c771539436faed9dcc77cf9346e/C670ESAdup_112024_2_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91154747 Dec  4 12:18 download/C675WRB_112024_2_ds.c13513be681a43909690c2d389fc5f76/C675WRB_112024_2_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85085075 Dec  4 12:18 download/C675WRBdup_112024_2_ds.674c07930925425ab12074bdbec8c562/C675WRBdup_112024_2_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67600125 Dec  4 12:18 download/C687KOA_112024_2_ds.84bd2994e2c6459db1943ad5cb9b7230/C687KOA_112024_2_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67287595 Dec  4 12:17 download/C687KOAdup_112024_2_ds.759ab6f05aca423c876a6f2a1200d866/C687KOAdup_112024_2_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75876041 Dec  4 12:19 download/C688SBA_112024_2_ds.44d548957b7d453182ec47632ace3173/C688SBA_112024_2_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81529682 Dec  4 12:18 download/C688SBAdup_112024_2_ds.7d096c9321b74e3faf733557f2022f74/C688SBAdup_112024_2_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89058543 Dec  4 12:18 download/C692LHF_112024_2_ds.49f276c2aa774c9a9303036b493fb9cd/C692LHF_112024_2_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79300461 Dec  4 12:18 download/C692LHFdup_112024_2_ds.b81874e1dae54593b4f3d0ec4e8538b1/C692LHFdup_112024_2_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96051324 Dec  4 12:18 download/C697TEQ_112024_2_ds.7ac4c27a15484b7ca11b909e398d666d/C697TEQ_112024_2_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87830633 Dec  4 12:18 download/C697TEQdup_112024_2_ds.24c8cce6d06e434fb3f275b27638ec3f/C697TEQdup_112024_2_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85052304 Dec  4 12:18 download/C699EYP_112024_2_ds.c8739403ddc647b2bfd109816e14ef3f/C699EYP_112024_2_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87224191 Dec  4 12:18 download/C699EYPdup_112024_2_ds.800d7f53611245de8e42f8e1dd0ac458/C699EYPdup_112024_2_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90189295 Dec  4 12:18 download/C707RSY_112024_2_ds.5dd28f8a9b594e1eb69d8fb06131c553/C707RSY_112024_2_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 123116756 Dec  4 12:17 download/C707RSYdup_112024_2_ds.2900f4542ae84e2ead7c69cab71852f2/C707RSYdup_112024_2_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  76376110 Dec  4 12:18 download/C712ZAP_112024_2_ds.1c63c6868ada446b85ac9c755dbd1c90/C712ZAP_112024_2_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69543774 Dec  4 12:18 download/C712ZAPdup_112024_2_ds.f936fff50fbe4ac3970422bb877120de/C712ZAPdup_112024_2_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100800161 Dec  4 12:18 download/CSE01_1_112024_2_ds.47ba44839ce44bd6aaadd1a01b6637f9/CSE01_1_112024_2_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86928384 Dec  4 12:18 download/CSE01_2_112024_2_ds.c40d13b87eb24f43b325f2fc1ae29cdc/CSE01_2_112024_2_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80167943 Dec  4 12:18 download/CSE13_1_112024_2_ds.a93a625dd3cd4577b61466b8f2cebc28/CSE13_1_112024_2_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71551342 Dec  4 12:18 download/CSE13_2_112024_2_ds.d311ae6089784bde8e174f3b9937275e/CSE13_2_112024_2_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91180816 Dec  4 12:18 download/P158CIS_112024_2_ds.0b4cab30493341ca83c1dbea3f1ebd8f/P158CIS_112024_2_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89561153 Dec  4 12:18 download/P158CISdup_112024_2_ds.dae6d08740734b73898523c71418e58e/P158CISdup_112024_2_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84145802 Dec  4 12:18 download/P222LDC_112024_2_ds.05b05f1eb1d24cb593d6c6bbfeac7ece/P222LDC_112024_2_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81987871 Dec  4 12:18 download/P222LDCdup_112024_2_ds.706bb1525b75458caa876dc30e6b0863/P222LDCdup_112024_2_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83820021 Dec  4 12:17 download/P227TPC_112024_2_ds.aafd7deefad64726b8ea61d5036059d8/P227TPC_112024_2_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90083501 Dec  4 12:17 download/P227TPCdup_112024_2_ds.60ee6275b8f244ddb4851afeac143bdf/P227TPCdup_112024_2_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95253415 Dec  4 12:18 download/P315LRS_112024_2_ds.5050b0675f4047b797b425ae7bfccece/P315LRS_112024_2_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82221232 Dec  4 12:18 download/P315LRSdup_112024_2_ds.ebf2ebc2d4674f58ac4612e66a6d0096/P315LRSdup_112024_2_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83002651 Dec  4 12:18 download/P325CEA_112024_2_ds.228bc1c28e3a4edd803ce6e97e4d2c82/P325CEA_112024_2_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  64930629 Dec  4 12:17 download/P325CEAdup_112024_2_ds.c7b2548704514921b3e456bc16144aa2/P325CEAdup_112024_2_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71409232 Dec  4 12:18 download/P337APS_112024_2_ds.e1d6b7c63f864023aeccc58eb67e3112/P337APS_112024_2_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  61916464 Dec  4 12:18 download/P337APSdup_112024_2_ds.4eb47bdcbc264fd598f5dca0e29894f7/P337APSdup_112024_2_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84077461 Dec  4 12:18 download/P378YHP_112024_2_ds.6c44fb76344f4176b89726ef6561bbde/P378YHP_112024_2_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72834417 Dec  4 12:18 download/P378YHPdup_112024_2_ds.ec2ba47f5e664b99b996faf10907246c/P378YHPdup_112024_2_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80422322 Dec  4 12:18 download/P391XQG_112024_2_ds.c65e1d2c32c34ad196cd351b33bb5654/P391XQG_112024_2_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  67968159 Dec  4 12:18 download/P391XQGdup_112024_2_ds.3a66dc04b0ef48858558f17a1ee927d7/P391XQGdup_112024_2_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81359953 Dec  4 12:18 download/P414AIK_112024_2_ds.2aecae98804a44a5aaafe5a9c88c7e27/P414AIK_112024_2_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78684046 Dec  4 12:18 download/P414AIKdup_112024_2_ds.7eb2146c1d334337bda6d03f4ef2faa5/P414AIKdup_112024_2_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86052581 Dec  4 12:18 download/P432CUD_112024_2_ds.f454da6445174ec6bbf3a6d231a1fb39/P432CUD_112024_2_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81046350 Dec  4 12:18 download/P432CUDdup_112024_2_ds.ccccd9eecaad481c8733bac81e8b3a13/P432CUDdup_112024_2_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72237192 Dec  4 12:17 download/PLib01_1_112024_2_ds.7709ab9feed241ce9d7a8932fa39b11a/PLib01_1_112024_2_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83020880 Dec  4 12:18 download/PLib01_2_112024_2_ds.c20fec2e2160446f964c7f0ad2727668/PLib01_2_112024_2_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74522044 Dec  4 12:17 download/PLib13_1_112024_2_ds.5ad1c8f79a5942a988a50f78e744dc82/PLib13_1_112024_2_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81726537 Dec  4 12:18 download/PLib13_2_112024_2_ds.55e644fd4b7f4785afdfa0dc1fb18da1/PLib13_2_112024_2_S139_L001_R1_001.fastq.gz

```

Note that there is STILL no "Undetermined"?


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






We have dropped the undetermined reads fastq into the SFTP for you. Please login using the following credentials:

SFTP: ---------
Password: -------

 


##	20250410

```
\rm -f manifest.csv

awk 'BEGIN{FS=OFS=","}{$4=$4",";print "S"int(substr($4,4)),$0}' L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv > manifest.csv

sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```





##	20251105

I noticed that the PLib, CSE and Blanks for plate's 1, 2, 13 and 14 have the sample names as subject names
so they include the _1 and _2. I don't think this is an issue during normal processing, but does
creep in when I have merged everything and expected the number of merged samples to be something.

20241204 and 20241224

Manually correcting.


