

The fastq files were renamed as links to suit the cellranger expectations.

```
ls -1 /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1*
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L001_R1_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L001_R2_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L002_R1_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L002_R2_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L003_R1_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L003_R2_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L004_R1_001.fastq.gz
/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq/B1-c1-10X_S0_L004_R2_001.fastq.gz
```


cellranger was run (using hg18/GRCh37 because the WGS was with hg19)


```
basename="B1-c1"

cellranger count \
	--id ${basename} \
	--sample ${basename}-10X \
	--fastqs ${IN} \
	--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select_iav \
	--localcores 16 \
	--localmem 120 \
	--localvmem 120
```

souporcell was run

```
basename="B1-c1"


singularity exec --bind /francislab /francislab/data1/refs/singularity/souporcell_latest.sif souporcell_pipeline.py \
	--bam ${OUT}/${basename}/outs/possorted_genome_bam.bam \
	--barcodes ${OUT}/${basename}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
	--fasta /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select.fa \
	--common_variants /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/common_variants_hg19.vcf \
	--threads 16 \
	--out_dir ${outbase} \
	--skip_remap True \
	--clusters 6
```






From ... https://samtools.github.io/hts-specs/VCFv4.1.pdf

GT : genotype, encoded as allele values separated by either of / or |. The allele values are 0 for the reference allele (what is in the REF field), 1 for the first allele listed in ALT, 2 for the second allele list in ALT and so on. For diploid calls examples could be 0/1, 1 | 0, or 1/2, etc. For haploid calls, e.g. on Y, male nonpseudoautosomal X, or mitochondrion, only one allele value should be given; a triploid call might look like 0/0/1. If a call cannot be made for a sample at a given locus, ‘.’ should be specified for each missing allele in the GT field (for example ‘./.’ for a diploid genotype and ‘.’ for haploid genotype). The meanings of the separators are as follows (see the PS field below for more details on incorporating phasing information into the genotypes):
* / : genotype unphased
* | : genotype phased



Generating `out/B1-c1/souporcell/cluster_genotypes.vcf`

