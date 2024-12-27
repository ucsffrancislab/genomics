
#	20241224-Illumina-PhIP


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
| 121724_192PhiP_L2                       | 441174819 | 16733158231  |
+-----------------------------------------+-----------+--------------+
```


```
bs download project -i 441174819
```

```
cd ..
ll download/*/*z >> README.md


-rw-r----- 1 gwendt francislab  64518742 Dec 24 06:33 download/024JCM_121724_ds.1167175eacd748bfaa06efa8be33704f/024JCM_121724_S50_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78854258 Dec 24 06:33 download/024JCMdup_121724_ds.f7bce0a87cac42f59fba41b2736b7e46/024JCMdup_121724_S58_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82102805 Dec 24 06:33 download/074KBP_121724_ds.0fb21be0b60c4af992e3840baeb42cbb/074KBP_121724_S66_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81615000 Dec 24 06:33 download/074KBPdup_121724_ds.ce1a3d12af6f40b095ecda70d7eadd12/074KBPdup_121724_S74_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87365373 Dec 24 06:33 download/1313_121724_ds.bee346bceeef40d699f54c969e19c4f1/1313_121724_S4_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84574523 Dec 24 06:33 download/1313dup_121724_ds.7e2b666b33bb4523b269fc4ebcf0efab/1313dup_121724_S12_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89338494 Dec 24 06:33 download/1314_121724_ds.8ae2d8d8732244c0bb5d289fa3c0055f/1314_121724_S6_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90599428 Dec 24 06:33 download/1314dup_121724_ds.b465f7403b344b1e972c904b8fc02007/1314dup_121724_S14_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94964564 Dec 24 06:33 download/1315_121724_ds.5014d9bac5b0430d9cca7d83d1c50c41/1315_121724_S18_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100364338 Dec 24 06:33 download/1315dup_121724_ds.2c9936a17def4f44b6b7828f95a629cb/1315dup_121724_S26_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88673319 Dec 24 06:33 download/1316_121724_ds.73e4d460c1724205bb15d17eb2d55b39/1316_121724_S22_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78391362 Dec 24 06:33 download/1316dup_121724_ds.32195b104daa4289a28604c438033df3/1316dup_121724_S30_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82740319 Dec 24 06:33 download/1317_121724_ds.a2b5ed39d23748d7879914233033dc4f/1317_121724_S23_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  63085303 Dec 24 06:33 download/1317dup_121724_ds.2106cd12756448d38e2955d5267f0a17/1317dup_121724_S31_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96225827 Dec 24 06:33 download/1318_121724_ds.810ecf83de3a465497b4082a8178f8e9/1318_121724_S34_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  99547367 Dec 24 06:33 download/1318dup_121724_ds.db48ee38db3e49f5afee47c444ffebed/1318dup_121724_S42_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92887380 Dec 24 06:33 download/1319_121724_ds.9a695c3bae23410b96acc54ddea40d9b/1319_121724_S38_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91620402 Dec 24 06:33 download/1319dup_121724_ds.6987cd418f9b4736beed8e762dbbeb8e/1319dup_121724_S46_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88453187 Dec 24 06:33 download/1320_121724_ds.be413c43b88449cab5d29e04eb5ffc1d/1320_121724_S39_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  99458173 Dec 24 06:33 download/1320dup_121724_ds.1e8a1cab5a4147ba9b7397294ac43b5e/1320dup_121724_S47_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  66313358 Dec 24 06:33 download/1321_121724_ds.97ccc7232ec244e8966bc53d2f480ce3/1321_121724_S52_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92966358 Dec 24 06:33 download/1321dup_121724_ds.337d65a9c72949aab63f27806f543b62/1321dup_121724_S60_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86775822 Dec 24 06:33 download/1322_121724_ds.dcbe53da3eee49e68c9063441b93f34a/1322_121724_S67_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79891947 Dec 24 06:33 download/1322dup_121724_ds.012f54596baf4e98a771a74dd4bcc9fe/1322dup_121724_S75_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95638299 Dec 24 06:33 download/1323_121724_ds.aab791336289464e9ad9c2dfc19b6cb3/1323_121724_S70_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84223230 Dec 24 06:33 download/1323dup_121724_ds.cdd2635f36554558899526c3711f9d17/1323dup_121724_S78_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88663203 Dec 24 06:33 download/1324_121724_ds.0c8f54ebbf6d4f58a5d93cee12998dae/1324_121724_S85_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82737067 Dec 24 06:33 download/1324dup_121724_ds.4899535196d94c8d8d1f0449ea135fc7/1324dup_121724_S93_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88602640 Dec 24 06:33 download/14061-01_121724_ds.c1d3b8d3bfaf4b93817ea10fcc624129/14061-01_121724_S116_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97638788 Dec 24 06:33 download/14061-01dup_121724_ds.0785919470574eb7a0e05cc69cef8afa/14061-01dup_121724_S124_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  75148672 Dec 24 06:33 download/14091-01_121724_ds.6834d4e42b7c469d8d3aa57ac1b697fc/14091-01_121724_S146_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91198902 Dec 24 06:33 download/14091-01dup_121724_ds.d5405e3675bf4eaeb02356f232ebbaa6/14091-01dup_121724_S154_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86345152 Dec 24 06:33 download/14160-01_121724_ds.7b7486869d9349d7bea2b2e2f6b004f3/14160-01_121724_S149_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95323333 Dec 24 06:33 download/14160-01dup_121724_ds.4d2b800bf63149e9913eb738ddb46f07/14160-01dup_121724_S157_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82719369 Dec 24 06:33 download/14167-01_121724_ds.690b70350f924f6f8bb8ab9d9bc209b1/14167-01_121724_S179_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86154872 Dec 24 06:33 download/14167-01dup_121724_ds.eb70f48f68c946e7885e613ada1fe199/14167-01dup_121724_S187_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69698993 Dec 24 06:33 download/14178-01_121724_ds.ccc72d24c55b4b8fb2080850de4525f0/14178-01_121724_S161_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78844354 Dec 24 06:33 download/14178-01dup_121724_ds.5f244b7a35d1456b9a73b7e83f14787f/14178-01dup_121724_S169_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92837737 Dec 24 06:33 download/14291-02_121724_ds.c53b1702ea0f4c968a6ce54392dc4409/14291-02_121724_S98_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85398460 Dec 24 06:33 download/14291-02dup_121724_ds.f99bef5b129d44db9c09a7a31cbf6db4/14291-02dup_121724_S106_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82753647 Dec 24 06:33 download/14323-01_121724_ds.1ed143dabfa24b978dce3f236cbb2a9b/14323-01_121724_S180_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74491548 Dec 24 06:33 download/14323-01dup_121724_ds.b68b8589e1b946d692b6cb39a4fb722a/14323-01dup_121724_S188_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71453994 Dec 24 06:33 download/14339-01_121724_ds.8626d6fb354941af8e29c8a43de1e4e5/14339-01_121724_S177_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  74895284 Dec 24 06:33 download/14339-01dup_121724_ds.febdcd0286f34d5f9006e1c8ba81cea9/14339-01dup_121724_S185_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93539187 Dec 24 06:33 download/14348-03_121724_ds.843f6693e3db4020973053fbfbd48420/14348-03_121724_S147_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93604358 Dec 24 06:33 download/14348-03dup_121724_ds.354a1c74f0a64844be6e51a2c1ab4fba/14348-03dup_121724_S155_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91787973 Dec 24 06:33 download/14435-01_121724_ds.e3e17d5783eb43598cffce46154c1d8a/14435-01_121724_S150_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92536756 Dec 24 06:33 download/14435-01dup_121724_ds.a6e7aa66bf014664a9bf298e51b3b77c/14435-01dup_121724_S158_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87015972 Dec 24 06:33 download/14443-01_121724_ds.9987e0ee030b4a67822f081a9238ea1d/14443-01_121724_S167_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81898723 Dec 24 06:33 download/14443-01dup_121724_ds.fadd085b3b0544cab23a7739cbca7d6c/14443-01dup_121724_S175_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 106295803 Dec 24 06:33 download/14478-01_121724_ds.83e3968ef7f84ad5b1a909ff6ec1d364/14478-01_121724_S168_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81967642 Dec 24 06:33 download/14478-01dup_121724_ds.6f99ef26e3c2472bb8f2bd3a495b46b9/14478-01dup_121724_S176_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79763392 Dec 24 06:33 download/14587-01_121724_ds.e32227ecac634c7890d609f4066a45bc/14587-01_121724_S164_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88601150 Dec 24 06:33 download/14587-01dup_121724_ds.d7bbd7bac4c64b60b732f2c8d6a0455d/14587-01dup_121724_S172_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  98031665 Dec 24 06:33 download/14629-01_121724_ds.06985e4a8fe74ddabb5a60551fbb25b7/14629-01_121724_S100_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89367278 Dec 24 06:33 download/14629-01dup_121724_ds.2e0e1ccc4a204d3c889e7180e51fe162/14629-01dup_121724_S108_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94892944 Dec 24 06:33 download/14714-01_121724_ds.188a9b71a38549f29db4fa52dd59c9ab/14714-01_121724_S148_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81680613 Dec 24 06:33 download/14714-01dup_121724_ds.139d95d72f6042f49f96d323ffe81873/14714-01dup_121724_S156_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94153634 Dec 24 06:33 download/14734-01_121724_ds.1e1dcd8a5e134db8981b6e76e7350539/14734-01_121724_S99_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83354946 Dec 24 06:33 download/14734-01dup_121724_ds.abf5eaf17c9d43379dd4117ad8a1f7cb/14734-01dup_121724_S107_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81441255 Dec 24 06:33 download/14750-01_121724_ds.728b41ce6026427091e82d71b0aa5a86/14750-01_121724_S129_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88184931 Dec 24 06:33 download/14750-01dup_121724_ds.8a3c21bc59d440ee963f37a3acb8bf43/14750-01dup_121724_S137_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  98205625 Dec 24 06:33 download/14783-01_121724_ds.fabbdfc05efa49fba830f630176053f3/14783-01_121724_S162_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83598482 Dec 24 06:33 download/14783-01dup_121724_ds.056fbc9b9d9d40f681e244da72e14cc0/14783-01dup_121724_S170_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  71743477 Dec 24 06:33 download/14917-01_121724_ds.c38b514ba48f4bf8a48e222c6dd15022/14917-01_121724_S152_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82786120 Dec 24 06:33 download/14917-01dup_121724_ds.a947c312faa5450c913d6b95cd7f174a/14917-01dup_121724_S160_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92552105 Dec 24 06:33 download/14977-01_121724_ds.40727e8d2f764b92b782cb92c83d65c5/14977-01_121724_S131_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96527787 Dec 24 06:33 download/14977-01dup_121724_ds.a9454e2a2f3d4bbe9845f4d02dc4b1c9/14977-01dup_121724_S139_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92809132 Dec 24 06:33 download/18017-01_121724_ds.5e72ae4bdc534514abed5cdd090b4fc4/18017-01_121724_S117_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  98847334 Dec 24 06:33 download/18017-01dup_121724_ds.4d832fb3571b418dbfa0a611e065442f/18017-01dup_121724_S125_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85929803 Dec 24 06:33 download/20049_121724_ds.bf71c2149ac140fab04d1419994f5473/20049_121724_S119_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85926144 Dec 24 06:33 download/20049dup_121724_ds.ca59da44875744f7a7834bf497bedecb/20049dup_121724_S127_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85559771 Dec 24 06:33 download/20058_121724_ds.8f7c1d84b47d4841b95bb3f4840bee04/20058_121724_S134_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95363635 Dec 24 06:33 download/20058dup_121724_ds.e7635653e7bc41bfb840679a05111946/20058dup_121724_S142_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80261062 Dec 24 06:33 download/20232_121724_ds.2a514762ee364fa5821b658dbd47c655/20232_121724_S97_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85448884 Dec 24 06:33 download/20232dup_121724_ds.ec255677e1a64da989d912cd32703458/20232dup_121724_S105_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97498517 Dec 24 06:33 download/20239_121724_ds.b3cb4e75e8db4f8780fe7d20faac2e5f/20239_121724_S102_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80082869 Dec 24 06:33 download/20239dup_121724_ds.6ae9ed0680644bd8b1783e1b139e6c32/20239dup_121724_S110_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85822734 Dec 24 06:33 download/20451_121724_ds.fd96848d8aa1411ba9bac99c27c91e4e/20451_121724_S132_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96534460 Dec 24 06:33 download/20451dup_121724_ds.362c00a896ae47a081c62bb4f6d71e28/20451dup_121724_S140_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92589915 Dec 24 06:33 download/20466_121724_ds.eb8d2f956b7647d18a0b2c05ec9d48ab/20466_121724_S183_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73340788 Dec 24 06:33 download/20466dup_121724_ds.305401c584e943758de11f7db3bb01f1/20466dup_121724_S191_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 101327300 Dec 24 06:33 download/21028_121724_ds.5584b31599f9465bb9709538e4ee2941/21028_121724_S120_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87928578 Dec 24 06:33 download/21028dup_121724_ds.6c36c2ee029f4090bb816d70f311a6c0/21028dup_121724_S128_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77697727 Dec 24 06:33 download/21171_121724_ds.b28f3d87dff540b591a2567c5fd6850f/21171_121724_S178_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79430941 Dec 24 06:33 download/21171dup_121724_ds.87907b6bb9f24ee29676971f03349f06/21171dup_121724_S186_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83193048 Dec 24 06:33 download/3108_121724_ds.0f0a27c56a6c400fb7cfdd711ddc93b4/3108_121724_S103_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89651750 Dec 24 06:33 download/3108dup_121724_ds.a5b275e292b44c35ab7c6693e1ec0de7/3108dup_121724_S111_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79649584 Dec 24 06:33 download/3209_121724_ds.441416ae995542c39d8189e3a44cd4a7/3209_121724_S163_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89573293 Dec 24 06:33 download/3209dup_121724_ds.82d1f12442d346428510c560f1d3a0c1/3209dup_121724_S171_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78002415 Dec 24 06:33 download/4071_121724_ds.70d13df3eb0b409ebc5dbf2a6cb281e8/4071_121724_S136_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88694789 Dec 24 06:33 download/4071dup_121724_ds.a36b2d086c334847b53dea0d60182895/4071dup_121724_S144_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84634010 Dec 24 06:33 download/410ERA_121724_ds.d1c9d353c8354b90951767f812a6f21b/410ERA_121724_S65_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91824744 Dec 24 06:33 download/410ERAdup_121724_ds.9e050a00e6a1471697ea2a280337b102/410ERAdup_121724_S73_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94683932 Dec 24 06:33 download/4121_121724_ds.899861da8bce4c31bd6ee64eeb68b325/4121_121724_S101_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91076536 Dec 24 06:33 download/4121dup_121724_ds.bf06279f718a48eaacb01b228c9f2bb8/4121dup_121724_S109_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79679489 Dec 24 06:33 download/4136_121724_ds.cb906aea8d234474afb5edeeb0a77db1/4136_121724_S184_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  70732852 Dec 24 06:33 download/4136dup_121724_ds.c26ab10afe8c45919afb192f743b0688/4136dup_121724_S192_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92332419 Dec 24 06:33 download/420SLF_121724_ds.825ca096d0fe4b82bc0130dbe6e1b16e/420SLF_121724_S69_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96479913 Dec 24 06:33 download/420SLFdup_121724_ds.f1898d4ada9c4e84ab9452b0443d1bc5/420SLFdup_121724_S77_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81326418 Dec 24 06:33 download/4217_121724_ds.02aa8f1db74649f5a5f694d66c52474f/4217_121724_S113_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87228153 Dec 24 06:33 download/4217dup_121724_ds.1ecfeb7c65674c6c940293bfde934059/4217dup_121724_S121_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94260966 Dec 24 06:33 download/4252_121724_ds.6327783556024c2dad282ea403c1ea3f/4252_121724_S151_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89384716 Dec 24 06:33 download/4252dup_121724_ds.60a65c2ffd9742a383c8caa14c3f24a3/4252dup_121724_S159_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79393417 Dec 24 06:33 download/4255_121724_ds.f61ccf25385c4b11854dacde2b133f1b/4255_121724_S115_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90501029 Dec 24 06:33 download/4255dup_121724_ds.e4dac3a17e7d4ad9992d248b415ae3ed/4255dup_121724_S123_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100873795 Dec 24 06:33 download/4303_121724_ds.9b2c467fbc0748b4932b79df13e154d2/4303_121724_S166_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  92685435 Dec 24 06:33 download/4303dup_121724_ds.3d846ee3c99b4008ae78602c4e0c1d3f/4303dup_121724_S174_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  80725889 Dec 24 06:33 download/4343_121724_ds.c0349062305a4e13938dd6f0a6e673e3/4343_121724_S104_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87059134 Dec 24 06:33 download/4343dup_121724_ds.920fac7702b94769bf77138882496269/4343dup_121724_S112_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89963072 Dec 24 06:33 download/4351_121724_ds.223ec71f945942a2838f772179706b31/4351_121724_S114_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89656693 Dec 24 06:33 download/4351dup_121724_ds.f2174ebd76554763a42645e417b0d88b/4351dup_121724_S122_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77273659 Dec 24 06:33 download/4422_121724_ds.98c0760644cf4d8eaed28f075a235806/4422_121724_S182_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81646147 Dec 24 06:33 download/4422dup_121724_ds.7da697d53d4b44e0824f9df0bf4747d4/4422dup_121724_S190_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79917910 Dec 24 06:33 download/4582_121724_ds.7329c3a4fbf94675bfde3fd79e1ef07a/4582_121724_S145_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90494264 Dec 24 06:33 download/4582dup_121724_ds.dfdea61b92a145f1a75b8bd736592196/4582dup_121724_S153_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91952943 Dec 24 06:33 download/464TDF_121724_ds.c553b401ac6345d7b0a06db439e8bb03/464TDF_121724_S71_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82801828 Dec 24 06:33 download/464TDFdup_121724_ds.dcdfcddc830b4640a94f4abbab460e44/464TDFdup_121724_S79_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  70108899 Dec 24 06:33 download/475ULC_121724_ds.64e08c8c43704424a0318e17ca7f98bf/475ULC_121724_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85198380 Dec 24 06:33 download/475ULCdup_121724_ds.ed719fd31db847f7ae02a257cd6ce16e/475ULCdup_121724_S11_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91223998 Dec 24 06:33 download/476ICM_121724_ds.d4264295979540bba556c6243f306660/476ICM_121724_S87_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  83190528 Dec 24 06:33 download/476ICMdup_121724_ds.0d5fa7c2d00d400288f455bc487846a0/476ICMdup_121724_S95_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77701847 Dec 24 06:33 download/477OVU_121724_ds.f1b8804fd759498aa40eb017ffcf5850/477OVU_121724_S5_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79375328 Dec 24 06:33 download/477OVUdup_121724_ds.a7fbf8b27621473faf89a35f8a6df7f1/477OVUdup_121724_S13_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91940854 Dec 24 06:33 download/479JOY_121724_ds.7dd131a717f94b0394e241fef9d8d3ae/479JOY_121724_S56_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 110196161 Dec 24 06:33 download/479JOYdup_121724_ds.c03cea937c3a441e848ded9560cf2f36/479JOYdup_121724_S64_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87490937 Dec 24 06:33 download/687CBI_121724_ds.adae7dc2b8ed48a08fc298ccce893379/687CBI_121724_S20_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90389769 Dec 24 06:33 download/687CBIdup_121724_ds.ddf29ec15ea94519900321bce54583bc/687CBIdup_121724_S28_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86545671 Dec 24 06:33 download/Blank05-1_121724_ds.fc9989170d674dcd85de51f83d869611/Blank05-1_121724_S130_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96622952 Dec 24 06:33 download/Blank05-2_121724_ds.cf139969918e4d7fbae3308405176c43/Blank05-2_121724_S138_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96403599 Dec 24 06:33 download/Blank06-1_121724_ds.159f4b6c97eb47829e3299a8ab9b99f8/Blank06-1_121724_S181_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95217428 Dec 24 06:33 download/Blank06-2_121724_ds.8af9622dadec43a49d79299d6c527616/Blank06-2_121724_S189_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89032775 Dec 24 06:33 download/Blank07-1_121724_ds.478fb2ecf2aa42b3869fc2599d4507cb/Blank07-1_121724_S118_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84695860 Dec 24 06:33 download/Blank07-2_121724_ds.ba042d20694844a385f84576c3e04584/Blank07-2_121724_S126_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96835148 Dec 24 06:33 download/Blank08-1_121724_ds.71c742daff4842adab0728326d55488c/Blank08-1_121724_S135_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  69839546 Dec 24 06:33 download/Blank08-2_121724_ds.3182f5de3404449e8851e7efcf4b3e15/Blank08-2_121724_S143_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93489065 Dec 24 06:33 download/Blank53-1_121724_ds.38271dcb84b44afcafbbd6d86d5afeeb/Blank53-1_121724_S17_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96246617 Dec 24 06:33 download/Blank53-2_121724_ds.30a2b2b60da1439cb1a7c01b668034f2/Blank53-2_121724_S25_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94842216 Dec 24 06:33 download/Blank54-1_121724_ds.f8af7569bb854421b6d75b3e0119099f/Blank54-1_121724_S35_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 106393736 Dec 24 06:33 download/Blank54-2_121724_ds.0fb49a460f1b4303a6e6f0ffce11b787/Blank54-2_121724_S43_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  98165625 Dec 24 06:33 download/Blank55-1_121724_ds.131ab3f9a6fe41e59578ff201f7ba2c8/Blank55-1_121724_S86_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82784383 Dec 24 06:33 download/Blank55-2_121724_ds.bb06e521f00547b283ad9fca43127e0d/Blank55-2_121724_S94_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 113328506 Dec 24 06:33 download/Blank56-1_121724_ds.a8fc2c06036547d39215f5fe6338d0fa/Blank56-1_121724_S7_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97259667 Dec 24 06:33 download/Blank56-2_121724_ds.d61cae147c4c428789f2c40885d1fc76/Blank56-2_121724_S15_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88477969 Dec 24 06:33 download/C664AFO_121724_ds.ea03ed66f5e6497ea8a8d7afe3dd5001/C664AFO_121724_S68_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77307270 Dec 24 06:33 download/C664AFOdup_121724_ds.4a3594cd3e9e4bf9a73b32783534b509/C664AFOdup_121724_S76_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  87037449 Dec 24 06:33 download/C668RVS_121724_ds.b189aa14eacd4d588150347fb4c8c5c6/C668RVS_121724_S40_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94657270 Dec 24 06:33 download/C668RVSdup_121724_ds.07f1c7eaca274ea9a6b54d1020dfbd56/C668RVSdup_121724_S48_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97650020 Dec 24 06:33 download/C669MAC_121724_ds.3b93d36eb346453ca7fb479af21c30b4/C669MAC_121724_S37_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82130832 Dec 24 06:33 download/C669MACdup_121724_ds.0d4011f41cf1435595b8427e6648fa9e/C669MACdup_121724_S45_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94184373 Dec 24 06:33 download/C676WBS_121724_ds.c204a35287cc4f188032b67b4b79f8fc/C676WBS_121724_S84_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86162519 Dec 24 06:33 download/C676WBSdup_121724_ds.c25942acce604b00bef01f5e7736a2e6/C676WBSdup_121724_S92_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88183946 Dec 24 06:33 download/C678IVS_121724_ds.df2e049278924230b4ea3e036c8389cb/C678IVS_121724_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  84552985 Dec 24 06:33 download/C678IVSdup_121724_ds.bb706636732243d9a7554969dbd537dc/C678IVSdup_121724_S9_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82740150 Dec 24 06:33 download/C681VAS_121724_ds.a497abc2e29345c5b2669c8793326f11/C681VAS_121724_S72_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  54116570 Dec 24 06:33 download/C681VASdup_121724_ds.f9ad4bad78a447f98492cbed16889be3/C681VASdup_121724_S80_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93371212 Dec 24 06:33 download/C691AXU_121724_ds.8987e4d6833e4c1c91d4a58f962557ac/C691AXU_121724_S83_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  72393029 Dec 24 06:33 download/C691AXUdup_121724_ds.20c7f5d83fb64ec2af09d5efad1e9997/C691AXUdup_121724_S91_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  63249810 Dec 24 06:33 download/C694UDW_121724_ds.494e9a37d76046eba480e549cb74c82b/C694UDW_121724_S55_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90599102 Dec 24 06:33 download/C694UDWdup_121724_ds.192d7e374c2b4b16b60f1f26288ce0d1/C694UDWdup_121724_S63_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79413655 Dec 24 06:33 download/C698YZG_121724_ds.3f56213bbec843ccbf0f98145a6b078e/C698YZG_121724_S19_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91535365 Dec 24 06:33 download/C698YZGdup_121724_ds.0d38f3cb914143d3b6b017f48b181771/C698YZGdup_121724_S27_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89501457 Dec 24 06:33 download/C710UWE_121724_ds.6483aa91cce04e54b30eaeddd8a5d719/C710UWE_121724_S36_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  97048189 Dec 24 06:33 download/C710UWEdup_121724_ds.f8dcf9b31e674026a20bee806254a45a/C710UWEdup_121724_S44_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  88203586 Dec 24 06:33 download/CSE02-1_121724_ds.d3ff722c25514b7f8b8196124cef273e/CSE02-1_121724_S165_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94350842 Dec 24 06:33 download/CSE02-2_121724_ds.babf6d5da82e4052a562f5e92844cd43/CSE02-2_121724_S173_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  78129331 Dec 24 06:33 download/CSE14-1_121724_ds.7eb31d6adcbc46b1b528ec3d3c1d38b2/CSE14-1_121724_S53_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 103703361 Dec 24 06:33 download/CSE14-2_121724_ds.6a3d26f0dd4b41ebae628831b0abcebc/CSE14-2_121724_S61_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82387437 Dec 24 06:33 download/P133EOG_121724_ds.7fcc4f4322f44ac6be6e5d5f1cff434b/P133EOG_121724_S21_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  93808858 Dec 24 06:33 download/P133EOGdup_121724_ds.48b2ec794dba44b4a46bd84b7415ed03/P133EOGdup_121724_S29_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  90312259 Dec 24 06:33 download/P226MNB_121724_ds.88a65a6a97e44d4bbf3a00f65d41eda1/P226MNB_121724_S33_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 100240476 Dec 24 06:33 download/P226MNBdup_121724_ds.c6dfdd1acfcd477dbbdfc0a8af4c6280/P226MNBdup_121724_S41_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  77843088 Dec 24 06:33 download/P232JCS_121724_ds.8ec46522781940af841a5d97b2d74e6a/P232JCS_121724_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79508661 Dec 24 06:33 download/P232JCSdup_121724_ds.e494fd57cb554a748d7e4f9b80ee6613/P232JCSdup_121724_S10_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  82913400 Dec 24 06:33 download/P292EJT_121724_ds.a82627de31704e3582ed06a200245d63/P292EJT_121724_S88_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  68663949 Dec 24 06:33 download/P292EJTdup_121724_ds.b7860774d9d546bc9a120e277d040c32/P292EJTdup_121724_S96_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  73099368 Dec 24 06:33 download/P339OSS_121724_ds.9fbf68e15e354b00a5a307977faeba54/P339OSS_121724_S54_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  99481749 Dec 24 06:33 download/P339OSSdup_121724_ds.25b58579fd3847ae8e4b779210ac4ef4/P339OSSdup_121724_S62_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  70820025 Dec 24 06:33 download/P360JIS_121724_ds.353286f1218347b0a1e7ebb7b1b12432/P360JIS_121724_S51_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91237104 Dec 24 06:33 download/P360JISdup_121724_ds.835cb48df9be4834aa9dfd0ce66dbe1c/P360JISdup_121724_S59_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  86571260 Dec 24 06:33 download/P362BCP_121724_ds.8730aa718da44026b5c3ca4fc930532d/P362BCP_121724_S24_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  94366035 Dec 24 06:33 download/P362BCPdup_121724_ds.9b16ddffc5d34578a0397ba0bfabeb9b/P362BCPdup_121724_S32_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  96648025 Dec 24 06:33 download/P380MQJ_121724_ds.5898723ecddf430f9d3cad8ebbb1e0ce/P380MQJ_121724_S8_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 106531221 Dec 24 06:33 download/P380MQJdup_121724_ds.af50e43722a04802bf1e426fca36a1de/P380MQJdup_121724_S16_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  55667351 Dec 24 06:33 download/P422DSR_121724_ds.10a039038e584dc89e824dbf4c243409/P422DSR_121724_S49_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  91006249 Dec 24 06:33 download/P422DSRdup_121724_ds.cc6f4bcc0cd44feeb80ccec39230a664/P422DSRdup_121724_S57_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  98322445 Dec 24 06:33 download/P429EMJ_121724_ds.e494ce36e2e44ed6b9d32a08ca01ce5b/P429EMJ_121724_S81_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  95164064 Dec 24 06:33 download/P429EMJdup_121724_ds.da2557caf58b4845a9415f2739be3160/P429EMJdup_121724_S89_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  85994131 Dec 24 06:33 download/PLib02-1_121724_ds.178f5f80c7084109a8fd2a8386075150/PLib02-1_121724_S133_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  89372906 Dec 24 06:33 download/PLib02-2_121724_ds.8aa796e6706b4044b505d6ce4019af52/PLib02-2_121724_S141_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  81065559 Dec 24 06:33 download/PLib14-1_121724_ds.7a85a4b1fb674b24b16ef0c78d442304/PLib14-1_121724_S82_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab  79531977 Dec 24 06:33 download/PLib14-2_121724_ds.fa29644b471a44638d126d6c0464aa78/PLib14-2_121724_S90_L001_R1_001.fastq.gz

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
x=${x%_121724_S*}
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
for z in download/*/*z; do f=$( basename $z _L001_R1_001.fastq.gz ); f=${f/_121724_/,}; echo $f; done | sort -t, -k1,1 > sample_s_number.csv
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




