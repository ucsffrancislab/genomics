#!/usr/bin/env bash

module load samtools


#	awk '{print "##contig=<ID="$1",length="$2">"}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa.fai

cat $1



#CHR	POS	MEI Type	1kGP2504_AF	1kGP698_AF	Amish_AF	JHS_AF	GTEx100bp_AF	GTEx150bp_AF	UKBB50k_AF	LGG-01_AF	LGG-01_AFLGG-01_AF	LGG-01_AF	LGG-02_AF	LGG-02_AF	LGG-02_AF	LGG-02_AF	LGG-10_AF	LGG-10_AF	LGG-10_AF	LGG-10_AF	GBM-01_AF	GBM-01_AF	GBM-01_AF	GBM-01_AF	GBM-02_AF	GBM-02_AF	GBM-02_AF	GBM-02_AF	GBM-10_AF	GBM-10_AF	GBM-10_AFGBM-10_AF
#1	52027	ALU	.	.	.	.	.	.	.	0.198864	.	.	.	0	.	.	.	0.226744	0.030302999999999997	.	.	.	0.0555556	.	.	.	0.0588235	.	.	.



#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	02-2483-10A-01D-1494

awk 'BEGIN{FS=OFS="\t"}
(NR==1){
	line="#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT"
	for (i=5;i<=NF;i++){
		line=line"\t"$i
	}
	print line
}
(NR>1){

	cmd="samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa chr"$1":"$2"-"$2" | tail -1"
	cmd | getline ref
	close(cmd)

	line=$1"\t"$2"\t.\t"ref"\t<INS:ME:"$3">\t.\tPASS\tSVTYPE="$3"\tAF"
	for (i=5;i<=NF;i++){
		line=line"\t"$i
	}
	print line

}' $2


## example chr1	1643221	.	a	<INS:ME:SVA>	.	PASS	TSD=null;ASSESS=2;INTERNAL=NM_033486,INTRONIC;SVTYPE=SVA;SVLEN=273;MEINFO=SVA,1042,1315,+;DIFF=0.14:n1-1041,a1053g,g1067a,a1079g,c1129g,c1146a,c1163a,c1164t,t1267c,g1268a,g1310t;LP=1;RP=11;RA=-3.459;PRIOR=false;SR=0;AC=37;AN=68;AF=0.544118	GT:GL:DP:AD	0/1:-45.3,-33.72,-75.6:56:0	0/1:-22.25,-19.27,-41.1:32:0	1/1:-50.36,-30.71,-28.2:51:2	0/1:-40.27,-27.09,-46.2:45:0	0/1:-46.69,-27.09,-39.3:45:0	0/1:-37.99,-24.08,-34.2:40:0	0/1:-52.29,-36.12,-54:60:0	0/1:-73.94,-42.75,-51.4:71:0	0/1:-49.02,-28.3,-28.8:47:0	0/1:-46.55,-28.9,-31.8:48:0	0/1:-39.2,-24.68,-35.7:41:0	0/1:-41.38,-27.09,-32.8:45:0	0/1:-36.96,-24.68,-42:41:0	0/1:-44.76,-27.69,-42.8:46:0	0/1:-29.36,-19.87,-22:33:0/1:-28.28,-23.48,-54.6:39:0	0/1:-44.22,-25.29,-25.8:42:2	0/1:-59.54,-42.75,-53.4:71:0	0/1:-45.63,-31.91,-58.8:53:0	0/1:-52.65,-41.54,-61.5:69:0	0/1:-55.4,-34.92,-39.2:58:0	0/1:-45.65,-29.5,-49.2:49:0	0/1:-45.7,-33.11,-61.9:55:0	0/1:-47.88,-34.92,-54.6:58:0	0/1:-54.95,-39.13,-48.6:65:0	0/1:-38.69,-23.48,-35.4:39:2	0/1:-60.59,-37.33,-43.6:62:0	0/1:-54.87,-34.92,-60.5:58:0	0/1:-34.82,-26.49,-46.6:44:0	1/1:-37.86,-23.48,-21.8:39:0	0/1:-41.42,-24.68,-43.4:41:0	0/1:-38.65,-27.69,-44.4:46:0	1/1:-55.72,-31.31,-24.4:52:0	0/1:-62.95,-43.35,-66.2:72:0


#	IGV doesn't display the AFs for "individual samples" as I had hoped.
#	Seems it would only do this for a variant as a whole.
#	Gonna have to make a heatmap of some sort, but its gonna be HUGE.


