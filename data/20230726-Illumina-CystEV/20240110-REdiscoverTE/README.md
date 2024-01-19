
#	20230726-Illumina-CystEV/20240110-REdiscoverTE

REdiscoverTE rollup and analysis of this dataset and 20211208-EV combined.


```
        20211208-EV/20230815-preprocess/out/SFHH009M.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R2.fastq.gz

20230726-Illumina-CystEV/20230809-preprocess/out/8_4.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.R2.fastq.gz
```


```
/francislab/data1/working/20230726-Illumina-CystEV/20230810-REdiscoverTE/out/*.salmon.REdiscoverTE.k15

/francislab/data1/working/20211208-EV/20240109-REdiscoverTE/out/*.salmon.REdiscoverTE.k15
```



I would think a good place to start would be 6 groups, 
HG_new, 
nonHG_new, 
HG_old, 
nonHG_old, (all of those being cyst) and 
HG_serum, 
nonHG_serum

? Just an idea, so we can see consistencies between old and new, and between cyst and serum? (edited) 




```

/francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv 

/francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv 

```

```
mkdir -p out
for d in /francislab/data1/working/20211208-EV/20240109-REdiscoverTE/out/*.salmon.REdiscoverTE.k15 \
  /francislab/data1/working/20230726-Illumina-CystEV/20230810-REdiscoverTE/out/*.salmon.REdiscoverTE.k15 ; do
ln -s $d out/
done
```



```

REdiscoverTE_rollup.bash

```



```
REdiscoverTE_EdgeR_rmarkdown.bash
```





```
rmarkdown_results_all_kirkwood_grade_collapsed

ll rmarkdown_results_all_kirkwood_grade_collapsed
total 1157076
-r--r----- 1 gwendt francislab 176140949 Jan 12 08:02 k15.grade_collapsed.GENE.alpha.0.05.logFC.0.5.html
drwxr-x--- 3 gwendt francislab        33 Jan 12 08:17 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.01_files
drwxr-x--- 3 gwendt francislab        33 Jan 12 08:03 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.2_files
drwxr-x--- 3 gwendt francislab        33 Jan 12 08:17 k15.grade_collapsed.GENE.alpha.0.5.logFC.0.2_files
drwxr-x--- 3 gwendt francislab        33 Jan 12 08:17 k15.grade_collapsed.GENE.alpha.1.logFC.0.01_files

array_options="--array_file REdiscoverTE_EdgeR_rmarkdown.bash.20240112073352348315893 "
array=2-5

date=$( date "+%Y%m%d%H%M%S%N" )
script=${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
  --parsable --job-name="$(basename $script)" \
  --time=10080 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G \
  --output=${PWD}/logs/$(basename $script).${date}-%A_%a.out.log \
  $( realpath ${script} ) ${array_options}



REdiscoverTE_EdgeR_rmarkdown.bash.20240112082152207141053 - possibly corrupted by running 2 at the same time
rmarkdown_results_all_kirkwood_CF_grade_collapsed

 ll rmarkdown_results_all_kirkwood_CF_grade_collapsed
total 615740
-r--r----- 1 gwendt francislab   1738783 Jan 12 08:23 k15.grade_collapsed.GENE.alpha.0.05.logFC.0.5.html
-r--r----- 1 gwendt francislab   1737647 Jan 12 08:28 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.01.html
-r--r----- 1 gwendt francislab   1738579 Jan 12 08:24 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.2.html
-r--r----- 1 gwendt francislab 376141032 Jan 12 09:18 k15.grade_collapsed.GENE.alpha.0.5.logFC.0.2.html
drwxr-x--- 3 gwendt francislab        33 Jan 12 08:28 k15.grade_collapsed.GENE.alpha.1.logFC.0.01_files


array_options="--array_file REdiscoverTE_EdgeR_rmarkdown.bash.20240112082152207141053 "
array=5

date=$( date "+%Y%m%d%H%M%S%N" )
script=${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
  --parsable --job-name="$(basename $script)" \
  --time=10080 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G \
  --output=${PWD}/logs/$(basename $script).${date}-%A_%a.out.log \
  $( realpath ${script} ) ${array_options}



REdiscoverTE_EdgeR_rmarkdown.bash.20240112091417613553111
rmarkdown_results_all_serum_grade_collapsed

ll rmarkdown_results_all_serum_grade_collapsed
total 235032
-r--r----- 1 gwendt francislab  2260585 Jan 12 09:15 k15.grade_collapsed.GENE.alpha.0.05.logFC.0.5.html
-r--r----- 1 gwendt francislab  2254161 Jan 12 09:15 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.01.html
-r--r----- 1 gwendt francislab  2262457 Jan 12 09:15 k15.grade_collapsed.GENE.alpha.0.1.logFC.0.2.html
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.GENE.alpha.0.5.logFC.0.2_files
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.GENE.alpha.1.logFC.0.01_files
-r--r----- 1 gwendt francislab  2291741 Jan 12 09:17 k15.grade_collapsed.RE_all.alpha.0.05.logFC.0.5.html
-r--r----- 1 gwendt francislab  2896671 Jan 12 09:17 k15.grade_collapsed.RE_all.alpha.0.1.logFC.0.01.html
-r--r----- 1 gwendt francislab  2897919 Jan 12 09:17 k15.grade_collapsed.RE_all.alpha.0.1.logFC.0.2.html
-r--r----- 1 gwendt francislab 23460858 Jan 12 09:20 k15.grade_collapsed.RE_all.alpha.0.5.logFC.0.2.html
-r--r----- 1 gwendt francislab 33007832 Jan 12 09:22 k15.grade_collapsed.RE_all.alpha.1.logFC.0.01.html
-r--r----- 1 gwendt francislab  1502881 Jan 12 09:18 k15.grade_collapsed.RE_all_repFamily.alpha.0.05.logFC.0.5.html
-r--r----- 1 gwendt francislab  1747269 Jan 12 09:19 k15.grade_collapsed.RE_all_repFamily.alpha.0.1.logFC.0.01.html
-r--r----- 1 gwendt francislab  1747477 Jan 12 09:18 k15.grade_collapsed.RE_all_repFamily.alpha.0.1.logFC.0.2.html
-r--r----- 1 gwendt francislab  2344960 Jan 12 09:19 k15.grade_collapsed.RE_all_repFamily.alpha.0.5.logFC.0.2.html
-r--r----- 1 gwendt francislab  4106148 Jan 12 09:19 k15.grade_collapsed.RE_all_repFamily.alpha.1.logFC.0.01.html
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.RE_exon.alpha.0.05.logFC.0.5_files
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.RE_exon.alpha.0.1.logFC.0.01_files
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.RE_exon.alpha.0.1.logFC.0.2_files
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:15 k15.grade_collapsed.RE_exon.alpha.0.5.logFC.0.2_files
drwxr-x--- 3 gwendt francislab       33 Jan 12 09:16 k15.grade_collapsed.RE_exon.alpha.1.logFC.0.01_files
-r--r----- 1 gwendt francislab  1494253 Jan 12 09:20 k15.grade_collapsed.RE_exon_repFamily.alpha.0.05.logFC.0.5.html

array_options="--array_file REdiscoverTE_EdgeR_rmarkdown.bash.20240112091417613553111 "
array=1-5,11-15

date=$( date "+%Y%m%d%H%M%S%N" )
script=${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
  --parsable --job-name="$(basename $script)" \
  --time=10080 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G \
  --output=${PWD}/logs/$(basename $script).${date}-%A_%a.out.log \
  $( realpath ${script} ) ${array_options}




array_options="--array_file REdiscoverTE_EdgeR_rmarkdown.bash.20240112143240093983107 "
array=3,5

date=$( date "+%Y%m%d%H%M%S%N" )
script=${PWD}/REdiscoverTE_EdgeR_rmarkdown.bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
  --parsable --job-name="$(basename $script)" \
  --time=10080 --nodes=1 --ntasks=16 --mem=120G --gres=scratch:500G \
  --output=${PWD}/logs/$(basename $script).${date}-%A_%a.out.log \
  $( realpath ${script} ) ${array_options}

```






