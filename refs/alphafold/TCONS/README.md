
#	alphafold/TCONS



```

ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-???.fa | wc -l
2090
ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-??.fa | wc -l
462
ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-?.fa | wc -l
26

```


```

for f in /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-???.fa \
  /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-??.fa \
  /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-?.fa ; do
ln $f
done

```



```

alphafold_array_wrapper.bash --time 14-0 --threads 8 --extension .fa TCONS_????????-?.fa


```


```

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/TCONS/TCONS_00000820-9/ranked_0.pdb /francislab/data1/refs/alphafold/HHV3-VZV/VZV/VZV aln tmpFolder --exhaustive-search 1

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/TCONS/TCONS_00000820-9/ranked_0.pdb /francislab/data1/refs/alphafold/HHV3-VZV/VZV/VZV aln.html tmpFolder --exhaustive-search 1 --format-mode 3


~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/TCONS/TCONS_*/ranked_0.pdb /francislab/data1/refs/alphafold/HHV3-VZV/VZV/VZV aln.html tmpFolder --format-mode 3

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/TCONS/TCONS_*/ranked_0.pdb /francislab/data1/refs/alphafold/HHV3-VZV/VZV/VZV aln.exhaustive.html tmpFolder --exhaustive-search 1 --format-mode 3

```




```
mkdir links
cd links
for f in ../TCONS_????????-*/ranked_?.pdb ; do echo $f ; d=$( basename $( dirname $f )); b=${f%%.pdb};b=${b##*/ranked_}; echo ${d}-${b}.pdb; ln -s $f ${d}-${b}.pdb ; done
cd ..
~/.local/foldseek/bin/foldseek createdb links/*pdb TCONS

```