```
grep -vs "^#" out/B1-c1/souporcell/cluster_genotypes.vcf | head
1	14464	rs546169444	A	T	100	PASS	AC=480;AF=0.0958466;NS=2504;AN=5008;EAS_AF=0.005;EUR_AF=0.1859;AFR_AF=0.0144;AMR_AF=0.1138;SAS_AF=0.1943;DP=26761;AA=a|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/0:0:5:-8:-14:-1,-18,-4:0,-17,-3	0/0:0:11:-8:-14:-1,-40,-8:0,-39,-7	0/0:0:6:-8:-14:-1,-22,-5:0,-21,-3	0/0:0:3:-8:-14:-1,-11,-3:0,-10,-2	./.:0:0:-8:-14:-1,-1,-1:-1,-1,-1	0/1:5:13:-8:-14:-15,-38,-4:-10,-34,0
1	14599	rs531646671	T	A	100	PASS	AC=739;AF=0.147564;NS=2504;AN=5008;EAS_AF=0.0893;EUR_AF=0.161;AFR_AF=0.121;AMR_AF=0.1758;SAS_AF=0.2096;DP=32081;AA=t|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/1:9:4:-17:-30:-28,-13,-3:-24,-9,0	0/1:16:7:-17:-30:-48,-21,-4:-44,-16,0	0/1:9:4:-17:-30:-28,-13,-3:-24,-9,0	1/1:21:0:-17:-30:-79,-1,-15:-78,0,-14	1/1:11:0:-17:-30:-42,-1,-8:-41,0,-7	0/1:9:12:-17:-30:-22,-43,-3:-19,-40,0
1	14604	rs541940975	A	G	100	PASS	AC=739;AF=0.147564;NS=2504;AN=5008;EAS_AF=0.0893;EUR_AF=0.161;AFR_AF=0.121;AMR_AF=0.1758;SAS_AF=0.2096;DP=29231;AA=a|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/1:10:4:-18:-30:-31,-12,-3:-27,-8,0	0/1:16:7:-18:-30:-48,-21,-4:-44,-16,0	0/1:11:3:-18:-30:-36,-9,-4:-31,-4,0	1/1:22:0:-18:-30:-83,-1,-15:-81,0,-14	1/1:11:0:-18:-30:-42,-1,-8:-40,0,-7	0/1:10:12:-18:-30:-25,-43,-3:-22,-40,0
1	564598	rs6594028	A	G	100	PASS	AC=1188;AF=0.23722;NS=2504;AN=5008;EAS_AF=0.126;EUR_AF=0.1074;AFR_AF=0.6286;AMR_AF=0.1023;SAS_AF=0.0521;DP=137507;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	1/1:2:0:-13:-20:-8,-1,-2:-7,0,-1	1/1:9:0:-13:-20:-32,-1,-7:-31,0,-5	1/1:168:0:-13:-20:-582,-2,-112:-579,0,-109	1/1:14:1:-13:-20:-46,-3,-8:-43,0,-5	1/1:14:0:-13:-20:-49,-1,-10:-48,0,-9	0/1:8:2:-13:-20:-25,-6,-4:-21,-2,0
1	565286	rs1578391	C	T	100	PASS	AC=2960;AF=0.591054;NS=2504;AN=5008;EAS_AF=0.5744;EUR_AF=0.5805;AFR_AF=0.7231;AMR_AF=0.5303;SAS_AF=0.4836;DP=781126;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	0/1:1:1:-2:-5:-4,-4,-1:-2,-3,0	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	1/1:1:0:-2:-5:-4,-1,-1:-4,0,-1
1	565406	rs6594029	C	T	100	PASS	AC=2208;AF=0.440895;NS=2504;AN=5008;EAS_AF=0.4335;EUR_AF=0.4354;AFR_AF=0.5983;AMR_AF=0.3415;SAS_AF=0.3119;DP=164232;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	1/1:1:0:-1:-4:-4,-1,-1:-3,0,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	1/1:1:0:-1:-4:-4,-1,-1:-3,0,-1
1	565697	rs3021087	A	G	100	PASS	AC=1423;AF=0.284145;NS=2504;AN=5008;EAS_AF=0.3353;EUR_AF=0.2753;AFR_AF=0.3896;AMR_AF=0.1844;SAS_AF=0.1687;DP=299103;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	1/1:1:0:-4:-7:-4,-1,-1:-3,0,-1	1/1:2:0:-4:-7:-7,-1,-2:-7,0,-1	1/1:3:0:-4:-7:-11,-1,-3:-10,0,-2	./.:0:0:-4:-7:-1,-1,-1:-1,-1,-1	1/1:2:0:-4:-7:-7,-1,-2:-7,0,-1	1/1:1:0:-4:-7:-4,-1,-1:-3,0,-1
1	566371	rs1832731	A	G	100	PASS	AC=101;AF=0.0201677;NS=2504;AN=5008;EAS_AF=0.0069;EUR_AF=0.004;AFR_AF=0.0628;AMR_AF=0.0043;SAS_AF=0.0041;DP=26473;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/0:0:3:-13:-14:-1,-11,-3:0,-10,-2	0/0:0:9:-13:-14:-1,-32,-7:0,-31,-5	0/0:1:14:-13:-14:-3,-47,-8:0,-44,-5	0/0:0:14:-13:-14:-1,-50,-10:0,-48,-9	0/0:1:8:-13:-14:-3,-26,-4:0,-23,-1	0/0:1:14:-13:-14:-3,-47,-8:0,-44,-5
1	567697	rs1972379	G	A	100	PASS	AC=860;AF=0.171725;NS=2504;AN=5008;EAS_AF=0.1746;EUR_AF=0.1849;AFR_AF=0.2511;AMR_AF=0.1052;SAS_AF=0.0951;DP=505996;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/1:1:1:-9:-12:-4,-5,-1:-2,-3,0	./.:0:0:-9:-12:-1,-1,-1:-1,-1,-1	1/1:6:1:-9:-12:-20,-3,-3:-17,0,0	1/1:6:1:-9:-12:-20,-3,-3:-17,0,0	1/1:1:0:-9:-12:-4,-1,-1:-4,0,-1	1/1:6:0:-9:-12:-22,-1,-5:-21,0,-3
1	567726	rs560688216	T	C	100	PASS	AC=237;AF=0.0473243;NS=2504;AN=5008;EAS_AF=0.0;EUR_AF=0.0;AFR_AF=0.1717;AMR_AF=0.0086;SAS_AF=0.0041;DP=548720;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/0:0:3:-5:-27:-1,-12,-3:0,-11,-2	./.:0:0:-5:-27:-1,-1,-1:-1,-1,-1	1/1:11:0:-5:-27:-49,-1,-8:-48,0,-7	0/0:0:6:-5:-27:-1,-24,-5:0,-23,-4	0/0:0:2:-5:-27:-1,-8,-2:0,-8,-1	0/0:0:7:-5:-27:-1,-28,-5:0,-27,-4
```


