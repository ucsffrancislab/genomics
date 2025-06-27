#!/usr/bin/env bash


pgs-calc create-collection --out=hg19.collection.txt.gz PGS??????.txt.gz

module load htslib
tabix -p vcf hg19.collection.txt.gz

chmod -w hg19.collection.txt.gz hg19.collection.txt.gz.info hg19.collection.txt.gz.tbi


