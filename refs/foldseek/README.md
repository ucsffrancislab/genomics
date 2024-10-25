
#	Foldseek



```
~/.local/foldseek/bin/foldseek databases

~/.local/foldseek/bin/foldseek databases PDB PDB tmpPDB/


~/.local/foldseek/bin/foldseek easy-search ~/TCONS_00000820.pdb PDB aln.m8 tmpFolder

```




When aligning multiple pdbs to a  reference, they are listed across the top of the HTML page.

They are sorted in no particular order.

They also include all pdbs, regardless of whether there are any alignments.

This javascript will hide the "(0)" tabs.


```

<script>function hide_blanks() { var tabs = document.querySelectorAll('div.v-tab'); var emptyTabs = Array.from(tabs).filter(div => div.textContent.includes('(0)')); for (let i = 0; i < emptyTabs.length; i++) { var tmp = emptyTabs[i].style.display = 'None'; }; } window.onload=hide_blanks; </script>

```

