#!/usr/bin/env bash

awk -F, '(FNR==NR){
  barcodes[$1]++
}
(FNR!=NR){
  if( $1 in barcodes ) {
    print
  }
}' <( ls -1d out/B*_c?_*.salmon.REdiscoverTE.k15 | xargs -I% basename % .salmon.REdiscoverTE.k15 ) mergedAllCells_withCellTypeIdents_CLEAN.filtered.csv > metadata.csv

