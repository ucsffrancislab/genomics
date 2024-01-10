#!/usr/bin/env bash


#	sadly this kept quiting on dev3. Probably admin killing it

zcat /francislab/data1/refs/refseq/bacteria-20210916/bacteria.*.*.genomic.fna.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' | gzip > /francislab/data1/refs/refseq/bacteria-20210916/bacteria.genomic.cleaned4.fna.gz



#	zcat *.protein.faa.gz  | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -r -e '/^>/s/_{2,}/_/g' | gzip > fungi.protein.cleaned.faa.gz



