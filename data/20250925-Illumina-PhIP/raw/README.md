
#	20250925-Illumina-PhIP


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
| 091925_HH_L6                            | 470793401 | 21973707790  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 470793401
```

```
cd ..
ll download/*/*z >> README.md



-rw-r----- 1 gwendt francislab  127890342 Sep 25 07:03 download/14657_091725_ds.0cbfef7a6cf14b55bc6c303df74befb2/14657_091725_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129609869 Sep 25 07:04 download/14657dup_091725_ds.273ca9f1667b4119a2f398e255f7dff1/14657dup_091725_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101254038 Sep 25 07:03 download/14910_091725_ds.bf0fbef379dc46b8a3785ab51031c38c/14910_091725_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94303368 Sep 25 07:04 download/14910dup_091725_ds.11ace3dff41a4c568dbf126469cd0799/14910dup_091725_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128287330 Sep 25 07:04 download/15224_091725_ds.24e5a116bd664388afd7bbf864e4871e/15224_091725_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123894460 Sep 25 07:03 download/15224dup_091725_ds.af6f62aa7d3b4cb3b8f4188a221f8a9a/15224dup_091725_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94311204 Sep 25 07:03 download/18019_091725_ds.264a8b8dce034552a9e6600190e2a357/18019_091725_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77904802 Sep 25 07:03 download/18019dup_091725_ds.01cec396332b481dbfcccdd378936048/18019dup_091725_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   71057343 Sep 25 07:03 download/21070_091725_ds.dc813a375b5f4dd8a3ea1ce6df6a160b/21070_091725_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114355652 Sep 25 07:04 download/21070dup_091725_ds.403f48f6c22e448294a49fcc8b83365c/21070dup_091725_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100353299 Sep 25 07:03 download/21296_091725_ds.d54f4d3329234241bc643e59dc98091d/21296_091725_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  124614258 Sep 25 07:04 download/21296dup_091725_ds.83e0593b135f49f59e67b13b7ab7c826/21296dup_091725_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      21779 Sep 25 07:03 download/23339_091725_ds.847ad1806bbd4426b929f7609337ca0a/23339_091725_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96113884 Sep 25 07:04 download/23339dup_091725_ds.a7f0e55a403d462abc8465d39d38af52/23339dup_091725_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141655695 Sep 25 07:04 download/234658_091725_ds.49d2aaf9850d43cc8c453e7b1110ec2b/234658_091725_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  122830235 Sep 25 07:03 download/234658dup_091725_ds.f4a9e8eef8f54b83b959d3e11b7aeacf/234658dup_091725_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    3230187 Sep 25 07:03 download/23565_091725_ds.38f3cf0835c9400690447ada793faece/23565_091725_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105854816 Sep 25 07:03 download/23565dup_091725_ds.282e2af7f4784473986b253d6b0a3955/23565dup_091725_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  147298070 Sep 25 07:03 download/238717_091725_ds.7dcf31faaf1c4cf8ae49094daee972a2/238717_091725_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141630955 Sep 25 07:04 download/238717dup_091725_ds.ef15482ea9b9407a8d3002eb655a9eab/238717dup_091725_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  122081749 Sep 25 07:04 download/278211_091725_ds.55cb1f7b858e4deb807fc20293ab1b8d/278211_091725_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132607967 Sep 25 07:03 download/278211dup_091725_ds.8a10e0784ece4e88afd29567e046b888/278211dup_091725_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81657276 Sep 25 07:04 download/292749_091725_ds.fc9097110e694dbbb58a42b0a02d8748/292749_091725_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86293937 Sep 25 07:04 download/292749dup_091725_ds.164d5571973742d28fee54d93ad886ca/292749dup_091725_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78122376 Sep 25 07:03 download/388426_091725_ds.d620f423072e4386977b07af47703765/388426_091725_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88494255 Sep 25 07:03 download/388426dup_091725_ds.ac382d9ba43e4d23b706f725116e0485/388426dup_091725_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102846346 Sep 25 07:03 download/388583_091725_ds.2565135937044463afb009edac085701/388583_091725_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  150069300 Sep 25 07:04 download/388583dup_091725_ds.f8d56a8e1f07406a8a0af21bca843dd4/388583dup_091725_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125734761 Sep 25 07:04 download/408951_091725_ds.53e325eb3c904144bfa5f09cc2ad58a9/408951_091725_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129277797 Sep 25 07:03 download/408951dup_091725_ds.824d3552c43d4248afcb0c49a42d0676/408951dup_091725_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  140805506 Sep 25 07:03 download/415383_091725_ds.e41d9d60e0504709b926982e22eb829e/415383_091725_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  151321747 Sep 25 07:03 download/415383dup_091725_ds.00cc4b5ccf3a4861bc5b21179adde832/415383dup_091725_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   67723516 Sep 25 07:04 download/428061_091725_ds.2aafde76cd2747c9be4c193cee7d302e/428061_091725_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106945960 Sep 25 07:04 download/428061dup_091725_ds.c42ef259b1954c2aa1dafdb602f83c1a/428061dup_091725_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125770773 Sep 25 07:04 download/434322_091725_ds.9127e77d0a444c038c78115ee945a7fc/434322_091725_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  139691234 Sep 25 07:04 download/434322dup_091725_ds.a566cbff6bf64128b6ea1098de7cadd5/434322dup_091725_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110427483 Sep 25 07:03 download/500912_091725_ds.2fb80afcd16746b4b9bd5a48b3b7e191/500912_091725_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120972259 Sep 25 07:04 download/500912dup_091725_ds.a64eb36d5e774780a483f974ea2042db/500912dup_091725_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115691280 Sep 25 07:03 download/679689_091725_ds.8666e9930b554afe91b993e2d057872c/679689_091725_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106303024 Sep 25 07:04 download/679689dup_091725_ds.aebfa56572de4ad79e3b3bc810d6ff68/679689dup_091725_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  126809459 Sep 25 07:04 download/700892_091725_ds.4f1143471fdd469c8c65f17d31b6ed7b/700892_091725_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115265762 Sep 25 07:03 download/700892dup_091725_ds.013e936d13624d2283618a715fdc3ab5/700892dup_091725_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  146892451 Sep 25 07:04 download/705153_091725_ds.47eab6ad52704880b700af590de5095d/705153_091725_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132650865 Sep 25 07:04 download/705153dup_091725_ds.06bdb5e96c3d4c11af1e390266c13f4a/705153dup_091725_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95195905 Sep 25 07:03 download/773554_091725_ds.410e2e38e6b644feb084867700527418/773554_091725_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  142220128 Sep 25 07:04 download/773554dup_091725_ds.49322ba07bc2475d9e3734df28848714/773554dup_091725_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83770390 Sep 25 07:03 download/774259_091725_ds.b2c0edf13cf74354931e0133f287ede0/774259_091725_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75251935 Sep 25 07:04 download/774259dup_091725_ds.90f73b2ae77049238b41b216d4885f6d/774259dup_091725_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115693118 Sep 25 07:03 download/797101_091725_ds.b07c46a97adb4516899f484d645adc6f/797101_091725_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132688066 Sep 25 07:04 download/797101dup_091725_ds.4a00a3f8b4284fcf8ddfe21376e3856f/797101dup_091725_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133498622 Sep 25 07:03 download/853500_091725_ds.9da5186d2d2d4882a49db27e15f72133/853500_091725_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  153072201 Sep 25 07:04 download/853500dup_091725_ds.9b6f96e773854384aba12235ae647cd6/853500dup_091725_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83650624 Sep 25 07:03 download/961440_091725_ds.8af9cde1147f4e16820b44c2ba04b495/961440_091725_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      62051 Sep 25 07:03 download/961440dup_091725_ds.c4914893dd364b98b176aed6c8ddaf99/961440dup_091725_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   59858955 Sep 25 07:03 download/A012158_091725_ds.b7d7d11466e64ff692b02cb71bcb6d7c/A012158_091725_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65923956 Sep 25 07:04 download/A012158dup_091725_ds.1a42574143344689a7f3819ee57cc00e/A012158dup_091725_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103828425 Sep 25 07:04 download/A044064_091725_ds.0d5cfe951efc425a911920b32d8f419c/A044064_091725_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92213180 Sep 25 07:04 download/A044064dup_091725_ds.b669ca0ee0e148129d87bebe5c1670d5/A044064dup_091725_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103677452 Sep 25 07:03 download/A045905_091725_ds.af526a31c4364ab68b62049fde6fea93/A045905_091725_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83170290 Sep 25 07:04 download/A045905dup_091725_ds.89d4b26f684b47418fca100ea8446769/A045905dup_091725_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74220599 Sep 25 07:03 download/A049686_091725_ds.91e7967062344a2fb59a69899803fbc2/A049686_091725_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   34249304 Sep 25 07:03 download/A049686dup_091725_ds.0aaa76b871a546ec9617ef9b923fca43/A049686dup_091725_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115377947 Sep 25 07:04 download/A051360_091725_ds.8666227cdb9c4764993b1498761cf5a8/A051360_091725_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110715321 Sep 25 07:04 download/A051360dup_091725_ds.a6d6fcd6584646a3b4f2bd06873b9cf2/A051360dup_091725_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127431966 Sep 25 07:03 download/A055498_091725_ds.87b9c997c8104c0eb086cdc0da2a3d8d/A055498_091725_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  144265064 Sep 25 07:04 download/A055498dup_091725_ds.3b2b2946b9a247c08a8fd6d351168b94/A055498dup_091725_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  164919936 Sep 25 07:04 download/A057510_091725_ds.563f74919e704eabb884346675a8432c/A057510_091725_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  151271391 Sep 25 07:03 download/A057510dup_091725_ds.415d8f78ec764579b77f11b897b11bfe/A057510dup_091725_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  142154620 Sep 25 07:03 download/A060701_091725_ds.f663fe61f9e74d2f895e2b4dc0e34d33/A060701_091725_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  167800706 Sep 25 07:04 download/A060701dup_091725_ds.fd7f1788dcdb46b8b2296dfb2bc9b973/A060701dup_091725_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89724652 Sep 25 07:03 download/A071863_091725_ds.21423bba2d4a44f3997fb3b10ec2d369/A071863_091725_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109467905 Sep 25 07:04 download/A071863dup_091725_ds.0664231a891144deb36bc2d43cadd197/A071863dup_091725_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  138142244 Sep 25 07:03 download/A075592_091725_ds.2864f34d0300435282a56546549b3839/A075592_091725_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  136156845 Sep 25 07:03 download/A075592dup_091725_ds.b9285349794f45ae996b34c708f729cd/A075592dup_091725_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90870018 Sep 25 07:03 download/A081940_091725_ds.c02bf5e24cd64887b7c4745b8743e1b8/A081940_091725_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99341530 Sep 25 07:03 download/A081940dup_091725_ds.ea4ad9a7011342558aed2c59fe30b61e/A081940dup_091725_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90080296 Sep 25 07:03 download/A101900_091725_ds.7e2a2b4e3c56483a9cef3b7aed0e4045/A101900_091725_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   84200271 Sep 25 07:03 download/A101900dup_091725_ds.96008b82583b4d398c569486a8e997b9/A101900dup_091725_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  135715059 Sep 25 07:03 download/A117039_091725_ds.edbdd00e9ee1441f916fe6433bde30b3/A117039_091725_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132611663 Sep 25 07:04 download/A117039dup_091725_ds.90a22c5a90ff4387835dffacc48c8737/A117039dup_091725_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101817662 Sep 25 07:03 download/A119904_091725_ds.abc228707db642008acd9a35f86d1c81/A119904_091725_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105106227 Sep 25 07:04 download/A119904dup_091725_ds.2c1b35e38020494ea21239e77904b57b/A119904dup_091725_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  131295492 Sep 25 07:03 download/A132171_091725_ds.f9036ae44e924f43a08619f6e8ed487a/A132171_091725_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134648336 Sep 25 07:04 download/A132171dup_091725_ds.3c98c16c7c4b4b1c8efa50c4719d6cae/A132171dup_091725_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111567499 Sep 25 07:04 download/A132472_091725_ds.11c566f0d7514d97a6f7a45988bf1b7c/A132472_091725_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91645620 Sep 25 07:04 download/A132472dup_091725_ds.a34c4fcc3143464c8394891de99da243/A132472dup_091725_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  132121278 Sep 25 07:04 download/A132637_091725_ds.780e2e1436784c1790a1950fdf53f63f/A132637_091725_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  139372877 Sep 25 07:03 download/A132637dup_091725_ds.bd916841f60e4c259f0b7ae09e3d529f/A132637dup_091725_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69827937 Sep 25 07:03 download/A133613_091725_ds.214766752ad64cc98cc6eb8657c8d496/A133613_091725_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100600678 Sep 25 07:04 download/A133613dup_091725_ds.119fb36d0b0c47ee907560d39469c58d/A133613dup_091725_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154862666 Sep 25 07:03 download/A137060_091725_ds.cd94d7e1e48e47c3ba6fac27e7608036/A137060_091725_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  131186322 Sep 25 07:04 download/A137060dup_091725_ds.b20b6bdd7e9a44bea5a09f76582ffe57/A137060dup_091725_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  147637285 Sep 25 07:03 download/A143419_091725_ds.57fe0175d3064a00b36303d7225da96d/A143419_091725_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120220575 Sep 25 07:04 download/A143419dup_091725_ds.93e0522ec4174f4e9a32d0a9fe757800/A143419dup_091725_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   51744588 Sep 25 07:03 download/B000408_091725_ds.6e757676f4aa413eaebf0f6a520fa948/B000408_091725_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   53881440 Sep 25 07:04 download/B000408dup_091725_ds.52f7eb273dea4e58b808de7ff166d366/B000408dup_091725_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   27564373 Sep 25 07:04 download/B002699_091725_ds.699a24deaf20421e941eb6fe6ede6457/B002699_091725_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97622304 Sep 25 07:03 download/B002699dup_091725_ds.f69c5ee508b04dd588bcdae5693efcf6/B002699dup_091725_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  133845472 Sep 25 07:04 download/B005092_091725_ds.c18ff270986348d882b490866cab29d1/B005092_091725_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  151185090 Sep 25 07:04 download/B005092dup_091725_ds.45f361808cff4bc39d8ffe8100af062a/B005092dup_091725_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97843257 Sep 25 07:03 download/B020351_091725_ds.b9b14eac4e7343a29a609ac4bfcede4f/B020351_091725_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   73731530 Sep 25 07:04 download/B020351dup_091725_ds.7a5a35dfdf61499cb8b30d951dc08c3c/B020351dup_091725_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94185601 Sep 25 07:03 download/B035391_091725_ds.fbece376145c4df3ac40bb1173c182ec/B035391_091725_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87352496 Sep 25 07:04 download/B035391dup_091725_ds.49dc6f59ddc146328fe357c8288a1cde/B035391dup_091725_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   71220004 Sep 25 07:03 download/B039615_091725_ds.bd5e8fc3256b4de1ae9f1bfc8f554a4f/B039615_091725_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88616081 Sep 25 07:04 download/B039615dup_091725_ds.c7d59c7a7c094c29a242f1ae8a338572/B039615dup_091725_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98322259 Sep 25 07:04 download/B071977_091725_ds.e0cd1181b16c41eeb156dee012c46203/B071977_091725_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112240518 Sep 25 07:04 download/B071977dup_091725_ds.bc51a9e86e8b42818ac045a9923c78e6/B071977dup_091725_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  148831883 Sep 25 07:03 download/B116021_091725_ds.43c1ec8cfe5e47e49fa6e645ff788b11/B116021_091725_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  152824080 Sep 25 07:04 download/B116021dup_091725_ds.93622a935ca146e18e6e740022f60abf/B116021dup_091725_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143463073 Sep 25 07:03 download/B121480_091725_ds.7c1dc33dbc3442da911c21070a0681c3/B121480_091725_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154709528 Sep 25 07:03 download/B121480dup_091725_ds.2867d70184304e78a2b0c140a32853f7/B121480dup_091725_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   66940977 Sep 25 07:04 download/B129920_091725_ds.fa553da6a3b24f4fb7ac2a62d28e27a9/B129920_091725_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101627571 Sep 25 07:03 download/B129920dup_091725_ds.008a7c0cb2154392862152a4b4ccd056/B129920dup_091725_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   84717648 Sep 25 07:03 download/B137732_091725_ds.72ccb456fff0416babe70e744201b4fa/B137732_091725_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76209350 Sep 25 07:03 download/B137732dup_091725_ds.2fd0a0cd68764dbba670248f491a2769/B137732dup_091725_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106416396 Sep 25 07:03 download/B150106_091725_ds.5eb00f72b5b24088bba172ee79b7968d/B150106_091725_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125500179 Sep 25 07:03 download/B150106dup_091725_ds.ba8576f502c34220a90c9c54edc4081f/B150106dup_091725_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  126139612 Sep 25 07:04 download/B158624_091725_ds.3ce07531804f4cefbb8403b75ecfb439/B158624_091725_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  141034786 Sep 25 07:04 download/B158624dup_091725_ds.f35aad3eb81e4c97a2f1f35aeb23b640/B158624dup_091725_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87961364 Sep 25 07:04 download/Blank65_091725_ds.59f8ce46a9c74fd583f3a6113910cc24/Blank65_091725_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  121459267 Sep 25 07:04 download/Blank65dup_091725_ds.af4c778922c84f53b25e7d8dc20ab068/Blank65dup_091725_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134309507 Sep 25 07:04 download/Blank66_091725_ds.97cf892a346542b19bd9003a53527741/Blank66_091725_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  154937895 Sep 25 07:04 download/Blank66dup_091725_ds.5e2fc45ff2a24a278b795be398d6c7ea/Blank66dup_091725_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  130745707 Sep 25 07:03 download/Blank67_091725_ds.8895c574d36b4c71b1041750b034abbd/Blank67_091725_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  131079034 Sep 25 07:03 download/Blank67dup_091725_ds.24060d30ed9f4640b106a86e9898819c/Blank67dup_091725_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  164552643 Sep 25 07:03 download/Blank68_091725_ds.a5cabffc8af5455199362a0feb32b735/Blank68_091725_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  161164254 Sep 25 07:04 download/Blank68dup_091725_ds.39b1786f99c44955b1ff243cad485f1e/Blank68dup_091725_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   67827152 Sep 25 07:04 download/Blank69_091725_ds.aedf1374350646d19d85b9c926cb8d47/Blank69_091725_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74682463 Sep 25 07:04 download/Blank69dup_091725_ds.691a600cb442485e9a87f57e4767bcf9/Blank69dup_091725_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85239305 Sep 25 07:04 download/Blank70_091725_ds.4511976b1bc6453dbf23fe54bcc2f499/Blank70_091725_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97402234 Sep 25 07:03 download/Blank70dup_091725_ds.7ea36dcffda148cfa5172f7a2b4279d4/Blank70dup_091725_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69704948 Sep 25 07:04 download/Blank71_091725_ds.c4e4db7c2a4148d7b6072ad4580208c1/Blank71_091725_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104497945 Sep 25 07:04 download/Blank71dup_091725_ds.88de2b2c4caa4157b97f6daaea15e034/Blank71dup_091725_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107876212 Sep 25 07:03 download/Blank72_091725_ds.1f019ee98b4c4b27af371d23980a6e34/Blank72_091725_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74639447 Sep 25 07:03 download/Blank72dup_091725_ds.85d15979470c411eaf457b8f87b14ec7/Blank72dup_091725_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  121022263 Sep 25 07:03 download/C014300_091725_ds.428dd83332364c0993e4552bc7505896/C014300_091725_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  145668920 Sep 25 07:03 download/C014300dup_091725_ds.79500ebdf4a54ca9b1ebd11d1d714013/C014300dup_091725_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  135873922 Sep 25 07:04 download/C021473_091725_ds.2e1a01b62f6246e7b69c753d2be8fdb0/C021473_091725_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  144261663 Sep 25 07:03 download/C021473dup_091725_ds.7add84b38fab4ff9a44e2c40ba4f550f/C021473dup_091725_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79753229 Sep 25 07:03 download/C030336_091725_ds.88ceb7db8fdf47539374607bb94803cc/C030336_091725_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80576244 Sep 25 07:04 download/C030336dup_091725_ds.ad61283f7bf34981a79cd0c0a7107d7c/C030336dup_091725_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102960207 Sep 25 07:03 download/C039887_091725_ds.42f8d023b89a4423aea59127b68fd980/C039887_091725_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76615984 Sep 25 07:03 download/C039887dup_091725_ds.1171b54b2eaf4f49990e4ecc11d355c1/C039887dup_091725_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  152683840 Sep 25 07:04 download/C046072_091725_ds.858a70d4d1324ba3b909d6297fc7cf58/C046072_091725_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107166948 Sep 25 07:04 download/C046072dup_091725_ds.a7e02f1bd9fc4e6d85554d4c0dc8c98f/C046072dup_091725_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   60126494 Sep 25 07:03 download/C096316_091725_ds.89a5bb1b39d44d80821854d2ee422972/C096316_091725_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85318665 Sep 25 07:04 download/C096316dup_091725_ds.4fd74c24b5ca400c84adb9c7fdbbe045/C096316dup_091725_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134855986 Sep 25 07:03 download/C138274_091725_ds.f4034a4db7ee4be3b6e68e3ec337e7e7/C138274_091725_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  147476085 Sep 25 07:04 download/C138274dup_091725_ds.80d33e2d30914fbfb0d419024ed9e4c8/C138274dup_091725_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128957726 Sep 25 07:04 download/C139338_091725_ds.81e354f09ca0444ba0ef308930f58db2/C139338_091725_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90174009 Sep 25 07:04 download/C139338dup_091725_ds.722f8840660a4de28db7bc5265980465/C139338dup_091725_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82571868 Sep 25 07:04 download/C155450_091725_ds.d414c11b8d914fbdadc76e5bea790964/C155450_091725_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100571565 Sep 25 07:03 download/C155450dup_091725_ds.212f727433a441c697a88f39982463d4/C155450dup_091725_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   36564471 Sep 25 07:03 download/C161983_091725_ds.07a2e763e0e2468789e3165bab83e8ab/C161983_091725_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79353493 Sep 25 07:04 download/C161983dup_091725_ds.28af1e73c3e94b44922ba413f7198bb6/C161983dup_091725_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  126697985 Sep 25 07:03 download/CSE17_091725_ds.ad52084591a74dd285447fc528c9311a/CSE17_091725_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109429354 Sep 25 07:03 download/CSE17dup_091725_ds.df69c469b3204ce084a18b98d84b3ca9/CSE17dup_091725_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85063597 Sep 25 07:03 download/CSE18_091725_ds.6a58a6fe6fe8499daa884bc4c7eefaa8/CSE18_091725_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91302096 Sep 25 07:03 download/CSE18dup_091725_ds.464100ad0372400d9b1c78d141f26355/CSE18dup_091725_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  127078375 Sep 25 07:04 download/D021798_091725_ds.e83d1aa56d7448fa88294f1ddb972668/D021798_091725_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  149884223 Sep 25 07:04 download/D021798dup_091725_ds.85c39a8a6fe348d7b0ba504893d0107a/D021798dup_091725_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79833593 Sep 25 07:04 download/D040704_091725_ds.78417624f02e4b03936dec35a356bf00/D040704_091725_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81922677 Sep 25 07:03 download/D040704dup_091725_ds.dff3c6bf17f24d6e86e8e343cdc0bf37/D040704dup_091725_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106754477 Sep 25 07:03 download/D069698_091725_ds.2f43e227eb0c40db98116ca5a03e8144/D069698_091725_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab       7520 Sep 25 07:03 download/D069698dup_091725_ds.0e4af28e1e87497dac2b89b12162e4b8/D069698dup_091725_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109711026 Sep 25 07:03 download/D081737_091725_ds.22624346144d4736bf7e9d4dd54a173b/D081737_091725_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112991287 Sep 25 07:04 download/D081737dup_091725_ds.771c10b50314476b89c2e921a5df6527/D081737dup_091725_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  142451592 Sep 25 07:03 download/D082062_091725_ds.44c5ca3eb5b04a33b42cbd7487a16083/D082062_091725_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  143624778 Sep 25 07:03 download/D082062dup_091725_ds.ed6a2d479d5b4834ae72fe408673dc28/D082062dup_091725_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   64021692 Sep 25 07:04 download/D087463_091725_ds.320a836706364ad2be3d39110bb647c8/D087463_091725_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   72284911 Sep 25 07:04 download/D087463dup_091725_ds.1fb4812df5aa442db0cc24f5c59a116f/D087463dup_091725_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134966686 Sep 25 07:03 download/D152826_091725_ds.6bad5d28093c43c5a146acce5886494b/D152826_091725_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94431194 Sep 25 07:04 download/D152826dup_091725_ds.d9f28606046a42aca0adf2e9ac0858be/D152826dup_091725_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128716078 Sep 25 07:04 download/E025148_091725_ds.6c6b60697e6542b8af76f4b0d7f74ff4/E025148_091725_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  164839154 Sep 25 07:04 download/E025148dup_091725_ds.d45fba743c2b43efb82be9b79d830c00/E025148dup_091725_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65895849 Sep 25 07:03 download/E045528_091725_ds.e3709ed8cff141ad91ca9ec523720f66/E045528_091725_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65515316 Sep 25 07:03 download/E045528dup_091725_ds.06b546dfd3b7455995b63b2a2a199546/E045528dup_091725_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90019041 Sep 25 07:04 download/E051173_091725_ds.5efe13a9b2034821804dfc111a2d848d/E051173_091725_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86266826 Sep 25 07:03 download/E051173dup_091725_ds.c7afdf82ffbd4a77b7d2b476a18f9061/E051173dup_091725_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   72197396 Sep 25 07:04 download/E094366_091725_ds.a75271ff8d1d4d08a6af919e747cffd1/E094366_091725_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103492256 Sep 25 07:03 download/E094366dup_091725_ds.06ac07265c1842f7b9859daffa154f8d/E094366dup_091725_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65606908 Sep 25 07:04 download/E097416_091725_ds.f9422035ed1f4c84ad158f45df767ebf/E097416_091725_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77848135 Sep 25 07:03 download/E097416dup_091725_ds.a2f5b16f6ad74b41a0c0bf2f151cd289/E097416dup_091725_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  128226193 Sep 25 07:03 download/E115775_091725_ds.af98af0ce38646699f59a845adeb6a10/E115775_091725_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  126198877 Sep 25 07:04 download/E115775dup_091725_ds.959d3af330ac4bada0f7fc634529fcae/E115775dup_091725_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82853188 Sep 25 07:03 download/E129145_091725_ds.bc073937bbe94afa9117e3ecaf953a4c/E129145_091725_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77461212 Sep 25 07:03 download/E129145dup_091725_ds.113b9791be5e4585a6d51419488cd058/E129145dup_091725_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  123484535 Sep 25 07:04 download/PLib17_091725_ds.8a0fdeddf8c44c8a9aa2c109b2f70d52/PLib17_091725_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98590372 Sep 25 07:04 download/PLib17dup_091725_ds.94654639ac724da0b111d4bfb660ccf5/PLib17dup_091725_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   51523525 Sep 25 07:03 download/PLib18_091725_ds.a928fc53c701442c8c25b86516a76da3/PLib18_091725_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   27076093 Sep 25 07:03 download/PLib18dup_091725_ds.7b6fa476f1e94f868b60a2fb03438fdf/PLib18dup_091725_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 1567606075 Sep 25 07:05 download/Undetermined_from_091925_HH_L6_ds.9a5af4077aa64867b433598fe3d11f9e/Undetermined_S0_L001_R1_001.fastq.gz

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
fastx_count_array_wrapper.bash S*fastq.gz
cd ..
```

```
for f in download/*/*fastq.gz ; do
b=$( basename $f )
x=$( basename $f _L001_R1_001.fastq.gz )
s=$( echo $x | awk -F_ '{print $NF}' )
x=${x%_091725_S*}
echo ${s},${x},${b}
done | sort -t, -k1,1 > manifest.csv
sed -i '1isnumber,sample,fastq' manifest.csv
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







