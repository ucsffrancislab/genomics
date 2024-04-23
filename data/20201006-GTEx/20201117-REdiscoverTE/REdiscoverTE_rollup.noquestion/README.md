

#	20201006-GTEx/20201117-REdiscoverTE/REdiscoverTE_rollup.noquestion




Plotting a huge correlation table as a heatmap is proving impossible


Filtering rows and cols with at least one 0.8 or 0.9. Assuming there are no 1s



```BASH
zcat GENE_x_RE_all.correlation.tsv.gz | head -1 > GENE_x_RE_all.correlation.gt08.tsv
zgrep "0\.[89]" GENE_x_RE_all.correlation.tsv.gz >> GENE_x_RE_all.correlation.gt08.tsv 

cat GENE_x_RE_all.correlation.gt08.tsv | datamash transpose  | head -1 > GENE_x_RE_all.correlation.gt08.gt08.tsv
cat GENE_x_RE_all.correlation.gt08.tsv | datamash transpose  | grep "0\.[89]" >> GENE_x_RE_all.correlation.gt08.gt08.tsv

zcat GENE_x_RE_all.correlation.tsv.gz | head -1 > GENE_x_RE_all.correlation.gt09.tsv
zgrep "0\.9" GENE_x_RE_all.correlation.tsv.gz >> GENE_x_RE_all.correlation.gt09.tsv 

cat GENE_x_RE_all.correlation.gt09.tsv | datamash transpose  | head -1 > GENE_x_RE_all.correlation.gt09.gt09.tsv
cat GENE_x_RE_all.correlation.gt09.tsv | datamash transpose  | grep "0\.9" >> GENE_x_RE_all.correlation.gt09.gt09.tsv

R
```


```R

c=read.table('GENE_x_RE_all.correlation.gt08.gt08.tsv',sep="\t",row.names=1,header=TRUE)

dim(c)
#[1] 1061 7668


c=read.table('GENE_x_RE_all.correlation.gt09.gt09.tsv',sep="\t",row.names=1,header=TRUE)

dim(c)
#[1]  396 1774





library(ggcorrplot)

plt = ggcorrplot(c, outline.color = "white", lab=TRUE)


```


##	20240417


Redo correlations on a subset of the columns (basically by sample location "cerebrum" )


```
    134 Brain - Amygdala
    156 Brain - Anterior cingulate cortex (BA24)
    215 Brain - Caudate (basal ganglia)
    180 Brain - Cerebellar Hemisphere
    231 Brain - Cerebellum
    206 Brain - Cortex
    172 Brain - Frontal Cortex (BA9)
    163 Brain - Hippocampus
    162 Brain - Hypothalamus
    191 Brain - Nucleus accumbens (basal ganglia)
    158 Brain - Putamen (basal ganglia)
    119 Brain - Spinal cord (cervical c-1)
    121 Brain - Substantia nigra
```


```BASH
awk -F, '($11=="Brain - Cerebellum"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Cerebellum
awk -F, '($11=="Brain - Amygdala"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Amygdala
awk -F, '($11=="Brain - Anterior cingulate cortex (BA24)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > AnteriorCingulateCortex
awk -F, '($11=="Brain - Caudate (basal ganglia)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Caudate
awk -F, '($11=="Brain - Cerebellar Hemisphere"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > CerebellarHemisphere
awk -F, '($11=="Brain - Cortex"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Cortex
awk -F, '($11=="Brain - Frontal Cortex (BA9)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > FrontalCortex
awk -F, '($11=="Brain - Hippocampus"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Hippocampus
awk -F, '($11=="Brain - Hypothalamus"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Hypothalamus
awk -F, '($11=="Brain - Nucleus accumbens (basal ganglia)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > NucleusAccumbens
awk -F, '($11=="Brain - Putamen (basal ganglia)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Putamen
awk -F, '($11=="Brain - Spinal cord (cervical c-1)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > SpinalCord
awk -F, '($11=="Brain - Substantia nigra"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > SubstantiaNigra

chmod 400 Amygdala AnteriorCingulateCortex Caudate CerebellarHemisphere Cerebellum Cortex FrontalCortex Hippocampus Hypothalamus NucleusAccumbens Putamen SpinalCord SubstantiaNigra 

```

```BASH

../correlate_select.Rscript --select Cerebellum

Warning messages:
1: In cor(t(g), t(r)) : the standard deviation is zero
2: In cor(t(g), t(r)) : the standard deviation is zero
3: In cor(t(g), t(r)) : the standard deviation is zero
4: In cor(t(g), t(r)) : the standard deviation is zero
5: In cor(t(g), t(r)) : the standard deviation is zero
6: In cor(t(g), t(r)) : the standard deviation is zero
7: In cor(t(g), t(r)) : the standard deviation is zero
Error: unexpected symbol in "t((1 - cormat)/2) : non-square matrix"
Execution halted




../correlate_select.Rscript


\rm commands
for f in Amygdala AnteriorCingulateCortex Caudate CerebellarHemisphere Cerebellum Cortex FrontalCortex Hippocampus Hypothalamus NucleusAccumbens Putamen SpinalCord SubstantiaNigra ; do
echo "module load r; $( realpath ${PWD}/../correlate_select.Rscript ) --select ${PWD}/${f}"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```







Filter greater than 0.8, 0.9
Are there 1s? Yes
Grepping like this doesn't work since there are scientific notations on occasion.
Gonna need to use awk or something

```BASH
\rm commands
for tsv in GENE_x_RE_*.correlation.tsv ; do
echo "$( realpath ${PWD}/select_gt.bash ) $( realpath ${tsv} )"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 
```






RNA expression of retroviral element RNLTR12-int is crucial for myelination
RNLTR12-int binds to SOX10 to regulate Mbp expression
RNLTR12-int-like sequences (RetroMyelin) were identified in all jawed vertebrates
Convergent evolution likely led to RetroMyelin acquisition, adapted for myelination


run r cocor to compare gtex to tcga

Compare sites to other sites

Just one "site" for tcga




##	20240422

```
tail -n +2 GENE_x_RE_all.correlation.tsv | cut -f1 | tr -d \" > GENEs
head -1 GENE_x_RE_all.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" > RE_all

```

```
wc -l GENEs RE_all
  55670 GENEs
   4788 RE_all
```







