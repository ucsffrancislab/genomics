
#	20250822-Illumina-PhIP


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
| 081225_L5_HH                            | 466145135 | 22672063929  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 466145135
```

```
cd ..
ll download/*/*z >> README.md


-rw-r----- 1 gwendt francislab   62847903 Aug 22 09:58 download/108741_082025_ds.52a266cf4d82466589b480fcdfd6abb6/108741_082025_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   67176649 Aug 22 09:57 download/108741dup_082025_ds.704aca311c0a4e729d2deb5dae158cde/108741dup_082025_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129472780 Aug 22 09:58 download/14350_082025_ds.1b44cd99e10941c3946e8153c322ae2a/14350_082025_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133017378 Aug 22 09:57 download/14350dup_082025_ds.a0edb69a38a9456ba7c611b7b921b0d6/14350dup_082025_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   71661022 Aug 22 09:57 download/14922_082025_ds.689cf7e745eb4e80a0010eceb54fbaaa/14922_082025_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92527360 Aug 22 09:58 download/14922dup_082025_ds.c738117e256e46708e1faaf45c3665d1/14922dup_082025_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77473399 Aug 22 09:57 download/18397_082025_ds.7270b7434d064504aac69353cc72f639/18397_082025_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   53231747 Aug 22 09:58 download/18397dup_082025_ds.7ddd3c2975034ff6b994c3ee236c39d3/18397dup_082025_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133314060 Aug 22 09:58 download/20314_082025_ds.294bafe25fc84286928835aa25108061/20314_082025_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  162895852 Aug 22 09:58 download/20314dup_082025_ds.e17a8cc7a14c41279e3aa3b2292c7683/20314dup_082025_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89275953 Aug 22 09:58 download/23392_082025_ds.1c741615860343fe919d14f245983d39/23392_082025_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90005533 Aug 22 09:58 download/23392dup_082025_ds.01f76953c1104b40aa37ffb08a610c31/23392dup_082025_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93651845 Aug 22 09:58 download/239601_082025_ds.3abd4dd340324a4f8877e79cabc3612d/239601_082025_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   55295182 Aug 22 09:57 download/239601dup_082025_ds.aa1597c4791341a2b0aaf8417163556f/239601dup_082025_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75846302 Aug 22 09:58 download/310600_082025_ds.6a9db06c13be4883abece78807c881b6/310600_082025_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98396321 Aug 22 09:58 download/310600dup_082025_ds.96476cf5be9a4356992a08b83af45e6f/310600dup_082025_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108510985 Aug 22 09:58 download/360027_082025_ds.8cb2cc803976414790627190804d37be/360027_082025_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82755426 Aug 22 09:58 download/360027dup_082025_ds.95f2423a4aa843e7b74ae57ecf3f4cd1/360027dup_082025_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82965414 Aug 22 09:57 download/389275_082025_ds.d89cd97b57b64eae9f969334f5f6b324/389275_082025_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80599108 Aug 22 09:57 download/389275dup_082025_ds.6e426d91586b4495a71995c3e0aaf7e6/389275dup_082025_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141848601 Aug 22 09:58 download/444991_082025_ds.a0152f3af5434c7eb54b7415dc6e3118/444991_082025_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128071204 Aug 22 09:58 download/444991dup_082025_ds.46959e426611405e9e220db88403c882/444991dup_082025_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  148767645 Aug 22 09:59 download/465513_082025_ds.8eede0aaea524deb834c4ba1f35a29e5/465513_082025_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  118901294 Aug 22 09:58 download/465513dup_082025_ds.a3db1dba870a497e81573572d7194546/465513dup_082025_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  153593107 Aug 22 09:57 download/498213_082025_ds.6cacf2be630c462480cb2d230ef13b4b/498213_082025_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140331243 Aug 22 09:59 download/498213dup_082025_ds.0abcfda6ec3c4d0b81a5d0187eb1ac0f/498213dup_082025_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123942718 Aug 22 09:57 download/562102_082025_ds.f783cf25d3f2436eaed7aa56a837700e/562102_082025_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154016458 Aug 22 09:58 download/562102dup_082025_ds.4b43e645ac3c46bda31dbaee9645878b/562102dup_082025_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74740455 Aug 22 09:57 download/59499_082025_ds.19cb0c0b0f1b4e0e9e166cc4296ab440/59499_082025_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116903108 Aug 22 09:57 download/59499dup_082025_ds.b860805841dd46389ecf65a59c85b53a/59499dup_082025_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  138333116 Aug 22 09:58 download/62986_082025_ds.a5abdb6ba9454bdd98b560f01f1484d9/62986_082025_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  146370654 Aug 22 09:58 download/62986dup_082025_ds.14ca7ecf13e14d639b52f12196f92b38/62986dup_082025_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133758262 Aug 22 09:58 download/659544_082025_ds.eecce2f278fd427fb2ccb4ed5ce2dcbc/659544_082025_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103612875 Aug 22 09:57 download/659544dup_082025_ds.d96a9ecfd5494e719c11b718269b07ae/659544dup_082025_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99072042 Aug 22 09:57 download/708611_082025_ds.157a70fd36cc40c4b8498faafd6fc1cb/708611_082025_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  119632211 Aug 22 09:57 download/708611dup_082025_ds.31a4581f89084bf29771dd399f4dbf6b/708611dup_082025_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  135557550 Aug 22 09:57 download/782727_082025_ds.d1db195c9811468da2500beae7a90721/782727_082025_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  138304889 Aug 22 09:58 download/782727dup_082025_ds.ce147bc5ebf84fc0b8c0858b1cbfb16c/782727dup_082025_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92441326 Aug 22 09:58 download/809532_082025_ds.9afd2c3e7f6d4e56a4bd234b46c61c7c/809532_082025_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   53729439 Aug 22 09:57 download/809532dup_082025_ds.bd97b9098b41475aa30195a10215eb5b/809532dup_082025_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  178567930 Aug 22 09:58 download/846782_082025_ds.66859804df9641098e946ed5f52f4cfa/846782_082025_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127205315 Aug 22 09:57 download/846782dup_082025_ds.a37ab4189e634fe9b8f0cd3178d82288/846782dup_082025_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141531949 Aug 22 09:59 download/864587_082025_ds.eaa129ad8ff54277ad44768c6559155d/864587_082025_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143489787 Aug 22 09:58 download/864587dup_082025_ds.20f44b4fc65a40ec9cb060fa7e7227cb/864587dup_082025_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140215171 Aug 22 09:57 download/A016990_082025_ds.e746b5ffe6e74bf0a22bf4e1a5972272/A016990_082025_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  142722748 Aug 22 09:59 download/A016990dup_082025_ds.9d6678078808491e9a82a2de760b325f/A016990dup_082025_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   71997116 Aug 22 09:57 download/A030663_082025_ds.810225a5b448420aba201ad59db2b8f8/A030663_082025_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109701010 Aug 22 09:58 download/A030663dup_082025_ds.c530fa9f80ce4ca7bdad71a9fdd18a53/A030663dup_082025_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  155935133 Aug 22 09:57 download/A032611_082025_ds.027d73654d1f41058b72d000bd9351a6/A032611_082025_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  172886068 Aug 22 09:57 download/A032611dup_082025_ds.b7667fb6f5f340b1bc9c1118c7c34873/A032611dup_082025_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  135238675 Aug 22 09:58 download/A033033_082025_ds.c658f1994f154ef1984280a60224146b/A033033_082025_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  146513666 Aug 22 09:58 download/A033033dup_082025_ds.554edbd501ee49409baf5845fbbf26e3/A033033dup_082025_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111723090 Aug 22 09:58 download/A035476_082025_ds.cbdd159b99c949a094d54830eee84190/A035476_082025_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69904473 Aug 22 09:57 download/A035476dup_082025_ds.f5880755eed0483abf94889ce38553f2/A035476dup_082025_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140010189 Aug 22 09:58 download/A036975_082025_ds.43d45bdfc1ab4ff4a5df45dc1b4de6f3/A036975_082025_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117578027 Aug 22 09:57 download/A036975dup_082025_ds.8498aa75cfe6484ea842852580126c84/A036975dup_082025_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  152821546 Aug 22 09:58 download/A068500_082025_ds.da29bc7fbf424b48865be97d41230030/A068500_082025_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130014564 Aug 22 09:57 download/A068500dup_082025_ds.443fbc48e0b34ff48970fe57e8c5e49d/A068500dup_082025_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  150755645 Aug 22 09:58 download/A079050_082025_ds.19e7ed29981e4325a93767639c565b1a/A079050_082025_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  167883235 Aug 22 09:57 download/A079050dup_082025_ds.6c4d85249412420abcd0cc4267291b16/A079050dup_082025_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78431149 Aug 22 09:58 download/A119879_082025_ds.6f42bf73d7bf4116b2ecd21a46e8450e/A119879_082025_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65464894 Aug 22 09:58 download/A119879dup_082025_ds.d702316f128148b289d0cbd1caac68f2/A119879dup_082025_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  146445581 Aug 22 09:58 download/A122000_082025_ds.37321497f5b34e53b200b8c34ccf873c/A122000_082025_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  139749443 Aug 22 09:58 download/A122000dup_082025_ds.321f4e147cfb4753b0e2af68e40840f4/A122000dup_082025_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129293628 Aug 22 09:57 download/A151899_082025_ds.60d3383e922143c3b125896b60803d8a/A151899_082025_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113243963 Aug 22 09:58 download/A151899dup_082025_ds.96becfd4129e4c04af1f893a34c69215/A151899dup_082025_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74770800 Aug 22 09:57 download/B002158_082025_ds.bb99caacb04b4d31a476f1741364131b/B002158_082025_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   67128243 Aug 22 09:58 download/B002158dup_082025_ds.9acc94ffd9534199ae0c321eddaf1535/B002158dup_082025_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82909123 Aug 22 09:57 download/B015810_082025_ds.6bc074d94e9d48b68e6425b7806e3f42/B015810_082025_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87861006 Aug 22 09:57 download/B015810dup_082025_ds.ea9c3d231dfd495cb9a275b3899aae65/B015810dup_082025_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111131705 Aug 22 09:58 download/B016958_082025_ds.f004c880fadd4d55887a9fa1d19be066/B016958_082025_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140137981 Aug 22 09:58 download/B016958dup_082025_ds.ce7186375454425283e30f569ec16136/B016958dup_082025_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100142359 Aug 22 09:57 download/B038911_082025_ds.4ffbcf4ed3074dbab8e1a96316730b5e/B038911_082025_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93161572 Aug 22 09:58 download/B038911dup_082025_ds.425c619aa6924b3da47f323ea21390d8/B038911dup_082025_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  135403082 Aug 22 09:58 download/B049271_082025_ds.b4e11cf0dd4b4ec2823a55611f0fbb1f/B049271_082025_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  142535583 Aug 22 09:58 download/B049271dup_082025_ds.1451b50fb11249d48439e3ee55a588e7/B049271dup_082025_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   70145696 Aug 22 09:57 download/B051431_082025_ds.cb35ebfbf47246b3bcf3de8a12562cda/B051431_082025_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   68728605 Aug 22 09:58 download/B051431dup_082025_ds.3b6c30f3e64b498a9af7633ec2010eb1/B051431dup_082025_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   48328402 Aug 22 09:57 download/B071505_082025_ds.784fc454b7544b83bed599d1922b40f1/B071505_082025_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80006255 Aug 22 09:58 download/B071505dup_082025_ds.c026940744c04ae9a3b6a38faaae021c/B071505dup_082025_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97546827 Aug 22 09:58 download/B091760_082025_ds.f9d2fc375e18474f8c6fd34e4f5caecc/B091760_082025_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81785415 Aug 22 09:57 download/B091760dup_082025_ds.4fe9f04ec59f41109917c2f66a0be8ba/B091760dup_082025_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   66185690 Aug 22 09:58 download/B094444_082025_ds.8083b88043cc42f29b5e7fb33e2b2e5d/B094444_082025_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79805672 Aug 22 09:58 download/B094444dup_082025_ds.70afaba1360e42fa89293aab76501dd7/B094444dup_082025_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129411763 Aug 22 09:58 download/B098824_082025_ds.a46682b3192944309e4b6a6b72a1c9a1/B098824_082025_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130381470 Aug 22 09:58 download/B098824dup_082025_ds.52e9dc80121f4fd5aa4c32615baceeb8/B098824dup_082025_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  119652172 Aug 22 09:58 download/B108966_082025_ds.874461a9be7f48acbd46b2ed32288c64/B108966_082025_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  145008181 Aug 22 09:58 download/B108966dup_082025_ds.86f6050845894d4f80132775fec110b8/B108966dup_082025_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   72762429 Aug 22 09:58 download/B120614_082025_ds.3f0479a620924923ae805f43686ad078/B120614_082025_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  150075465 Aug 22 09:57 download/B120614dup_082025_ds.3db1440e5462447686466e19058b9959/B120614dup_082025_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95697216 Aug 22 09:58 download/B124078_082025_ds.376acc063b764f19a35b89295100d25e/B124078_082025_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   54270440 Aug 22 09:57 download/B124078dup_082025_ds.0a46c4042b584745a3bc2ccd413f5398/B124078dup_082025_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134407586 Aug 22 09:58 download/B137836_082025_ds.debcbcdc77ba4679a027661bd1fe14af/B137836_082025_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143640503 Aug 22 09:58 download/B137836dup_082025_ds.57c201efaa824de1840d019d7498c53f/B137836dup_082025_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123505850 Aug 22 09:58 download/B141148_082025_ds.23a81e98e55c4966ba7abda0b1a6145d/B141148_082025_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143153583 Aug 22 09:59 download/B141148dup_082025_ds.d868479fb45a483ab029cd2765c01853/B141148dup_082025_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  121809732 Aug 22 09:58 download/Blank57_082025_ds.528ea105580c46298f0b2a04d0483d39/Blank57_082025_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  155655148 Aug 22 09:57 download/Blank57dup_082025_ds.dc08de677e1f4663bf57b3680a508dc4/Blank57dup_082025_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  147453503 Aug 22 09:57 download/Blank58_082025_ds.9901acf320634a989ec28cd5ef5be25e/Blank58_082025_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129160855 Aug 22 09:57 download/Blank58dup_082025_ds.49457cabc33144aba33cd62d8014f06b/Blank58dup_082025_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  169940688 Aug 22 09:57 download/Blank59_082025_ds.3a1141c87c044cad9f2fce74d2f4f405/Blank59_082025_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  163105841 Aug 22 09:57 download/Blank59dup_082025_ds.1d3c403761af48c59265d44e40937686/Blank59dup_082025_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111279670 Aug 22 09:57 download/Blank60_082025_ds.2552ca1ed1d248968161da23383f88f1/Blank60_082025_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154914778 Aug 22 09:57 download/Blank60dup_082025_ds.cb0c5acac03c4547a544fa84100160cf/Blank60dup_082025_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108024015 Aug 22 09:58 download/Blank61_082025_ds.c5830b0cf82e48a18dfbe40f975979c9/Blank61_082025_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   31696439 Aug 22 09:57 download/Blank61dup_082025_ds.5181abb612a441158ab646171e20028e/Blank61dup_082025_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90615146 Aug 22 09:58 download/Blank62_082025_ds.d746ba551dd14193a6474e5685d85537/Blank62_082025_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83953562 Aug 22 09:58 download/Blank62dup_082025_ds.953fae908b794c29b617c787b21c7be4/Blank62dup_082025_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111332939 Aug 22 09:57 download/Blank63_082025_ds.1c436de727cf4b24b10ae512fc30fa5f/Blank63_082025_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94595864 Aug 22 09:58 download/Blank63dup_082025_ds.d595dc1ab81243f09c676e86d41d13cd/Blank63dup_082025_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   62038583 Aug 22 09:58 download/Blank64_082025_ds.3b8b956f82484494becff217f739bad8/Blank64_082025_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   42351521 Aug 22 09:57 download/Blank64dup_082025_ds.614f98b3df71410fb38bb993f6383bba/Blank64dup_082025_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128436308 Aug 22 09:58 download/C015789_082025_ds.33b3610d61784bfa897502214099fa52/C015789_082025_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117660827 Aug 22 09:57 download/C015789dup_082025_ds.35641d545f1e4971a9abc68ce549e44d/C015789dup_082025_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   63041274 Aug 22 09:57 download/C017597_082025_ds.587dd187fb924b2fac745ad755c31d06/C017597_082025_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83965231 Aug 22 09:57 download/C017597dup_082025_ds.614dfc9cffc543bbb6aacfff8e19b9cb/C017597dup_082025_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   66762352 Aug 22 09:57 download/C020280_082025_ds.9a1978a26c1646d2814ec2be0f1fed4b/C020280_082025_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80520543 Aug 22 09:58 download/C020280dup_082025_ds.1e20b089e27f47c9b96a932e2efb6995/C020280dup_082025_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   84681966 Aug 22 09:58 download/C027770_082025_ds.cd0becd1f28149f986731f5224a461b9/C027770_082025_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103885334 Aug 22 09:58 download/C027770dup_082025_ds.2e2e8d904ab14625b1661eb59e04007a/C027770dup_082025_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140729914 Aug 22 09:57 download/C038263_082025_ds.02effd84f44f46cd87ceb563ca78c5d2/C038263_082025_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133677505 Aug 22 09:58 download/C038263dup_082025_ds.11995e28a13b4333920abf487819c068/C038263dup_082025_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104636018 Aug 22 09:58 download/C062015_082025_ds.f8c2312528f040eaabf0ac2e874f6d50/C062015_082025_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99337305 Aug 22 09:58 download/C062015dup_082025_ds.e498b8f14579436e95420bc44b325cb5/C062015dup_082025_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132416028 Aug 22 09:57 download/C066645_082025_ds.e59b987cf61d4adeb7cdccea75a884f0/C066645_082025_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130016429 Aug 22 09:58 download/C066645dup_082025_ds.464f612e80a5445ea60e6d061ba26096/C066645dup_082025_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   58552193 Aug 22 09:57 download/C103395_082025_ds.7c817c841376410f947d09d1bff25bee/C103395_082025_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   36703947 Aug 22 09:58 download/C103395dup_082025_ds.912381bd117a4210af170efaa60bd74d/C103395dup_082025_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  147907574 Aug 22 09:58 download/C106425_082025_ds.b48c812a874e40baadca6e15044e206d/C106425_082025_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127505848 Aug 22 09:57 download/C106425dup_082025_ds.901208e29d7342b9ab9b010d72a0e41f/C106425dup_082025_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141158449 Aug 22 09:58 download/C117389_082025_ds.c8b9c6c78e3b48b2a49ea8d14bc51dc6/C117389_082025_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  139131911 Aug 22 09:59 download/C117389dup_082025_ds.94ce7be1db974070bf2b69b1bf857dbd/C117389dup_082025_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83734831 Aug 22 09:58 download/C131369_082025_ds.59fdc8c156e444d9af01204aa6f559fa/C131369_082025_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91587811 Aug 22 09:58 download/C131369dup_082025_ds.694b732188784b4eafbe02b96e218053/C131369dup_082025_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  149155377 Aug 22 09:58 download/C156795_082025_ds.b8505e5ee4e04b4f87ac23935860ab36/C156795_082025_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143147722 Aug 22 09:57 download/C156795dup_082025_ds.2496896ccf4348298970743223ec4cc6/C156795dup_082025_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117513156 Aug 22 09:57 download/C159853_082025_ds.a7848474880d49488facd5e523d650ef/C159853_082025_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73322761 Aug 22 09:58 download/C159853dup_082025_ds.40aac1131ecc4c7388f3f1cfbfd7fed5/C159853dup_082025_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134199206 Aug 22 09:58 download/CSE15_082025_ds.0e65e64900f64c1dbc1152cc3e301490/CSE15_082025_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123491101 Aug 22 09:57 download/CSE15dup_082025_ds.c4f327539ec3451e9882cd23ee3366f8/CSE15dup_082025_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89310233 Aug 22 09:58 download/CSE16_082025_ds.698d067dc1604c3dbbbe7206c5020e5e/CSE16_082025_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74666420 Aug 22 09:58 download/CSE16dup_082025_ds.b78c077ff5eb4ee5be1811950e06e702/CSE16dup_082025_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   72266551 Aug 22 09:58 download/D006771_082025_ds.b8ebe7976b8743188635b9ffe1cfb320/D006771_082025_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   71257929 Aug 22 09:58 download/D006771dup_082025_ds.958a738b22d649529c9c317fc4ee70ce/D006771dup_082025_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132035481 Aug 22 09:57 download/D026428_082025_ds.4a11ad0e522243f0bb643acd5af3f803/D026428_082025_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109603337 Aug 22 09:58 download/D026428dup_082025_ds.10a37d2dbc5948c38ea83030ae2ced5e/D026428dup_082025_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134248618 Aug 22 09:57 download/D031463_082025_ds.3381cd5220b34e25972a605e67f32de3/D031463_082025_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  136992724 Aug 22 09:58 download/D031463dup_082025_ds.b8f1eefa62bd41ec9d52cf553d9e6211/D031463dup_082025_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132652293 Aug 22 09:58 download/D045847_082025_ds.a3babed606d8403ca70b9d408d15eb92/D045847_082025_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  145159019 Aug 22 09:57 download/D045847dup_082025_ds.59ad5ed8419c4ce882d2ee7bb894fbd6/D045847dup_082025_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  152549173 Aug 22 09:57 download/D051856_082025_ds.aacd7ccfaa6149e1ac068707ccbb6f52/D051856_082025_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110911267 Aug 22 09:57 download/D051856dup_082025_ds.78175a51b1fd4ec49c49fa5b80798ced/D051856dup_082025_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141521995 Aug 22 09:58 download/D058386_082025_ds.7c97af6dc41942d7800684bfdbf83f3e/D058386_082025_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  152528187 Aug 22 09:58 download/D058386dup_082025_ds.89bc406169234543bdc27182bfbbb4d2/D058386dup_082025_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88859061 Aug 22 09:58 download/D080216_082025_ds.089cd23a4a274cf192135a3d97f5e5fe/D080216_082025_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114284502 Aug 22 09:57 download/D080216dup_082025_ds.6c77737773b64bfe9c6a6cb0e544e4bf/D080216dup_082025_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87419000 Aug 22 09:58 download/D082004_082025_ds.0692d6d2f2ec41ca9bbf3a7c6e041510/D082004_082025_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86511236 Aug 22 09:58 download/D082004dup_082025_ds.1dcf4e5e537044db93eff613798d0865/D082004dup_082025_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123899141 Aug 22 09:58 download/D082062_082025_ds.5dd64d33e45645c6bfa7fff88caa8280/D082062_082025_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132198862 Aug 22 09:57 download/D082062dup_082025_ds.8e9e85289c49408285c3b3d7e8fc0b9e/D082062dup_082025_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130949909 Aug 22 09:57 download/D110966_082025_ds.f3ffd8d64e94419c8c40cdaa82b97541/D110966_082025_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133530833 Aug 22 09:58 download/D110966dup_082025_ds.cd18e6d2d02e44b6b1639e13995cd042/D110966dup_082025_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  136751723 Aug 22 09:58 download/D114173_082025_ds.1fb2a50f2392489b97a6b0dcc496107e/D114173_082025_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125080110 Aug 22 09:57 download/D114173dup_082025_ds.99aba47a0c9144328d6dde8c587b083a/D114173dup_082025_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   35968407 Aug 22 09:57 download/D124834_082025_ds.55aea63bcfb34c8780efc1f561a65cc8/D124834_082025_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77263882 Aug 22 09:58 download/D124834dup_082025_ds.d5e6c8438c864da1863b89b3273dc477/D124834dup_082025_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   64807760 Aug 22 09:57 download/D126745_082025_ds.87493721b40f4557b5f864918c0da77e/D126745_082025_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107783864 Aug 22 09:58 download/D126745dup_082025_ds.e3830e403c944f378a84826b16466095/D126745dup_082025_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130968711 Aug 22 09:58 download/D143263_082025_ds.8ec3b0078ba04e9f9af27d015258e252/D143263_082025_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96919967 Aug 22 09:58 download/D143263dup_082025_ds.1a5e52dfad7b4065a1fd3677186d1f28/D143263dup_082025_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73360645 Aug 22 09:58 download/D145365_082025_ds.fe9faef93b654eaa85c4ef5f34e683a8/D145365_082025_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75022170 Aug 22 09:57 download/D145365dup_082025_ds.a0f5f0c350384bdd98708464e2bae174/D145365dup_082025_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101900119 Aug 22 09:58 download/D149048_082025_ds.b13d593ad3074bc59b806d9cb9d09a1a/D149048_082025_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114264634 Aug 22 09:57 download/D149048dup_082025_ds.a5170f982b0e4824b2ba82650209b603/D149048dup_082025_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76468659 Aug 22 09:57 download/E042962_082025_ds.d0321953b23b4dbba2f02894810974db/E042962_082025_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73746704 Aug 22 09:58 download/E042962dup_082025_ds.dbbe17e735c04456956b7d0d06e10154/E042962dup_082025_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   51223554 Aug 22 09:58 download/E045528_082025_ds.ead7e6c7db4c478faefb74d903583564/E045528_082025_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76591543 Aug 22 09:58 download/E045528dup_082025_ds.c0ece7a746d24805a50904220f9183d9/E045528dup_082025_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123875603 Aug 22 09:57 download/E072621_082025_ds.eca4ac34bffc4bc6b8d9accd2b811080/E072621_082025_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103784380 Aug 22 09:58 download/E072621dup_082025_ds.2cf486276ef3471786269fc606f368dc/E072621dup_082025_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   58659901 Aug 22 09:58 download/E076688_082025_ds.5789ec100a0e4b01848d1c285f4e9ccb/E076688_082025_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112875299 Aug 22 09:57 download/E076688dup_082025_ds.d315030b88bc4688bed4c3a001924b0c/E076688dup_082025_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101692574 Aug 22 09:57 download/E123179_082025_ds.353233655b4a4200bb21137b394b319b/E123179_082025_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111914410 Aug 22 09:58 download/E123179dup_082025_ds.6390f947a9ea482399f77af5c2d618ed/E123179dup_082025_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154819857 Aug 22 09:59 download/E130913_082025_ds.2fd55cd1d5744ce785d8a37e47aa72cc/E130913_082025_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143745150 Aug 22 09:57 download/E130913dup_082025_ds.dbec7977ec0a49788b6b7afcdf0f8b12/E130913dup_082025_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  145730614 Aug 22 09:57 download/E150248_082025_ds.e96e8d1e3ca3440bb28e7515667e430d/E150248_082025_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130746295 Aug 22 09:58 download/E150248dup_082025_ds.f07a0b8a9edc484da386d572295d0209/E150248dup_082025_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143366545 Aug 22 09:58 download/PLib15_082025_ds.f454235eded343abbbe14521e88f8a21/PLib15_082025_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120780879 Aug 22 09:58 download/PLib15dup_082025_ds.1e2655da6c4e428d99dc14e571d8c9d2/PLib15dup_082025_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81926449 Aug 22 09:58 download/PLib16_082025_ds.f02f05ae413d4bbb8d49a3ff4c4d7e5b/PLib16_082025_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   50157530 Aug 22 09:57 download/PLib16dup_082025_ds.9c1b39ceb26b416881b9caca9d2af00a/PLib16dup_082025_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 1524800161 Aug 22 09:59 download/Undetermined_from_082125_L5_HH_ds.4af1e125230e4d8d8d3d4e0f5e184a67/Undetermined_S0_L001_R1_001.fastq.gz

```



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
x=${x%_082025_S*}
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
for z in download/*/*z; do f=$( basename $z _L001_R1_001.fastq.gz ); f=${f/_082025_/,}; echo $f; done | sort -t, -k1,1 > sample_s_number.csv
sed -i '1isample,s' sample_s_number.csv 
```












----








```
dos2unix L5_full_covariates_Vir3_phip-seq_GBM_ALL_p15_and_p16_8-22-25hmh.csv
```

edit `L5_full_covariates_Vir3_phip-seq_GBM_ALL_p15_and_p16_8-22-25hmh.csv`

remove commas from some field for ease of use later

remove new lines from header fields


change group CA to case
change group CO to control


This set is plate 15 and 16

```
\rm -f manifest.csv
cp L5_full_covariates_Vir3_phip-seq_GBM_ALL_p15_and_p16_8-22-25hmh.csv manifest.csv

sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```


