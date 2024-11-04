
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



```

for f in ../NP_040188-?/ranked_?.pdb ; do echo $f ; d=$( basename $( dirname $f )); b=${f%%.pdb};b=${b##*/ranked_}; echo ${d}-${b}.pdb; ln -s $f ${d}-${b}.pdb ; done

~/.local/foldseek/bin/foldseek createdb NP_040188*pdb NP_040188_parts

for f in ../??_??????/ranked_?.pdb ; do echo $f ; d=$( basename $( dirname $f )); b=${f%%.pdb};b=${b##*/ranked_}; echo ${d}-${b}.pdb; ln -s $f ${d}-${b}.pdb ; done

~/.local/foldseek/bin/foldseek createdb *pdb VZV

```


```

mkdir links
cd links
for f in ../??_??????/ranked_?.pdb ; do echo $f ; d=$( basename $( dirname $f )); b=${f%%.pdb};b=${b##*/ranked_}; echo ${d}-${b}.pdb; ln -s $f ${d}-${b}.pdb ; done
cd ..

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/HHV3-VZV/links/*.pdb /francislab/data1/refs/alphafold/TCONS/TCONS aln.html tmpFolder --format-mode 3

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/HHV3-VZV/links/*.pdb /francislab/data1/refs/alphafold/TCONS/TCONS aln.exhaustive.html tmpFolder --exhaustive-search 1 --format-mode 3
```


##	20241022

```

~/.local/foldseek/bin/foldseek easy-search /francislab/data1/refs/alphafold/HHV3-VZV/links/*.pdb /francislab/data1/refs/alphafold/TCONS/TCONS VZVinTCONS.html tmpFolder --format-mode 3 -e 0.00001
echo "<script>function hide_blanks() { var tabs = document.querySelectorAll('div.v-tab'); var emptyTabs = Array.from(tabs).filter(div => div.textContent.includes('(0)')); for (let i = 0; i < emptyTabs.length; i++) { var tmp = emptyTabs[i].style.display = 'None'; }; } window.onload=hide_blanks; </script>" >> VZVinTCONS.html

```



