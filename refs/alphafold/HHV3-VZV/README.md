
#	alphafold/HHV3-VZV


```

ll /francislab/data1/refs/refseq/viral-20231129/viral.protein/*Human_alphaherpesvirus_3.fa | wc -l
73

```



```

for f in /francislab/data1/refs/refseq/viral-20231129/viral.protein/*Human_alphaherpesvirus_3.fa ; do
b=${f##*/}
b=${b%%.*}
ln -s $f ${b}.faa
done


```



Not sure how much memory or time this will need

```

alphafold_array_wrapper.bash --array 27-73 --time 7-0 --extension .faa --threads 8 *faa

```





Gotta use the exhaustive-search otherwise most don't return alignments

```

~/.local/foldseek/bin/foldseek easy-search NP_040188-?/ranked_?.pdb /francislab/data1/refs/alphafold/server/fold_np_040188_model_0 aln.html tmpFolder --exhaustive-search 1 --format-mode 3

```

A little weird as every alignment is on its own tab.






Try to create the db from all of the fragments and then align the full standard.