Notice that many samples have the "uncalled" genotype of `./.`. 
I chose to treat this the same as `0/0`. 
It is not necessarily correct, but it is what I did.




bcftools on all WGS

```
bcftools mpileup --output-type u --fasta-ref /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select.fa ${bam} | bcftools call  --output-type z --output ${f} --multiallelic-caller --variants-only 
```


out/HMN83551.call.vcf.gz


```
zcat out/HMN83551.call.vcf.gz | grep -vs "^#" | head
1	13116	.	T	G	25.2483	.	DP=7;VDB=0.311141;SGB=-0.616816;RPBZ=1;MQBZ=0.83666;MQSBZ=0.83666;BQBZ=1.87083;SCBZ=0;FS=0;MQ0F=0.571429;AC=2;AN=2;DP4=1,0,0,6;MQ=10	GT:PL	1/1:52,12,0
1	13118	.	A	G	25.2483	.	DP=7;VDB=0.311141;SGB=-0.616816;RPBZ=1;MQBZ=0.83666;MQSBZ=0.83666;BQBZ=1.03775;SCBZ=0;FS=0;MQ0F=0.571429;AC=2;AN=2;DP4=1,0,0,6;MQ=10	GT:PL	1/1:52,12,0
1	14907	.	A	G	65.9607	.	DP=12;VDB=0.999583;SGB=-0.651104;RPBZ=-0.255658;MQBZ=0.511316;MQSBZ=-2.00864;BQBZ=-1.43614;SCBZ=0;FS=0;MQ0F=0.166667;AC=1;AN=2;DP4=1,3,5,3;MQ=22	GT:PL	0/1:99,0,47
1	14930	.	A	G	44.6028	.	DP=6;VDB=0.202231;SGB=-0.556411;RPBZ=-1.85164;MQBZ=0.92582;MQSBZ=-1.96396;BQBZ=0;SCBZ=0;FS=0;MQ0F=0;AC=1;AN=2;DP4=0,2,3,1;MQ=29	GT:PL	0/1:78,0,23
1	15118	.	A	G	41.5989	.	DP=10;VDB=0.15244;SGB=-0.636426;RPBZ=1.48149;MQBZ=1.04482;MQSBZ=-0.348273;BQBZ=0;SCBZ=0;FS=0;MQ0F=0.3;AC=1;AN=2;DP4=1,2,2,5;MQ=14	GT:PL	0/1:73,0,7
1	15211	.	T	G	137.29	.	DP=13;VDB=0.0894615;SGB=-0.676189;RPBZ=-0.789542;MQBZ=1.81165;MQSBZ=2.01533;BQBZ=1.25336;SCBZ=0;FS=0;MQ0F=0.307692;AC=2;AN=2;DP4=2,0,6,5;MQ=20	GT:PL	1/1:164,20,0
1	15274	.	A	T	88.4196	.	DP=9;VDB=0.83311;SGB=-0.651104;MQSBZ=0.734931;FS=0;MQ0F=0.222222;AC=2;AN=2;DP4=0,0,4,4;MQ=20	GT:PL	1/1:118,21,0
1	16068	.	T	C	15.5373	.	DP=3;VDB=0.996597;SGB=-0.511536;FS=0;MQ0F=0;AC=2;AN=2;DP4=0,0,3,0;MQ=17	GT:PL	1/1:45,9,0
1	16103	.	T	G	29.4193	.	DP=5;VDB=0.233642;SGB=-0.590765;FS=0;MQ0F=0.2;AC=2;AN=2;DP4=0,0,5,0;MQ=17	GT:PL	1/1:59,15,0
1	16378	.	T	C	150.241	.	DP=26;VDB=0.0404417;SGB=-0.692562;RPBZ=-1.70707;MQBZ=2.0243;MQSBZ=0.856182;BQBZ=0.970836;SCBZ=0;FS=0;MQ0F=0.5;AC=2;AN=2;DP4=3,1,14,8;MQ=13	GT:PL	1/1:177,37,0
```




