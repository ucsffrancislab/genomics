
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


alphafold_array_wrapper.bash --threads 8 S10/Modified-TCONS_00000820-9.faa

```






