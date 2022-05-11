#!/usr/bin/env bash


#	tail -n +254 out/B1-c1/souporcell/cluster_genotypes.vcf | head
#	1	14464	rs546169444	A	T	100	PASS	AC=480;AF=0.0958466;NS=2504;AN=5008;EAS_AF=0.005;EUR_AF=0.1859;AFR_AF=0.0144;AMR_AF=0.1138;SAS_AF=0.1943;DP=26761;AA=a|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/0:0:5:-8:-14:-1,-18,-4:0,-17,-3	0/0:0:11:-8:-14:-1,-40,-8:0,-39,-7	0/0:0:6:-8:-14:-1,-22,-5:0,-21,-3	0/0:0:3:-8:-14:-1,-11,-3:0,-10,-2	./.:0:0:-8:-14:-1,-1,-1:-1,-1,-1	0/1:5:13:-8:-14:-15,-38,-4:-10,-34,0
#	1	14599	rs531646671	T	A	100	PASS	AC=739;AF=0.147564;NS=2504;AN=5008;EAS_AF=0.0893;EUR_AF=0.161;AFR_AF=0.121;AMR_AF=0.1758;SAS_AF=0.2096;DP=32081;AA=t|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/1:9:4:-17:-30:-28,-13,-3:-24,-9,0	0/1:16:7:-17:-30:-48,-21,-4:-44,-16,0	0/1:9:4:-17:-30:-28,-13,-3:-24,-9,0	1/1:21:0:-17:-30:-79,-1,-15:-78,0,-14	1/1:11:0:-17:-30:-42,-1,-8:-41,0,-7	0/1:9:12:-17:-30:-22,-43,-3:-19,-40,0
#	1	14604	rs541940975	A	G	100	PASS	AC=739;AF=0.147564;NS=2504;AN=5008;EAS_AF=0.0893;EUR_AF=0.161;AFR_AF=0.121;AMR_AF=0.1758;SAS_AF=0.2096;DP=29231;AA=a|||;VT=SNP	GT:AO:RO:T:E:GO:GN	0/1:10:4:-18:-30:-31,-12,-3:-27,-8,0	0/1:16:7:-18:-30:-48,-21,-4:-44,-16,0	0/1:11:3:-18:-30:-36,-9,-4:-31,-4,0	1/1:22:0:-18:-30:-83,-1,-15:-81,0,-14	1/1:11:0:-18:-30:-42,-1,-8:-40,0,-7	0/1:10:12:-18:-30:-25,-43,-3:-22,-40,0
#	1	564598	rs6594028	A	G	100	PASS	AC=1188;AF=0.23722;NS=2504;AN=5008;EAS_AF=0.126;EUR_AF=0.1074;AFR_AF=0.6286;AMR_AF=0.1023;SAS_AF=0.0521;DP=137507;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	1/1:2:0:-13:-20:-8,-1,-2:-7,0,-1	1/1:9:0:-13:-20:-32,-1,-7:-31,0,-5	1/1:168:0:-13:-20:-582,-2,-112:-579,0,-109	1/1:14:1:-13:-20:-46,-3,-8:-43,0,-5	1/1:14:0:-13:-20:-49,-1,-10:-48,0,-9	0/1:8:2:-13:-20:-25,-6,-4:-21,-2,0
#	1	565286	rs1578391	C	T	100	PASS	AC=2960;AF=0.591054;NS=2504;AN=5008;EAS_AF=0.5744;EUR_AF=0.5805;AFR_AF=0.7231;AMR_AF=0.5303;SAS_AF=0.4836;DP=781126;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	0/1:1:1:-2:-5:-4,-4,-1:-2,-3,0	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	./.:0:0:-2:-5:-1,-1,-1:-1,-1,-1	1/1:1:0:-2:-5:-4,-1,-1:-4,0,-1
#	1	565406	rs6594029	C	T	100	PASS	AC=2208;AF=0.440895;NS=2504;AN=5008;EAS_AF=0.4335;EUR_AF=0.4354;AFR_AF=0.5983;AMR_AF=0.3415;SAS_AF=0.3119;DP=164232;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	1/1:1:0:-1:-4:-4,-1,-1:-3,0,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	./.:0:0:-1:-4:-1,-1,-1:-1,-1,-1	1/1:1:0:-1:-4:-4,-1,-1:-3,0,-1
#	1	565697	rs3021087	A	G	100	PASS	AC=1423;AF=0.284145;NS=2504;AN=5008;EAS_AF=0.3353;EUR_AF=0.2753;AFR_AF=0.3896;AMR_AF=0.1844;SAS_AF=0.1687;DP=299103;AA=-|||;VT=SNP	GT:AO:RO:T:E:GO:GN	1/1:1:0:-4:-7:-4,-1,-1:-3,0,-1	1/1:2:0:-4:-7:-7,-1,-2:-7,0,-1	1/1:3:0:-4:-7:-11,-1,-3:-10,0,-2	./.:0:0:-4:-7:-1,-1,-1:-1,-1,-1	1/1:2:0:-4:-7:-7,-1,-2:-7,0,-1	1/1:1:0:-4:-7:-4,-1,-1:-3,0,-1

dir=$( dirname $1 )

#tail -n +254 out/B1-c1/souporcell/cluster_genotypes.vcf | awk 'BEGIN{FS=OFS="\t"}{
tail -n +254 $1 | awk -v d=$dir 'BEGIN{FS=OFS="\t"}{
print $1,$2,$4 > d"/positions"
for(i=0;i<=5;i++){
c=10+i
split($c,a,":")
g=a[1]
#gsub(/\./," ",g)
gsub(/\./,$4,g)
gsub(/0/,$4,g)
gsub(/1/,$5,g)
print $1,$2,g > d"/"i".snps"
}
}'

#	Also there can be 1/2
#	ALT can be XXX,YYY



#	GT : genotype, encoded as allele values separated by either of / or |. The allele values are 0 for the reference
#	allele (what is in the REF field), 1 for the first allele listed in ALT, 2 for the second allele list in ALT and
#	so on. For diploid calls examples could be 0/1, 1 | 0, or 1/2, etc. For haploid calls, e.g. on Y, male nonpseudoautosomal X, or mitochondrion, only one allele value should be given; a triploid call might look like
#	0/0/1. If a call cannot be made for a sample at a given locus, ‘.’ should be specified for each missing allele
#	in the GT field (for example ‘./.’ for a diploid genotype and ‘.’ for haploid genotype). The meanings of the
#	separators are as follows (see the PS field below for more details on incorporating phasing information into the
#	genotypes):
#	◦ / : genotype unphased
#	◦ | : genotype phased


#	These data appear to only be unphased



#	B1_c1
# HMN83551
# HMN83552
# HMN83553
# HMN83554
# HMN83558
# HMN83559


#	bcftools merge out/B1-c1/souporcell/cluster_genotypes.vcf out/HMN83551.call.vcf.gz
#	Failed to open out/B1-c1/souporcell/cluster_genotypes.vcf: not compressed with bgzip