manually extracted genotypes from cluster_genotypes.vcf into individual files as well as just positions with reference value
with `souporcell_cluster_genotypes_to_SNP_lists.bash`


```
b=1
c=1
./souporcell_cluster_genotypes_to_SNP_lists.bash out/B${b}-c${c}/souporcell/cluster_genotypes.vcf

out/B1-c1/souporcell/0.snps
out/B1-c1/souporcell/1.snps
out/B1-c1/souporcell/2.snps
out/B1-c1/souporcell/3.snps
out/B1-c1/souporcell/4.snps
out/B1-c1/souporcell/5.snps


head out/B1-c1/souporcell/0.snps
1	14464	A/A
1	14599	T/A
1	14604	A/G
1	564598	G/G
1	565286	C/C
1	565406	C/C
1	565697	G/G
1	566371	A/A
1	567697	G/A
1	567726	T/T


out/B1-c1/souporcell/positions

head out/B1-c1/souporcell/positions
1	14464	A
1	14599	T
1	14604	A
1	564598	A
1	565286	C
1	565406	C
1	565697	A
1	566371	A
1	567697	G
1	567726	T
```



manually extracted the genotypes from the WGS vcfs for subject in batch for the souporcell selected positions with `extract`.


```
b=1
c=1
for s in $( grep "B${b}_c${c}" metadata.csv | awk -F, '{print $2}' ) ; do
./extract -v=out/${s}.call.vcf.gz -p=out/B${b}-c${c}/souporcell/positions > out/B${b}-c${c}/souporcell/${s}.snps
done

out/B1-c1/souporcell/HMN83551.snps
out/B1-c1/souporcell/HMN83552.snps
out/B1-c1/souporcell/HMN83553.snps
out/B1-c1/souporcell/HMN83554.snps
out/B1-c1/souporcell/HMN83558.snps
out/B1-c1/souporcell/HMN83559.snps


head out/B1-c1/souporcell/HMN83551.snps
1	14464	A/A
1	14599	T/T
1	14604	A/A
1	564598	A/A
1	565286	C/C
1	565406	C/C
1	565697	A/A
1	566371	A/A
1	567697	G/G
1	567726	T/T

```


Not all of the variant positions found in the souporcell exist in the WGS VCF files.
Those not found were treated the same as `0/0` or the reference value.
Again, not sure if this is the correct technique, but it is what I did.


Each of these unknown sample genotype snps files was compared to the know WGS genotype snps files with a simple `sdiff -s` which only outputs differing lines, which were counted.


