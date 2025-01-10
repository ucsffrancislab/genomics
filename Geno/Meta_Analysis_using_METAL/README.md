
# Quick guide to how I have been doing meta-analyses across the three datasets. 

20210226-AGS-Mayo-Oncoarray

20210223-TCGA-GBMLGG-WTCCC-Affy6

20210302-AGS-illumina


I use the software METAL, which I downloaded to C4, its a very lightweight script, but does not seem to like being called in a shell script, .sh, I have always had to create .bash files and run those from the command line to get metal to loop over multiple analyses (e.g. multiple subtypes). 

You can find a very straightforward guide here:
https://genome.sph.umich.edu/wiki/METAL_Documentation

Depending on which estimates are available, like the beta (effect size) or just p-values (like survival analysis using SPAcox would give), you must specify which mode to use. 

Easy examples of these differences are in the Script_Repository/metal folder of this Box container. 

Using Beta estimates look at: `script_Pharma_survival_metal_all3.txt`

Using just P-values look at: `script_Pharma_survival_metal_spa_all3.txt`

I've built wrapper files which loop through all subtypes and call this script, see `Pharma_surv_meta_wrapper_spa_all3.txt` as an example. 





```
metal/generic-metal/metal script_metal_sexspec_PRS.txt
```


