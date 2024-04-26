
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

```BASH

REdiscoverTE_EdgeR_rmarkdown.bash

```


```BASH

\rm commands
echo "module load r; $( realpath ${PWD}/correlate_select.Rscript ) > commands
for f in Amygdala AnteriorCingulateCortex Caudate CerebellarHemisphere Cerebellum Cortex FrontalCortex Hippocampus Hypothalamus NucleusAccumbens Putamen SpinalCord SubstantiaNigra ; do
echo "module load r; $( realpath ${PWD}/correlate_select.Rscript ) --select ${PWD}/${f}"
done >> commands
commands_array_wrapper.bash --array_file commands --time 720 --threads 4 --mem 30G 

```