```
tail logs/REdiscoverTE_EdgeR_rmarkdown.bash.20240112163637780518777-1665503_3.out.log
57/63                                            
58/63 [box plots]                                

Quitting from lines 695-729 [box plots] (REdiscoverTE_EdgeR_rmarkdown.Rmd)
Error in `$<-.data.frame`:
! replacement has 24 rows, data has 0
Backtrace:
 1. base::`$<-`(`*tmp*`, "group", value = `<fct>`)
 2. base::`$<-.data.frame`(`*tmp*`, "group", value = `<fct>`)
Warning message:
ggrepel: 6642 unlabeled data points (too many overlaps). Consider increasing max.overlaps 
Execution halted




tail -n 20 logs/REdiscoverTE_EdgeR_rmarkdown.bash.20240112163637780518777-1665503_5.out.log
57/63                                            
58/63 [box plots]                                

Quitting from lines 695-729 [box plots] (REdiscoverTE_EdgeR_rmarkdown.Rmd)
Error in `$<-.data.frame`:
! replacement has 24 rows, data has 0
Backtrace:
 1. base::`$<-`(`*tmp*`, "group", value = `<fct>`)
 2. base::`$<-.data.frame`(`*tmp*`, "group", value = `<fct>`)
Warning messages:
1: ggrepel: 15218 unlabeled data points (too many overlaps). Consider increasing max.overlaps 
2: ggrepel: 14745 unlabeled data points (too many overlaps). Consider increasing max.overlaps 
3: ggrepel: 11711 unlabeled data points (too many overlaps). Consider increasing max.overlaps 
Execution halted



tail -n 20 logs/REdiscoverTE_EdgeR_rmarkdown.bash.20240112163637780518777-1665503_11.out.log
51/63                                            
52/63 [DE setup]                                 

Quitting from lines 579-616 [DE setup] (REdiscoverTE_EdgeR_rmarkdown.Rmd)
Error in `.compressDispersions()`:
! dispersions must be finite non-negative values
Backtrace:
 1. edgeR::estimateGLMTagwiseDisp(d2, design.mat)
 2. edgeR::estimateGLMTagwiseDisp.DGEList(d2, design.mat)
 4. edgeR::estimateGLMTagwiseDisp.default(...)
 7. edgeR::dispCoxReidInterpolateTagwise(...)
 8. edgeR::adjustedProfileLik(...)
 9. edgeR:::.compressDispersions(y, dispersion)
Execution halted
```
