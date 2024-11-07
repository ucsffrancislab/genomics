#!/usr/bin/env bash

f=$1


#for f in GENE_x_RE_all.GBMWTFirstTumors.correlation.shared.tsv GENE_x_RE_all.CerebellumSelect.correlation.shared.tsv ; do 

echo $f

awk -F"\t" '(NR==1){header=$0;c=0;i=1;n=sprintf("%03d",i);print header > FILENAME"."n}(NR>1){
if( c >= 1000 ){
c=0;i++;n=sprintf("%03d",i);
print header > FILENAME"."n
}
c++;print >> FILENAME"."n
}' $f

