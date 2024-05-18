#!/usr/bin/env bash


shared_genes=$1
shared_res=$2
f=$3

#echo "Gene" > shared_genes
#cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GENEs.CerebellumSelect.GBMWTFirstTumors.shared >> shared_genes
#echo "RE" > shared_res
#cat /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/RE_all.CerebellumSelect.GBMWTFirstTumors.shared >> shared_res

#for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv /francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.CerebellumSelect.correlation.tsv ; do

echo $f
echo "substituting"
cat $f | tr -d \" | tr "\t" \; > tmp1
echo "sorting"
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t\; -k1,1 >> tmp2
echo "joining"
join --header -t\; $shared_genes tmp2 > tmp3
echo "transposing"
cat tmp3 | datamash transpose -t \; > tmp4
echo "sorting"
head -1 tmp4 > tmp5
tail -n +2 tmp4 | sort -t\; -k1,1 >> tmp5
echo "joining"
join --header -t\; $shared_res tmp5 > tmp6
echo "transposing to output"
cat tmp6 | datamash transpose -t \; | tr \; "\t" > $( basename $f .tsv ).shared.tsv


#done

\rm tmp*


