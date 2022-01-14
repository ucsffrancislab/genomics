


```

mkdir -p /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-895%8 --job-name="viralchimera" --output="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220103-viral-chimera/array_wrapper.bash

```



```


./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv



```


