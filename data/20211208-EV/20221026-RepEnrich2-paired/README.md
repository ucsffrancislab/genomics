
#	RepEnrich2

https://github.com/nerettilab/RepEnrich2

cat data/20200909-TARGET-ALL-P2-RNA_bam/20220309-RepEnrich2-test/README.md 


While this was originally paired-end data, post-deduplication extraction broke that.

```
samtools view -c -f64 -F3844 ../20221024-preprocessing-paired/out/SFHH009E.format.umi.quality15.t1.t2.t3.readname.hg38.tags.mated.marked.bam
871085

samtools view -c -f128 -F3844 ../20221024-preprocessing-paired/out/SFHH009E.format.umi.quality15.t1.t2.t3.readname.hg38.tags.mated.marked.bam
641778
```

Treating as unpaired


```
ln -s /francislab/data1/raw/20211208-EV/plot_2.csv metadata.csv

```


```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%4 --job-name="RepEnrich2" --output="${PWD}/logs/RepEnrich2.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/RepEnrich2_array_wrapper.bash
```



```
./RepEnrich2_EdgeR_rmarkdown.bash
```



```
RepEnrich2_upload.bash
```

