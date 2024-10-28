
#	TEProF2/41588_2023_1349_MOESM3_ESM


```
head S10.csv 
Supplementary Table 10. Protein prediction of candidate transcripts,,,,,,,,,,,,,,,,,
Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,Index of Start Codon,Frame,Frame Type,Protein Sequence,Original Protein Sequence,Strategy,,,


```


```

tail -n +3 S10.csv | awk 'BEGIN{FS=OFS=","}($13!="None"){print ">Modified-"$1"-"$10;print $13; print ">Original-"$1"-"$10;print $14}' > S10.faa

faSplit byname S10.faa S10/

rename .fa .faa S10/*fa

chmod -w S10/*.faa


alphafold_array_wrapper.bash --time 14-0 --threads 16 S10/Modified-TCONS_00000820-9.faa

```



##	20241028

```

mkdir -p links

for f in S10/*-TCONS_00000820-9/ranked_?.pdb ; do
b=$( basename $( dirname $f ) )
i=$( basename $f .pdb )
i=${i#ranked_}
ln -s ../$f links/${b}_${i}.pdb
done

~/.local/foldseek/bin/foldseek createdb links/Original-TCONS_00000820-9_*.pdb Original-TCONS_00000820-9

~/.local/foldseek/bin/foldseek easy-search links/Modified-TCONS_00000820-9_?.pdb Original-TCONS_00000820-9 --format-mode 3 TCONS_00000820-9.html tmp

```