```
b=1
c=1
for i in 0 1 2 3 4 5 ; do
for s in $( grep "B${b}_c${c}" metadata.csv | awk -F, '{print $2}' ) ; do
echo -n "${i} - ${s} - "
sdiff -s out/B${b}-c${c}/souporcell/${i}.snps out/B${b}-c${c}/souporcell/${s}.snps | wc -l
done ; echo ; done


0 - HMN83551 - 100030
0 - HMN83552 - 100433
0 - HMN83553 - 99999
0 - HMN83554 - 99930
0 - HMN83558 - 95317    <------
0 - HMN83559 - 99709

1 - HMN83551 - 101335
1 - HMN83552 - 97523    <------
1 - HMN83553 - 101322
1 - HMN83554 - 101045
1 - HMN83558 - 102788
1 - HMN83559 - 103070

2 - HMN83551 - 107713
2 - HMN83552 - 107764
2 - HMN83553 - 107287
2 - HMN83554 - 107450
2 - HMN83558 - 106721
2 - HMN83559 - 102406    <------

3 - HMN83551 - 98751    <------
3 - HMN83552 - 103141
3 - HMN83553 - 103013
3 - HMN83554 - 102876
3 - HMN83558 - 104362
3 - HMN83559 - 104787

4 - HMN83551 - 99317
4 - HMN83552 - 99320
4 - HMN83553 - 95212    <------
4 - HMN83554 - 99019
4 - HMN83558 - 100600
4 - HMN83559 - 100635

5 - HMN83551 - 90376
5 - HMN83552 - 90523
5 - HMN83553 - 90370
5 - HMN83554 - 87220    <------
5 - HMN83558 - 91637
5 - HMN83559 - 92056

```


So far, after comparing 8 of the 30 batches, the least differences have all been unique.





