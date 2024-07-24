
#	20201006-GTEx/20240424-REdiscoverTE

1438 total files

Approx 1-2 hours each




##	Quick Run on Select



Quick run with just what is needed

```BASH

awk -F, '($11=="Brain - Amygdala"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Amygdala
awk -F, '($11=="Brain - Anterior cingulate cortex (BA24)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > AnteriorCingulateCortex
awk -F, '($11=="Brain - Caudate (basal ganglia)"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Caudate
awk -F, '($11=="Brain - Cerebellar Hemisphere"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > CerebellarHemisphere
awk -F, '($11=="Brain - Cerebellum"){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.NoResequencing.csv | sort > Cerebellum
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

mkdir Cerebellum_in
for f in $( cat Cerebellum ) ; do
if [ -f /francislab/data1/working/20201006-GTEx/20230817-cutadapt/out/${f}_R1.fastq.gz ] ; then
ln -s /francislab/data1/working/20201006-GTEx/20230817-cutadapt/out/${f}_R1.fastq.gz Cerebellum_in/
ln -s /francislab/data1/working/20201006-GTEx/20230817-cutadapt/out/${f}_R2.fastq.gz Cerebellum_in/
fi
done

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/Cerebellum_out \
  --extension _R1.fastq.gz \
  ${PWD}/Cerebellum_in/*_R1.fastq.gz

```



```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/Cerebellum_out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion \
--outbase ${PWD}/Cerebellum_REdiscoverTE_rollup_noquestion

```


Redo correlations on a subset of the columns (basically by sample location "cerebellum" )


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

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=correlate --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/correlate_select.Cerebellum.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/correlate_select.Rscript --indir ${PWD}/Cerebellum_REdiscoverTE_rollup_noquestion --select ${PWD}/Cerebellum"

```


Filter greater than 0.8, 0.9, 0.95, 0.99

```BASH

\rm commands
for tsv in Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_*.correlation.tsv ; do
echo "${PWD}/select_gt.bash ${tsv}"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```



```BASH

tail -n +2 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs.Cerebellum
head -1 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all.Cerebellum

```

```BASH

wc -l GENEs.Cerebellum RE_all.Cerebellum
 47024 GENEs.Cerebellum
  3583 RE_all.Cerebellum

```



```BASH

