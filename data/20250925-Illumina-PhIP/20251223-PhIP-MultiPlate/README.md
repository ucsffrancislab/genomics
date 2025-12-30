
#	20250925-Illumina-PhIP/20251223-PhIP-MultiPlate


This is just a cleaned up set of the original run with just the GBM analysis.


reference 20250409-Illumina-PhIP/20250414-PhIP-MultiPlate

```bash

ln -s /francislab/data1/working/20241204-Illumina-PhIP/20250411-PhIP/out.plate1
ln -s /francislab/data1/working/20241204-Illumina-PhIP/20250411-PhIP/out.plate13
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20250411-PhIP/out.plate14
ln -s /francislab/data1/working/20250822-Illumina-PhIP/20250822c-PhIP/out.plate15
ln -s /francislab/data1/working/20250822-Illumina-PhIP/20250822c-PhIP/out.plate16
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20250925c-PhIP/out.plate17
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20250925c-PhIP/out.plate18
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20250411-PhIP/out.plate2
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20250411-PhIP/out.plate3
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20250411-PhIP/out.plate4
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20250411-PhIP/out.plate5
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20250411-PhIP/out.plate6

```






```bash

module load blast

makeblastdb -in /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq.faa -dbtype prot -title VIR3_clean.id_upper_peptide.uniq -out /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq

blastp -word_size 2 -query /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq.faa -db /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq -outfmt 6 -out /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq.sequence_similarity.word_size-2.tsv

awk 'BEGIN{FS="\t";OFS=",";print "query","target","weight"}($1 != $2){print $1,$2,$12}' /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq.sequence_similarity.word_size-2.tsv | gzip > /francislab/data1/refs/PhIP-Seq/VirScan/edgelist.csv.gz

ln -s /francislab/data1/refs/PhIP-Seq/VirScan/edgelist.csv.gz
```






Using Zscores ...

Select AGS, IPS and PLCO into 1 matrix.