```
dos2unix L6_full_covariates_Vir3_phip-seq_GBM_ALL_p17_and_p18_9-25-25hmh.csv
```

edit L6_full_covariates_Vir3_phip-seq_GBM_ALL_p17_and_p18_9-25-25hmh.csv

remove commas from some field for ease of use later

remove new lines from header fields


This set is plate 17 and 18

```
\rm -f manifest.csv
cp L6_full_covariates_Vir3_phip-seq_GBM_ALL_p17_and_p18_9-25-25hmh.csv manifest.csv

sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```







##	20251008


```BASH
dos2unix L6_full_covariatesv3_Vir3_phip-seq_GBM_ALL_p17_and_p18_10-7-25hmh.csv

vi L6_full_covariatesv3_Vir3_phip-seq_GBM_ALL_p17_and_p18_10-7-25hmh.csv


\rm -f manifest.csv
cp L6_full_covariatesv3_Vir3_phip-seq_GBM_ALL_p17_and_p18_10-7-25hmh.csv manifest.csv

sed -i -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' manifest.csv
chmod -w manifest.csv
```


```BASH
head -1 L6_full_covariatesv3_Vir3_phip-seq_GBM_ALL_p17_and_p18_10-7-25hmh.csv | tr , "\n" | awk '{print NR,$0}'
1 Sequencer S#
2 Avera Sample_ID
3 "Avera RunName"
4 Index primer
5 Index 'READ'
6 "UCSF sample name (PRN BlindID/PLCO liid)"
7 UCSF sample name for sequencing (PRN BlindID/PLCO liid)
8 Sample type
9 Study
10 "Analysis group (PLCO and PRN - Child)"
11 PLCO barcode [GBM]/PRN tube no [ALL] /IPS kitno [Plate 4 repeats]
12 sex (SE donor)
13 age
14 "best_draw_label (PLCO)"
15 match_race7 (PLCO)
16 self-identified race/ethnicity (PRN - birth certificate?)
17 M_BLINDID (PRN - mother)
18 BIRTH_YEAR (PRN - child)
19 Sex-ch (PRN - child)
20 "Matching Race (IPS case)"
21 "IDH mut (IPS case)"
22 dex_draw (IPS case)
23 "dex_prior_month (IPS case)"
24 "Timepoint (IPS cases)"
25 192 sequencing Lane
26 Plate
27 well
28 column order
29 
30 
```



