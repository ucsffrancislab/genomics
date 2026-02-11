#!/usr/bin/env bash

#for model in PGS000342 PGS000199 PGS000021 PGS000004 PGS000005 PGS000007 PGS000008 PGS000001 PGS004591 PGS003135 ; do
for model in PGS000342 PGS000199 PGS000021 PGS000004 PGS000005 ; do

    echo -n "$model: "
    total_used=0
    total_variants=0
    for chr in {1..22}; do
        used=$(grep "^${model}," pgs-calc-scores/cidr/chr${chr}.scores.csv 2>/dev/null | cut -d',' -f3)
        total=$(grep "^${model}," pgs-calc-scores/cidr/chr${chr}.scores.csv 2>/dev/null | cut -d',' -f4)
        total_used=$((total_used + used))
        total_variants=$total  # This will be the same for all chrs
    done
    echo "${total_used} / ${total_variants} ($(awk "BEGIN {printf \"%.1f\", ${total_used}/${total_variants}*100}")%)"
done