Remove any duplicated subjects? Keep which one? Note it. (I didn't remove any)

"glioma serum"








Just AGS/IPS/PLCO to build communities







Correlate using the Calls

```bash

mkdir out.123456131415161718

merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456131415161718/Zscores.t.csv ${PWD}/out.plate*/Zscores.t.csv

merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456131415161718/Zscores.minimums.t.csv ${PWD}/out.plate*/Zscores.minimums.t.csv


cat out.123456131415161718/Zscores.minimums.t.csv | datamash transpose -t, > out.123456131415161718/tmp1.csv

head -2 out.123456131415161718/tmp1.csv > out.123456131415161718/tmp2.csv
awk -F, '($2 == "glioma serum")' out.123456131415161718/tmp1.csv >> out.123456131415161718/tmp2.csv

cat out.123456131415161718/tmp2.csv | datamash transpose -t, > out.123456131415161718/Zscores.minimums.t.glioma.csv

```








FILTER HERE? 


Remove tiles with 10 or less subjects zscore > 5
Remove tiles observed hit in EVERYONE

```python3
import pandas as pd
df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.csv', header=[0,1,2], index_col=[0,1])
df[(df>=5).sum(axis='columns')<=10].shape
(100044, 376) # wow.

df[(df>=5).sum(axis='columns')>10].shape
(15249, 376)

df[(df>=5).sum(axis='columns')==376].shape
(0, 376)

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --wrap="python3 -c \"import pandas as pd; df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.csv', header=[0,1,2], index_col=[0,1]); df[(df>=5).sum(axis='columns')>10].to_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered.csv')\""

```








```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --wrap="python3 -c \"import pandas as pd; df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered.csv', header=[0,1,2], index_col=[0,1]); df=(df >= 5).astype(int);df.to_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.csv')\""

```



correlation can be very finicky with memory so manipulating data types.

Using the Zscores.minimums.t.glioma.filtered.threshold5.csv which are 0/1 based on zscores and threshold

```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --wrap="$PWD/correlation.py"

#	produces zscore.filtered.threshold5.correlation_edges.csv.gz

phipseq_parallel.py prepare 32
```



```bash

[2025-12-23 14:59:49] Starting data preparation...
[2025-12-23 14:59:49] Loading master peptide list...
[2025-12-23 14:59:49] Master peptide list: 115753 peptides
[2025-12-23 14:59:49] Peptide ID range: 1 to 128287
[2025-12-23 14:59:49] Loading BLAST edges...
[2025-12-23 14:59:51] Loaded 8045523 BLAST edges
[2025-12-23 14:59:52] Unique peptides in BLAST: 115641
[2025-12-23 14:59:52] Peptides in master but not in BLAST: 112
[2025-12-23 14:59:53] Running Leiden on BLAST graph...
[2025-12-23 15:00:06] BLAST clustering: 3478 communities from 115641 peptides
[2025-12-23 15:00:48] Assigning 112 peptides without BLAST edges to singleton communities
[2025-12-23 15:00:48] Loading correlation edges...
[2025-12-23 15:00:48] Loaded 183290 correlation edges
[2025-12-23 15:00:48] After filtering to actual peptides: 183290 edges
[2025-12-23 15:00:48] After filtering positive correlations: 183290 edges
[2025-12-23 15:00:48] Filtering correlations to within-BLAST-community pairs...
[2025-12-23 15:00:48] Within-community correlation edges: 37102
[2025-12-23 15:00:52] Saved prepared data to parallel_work/
[2025-12-23 15:00:52] Total BLAST communities to process: 3590
[2025-12-23 15:00:52] Total peptides with community assignments: 115753

```



```bash
sbatch run_parallel.sh

phipseq_parallel.py merge
```


```bash

[2025-12-23 15:02:13] Merging batch results...
[2025-12-23 15:02:13] Actual peptides in dataset: 115753
[2025-12-23 15:02:13] Found 32 batch files
[2025-12-23 15:02:16] Total peptides from batch processing: 115753
[2025-12-23 15:02:16] Final output contains 115753 peptides (expected 115753)
[2025-12-23 15:02:16] Saved community assignments to final_communities.csv
[2025-12-23 15:02:16] Saved community dictionary to final_communities.pkl
[2025-12-23 15:02:16] Final community statistics:
[2025-12-23 15:02:16]   Total communities: 110961
[2025-12-23 15:02:16]   Peptides assigned: 115753
[2025-12-23 15:02:16]   Community sizes - min: 1, max: 153, median: 1
[2025-12-23 15:02:16]   Singletons: 109808
[2025-12-23 15:02:16] Complete!

```



```bash

tail -n +2 final_communities.csv | cut -d, -f2 | sort -n | uniq -c | sed 's/^\s*//' | sort -k1nr,1 | head
153 22219
111 19142
97 22220
83 77726
80 4526
79 10113
79 10960
77 13747
72 19143
69 21200

```

```bash
head -1 final_communities.csv > final_communities.to_join.csv
tail -n +2 final_communities.csv | sort -t, -k1,1 >> final_communities.to_join.csv

join --header -t, final_communities.to_join.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species.uniq.csv > final_communities.with_species.csv
```



```bash
while read count community ; do
 echo "Community: $community; Count: $count"
 awk -F, '( $2=="'${community}'"){print $3}' final_communities.with_species.csv | sort | uniq -c
done < <( tail -n +2 final_communities.csv | cut -d, -f2 | sort | uniq -c | sed 's/^\s*//' | sort -t' ' -k1nr,1 | head -5 )

Community: 22219; Count: 153
      3 Cosavirus A
      9 Enterovirus A
     48 Enterovirus B
     61 Enterovirus C
      2 Enterovirus D
     23 Rhinovirus A
      5 Rhinovirus B
      1 Rosavirus A
      1 Salivirus A
Community: 19142; Count: 111
    111 Human respiratory syncytial virus
Community: 22220; Count: 97
      3 Enterovirus A
     31 Enterovirus B
     54 Enterovirus C
      8 Rhinovirus A
      1 Rhinovirus B
Community: 77726; Count: 83
     83 Influenza A virus
Community: 4526; Count: 80
      5 Enterovirus A
     34 Enterovirus B
     15 Enterovirus C
      2 Enterovirus D
     16 Rhinovirus A
      8 Rhinovirus B

```




Need to ONLY KEEP THESE PEPTIDES

out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.csv

id,,14350,A016990,A032611,A033033,A068500,A079050,A122000,A151899,B016958,B049271,B098824,B108966,B1
id,,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,gliom
id,,case,control,case,control,control,control,control,control,control,case,case,case,control,control
5,Papiine herpesvirus 2,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,
7,Papiine herpesvirus 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,
11,Vaccinia virus,0,0,0,1,0,

y,subject,14078-01,14078-01,14118-01,14118-01,14127-01,14127-01,14142-01,14142-01,14206-01,14206-01,
x,type,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,glioma serum,gl
id,species,14078-01,14078-01dup,14118-01,14118-01dup,14127-01,14127-01dup,14142-01,14142-01dup,14206
1,Papiine herpesvirus 2,-0.19242194464004103,-0.33853462965065895,-0.2344245250248148,-0.20395148320
10,Vaccinia virus,-0.19242194464004103,-0.33853462965065895,-0.2344245250248148,-0.20395148320255996


Convert peptides to communities

```bash
head -3 out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.csv > out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.joinsorted.csv
tail -n +4 out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.csv | sort -t, -k1,1 >> out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.joinsorted.csv

for f in out.plate*/Zscores.t.csv ; do
  echo $f
  d=$( dirname ${f} )

  head -3 ${f} > ${d}/tmp0.csv
  join -t, <( tail -n +4 out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.joinsorted.csv | cut -d, -f1 ) <( tail -n +4 ${f} ) >> ${d}/tmp0.csv

  head -2 ${d}/tmp0.csv > ${d}/tmp1.csv
  join --header -t, final_communities.to_join.csv <( tail -n +3 ${d}/tmp0.csv ) >> ${d}/tmp1.csv

  sed -i '1,2s/^/z,/' ${d}/tmp1.csv
  group_by_community.py ${d}/tmp1.csv | datamash transpose -t, > ${d}/tmp2.csv
  head -1 ${d}/tmp2.csv > ${d}/Zscores.gliomafilteredthreshold5.communities.csv
  cat ${d}/tmp2.csv >> ${d}/Zscores.gliomafilteredthreshold5.communities.csv
  sed -i '1s/^subject,type,sample,/y,x,id,/' ${d}/Zscores.gliomafilteredthreshold5.communities.csv
  sed -i '2s/^subject,type,sample,/subject,type,species,/' ${d}/Zscores.gliomafilteredthreshold5.communities.csv
done

```









DROP OR DEDUPLICATE THIS TILE AND RERUN

89962,Chikungunya virus
89962,O'nyong-nyong virus

IF MAY BE MOOT AS IT SHOULD BE CORRELATED AND IN THE SAME COMMUNITY














Select AGS and IPS into 1 matrix? Remove any duplicated subjects? Keep which one? Note it.

Correlations on zscore>5 calls 

Select PLCO into 1 matrix. Remove any duplicated subjects? Keep which one? Note it.

Not really needed.


```BASH
\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.123456 -p ${plates} --sex F
done >> commands

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.15161718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --zfile_basename Zscores.gliomafilteredthreshold5.communities.csv -o ${PWD}/out.15161718 -p ${plates} --sex F
done >> commands

commands_array_wrapper.bash --jobname MultiPlate --array_file commands --time 1-0 --threads 4 --mem 30G
```







Convert this to a commands_array job

```bash

\rm commands

for f in ${PWD}/out.{123456,15161718}/Multiplate_Community*gliomafilteredthreshold5*.csv ; do
echo module load r pandoc\; PeptideComparison.Rmd -i ${f} -o ${f%.csv}
done >> commands

commands_array_wrapper.bash --jobname PeptideComparison --array_file commands --time 1-0 --threads 4 --mem 30G

```


```bash

box_upload.bash out.{123456,15161718}/Multiplate_Community*gliomafilteredthreshold5*

```





















Benjamini–Hochberg (BH) FDR

```bash
for f in ${PWD}/out.{123456,15161718}/Multiplate_Community*gliomafilteredthreshold5*.csv ; do
basename $f
python3 -c "import pandas as pd; from statsmodels.stats.multitest import multipletests; df = pd.read_csv('"${f}"'); print(multipletests(df['pval'].dropna(), alpha=0.05, method='fdr_bh')[1].min())"
done

```



```python

df = pd.read_csv('out.123456/Multiplate_Community_Comparison-Zscores.gliomafilteredthreshold5.communities-AGS-IPS-glioma_serum-case-control-Z-3.5-sex-M.csv').dropna()
df.index += 1
df['m']=len(df)
df['m.p']=df.m*df.pval
df['m.p/i']=df.m*df.pval/df.index

df['adjusted_pvalue'] = [df['m.p/i'][i:].min() for i in range(len(df))]

df
       community  freq_case  freq_control      beta        se      pval      m           m.p     m.p/i adjusted_pvalue
1          11676   0.614458      0.385542  1.294750  0.387527  0.000835  10309      8.603759  8.603759        0.999992
2          90141   0.662651      0.867470 -1.440715  0.442043  0.001117  10309     11.517157  5.758578        0.999992
3          89984   0.240964      0.457831 -1.194477  0.377978  0.001577  10309     16.254566  5.418189        0.999992
4         100265   0.204819      0.036145  2.052616  0.664848  0.002020  10309     20.819163  5.204791        0.999992
5          91000   0.518072      0.313253  1.109675  0.374881  0.003076  10309     31.707253  6.341451        0.999992
...          ...        ...           ...       ...       ...       ...    ...           ...       ...             ...
10305      30113   0.084337      0.084337 -0.000054  0.565798  0.999924  10309  10308.217538  1.000312        0.999992
10306      56442   0.349398      0.349398  0.000016  0.341999  0.999963  10309  10308.620507  1.000254        0.999992
10307      91162   0.036145      0.036145  0.000042  0.921221  0.999963  10309  10308.623326  1.000157        0.999992
10308      73831   0.024096      0.024096  0.000047  1.024684  0.999964  10309  10308.626600  1.000061        0.999992
10309       7147   0.036145      0.036145  0.000008  0.846910  0.999992  10309  10308.918339  0.999992        0.999992

```







Seropositivity

echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control -o ${PWD}/out.123456 -p ${plates} --zfile_basename Zscores.csv

```bash

\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex F
done >> commands

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates}
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
echo module load r\; Multi_Plate_Case_Control_VirScan_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control --sfile_basename seropositive.${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex F
done >> commands

commands_array_wrapper.bash --jobname sero --array_file commands --time 1-0 --threads 4 --mem 30G
```




```BASH
\rm commands

for p in 1 2 3 4 5 6 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study AGS --study IPS --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
done ; done >> commands

for p in 15 16 17 18 ; do
plate=out.plate${p}
manifest=${plate}/manifest.plate${p}.csv
for z in 3.5 5 10 ; do
echo module load r\; Count_Viral_Tile_Hit_Fraction.R --zscore ${z} --manifest ${manifest} --output_dir ${plate} --study PLCO --type \"glioma serum\" -a case -b control --zfilename ${plate}/Zscores.csv
done ; done >> commands

commands_array_wrapper.bash --jobname individual --array_file commands --time 1-0 --threads 2 --mem 15G
```




```bash

\rm commands

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study AGS --study IPS --type \"glioma serum\" -a case -b control -o ${PWD}/out.123456 -p ${plates} --zfile_basename Zscores.csv
done >> commands

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
for z in 3.5 5 10 ; do
echo module load r\; Multi_Plate_Case_Control_VirHitFrac_Seropositivity_Regression.R -z ${z} --study PLCO --type \"glioma serum\" -a case -b control -o ${PWD}/out.15161718 -p ${plates} --zfile_basename Zscores.csv
done >> commands

commands_array_wrapper.bash --jobname sero --array_file commands --time 1-0 --threads 4 --mem 30G

```


```bash
for z in 3.5 5 10 ; do
merge_matrices.py --axis columns --de_nan --int \
  --header_rows 3 --index_col species \
  --out ${PWD}/out.123456131415161718/seropositive.${z}.t.csv \
  ${PWD}/out.plate*/seropositive.${z}.t.csv 
done

box_upload.bash out.123456131415161718/seropositive.*
```







##	20251230



```bash
awk 'BEGIN{FS=OFS=","}{print $2,$1,$3,$4,$5,$6,$7,$8}' manifest.csv > tmp.csv
head -1 tmp.csv > manifest.sample_sorted.csv
tail -n +2 tmp.csv | sort -t, -k1,1 >> manifest.sample_sorted.csv

awk 'BEGIN{FS=OFS=","}{print $2,$1}' /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/agsips_manifest.csv > tmp.csv
head -1 tmp.csv > ucsf-agsips.sample_sorted.csv
tail -n +2 tmp.csv | sort -t, -k1,1 >> ucsf-agsips.sample_sorted.csv

join --header -t, ucsf-agsips.sample_sorted.csv manifest.sample_sorted.csv | cut -d, -f2- > tmp.csv
head -1 tmp.csv > agsips.manifest.agsips_sorted.csv
tail -n +2 tmp.csv | sort -t, -k1,1 | uniq >> agsips.manifest.agsips_sorted.csv

join --header -t, agsips.manifest.agsips_sorted.csv /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/chr6.hla_dosage.onco_i370_cidr_gte_0.8.t.agsipsonly.select.csv | cut -d, -f1-8,12- > agsips.manifest.hla.agsips_sorted.csv

cut -d, -f2- agsips.manifest.hla.agsips_sorted.csv > tmp.csv
head -1 tmp.csv > agsips.manifest.hla.subject_sorted.csv
tail -n +2 tmp.csv | sort -t, -k1,1 >> agsips.manifest.hla.subject_sorted.csv



for z in 3.5 5 10 ; do
echo $z

cat out.123456131415161718/seropositive.${z}.t.csv | datamash transpose -t, | awk 'BEGIN{FS=OFS=","}(NR==1 || $3~/_B/)' | cut -d, -f1,4- > tmp.csv
head -1 tmp.csv > tmp.${z}.csv
tail -n +2 tmp.csv | sort -t, -k1,1 >> tmp.${z}.csv

join --header -t, agsips.manifest.hla.subject_sorted.csv tmp.${z}.csv > agsips.manifest.hla.seropositive.${z}.subject_sorted.csv

done

```