```

B1 c1
0 - HMN83551 - 100030
0 - HMN83552 - 100433
0 - HMN83553 - 99999
0 - HMN83554 - 99930
0 - HMN83558 - 95317     <-----
0 - HMN83559 - 99709

1 - HMN83551 - 101335
1 - HMN83552 - 97523     <-----
1 - HMN83553 - 101322
1 - HMN83554 - 101045
1 - HMN83558 - 102788
1 - HMN83559 - 103070

2 - HMN83551 - 107713
2 - HMN83552 - 107764
2 - HMN83553 - 107287
2 - HMN83554 - 107450
2 - HMN83558 - 106721
2 - HMN83559 - 102406     <-----

3 - HMN83551 - 98751     <-----
3 - HMN83552 - 103141
3 - HMN83553 - 103013
3 - HMN83554 - 102876
3 - HMN83558 - 104362
3 - HMN83559 - 104787

4 - HMN83551 - 99317
4 - HMN83552 - 99320
4 - HMN83553 - 95212     <-----
4 - HMN83554 - 99019
4 - HMN83558 - 100600
4 - HMN83559 - 100635

5 - HMN83551 - 90376
5 - HMN83552 - 90523
5 - HMN83553 - 90370
5 - HMN83554 - 87220     <-----
5 - HMN83558 - 91637
5 - HMN83559 - 92056

B1 c2
0 - HMN83551 - 96227
0 - HMN83552 - 96366
0 - HMN83553 - 92219     <-----
0 - HMN83554 - 96021
0 - HMN83558 - 97734
0 - HMN83559 - 97836

1 - HMN83551 - 101414
1 - HMN83552 - 101717
1 - HMN83553 - 101506
1 - HMN83554 - 97806     <-----
1 - HMN83558 - 103028
1 - HMN83559 - 103305

2 - HMN83551 - 114411
2 - HMN83552 - 109850     <-----
2 - HMN83553 - 114462
2 - HMN83554 - 114272
2 - HMN83558 - 116298
2 - HMN83559 - 116321

3 - HMN83551 - 97706     <-----
3 - HMN83552 - 102203
3 - HMN83553 - 101964
3 - HMN83554 - 101792
3 - HMN83558 - 103463
3 - HMN83559 - 103768

4 - HMN83551 - 113548
4 - HMN83552 - 113994
4 - HMN83553 - 113575
4 - HMN83554 - 113544
4 - HMN83558 - 108219     <-----
4 - HMN83559 - 113139

5 - HMN83551 - 111054
5 - HMN83552 - 111330
5 - HMN83553 - 110718
5 - HMN83554 - 110933
5 - HMN83558 - 110405
5 - HMN83559 - 105715     <-----

B2 c1
0 - HMN83556 - 90294
0 - HMN83560 - 90056
0 - HMN83561 - 90289
0 - HMN83562 - 86134     <-----
0 - HMN83555 - 90065
0 - HMN83557 - 90172

1 - HMN83556 - 93147
1 - HMN83560 - 92857
1 - HMN83561 - 92340
1 - HMN83562 - 92862
1 - HMN83555 - 87477     <-----
1 - HMN83557 - 91224

2 - HMN83556 - 102978
2 - HMN83560 - 98144     <-----
2 - HMN83561 - 102719
2 - HMN83562 - 102544
2 - HMN83555 - 102841
2 - HMN83557 - 102841

3 - HMN83556 - 100702
3 - HMN83560 - 100435
3 - HMN83561 - 99830
3 - HMN83562 - 100458
3 - HMN83555 - 98796
3 - HMN83557 - 94947     <-----

4 - HMN83556 - 117458     <-----
4 - HMN83560 - 122899
4 - HMN83561 - 122892
4 - HMN83562 - 122648
4 - HMN83555 - 123136
4 - HMN83557 - 123173

5 - HMN83556 - 96478
5 - HMN83560 - 96377
5 - HMN83561 - 92378     <-----
5 - HMN83562 - 96360
5 - HMN83555 - 95815
5 - HMN83557 - 95840

B2 c2
0 - HMN83556 - 81478
0 - HMN83560 - 81287
0 - HMN83561 - 80992
0 - HMN83562 - 81589
0 - HMN83555 - 79963
0 - HMN83557 - 76826     <-----

1 - HMN83556 - 93402
1 - HMN83560 - 93214
1 - HMN83561 - 89356     <-----
1 - HMN83562 - 93596
1 - HMN83555 - 92914
1 - HMN83557 - 92804

2 - HMN83556 - 83362
2 - HMN83560 - 79480     <-----
2 - HMN83561 - 83320
2 - HMN83562 - 83255
2 - HMN83555 - 83308
2 - HMN83557 - 83261

3 - HMN83556 - 89812
3 - HMN83560 - 89626
3 - HMN83561 - 89996
3 - HMN83562 - 85677     <-----
3 - HMN83555 - 89852
3 - HMN83557 - 89945

4 - HMN83556 - 97258     <-----
4 - HMN83560 - 101630
4 - HMN83561 - 101942
4 - HMN83562 - 101675
4 - HMN83555 - 101989
4 - HMN83557 - 101941

5 - HMN83556 - 85867
5 - HMN83560 - 85759
5 - HMN83561 - 85343
5 - HMN83562 - 85909
5 - HMN83555 - 80766     <-----
5 - HMN83557 - 84219

B3 c1
0 - HMN83565 - 68140
0 - HMN83568 - 65881     <-----
0 - HMN83569 - 68347
0 - HMN83570 - 68106
0 - HMN83564 - 69117
0 - HMN83567 - 69288

1 - HMN83565 - 75609
1 - HMN83568 - 75888
1 - HMN83569 - 72885     <-----
1 - HMN83570 - 75592
1 - HMN83564 - 76545
1 - HMN83567 - 76799

2 - HMN83565 - 67174
2 - HMN83568 - 67423
2 - HMN83569 - 67409
2 - HMN83570 - 67250
2 - HMN83564 - 64544     <-----
2 - HMN83567 - 67503

3 - HMN83565 - 79498
3 - HMN83568 - 79702
3 - HMN83569 - 79549
3 - HMN83570 - 79553
3 - HMN83564 - 79410
3 - HMN83567 - 76112     <-----

4 - HMN83565 - 57977     <-----
4 - HMN83568 - 60352
4 - HMN83569 - 60327
4 - HMN83570 - 60116
4 - HMN83564 - 61055
4 - HMN83567 - 61338

5 - HMN83565 - 57574
5 - HMN83568 - 57821
5 - HMN83569 - 57848
5 - HMN83570 - 55827     <-----
5 - HMN83564 - 58533
5 - HMN83567 - 58737

B3 c2
0 - HMN83565 - 66219     <-----
0 - HMN83568 - 69005
0 - HMN83569 - 68886
0 - HMN83570 - 68637
0 - HMN83564 - 69694
0 - HMN83567 - 69934

1 - HMN83565 - 68549
1 - HMN83568 - 69060
1 - HMN83569 - 68939
1 - HMN83570 - 66453     <-----
1 - HMN83564 - 69563
1 - HMN83567 - 69899

2 - HMN83565 - 74532
2 - HMN83568 - 75013
2 - HMN83569 - 74862
2 - HMN83570 - 74829
2 - HMN83564 - 71683     <-----
2 - HMN83567 - 74857

3 - HMN83565 - 89433
3 - HMN83568 - 89760
3 - HMN83569 - 89541
3 - HMN83570 - 89403
3 - HMN83564 - 89238
3 - HMN83567 - 85648     <-----

4 - HMN83565 - 82493
4 - HMN83568 - 79900     <-----
4 - HMN83569 - 82955
4 - HMN83570 - 82596
4 - HMN83564 - 83496
4 - HMN83567 - 83903

5 - HMN83565 - 87026
5 - HMN83568 - 87462
5 - HMN83569 - 84102     <-----
5 - HMN83570 - 87249
5 - HMN83564 - 88104
5 - HMN83567 - 88335

B4 c1
0 - HMN83563 - 99436
0 - HMN83566 - 99478
0 - HMN83571 - 95212     <-----
0 - HMN83572 - 99203
0 - HMN83575 - 99277
0 - HMN83576 - 99854

1 - HMN83563 - 69532
1 - HMN83566 - 69708
1 - HMN83571 - 69540
1 - HMN83572 - 68506
1 - HMN83575 - 65470     <-----
1 - HMN83576 - 68521

2 - HMN83563 - 94996     <-----
2 - HMN83566 - 98907
2 - HMN83571 - 99043
2 - HMN83572 - 98708
2 - HMN83575 - 98828
2 - HMN83576 - 99180

3 - HMN83563 - 96922
3 - HMN83566 - 97060
3 - HMN83571 - 97184
3 - HMN83572 - 95981
3 - HMN83575 - 95097
3 - HMN83576 - 91631     <-----

4 - HMN83563 - 88067
4 - HMN83566 - 88210
4 - HMN83571 - 88114
4 - HMN83572 - 84007     <-----
4 - HMN83575 - 87094
4 - HMN83576 - 87584

5 - HMN83563 - 93174
5 - HMN83566 - 89521     <-----
5 - HMN83571 - 93459
5 - HMN83572 - 93146
5 - HMN83575 - 93358
5 - HMN83576 - 93668

B4 c2
0 - HMN83563 - 80360
0 - HMN83566 - 76938     <-----
0 - HMN83571 - 80589
0 - HMN83572 - 80623
0 - HMN83575 - 80836
0 - HMN83576 - 80982

1 - HMN83563 - 59507
1 - HMN83566 - 59801
1 - HMN83571 - 59550
1 - HMN83572 - 58769
1 - HMN83575 - 56006     <-----
1 - HMN83576 - 58600

2 - HMN83563 - 76746
2 - HMN83566 - 77036
2 - HMN83571 - 76938
2 - HMN83572 - 76220
2 - HMN83575 - 75504
2 - HMN83576 - 72459     <-----

3 - HMN83563 - 73698     <-----
3 - HMN83566 - 76906
3 - HMN83571 - 76999
3 - HMN83572 - 76835
3 - HMN83575 - 76940
3 - HMN83576 - 77118

4 - HMN83563 - 81172
4 - HMN83566 - 81371
4 - HMN83571 - 81058
4 - HMN83572 - 77331     <-----
4 - HMN83575 - 80531
4 - HMN83576 - 80800

5 - HMN83563 - 74527
5 - HMN83566 - 74633
5 - HMN83571 - 71139     <-----
5 - HMN83572 - 74408
5 - HMN83575 - 74359
5 - HMN83576 - 74715


```
