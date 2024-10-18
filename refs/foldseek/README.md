
#	Foldseek



```
~/.local/foldseek/bin/foldseek databases

~/.local/foldseek/bin/foldseek databases PDB PDB tmpPDB/


~/.local/foldseek/bin/foldseek easy-search ~/TCONS_00000820.pdb PDB aln.m8 tmpFolder

```



---



```
mkdir testDB.links
cd testDB.links
for f in ../human_herpes/*/ranked_?.pdb; do
ext=${f#*/ranked_}
b=$( basename $( dirname $f ) )
ln -s $f ${b}_${ext}
done

~/.local/foldseek/bin/foldseek createdb testDB.links/ testDB
~/.local/foldseek/bin/foldseek createindex testDB tmp

~/.local/foldseek/bin/foldseek easy-search ../alphafold/SPELLARDPYGPAVDIWSAGIVLFEMATGQ-prehensile_ranked_0.pdb testDB aln.m8 tmpFolder

~/.local/foldseek/bin/foldseek easy-search human_herpes/100/ranked_0.pdb testDB aln.m8 tmpFolder


```

