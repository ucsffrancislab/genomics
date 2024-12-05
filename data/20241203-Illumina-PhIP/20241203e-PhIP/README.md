
#	20241203-Illumina-PhIP/20241203e-PhIP


==> /francislab/data1/raw/20241127-Illumina-PhIP/manifest.tsv <==
Number 	Name	 Index	% Reads	IDX #	READ	 # of Reads  
S1	Blank01_1	CTTGGTT	0.4989	IDX001	AACCAAG	
S2	14118-01	TGCGGTT	0.0004	IDX002	AACCGCA	 2,055,110 
S3	PLib01_1	GCAGGTT	0.5306	IDX003	AACCTGC	
S4	4207	GGTCGTT	0.0015	IDX004	AACGACC	 1,823,293 
S5	4460	ATGCGTT	0.0006	IDX005	AACGCAT	 2,241,270 
S6	14235-01	TAACGTT	0.0002	IDX006	AACGTTA	 1,876,334 
S7	Blank04_1	TCTAGTT	0.0004	IDX007	AACTAGA	 1,834,349 
S8	4129	CGGAGTT	0.0012	IDX008	AACTCCG	 1,383,458 
S9	Blank01_2	GTCAGTT	0.0007	IDX009	AACTGAC	 1,742,107 


remove _1, _2 and dup for subject


```
awk 'BEGIN{OFS=","}(NR>1){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/"$1".VIR3_clean.1-84.bam,serum"}' /francislab/data1/raw/20241203-Illumina-PhIP/manifest.tsv | sort -t, -k1,2 > manifest.csv

sed -i '1isubject,sample,bampath,type' manifest.csv
sed -i '/^Blank/s/serum/input/' manifest.csv 
sed -i '/^PLib/d' manifest.csv
chmod -w manifest.csv
```




```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 00 --manifest ${PWD}/manifest.csv --output ${PWD}/out
```



```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.1.csv --output ${PWD}/out1

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.2.csv --output ${PWD}/out2

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.3.csv --output ${PWD}/out3

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.4.csv --output ${PWD}/out4
```





Create a species order to use for all 4 batches.
Clean up file created after the separate runs, then run again.


```
tail -q -n +2 out?/All.count.Zscores.merged_trues.csv | sort -t, -k1,1 > merged.All.count.Zscores.merged_trues.csv

join --header -t, merged.All.count.Zscores.merged_trues.csv \
  /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv > tmp

awk -F, '(NR>1){print $3}' tmp | sort | uniq -c | sort -k1nr,1 | sed 's/^ *//' | cut -d' ' -f2- > species_order.txt
\rm tmp

/bin/rm -rf out?/*csv out?/*txt
```






```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.1.csv --output ${PWD}/out1 -s ${PWD}/species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.2.csv --output ${PWD}/out2 -s ${PWD}/species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.3.csv --output ${PWD}/out3 -s ${PWD}/species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.4.csv --output ${PWD}/out4 -s ${PWD}/species_order.txt
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm.csv --output ${PWD}/out.gbm
```

TOO MANY SO SPLIT


```
awk 'BEGIN{FS=OFS=","}(NR>1 && ( $5 ~ /glioma/ || $5 ~ /blank/ )){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241203-Illumina-PhIP/20241203d-bowtie2/out/"$1".VIR3_clean.1-84.bam",$5}' /francislab/data1/raw/20241203-Illumina-PhIP/L1\ Sample\ groups\ with\ caco_12-4-24hmh\(in\).csv | sort -t, -k1,2 > manifest.gbm.csv

sed -i '1isubject,sample,bampath,type' manifest.gbm.csv
sed -i 's/pbs blank/input/' manifest.gbm.csv 
chmod -w manifest.gbm.csv
```





```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm1.csv --output ${PWD}/out.gbm1 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm2.csv --output ${PWD}/out.gbm2 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm3.csv --output ${PWD}/out.gbm3 --stop_after_zscore

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm4.csv --output ${PWD}/out.gbm4 --stop_after_zscore
```


```
tail -n +2 out.gbm?/*.count.Zscores.hits.csv | sort -t, -k1,1 \
  | awk -F, '($2=="True")' > mergedgbm.All.count.Zscores.merged_trues.csv
	
sed -i '1iid,all' mergedgbm.All.count.Zscores.merged_trues.csv

join --header -t, mergedgbm.All.count.Zscores.merged_trues.csv \
  /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv > tmp

awk -F, '(NR>1){print $3}' tmp | sort | uniq -c | sort -k1nr,1 | sed 's/^ *//' | cut -d' ' -f2- > gbm_species_order.txt
```

```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm1.csv --output ${PWD}/out.gbm1 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm2.csv --output ${PWD}/out.gbm2 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm3.csv --output ${PWD}/out.gbm3 --species_order gbm_species_order.txt

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.gbm4.csv --output ${PWD}/out.gbm4 --species_order gbm_species_order.txt
```



```
box_upload.bash out.gbm?/All* out.gbm?/m*

```




