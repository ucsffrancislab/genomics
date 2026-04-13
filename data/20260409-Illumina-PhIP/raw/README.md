
#	20260409-Illumina-PhIP


```bash
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```bash
bs list projects >> ../README.md 


+-----------------------------------------+-----------+--------------+
|                  Name                   |    Id     |  TotalSize   |
+-----------------------------------------+-----------+--------------+
| MEX_LEUK_2018                           | 60976917  | 132686382176 |
| Mex_leucemia_18                         | 61769708  | 66088939767  |
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 233154687    |
| 040826_HH_L1                            | 496329250 | 21160864207  |
+-----------------------------------------+-----------+--------------+
```


```bash
bs download project -i 496329250
```

```bash
cd ..
ll download/*/*z >> README.md


-rw-r----- 1 gwendt francislab  116480091 Apr  9 15:29 download/2001194_040126_ds.9c33c59432314e7c89b56331e126ced7/2001194_040126_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112667031 Apr  9 15:29 download/2001194dup_040126_ds.0d5dac23cdff409ea758ac73b1117cc8/2001194dup_040126_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105014689 Apr  9 15:29 download/2004880_040126_ds.eba3698f63c14a689b1b8585e275079a/2004880_040126_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94017885 Apr  9 15:29 download/2004880dup_040126_ds.6637c92bfc65454b928cd78f43d59b99/2004880dup_040126_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69701806 Apr  9 15:29 download/2006387_040126_ds.81d208378fbd43f1a58194bf867c4790/2006387_040126_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75224399 Apr  9 15:29 download/2006387dup_040126_ds.eef2be649b4549608a1bf61a1539be1f/2006387dup_040126_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93831140 Apr  9 15:29 download/2011444_040126_ds.02fa43fda37940c6a2ea1367f520ec92/2011444_040126_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92543938 Apr  9 15:29 download/2011444dup_040126_ds.9b4670c2d62647fc99a2353e58ceeb24/2011444dup_040126_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105401424 Apr  9 15:29 download/2015165_040126_ds.25a45fc5636f4e14a1d701df51ee7070/2015165_040126_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  134831608 Apr  9 15:29 download/2015165dup_040126_ds.2117bd0d12fd463bbc99760e376ca885/2015165dup_040126_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102584015 Apr  9 15:29 download/2017888_040126_ds.1a90a06c1ca44cd69c2b7a020f188b54/2017888_040126_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111686937 Apr  9 15:29 download/2017888dup_040126_ds.4719e2cd22aa43e4bb905e77876a0ac9/2017888dup_040126_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103291902 Apr  9 15:29 download/315DGA_040126_ds.4548c1e8fcd041ddbc0ec5c2c073ab26/315DGA_040126_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103795239 Apr  9 15:29 download/315DGAdup_040126_ds.e4ff2a83306a4945abfe13f858b2a4e5/315DGAdup_040126_S90_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   94029921 Apr  9 15:29 download/419SCA_040126_ds.d0a8321d50434996a7785b9f92bd5eac/419SCA_040126_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104723578 Apr  9 15:29 download/419SCAdup_040126_ds.918e668036f1437bb8f66c1948b337fd/419SCAdup_040126_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   82298612 Apr  9 15:29 download/434ACB_040126_ds.2c52451f4d93497cbb852b386b01569b/434ACB_040126_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79546455 Apr  9 15:29 download/434ACBdup_040126_ds.628b256cb9c1402996ef8986b8d51a31/434ACBdup_040126_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91635599 Apr  9 15:29 download/620XAM_040126_ds.09c9fcaca07c4d8191b9380a130693f0/620XAM_040126_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92791547 Apr  9 15:29 download/620XAMdup_040126_ds.0fe33bf68a5749c28bf5743bff51494f/620XAMdup_040126_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89311382 Apr  9 15:29 download/637CJB_040126_ds.3acb0311c1644bdb8dcb9b8648ef0171/637CJB_040126_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86009035 Apr  9 15:29 download/637CJBdup_040126_ds.7ed480deab8c4523be1d908c9fdfa643/637CJBdup_040126_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95835283 Apr  9 15:29 download/656JOC_040126_ds.cc297f823f5e4558b38ebac57fb863f5/656JOC_040126_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96879019 Apr  9 15:29 download/656JOCdup_040126_ds.39e27a7cf9524276a4e35b48f8830f22/656JOCdup_040126_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114122321 Apr  9 15:29 download/690VLK_040126_ds.f109a34e25674024ad3dc8a14bc5ff25/690VLK_040126_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112858799 Apr  9 15:29 download/690VLKdup_040126_ds.87eef9a276aa4bc3b1ad8b07fbc3195b/690VLKdup_040126_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107769257 Apr  9 15:29 download/703PIS_040126_ds.dffe294a971f4c56ab6442bb6dc792a1/703PIS_040126_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98524610 Apr  9 15:29 download/703PISdup_040126_ds.65fee0e378ab4035b1f4eb91938066bd/703PISdup_040126_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102748372 Apr  9 15:29 download/727CIH_040126_ds.b56a96f344084e48b5b23e79950023cc/727CIH_040126_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96393881 Apr  9 15:29 download/727CIHdup_040126_ds.4f58092675a34ef3bf15eafa96cfad79/727CIHdup_040126_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100750380 Apr  9 15:29 download/728AGH_040126_ds.e4344953dd314a3b8681ee02fcc7c10f/728AGH_040126_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108941590 Apr  9 15:29 download/728AGHdup_040126_ds.ef738d48a36a4642b7f1b596491639fc/728AGHdup_040126_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103327770 Apr  9 15:29 download/730FJA_040126_ds.41d2a783b5cd465eb26cedb360fa1a8d/730FJA_040126_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98279809 Apr  9 15:29 download/730FJAdup_040126_ds.413b2d32c16d420689430b7b1f4c321c/730FJAdup_040126_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108382767 Apr  9 15:29 download/738BRT_040126_ds.2d789c18e8b246fcabb6e33eaddb2630/738BRT_040126_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102031224 Apr  9 15:29 download/738BRTdup_040126_ds.c420ef96836b4c5d94962659a88852a4/738BRTdup_040126_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114181963 Apr  9 15:29 download/742TVZ_040126_ds.dd889231216046d3bca8461d084ac4ec/742TVZ_040126_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98136849 Apr  9 15:29 download/742TVZdup_040126_ds.29923fb3f20f4135bf936f58c6c2ad44/742TVZdup_040126_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104836982 Apr  9 15:29 download/745MIA_040126_ds.c2b22eba03b844c38a48e72222b56fbb/745MIA_040126_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91279036 Apr  9 15:29 download/745MIAdup_040126_ds.ae8cc883e733414281c505d1ee8273ac/745MIAdup_040126_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109628730 Apr  9 15:29 download/747DAI_040126_ds.289eda6a83e142efa871f23ea73d5869/747DAI_040126_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  124309877 Apr  9 15:29 download/747DAIdup_040126_ds.bc2fedeb6a104da2a98b619c86b718dd/747DAIdup_040126_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89154443 Apr  9 15:29 download/748FAY_040126_ds.0c8ec58f363b4460bec2f7e2ef68e7e9/748FAY_040126_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110564477 Apr  9 15:29 download/748FAYdup_040126_ds.234d6c252c274872b295d5da95e33204/748FAYdup_040126_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  120860100 Apr  9 15:29 download/753FAR_040126_ds.42d691254a034cff9550bf13c655dab6/753FAR_040126_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78814981 Apr  9 15:29 download/753FARdup_040126_ds.1896b1c939344bbf8e9aa75e9c9517bf/753FARdup_040126_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91794592 Apr  9 15:29 download/755TSF_040126_ds.246e3aaeb91046a28d9933df477eeae8/755TSF_040126_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103822968 Apr  9 15:29 download/755TSFdup_040126_ds.f96982f5d7d046488577ae6658d90b3e/755TSFdup_040126_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114165229 Apr  9 15:29 download/757SEX_040126_ds.4099a92cdeb2468d91452d82a7e2e8b9/757SEX_040126_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116925650 Apr  9 15:29 download/757SEXdup_040126_ds.f5f98d933a024db692a27de4c30cf959/757SEXdup_040126_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   79461943 Apr  9 15:29 download/768TPO_040126_ds.71be30d5a99d45a5bcaa9675a4521ba7/768TPO_040126_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88311909 Apr  9 15:29 download/768TPOdup_040126_ds.499a884aae2d4bdebeca03e6db60bf64/768TPOdup_040126_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103225462 Apr  9 15:29 download/769ABC_040126_ds.bfbfbc0545034c92960ebdbcfe6ff774/769ABC_040126_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103863042 Apr  9 15:29 download/769ABCdup_040126_ds.d682f7e0c1f2437582b820dd42e38bf4/769ABCdup_040126_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115810139 Apr  9 15:29 download/774FFA_040126_ds.9d50d45d90ed41d8a08c6768ac9f1316/774FFA_040126_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110007498 Apr  9 15:29 download/774FFAdup_040126_ds.2cb67de3c8e24866ab22a654588eb3ac/774FFAdup_040126_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96175853 Apr  9 15:29 download/783CFK_040126_ds.7609092bbf78460fbebd472b6e0b0cb9/783CFK_040126_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  122289962 Apr  9 15:29 download/783CFKdup_040126_ds.10991d2c3ef44d389d29781a69d836b2/783CFKdup_040126_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   56459132 Apr  9 15:29 download/784CBS_040126_ds.aa3f60f093284a829e7fb540fe3cad55/784CBS_040126_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   81509040 Apr  9 15:29 download/784CBSdup_040126_ds.ff680468b3e14a54a4abeedeff48bdfb/784CBSdup_040126_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125535649 Apr  9 15:29 download/788CBR_040126_ds.d1896b1428af42c7b5581465b6a89907/788CBR_040126_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117919097 Apr  9 15:29 download/788CBRdup_040126_ds.2d3dcb151b194b2ab98faef81212f467/788CBRdup_040126_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86830273 Apr  9 15:29 download/799TFO_040126_ds.adcac924f32a443bac3d59b74272f6c2/799TFO_040126_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88711388 Apr  9 15:29 download/799TFOdup_040126_ds.ccbe5eedd3c14366b74c215a99b1d418/799TFOdup_040126_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   62971615 Apr  9 15:29 download/Blank01_040126_ds.04f12bb15b044777b138f33007569c4c/Blank01_040126_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   62614962 Apr  9 15:29 download/Blank01dup_040126_ds.69e9bd0241274daa8d6643b3d58bd797/Blank01dup_040126_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105828397 Apr  9 15:29 download/Blank02_040126_ds.a3a02e0e96f740beba6efb360a2ad748/Blank02_040126_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111420566 Apr  9 15:29 download/Blank02dup_040126_ds.6319fb5a3553452998b4200ad2243c15/Blank02dup_040126_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113895373 Apr  9 15:29 download/Blank03_040126_ds.821b575752a0404182ef1baaf58e6837/Blank03_040126_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   88417783 Apr  9 15:29 download/Blank03dup_040126_ds.986889e2031443c4b5f1363422f3a16d/Blank03dup_040126_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  139140148 Apr  9 15:29 download/Blank04_040126_ds.415a80af920943a7922210775abc5307/Blank04_040126_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100847334 Apr  9 15:29 download/Blank04dup_040126_ds.2c189452784e4ab892d03c1b6b7e91e3/Blank04dup_040126_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  115000155 Apr  9 15:29 download/Blank05_040126_ds.2da70d1e737347c281432ebae242be2c/Blank05_040126_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113236341 Apr  9 15:29 download/Blank05dup_040126_ds.7afbd02697df401f966479425d8409ee/Blank05dup_040126_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90268584 Apr  9 15:29 download/Blank06_040126_ds.9bdc8d83d07b4e0bb8f5d4f7ea249c63/Blank06_040126_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105832387 Apr  9 15:29 download/Blank06dup_040126_ds.f670e35a608645128ae36a76c6b3a6e7/Blank06dup_040126_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100112362 Apr  9 15:29 download/Blank07_040126_ds.5b4967f761f7422da2019472544480e2/Blank07_040126_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104333537 Apr  9 15:29 download/Blank07dup_040126_ds.d1e0b203a97e4a488fc8416f80d39045/Blank07dup_040126_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113758166 Apr  9 15:29 download/Blank08_040126_ds.d6c423a1d648431780fd2a0d57e4b7eb/Blank08_040126_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104583253 Apr  9 15:29 download/Blank08dup_040126_ds.55f24b854f964e549fd18fa8f6d573c3/Blank08dup_040126_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116788664 Apr  9 15:29 download/C619ASF_040126_ds.0c2af84979c24a108716ba1dfa8c54b4/C619ASF_040126_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      17702 Apr  9 15:29 download/C619ASFdup_040126_ds.ede1809afd904e5f94e36f78c2b01ea8/C619ASFdup_040126_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  122389624 Apr  9 15:29 download/C631OCS_040126_ds.1f9f3b74673f46b9951b9b2a7b8598c8/C631OCS_040126_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90301849 Apr  9 15:29 download/C631OCSdup_040126_ds.dc80312264b9480792bdc99ff288d916/C631OCSdup_040126_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69338698 Apr  9 15:29 download/C633DNO_040126_ds.27c00baca318414d8aa8cf3ab21e09ed/C633DNO_040126_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   80982255 Apr  9 15:29 download/C633DNOdup_040126_ds.59c644ee124c4f2a83a49604ced35e9f/C633DNOdup_040126_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105035566 Apr  9 15:29 download/C639SAS_040126_ds.88ea3a71f4a44c63ae439998e37fa12f/C639SAS_040126_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107402187 Apr  9 15:29 download/C639SASdup_040126_ds.cd0c741fb2e5425fa15f1c7c9c44a3bf/C639SASdup_040126_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102629574 Apr  9 15:29 download/C652SSP_040126_ds.f6bd83a18e964fd1adfd070674257165/C652SSP_040126_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98900808 Apr  9 15:29 download/C652SSPdup_040126_ds.0143ce5453354150b2674b0908103721/C652SSPdup_040126_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  111137389 Apr  9 15:29 download/C654TAN_040126_ds.0648d66d33904e1ca3a9a93f500eb93e/C654TAN_040126_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95306905 Apr  9 15:29 download/C654TANdup_040126_ds.fbd600f4703f43aa9d57f1a7508229fe/C654TANdup_040126_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86888387 Apr  9 15:29 download/C693KDK_040126_ds.20800ced276f448685b6adb216b4bb3a/C693KDK_040126_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100530918 Apr  9 15:29 download/C693KDKdup_040126_ds.73740c7d008c47a698f87aaa7b86ccb3/C693KDKdup_040126_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85948102 Apr  9 15:29 download/CK520PCM_040126_ds.12c270f26a4341bb9cc120be56999b98/CK520PCM_040126_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99343043 Apr  9 15:29 download/CK520PCMdup_040126_ds.670617d239b14ca0859852de929d5d5b/CK520PCMdup_040126_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104751363 Apr  9 15:29 download/CK521TSL_040126_ds.19f81711a119420d86c61b956a9287a9/CK521TSL_040126_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96226288 Apr  9 15:29 download/CK521TSLdup_040126_ds.2f5cbf6e36ed4de69e086345c2bae4a0/CK521TSLdup_040126_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  113336207 Apr  9 15:29 download/CK524EAP_040126_ds.702beb8005934e1a8e82104c4334a7da/CK524EAP_040126_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95861001 Apr  9 15:29 download/CK524EAPdup_040126_ds.455a477823d64464a2053250b2869e89/CK524EAPdup_040126_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107099385 Apr  9 15:29 download/CK525APC_040126_ds.35c08dbdd6fa4b199ab0de04cd0a4fd2/CK525APC_040126_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100945272 Apr  9 15:29 download/CK525APCdup_040126_ds.d68e32e4aff14174b798e4cd4be8ba03/CK525APCdup_040126_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112113787 Apr  9 15:29 download/CK526CMB_040126_ds.8c523bbfee3a4a838b217f7cbae982f1/CK526CMB_040126_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      53872 Apr  9 15:29 download/CK526CMBdup_040126_ds.09180556e83c4bf9a426f6163ee81dca/CK526CMBdup_040126_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100090375 Apr  9 15:29 download/CP303FSG_040126_ds.892c8c93ed5045a1aa1a48e7bd1d7e79/CP303FSG_040126_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97687047 Apr  9 15:29 download/CP303FSGdup_040126_ds.fbd52c34f84349a0bca485552b6ccffd/CP303FSGdup_040126_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92219474 Apr  9 15:29 download/CP304DSS_040126_ds.603c6bf27bc34856b94199877f171032/CP304DSS_040126_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91300848 Apr  9 15:29 download/CP304DSSdup_040126_ds.05fd7bc2e9cd418e8bcd3b75a20ea1c3/CP304DSSdup_040126_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89360220 Apr  9 15:29 download/CP316EMS_040126_ds.695da76f3444408380fac68fb3c6b22a/CP316EMS_040126_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107191934 Apr  9 15:29 download/CP316EMSdup_040126_ds.a16ca740a5164538a71589a599ba89e0/CP316EMSdup_040126_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102533384 Apr  9 15:29 download/CP319JMN_040126_ds.9cdd4f612fec43b5bb0ed4b007047615/CP319JMN_040126_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95379905 Apr  9 15:29 download/CP319JMNdup_040126_ds.ea17cba35fa742058723341a93a85690/CP319JMNdup_040126_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89668817 Apr  9 15:29 download/CP338AMB_040126_ds.99d39d1584624af59bbe1ccf4bfdb922/CP338AMB_040126_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105486047 Apr  9 15:29 download/CP338AMBdup_040126_ds.f06f0e8712c545368be6ab950e92fc76/CP338AMBdup_040126_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90945163 Apr  9 15:29 download/CP344RMS_040126_ds.b062fb25f90343b3b6e27e5d4825640a/CP344RMS_040126_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97322113 Apr  9 15:29 download/CP344RMSdup_040126_ds.95b20fa0e5cf4ff8ac329067c8d17a7b/CP344RMSdup_040126_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98737170 Apr  9 15:29 download/CP346MMS_040126_ds.962277f747d4481894b2a35079bd3e8a/CP346MMS_040126_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107210378 Apr  9 15:29 download/CP346MMSdup_040126_ds.a94e863c00364ca783cbddcbbce99b35/CP346MMSdup_040126_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103624391 Apr  9 15:29 download/CP360AAS_040126_ds.5cf6603e48ad481b9b3f540a4aee2ba9/CP360AAS_040126_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102452261 Apr  9 15:29 download/CP360AASdup_040126_ds.add814915cc648dd9ffcd62d19b6a3d8/CP360AASdup_040126_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93963462 Apr  9 15:29 download/CP405RAQ_040126_ds.420c61f5d0a0493b84cdf16742769fe5/CP405RAQ_040126_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86726911 Apr  9 15:29 download/CP405RAQdup_040126_ds.323f8c46c305446fa8d6d4b2ec8726fa/CP405RAQdup_040126_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107656916 Apr  9 15:29 download/CP407LBS_040126_ds.5505faf814134df1b6348eef1f3933d4/CP407LBS_040126_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104352955 Apr  9 15:29 download/CP407LBSdup_040126_ds.42e7beacf7c74cc7a55ca13240794396/CP407LBSdup_040126_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105518930 Apr  9 15:29 download/CP410HED_040126_ds.a88d56aaf15c4eaea1a586d3d8f9138b/CP410HED_040126_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   84063090 Apr  9 15:29 download/CP410HEDdup_040126_ds.5d7dd137bcf449daa160613d927a2ef4/CP410HEDdup_040126_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab    7506358 Apr  9 15:29 download/CP468OSP_040126_ds.63184af9964d414db7c5426e419ae38d/CP468OSP_040126_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   85037454 Apr  9 15:29 download/CP468OSPdup_040126_ds.c3c64f3ed45743ca86942d3618350a5c/CP468OSPdup_040126_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102827426 Apr  9 15:29 download/CP489JFC_040126_ds.4a49160bc711457da26de8b38190a163/CP489JFC_040126_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108195693 Apr  9 15:29 download/CP489JFCdup_040126_ds.b87d27f511df4071a63c17851198858a/CP489JFCdup_040126_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76108468 Apr  9 15:29 download/CP491RJF_040126_ds.d07b11f9b0b943f981500fd4e6b59f3e/CP491RJF_040126_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   65183704 Apr  9 15:29 download/CP491RJFdup_040126_ds.8158ee5d9c1d49798f9db6a3b6ba4991/CP491RJFdup_040126_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114212772 Apr  9 15:29 download/CSE01_040126_ds.fcd0ae6e89c044b58fecf34155d24aa2/CSE01_040126_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab      97739 Apr  9 15:29 download/CSE01dup_040126_ds.8336fa64fbb84e419c5ed63480eec523/CSE01dup_040126_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99617656 Apr  9 15:29 download/CSE02_040126_ds.c95410fa60064cc8b07db1d6bba696bc/CSE02_040126_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108940069 Apr  9 15:29 download/CSE02dup_040126_ds.757a7f282b314f66b4152fb95b847c23/CSE02dup_040126_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100382870 Apr  9 15:29 download/P120RAR_040126_ds.bdff7951325542e08aadcc887d121e68/P120RAR_040126_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   91731751 Apr  9 15:29 download/P120RARdup_040126_ds.5cd482778d944c93a3d1d12780360996/P120RARdup_040126_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   89489357 Apr  9 15:29 download/P141JAQ_040126_ds.155c7870a4ed46188aa3de536174288e/P141JAQ_040126_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92891314 Apr  9 15:29 download/P141JAQdup_040126_ds.c3a575abc29b4506a871ba208c31f81c/P141JAQdup_040126_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  107168643 Apr  9 15:29 download/P177JUN_040126_ds.bcd64233ab3d426b820804fbee260d66/P177JUN_040126_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99777350 Apr  9 15:29 download/P177JUNdup_040126_ds.af836c3b0b084a22b31e26da6cea311f/P177JUNdup_040126_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93209015 Apr  9 15:29 download/P182FON_040126_ds.4cf0c94086a942ef92a722fe2f576941/P182FON_040126_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  108494626 Apr  9 15:29 download/P182FONdup_040126_ds.0017df641d944d6ebd19e64e16f074e8/P182FONdup_040126_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101160594 Apr  9 15:29 download/P203JCA_040126_ds.bad1d1256bba4a9da4973fd93a5aac2d/P203JCA_040126_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  105236187 Apr  9 15:29 download/P203JCAdup_040126_ds.fef8bfe478a041829cdb64c7a1f37986/P203JCAdup_040126_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   77976259 Apr  9 15:29 download/P208RTP_040126_ds.e0d93c4cf2134350b0ba582a49a9bc92/P208RTP_040126_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96138741 Apr  9 15:29 download/P208RTPdup_040126_ds.a92f38b5880447028b6cfc75b4e3e549/P208RTPdup_040126_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101888831 Apr  9 15:29 download/P216WIC_040126_ds.39834696425347c997e00beaef0d6e0b/P216WIC_040126_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   90942568 Apr  9 15:29 download/P216WICdup_040126_ds.4ed0ea49977c4f10a8a8cdfcc30f5339/P216WICdup_040126_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117318989 Apr  9 15:29 download/P234AFG_040126_ds.0110c48a80e941498aed31dd1a74524b/P234AFG_040126_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114833702 Apr  9 15:29 download/P234AFGdup_040126_ds.48fe394fc9d94dbe924ef0ef427a6155/P234AFGdup_040126_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104803596 Apr  9 15:29 download/P242NRS_040126_ds.6e0681f4b14f499984bf5bb55edf9f1a/P242NRS_040126_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  102870766 Apr  9 15:29 download/P242NRSdup_040126_ds.d08ba5b4d7bd4c4d8a579cfc4e7b863d/P242NRSdup_040126_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  117285529 Apr  9 15:29 download/P296ESA_040126_ds.504201912c8a40efa81b49b1e24de5bf/P296ESA_040126_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101376260 Apr  9 15:29 download/P296ESAdup_040126_ds.55a7766e9dd24e408b89454b1bb35cb6/P296ESAdup_040126_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  110677729 Apr  9 15:29 download/P299AFR_040126_ds.bf4257230c5c49f195da40138f8fa6a7/P299AFR_040126_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  106099970 Apr  9 15:29 download/P299AFRdup_040126_ds.47f67b9c20ab45d69b574293662b8cac/P299AFRdup_040126_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  131946666 Apr  9 15:29 download/P331AGM_040126_ds.59faf8683f354060a8510b5141da12ba/P331AGM_040126_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103126882 Apr  9 15:29 download/P331AGMdup_040126_ds.30fd0932a6d14785bb6e12d8a83721ad/P331AGMdup_040126_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  109444528 Apr  9 15:29 download/P336ELC_040126_ds.33288b7b749c48fbbb6330c46e51da57/P336ELC_040126_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96949977 Apr  9 15:29 download/P336ELCdup_040126_ds.b978c4b951934a419f258273d5dd6bb3/P336ELCdup_040126_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  100079815 Apr  9 15:29 download/P347DVA_040126_ds.6021cc240b9747619db95be3b53ce84d/P347DVA_040126_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96487669 Apr  9 15:29 download/P347DVAdup_040126_ds.b92a660f749048f8ad54a5762db9189f/P347DVAdup_040126_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   69458119 Apr  9 15:29 download/P349CPP_040126_ds.e743b5b493e949c0b30788afc8b0e346/P349CPP_040126_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92847721 Apr  9 15:29 download/P349CPPdup_040126_ds.8209afe167274e79a19d39ca12a675d0/P349CPPdup_040126_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  125916330 Apr  9 15:29 download/P359RSG_040126_ds.236cef6ec5e5490a80d04454ca57793e/P359RSG_040126_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  116896106 Apr  9 15:29 download/P359RSGdup_040126_ds.9164763e6d9b423d9432de151255a283/P359RSGdup_040126_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   92878115 Apr  9 15:29 download/P369JCC_040126_ds.8b7cfec557e84122af0899b8abadb437/P369JCC_040126_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  104324104 Apr  9 15:29 download/P369JCCdup_040126_ds.51acaf1ba29d45dea4119dba597b431a/P369JCCdup_040126_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   78292290 Apr  9 15:29 download/P372DPB_040126_ds.8b0abad8815344768de3ef8f59bf5d39/P372DPB_040126_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   98883972 Apr  9 15:29 download/P372DPBdup_040126_ds.c4b9123a4a8a4fd188170af27977f1f8/P372DPBdup_040126_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87175161 Apr  9 15:29 download/P373ITS_040126_ds.867021f29bc7473e8055f6fb8b80153c/P373ITS_040126_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   83357039 Apr  9 15:29 download/P373ITSdup_040126_ds.6e95e70e7c4c4312ab10c8b0b5775e47/P373ITSdup_040126_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   95000572 Apr  9 15:29 download/P386JGY_040126_ds.dec2b895708544cfbae5bf1dfc969270/P386JGY_040126_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  114451915 Apr  9 15:29 download/P386JGYdup_040126_ds.9a4526e8305545c58b202b26367c4129/P386JGYdup_040126_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  103254386 Apr  9 15:29 download/P408MKP_040126_ds.4913c6d0ee384c969c18502efbe2a1e6/P408MKP_040126_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101270667 Apr  9 15:29 download/P408MKPdup_040126_ds.f7138d70542f4f1cb0bf0be4bfeeef2f/P408MKPdup_040126_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  112096983 Apr  9 15:29 download/P419MVI_040126_ds.5ec9062ebce14a4cabe1fed1d30ad852/P419MVI_040126_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  129568718 Apr  9 15:29 download/P419MVIdup_040126_ds.a21c7341a9a945bfaf12d891d9675cae/P419MVIdup_040126_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76433940 Apr  9 15:29 download/P513IJS_040126_ds.eb02b8d9e3374e788bebcacf5985a653/P513IJS_040126_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   75379998 Apr  9 15:29 download/P513IJSdup_040126_ds.24f9c5a547e34a3e80d84174a29f7be3/P513IJSdup_040126_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74428358 Apr  9 15:29 download/P515SAT_040126_ds.a0ba46e558bb4c91997fb31d97e9e81e/P515SAT_040126_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   87220378 Apr  9 15:29 download/P515SATdup_040126_ds.1c7b6da287b24d7ebf8656afd38103a9/P515SATdup_040126_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   97800758 Apr  9 15:29 download/P531CHC_040126_ds.f42382ed347549db924abe0a61960479/P531CHC_040126_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   93312531 Apr  9 15:29 download/P531CHCdup_040126_ds.583b66fa64f14956a4f3efe9d12cd15e/P531CHCdup_040126_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   74774558 Apr  9 15:29 download/PK216AOS_040126_ds.262e3204f6c846a6893522841401f47d/PK216AOS_040126_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   96035347 Apr  9 15:29 download/PK216AOSdup_040126_ds.e1c1280cc103472c8807f9b68eefd7e5/PK216AOSdup_040126_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  101862411 Apr  9 15:29 download/PLib01_040126_ds.46c9c4d456f748a4afd20db364e587af/PLib01_040126_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   76331857 Apr  9 15:29 download/PLib01dup_040126_ds.d4e81a4309c44f3899ef1fe9ca27185e/PLib01dup_040126_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   86814653 Apr  9 15:29 download/PLib02_040126_ds.0cf61a4c60454b7b93f9436dabc173c6/PLib02_040126_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   99626761 Apr  9 15:29 download/PLib02dup_040126_ds.ad232e24ebc84de090cfb4f2abf59746/PLib02dup_040126_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 2440830880 Apr  9 15:30 download/Undetermined_from_040826_HH_L1_ds.ab3badc2fdb84515bc9be6be76d0a3a5/Undetermined_S0_L001_R1_001.fastq.gz

```



```bash
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


```bash
for f in download/*/*fastq.gz ; do
b=$( basename $f )
x=$( basename $f _L001_R1_001.fastq.gz )
s=$( echo $x | awk -F_ '{print $NF}' )
x=${x%_040126_S*}
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
for z in download/*/*z; do f=$( basename $z _L001_R1_001.fastq.gz ); f=${f/_040126_/,}; echo $f; done | sort -t, -k1,1 > sample_s_number.csv
sed -i '1isample,s' sample_s_number.csv 
```

Drop S0 by hand



##	20260413

Create a standardized local covariates file.

Calling these plates 21 and 22.

```bash
awk 'BEGIN{
FS=OFS=","
print "snumber,sample,subject,type,study,sex,age,casecontrol,plate,well"
}(NR>1){
$19=$19+20
print $1,$2,$3,$8,$9,$10,$11,$12,$19,$20
}' 040826_192Phip_L1_covariate_file_Avera_4-8-26HMH.csv > select_covariates.csv

sed -i -e 's/PBS blank/input/' -e 's/VIR phage Library/Phage Library/g' -e 's/phage library (blank)/Phage Library/g' select_covariates.csv
chmod -w select_covariates.csv
```



