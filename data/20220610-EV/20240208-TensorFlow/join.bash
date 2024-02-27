#!/usr/bin/env bash


kmer_len=18

#for kmer_len in 11 21 31 ; do
echo $kmer_len
i=0

for tsv in kmc_dir/joined.18.normalized.tmp.0.tsv kmc_dir/*.${kmer_len}.normalized.tsv ; do
if [ $i -eq 0 ] ; then
base_tsv=${tsv}
else
echo "Joining ${base_tsv} ${tsv}"
join --header -a1 -a2 -e0 -oauto ${base_tsv} ${tsv} > kmc_dir/joined.${kmer_len}.normalized.tmp.${i}.tsv
base_tsv=kmc_dir/joined.${kmer_len}.normalized.tmp.${i}.tsv
fi
i=$[i+1]
done

sed -i -e 's/ /\t/g' ${base_tsv}
#done