box_upload.bash GENEs.Cerebellum RE_all.Cerebellum Cerebellum_REdiscoverTE_rollup_noquestion/*tsv

```











##	Complete Run


```BASH

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20230817-cutadapt/out/*_R1.fastq.gz

```

```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion \
--outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/REdiscoverTE_rollup_noquestion

```



```BASH

REdiscoverTE_EdgeR_rmarkdown.bash

```


```BASH

\rm commands
echo "module load r; $( realpath ${PWD}/correlate_select.Rscript )" > commands
for f in Amygdala AnteriorCingulateCortex Caudate CerebellarHemisphere Cerebellum Cortex FrontalCortex Hippocampus Hypothalamus NucleusAccumbens Putamen SpinalCord SubstantiaNigra ; do
echo "module load r; $( realpath ${PWD}/correlate_select.Rscript ) --select ${PWD}/${f}"
done >> commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```





##	20240507 - Change from RE_all to RE_all_repFamily


```BASH

tail -n +2 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs_x_RE_all_repFamily.Cerebellum
head -1 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all_repFamily.Cerebellum

```





##	Something is off with 3 subjects/samples so removing and rerunning analyses


SRR627429 SRR627451 SRR627462




```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=correlate --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/correlate_select.CerebellumSelect.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/correlate_select.Rscript --indir ${PWD}/Cerebellum_REdiscoverTE_rollup_noquestion --select ${PWD}/CerebellumSelect"

```


Filter greater than 0.8, 0.9, 0.95, 0.99

```BASH

\rm commands
for tsv in Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_*.CerebellumSelect.correlation.tsv ; do
echo "${PWD}/select_gt.bash ${tsv}"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```



```BASH

tail -n +2 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.CerebellumSelect.correlation.tsv | cut -f1 | tr -d \" | sort > GENEs.CerebellumSelect
head -1 Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.CerebellumSelect.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all.CerebellumSelect

```

```BASH

wc -l GENEs.CerebellumSelect RE_all.CerebellumSelect
 47024 GENEs.CerebellumSelect
  3583 RE_all.CerebellumSelect

```



```BASH

box_upload.bash GENEs.CerebellumSelect RE_all.CerebellumSelect Cerebellum_REdiscoverTE_rollup_noquestion/*.CerebellumSelect.*tsv

```




###	Rollup with just the select samples


Using the existing rollup matrix results in a lot of NAs. Rolling up without the 3 offending samples.

```BASH
mkdir CerebellumSelect_out
for s in $( cat CerebellumSelect ) ; do
if [ -d out/${s}.salmon.REdiscoverTE.k15 ] ; then
ln -s ../out/${s}.salmon.REdiscoverTE.k15 CerebellumSelect_out/
fi
done
```

```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/CerebellumSelect_out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion \
--outbase ${PWD}/CerebellumSelect_REdiscoverTE_rollup_noquestion

```


AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/CerebellumSelect_REdiscoverTE_rollup_noquestion

```



```BASH

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=correlate --time=1-0 --nodes=1 --ntasks=4 --mem=30G \
  --output=${PWD}/logs/correlate_select.CerebellumSelect.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --wrap "module load r; ${PWD}/correlate_select.Rscript --indir ${PWD}/CerebellumSelect_REdiscoverTE_rollup_noquestion --select ${PWD}/CerebellumSelect"

```


Filter greater than 0.8, 0.9, 0.95, 0.99

```BASH

\rm commands
for tsv in CerebellumSelect_REdiscoverTE_rollup_noquestion/GENE_x_RE_*.CerebellumSelect.correlation.tsv ; do
echo "${PWD}/select_gt.bash ${tsv}"
done > commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```



```BASH

tail -n +2 CerebellumSelect_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.CerebellumSelect.correlation.tsv | cut -f1 | tr -d \" | sort > GENE.CerebellumSelect
head -1 CerebellumSelect_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.CerebellumSelect.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all.CerebellumSelect
head -1 CerebellumSelect_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.CerebellumSelect.correlation.tsv | datamash transpose | tail -n +2 | tr -d \" | sort > RE_all_repFamily.CerebellumSelect

```

```BASH

wc -l *.CerebellumSelect 
 46278 GENE.CerebellumSelect
  3491 RE_all.CerebellumSelect
    49 RE_all_repFamily.CerebellumSelect

```



```BASH

box_upload.bash *.CerebellumSelect CerebellumSelect_REdiscoverTE_rollup_noquestion/*.CerebellumSelect.*tsv

```





##	20240722


```
module load r
R

g = readRDS('REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.RDS')
g = g$counts
write.table(g, file = 'REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.csv', row.names=TRUE, sep="=", col.names = NA, quote=FALSE)
```

Use = as separator as data contains ,. Join doesn't work with tabs.

Note that the gene annotation table is not 1:1 for ensemble ID to symbol. There are 206 symbols with multiple ensemble IDs. What to do? I'm going to sum the rows.


```
echo -e "ensembl_ID=symbol" > tmp1
tail -n +2 /francislab/data1/refs/REdiscoverTE/rollup_annotation/GENCODE.V26.Basic_Gene_Annotation_md5.tsv | cut -f4,5 --output-delimiter== | sort -t= -k1,1 | uniq >> tmp1

join --header -t= tmp1 REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.csv | cut -d= -f2- > tmp2

head -1 tmp2 > REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.csv
tail -n +2 tmp2 | sort -t= -k1,1 >> REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.csv

sed 's/=/\t/g' REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.csv > REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.tsv
```


```
module load WitteLab python3/3.9.1
REdiscoverTE_groupby_symbol_and_sum.py REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.tsv > tmp3

head -1 tmp3 > REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.tsv
tail -n +2 tmp3 | sort -k1,1 >> REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.tsv
```





```
import pandas as pd
df=pd.read_csv('REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.tsv',sep="\t")
df.set_index('symbol',inplace=True)

m=df.median(axis='columns')
m[m>0]

s=df.sum(axis='columns')
s[s>50]

```




```
cut -f1 REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.tsv > REdiscoverTE_rollup_noquestion/GENE.txt
join --header REdiscoverTE_rollup_noquestion/GENE.txt /francislab/data1/working/20201006-GTEx/20240618-STAR_twopass_basic-hg38_v25/featureCounts.exon.gene_name.txt > shared

wc -l REdiscoverTE_rollup_noquestion/GENE.txt /francislab/data1/working/20201006-GTEx/20240618-STAR_twopass_basic-hg38_v25/featureCounts.exon.gene_name.txt shared

join --header shared REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.tsv | sed 's/ /\t/g' > REdiscoverTE_rollup_noquestion/GENE_1_raw_counts.symbols.summed.shared.tsv
```

