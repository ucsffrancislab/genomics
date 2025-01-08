
#	20241224-Illumina-PhIP/20250107-PhIP



Process ALL of this data set and ALL of the previous dataset together, 
predominantly to take advantage of variations in the blank samples 
and hopefully alleviate any plate batch effects.


Merge all manifests

```
cat /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/manifest.all.csv > manifest.all.csv
tail -n +2 /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/manifest.gbm.csv >> manifest.all.csv
tail -n +2 /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/manifest.menpem.csv >> manifest.all.csv
chmod -w manifest.all.csv
```


Link all existing count files, rather than to count them again which would make no difference

```
mkdir -p out.all/counts/input
mkdir logs/

for z in /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz/counts/*q40.count.csv.gz /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.multiz/counts/*q40.count.csv.gz /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.gbm.multiz/counts/*q40.count.csv.gz /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.menpem.multiz/counts/*q40.count.csv.gz ; do
ln -s ${z} out.all/counts/
done

for z in /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.gbm.multiz/counts/input/*q40.count.csv.gz /francislab/data1/working/20241204-Illumina-PhIP/20241204c-PhIP/out.menpem.multiz/counts/input/*q40.count.csv.gz /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.gbm.multiz/counts/input/*q40.count.csv.gz /francislab/data1/working/20241224-Illumina-PhIP/20241224c-PhIP/out.menpem.multiz/counts/input/*q40.count.csv.gz ; do
ln -s ${z} out.all/counts/input/
done
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=32 --mem=240G \
  --output=${PWD}/logs/phip_seq.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 40 --manifest ${PWD}/manifest.all.csv --thresholds 3.5,10 --output ${PWD}/out.all


```





```
merge_all_combined_counts_files.py --int --de_nan --out out.all/Plibs.csv out.all/counts/PLib* 

head out.all/Plibs.csv
wc -l out.all/Plibs.csv 
grep -vs ",0" out.all/Plibs.csv | head


echo "id" > out.all/All4Plibs.csv
grep -vs ",0" out.all/Plibs.csv | tail -n +2 | cut -d, -f1 | sort >> out.all/All4Plibs.csv


join -t, --header out.all/All4Plibs.csv out.all/All.count.Zscores.csv | wc -l
#50567 - 68955 up from ...53061

join -t, --header out.all/All4Plibs.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv | cut -d, -f2 | tail -n +2 | sort | uniq -c | sed -e 's/^\s*//' -e 's/ /,/' -e '1icount,species' > out.all/All4Plibs.species_counts.csv

box_upload.bash out.all/Plibs.csv out.all/All4Plibs.csv out.all/All4Plibs.species_counts.csv
```


```
phip_seq_aggregate.bash manifest.all.csv out.all

box_upload.bash out.all/Zscores*csv out.all/seropositive*csv out.all/All* out.all/m*
```




Process the virus plots biggest (longest processing?) first

```
\rm commands
for z in 3.5 10 ; do
 echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.all.csv  --working_dir out.all -a case -b control
 echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.all.csv --working_dir out.all -a case -b control
 echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.all.csv  --working_dir out.all -a case -b control
done >> commands
while read virus ; do
 echo module load r\; By_virus_plotter.R --manifest manifest.all.csv --working_dir out.all --virus \"${virus}\" -g case -g control
done < <( tail -n +2 out.all/merged.3.5.seropositive.csv | datamash transpose -t, | datamash --headers -t, sum 2-$( tail -n +2 out.all/merged.3.5.seropositive.csv | wc -l ) | datamash transpose -t, | sort -t, -k2nr,2 | sed -e 's/^sum(//' -e 's/),/,/' | cut -d, -f1) >> commands


for z in 3.5 10 ; do
 for groups in '-a "PF Patient" -b "Endemic Control"' '-a "PF Patient" -b "Non Endemic Control"' '-a "Endemic Control" -b "Non Endemic Control"' ; do
  echo module load r\; Case_Control_Z_Script.R --zscore ${z} --manifest manifest.all.csv --working_dir out.all ${groups}
  echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest manifest.all.csv  --working_dir out.all ${groups}
  echo module load r\; Seropositivity_Comparison.R --zscore ${z} --manifest manifest.all.csv  --working_dir out.all ${groups}
 done
done >> commands

while read virus ; do
 echo module load r\; By_virus_plotter.R --manifest manifest.all.csv --working_dir out.all --virus \"${virus}\" -g \"PF Patient\" -g \"Endemic Control\" -g \"Non Endemic Control\"
done < <( tail -n +2 out.all/merged.3.5.seropositive.csv | datamash transpose -t, | datamash --headers -t, sum 2-$( tail -n +2 out.all/merged.3.5.seropositive.csv | wc -l ) | datamash transpose -t, | sort -t, -k2nr,2 | sed -e 's/^sum(//' -e 's/),/,/' | cut -d, -f1) >> commands


commands_array_wrapper.bash --array_file commands --time 4-0 --threads 4 --mem 30G



box_upload.bash out.all/Tile_Comparison* out.all/Viral_* out.all/Seropositivity* out.all/Manhattan_plots*

```


