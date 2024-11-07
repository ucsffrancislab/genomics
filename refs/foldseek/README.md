
#	Foldseek



```
~/.local/foldseek/bin/foldseek databases

~/.local/foldseek/bin/foldseek databases PDB PDB tmpPDB/

~/.local/foldseek/bin/foldseek databases Alphafold/UniProt UniProt tmpUniProt

~/.local/foldseek/bin/foldseek databases Alphafold/UniProt50 UniProt50 tmpUniProt50

~/.local/foldseek/bin/foldseek databases Alphafold/Proteome Proteome tmpProteome

~/.local/foldseek/bin/foldseek databases Alphafold/Swiss-Prot SwissProt tmpSwissProt

~/.local/foldseek/bin/foldseek easy-search ~/TCONS_00000820.pdb PDB aln.m8 tmpFolder

```




When aligning multiple pdbs to a  reference, they are listed across the top of the HTML page.

They are sorted in no particular order.

They also include all pdbs, regardless of whether there are any alignments.

This javascript will hide the "(0)" tabs.


```

<script>function hide_blanks() { var tabs = document.querySelectorAll('div.v-tab'); var emptyTabs = Array.from(tabs).filter(div => div.textContent.includes('(0)')); for (let i = 0; i < emptyTabs.length; i++) { var tmp = emptyTabs[i].style.display = 'None'; }; } window.onload=hide_blanks; </script>

```


##	20241025

```
wget https://bfvd.steineggerlab.workers.dev/bfvd_foldseekdb.tar.gz
tar xvfz bfvd_foldseekdb.tar.gz 
rename bfvd BFVD bfvd*



~/.local/foldseek/bin/foldseek databases Alphafold/UniProt50 UniProt50 tmpUniProt50

~/.local/foldseek/bin/foldseek databases Alphafold/Proteome Proteome tmpProteome

~/.local/foldseek/bin/foldseek databases Alphafold/Swiss-Prot SwissProt tmpSwissProt
```



##	20241029


```
sed 's/,//g' BFVD_taxID_rank_scientificname_lineage.tsv | sed 's/\t/,/g' > BFVD_taxID_rank_scientificname_lineage.csv
sort -t, -k1,1 BFVD_taxID_rank_scientificname_lineage.csv > BFVD_taxID_rank_scientificname_lineage.join_sorted.csv
sed -i '1iBFVD,taxID,rank,scientificname,lineage' BFVD_taxID_rank_scientificname_lineage.join_sorted.csv

```
