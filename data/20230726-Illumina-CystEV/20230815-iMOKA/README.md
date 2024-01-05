

#	20230726-Illumina-CystEV/20230815-iMOKA


ONLY DEDUPED READS THAT ALIGNED TO HUMAN


```
mkdir -p in
for id in \
  $( awk -F, '($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  #echo $id
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done



for id in \
  $( awk -F, '($6=="CF"){print $1}' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv ); do
  for f in $( ls ../../20211208-EV/20230815-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done
```






Paired data, so R1;R2 and also O1;O2 (never any S0)

NO SPACES IN GROUP NAMES

```
#awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="cyst fluid" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.all.tsv

#awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($6=="CF"){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv | sed 's/ /_/g' >> source.all.tsv

awk -v pwd=${PWD} 'BEGIN{FS=OFS="\t"}{ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' metadata.tsv | sed 's/ /_/g' > source.all.tsv
```


```
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490
done
```

```
chmod -w out/*/preprocess/*/*bin
```


```
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  mkdir -p out/grade_collapsed-${k}
  ln -s ../${k}/preprocess out/grade_collapsed-${k}/preprocess
  ln -s ../${k}/create_matrix.tsv out/grade_collapsed-${k}/
done

```



Group sizes are 11 and 13

Using cross validation of 7

```

for k in 11 13 16 21 25 31 35 39 43 47 51; do
 for s in grade_collapsed-${k} ; do
  sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
   --output="${PWD}/logs/iMOKA.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=720 --nodes=1 --ntasks=32 --mem=240G \
   ~/.local/bin/iMOKA.bash --dir ${PWD}/out/${s} --k ${k} --step create --random_forest --cross-validation 7
done ; done

```




```

for k in 11 13 16 21 25 31 35 39 43 47 51; do
 for s in grade_collapsed-${k} ; do
  if [ -f out/${s}/output.json ] ; then
   iMOKA_upload.bash out/${s}
  fi
done ; done

```




Let's predict the SE

```
mkdir -p in
for id in \
  $( awk -F, '($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  #echo $id
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done

```

```

awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="Kirkwood Cyst Study" && $8=="SE" && $NF!=""){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$NF,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.predict.tsv

```

```
date=$( date "+%Y%m%d%H%M%S%N" )
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490 --source_file ${PWD}/source.predict.tsv --dir ${PWD}/predictions
done
```


```
chmod -w predictions/*/preprocess/*/*bin
```





```
ssh d1
cd /francislab/data1/working/20230726-Illumina-CystEV/20230815-iMOKA

./predict.bash

```



```
box_upload.bash predictions/grade_collapsed-??/*

```



##	20230824


```
\rm iMOKA_commands
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 11 13 16 21 25 31 35 39 43 47 51; do
dir=${PWD}/out/grade_collapsed-${k}
cat ${dir}/output_models/*.features | sort | uniq > ${dir}/select_kmers.txt
echo "export SINGULARITY_BINDPATH=/francislab; export APPTAINER_BINDPATH=/francislab; export OMP_NUM_THREADS=8; export IMOKA_MAX_MEM_GB=50; singularity exec ${img} iMOKA_core create -i ${dir}/create_matrix.tsv -o ${dir}/create_matrix.json; singularity exec ${img} iMOKA_core extract -s ${dir}/create_matrix.json -i ${dir}/select_kmers.txt -o ${dir}/select_kmers.tsv" >> iMOKA_commands
done

commands_array_wrapper.bash --array_file iMOKA_commands --time 720 --threads 8 --mem 60G 
```









```
\rm iMOKA_commands
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 11 13 16 21 25 31 35 39 43 47 51; do
mkdir -p ${PWD}/all/${k}
cat ${PWD}/out/grade_collapsed-${k}/output_models/*.features | sort | uniq > ${PWD}/all/${k}/select_kmers.txt
cat ${PWD}/{out,predictions}/${k}/create_matrix.tsv > ${PWD}/all/${k}/create_matrix.tsv
echo "export SINGULARITY_BINDPATH=/francislab; export APPTAINER_BINDPATH=/francislab; export OMP_NUM_THREADS=8; export IMOKA_MAX_MEM_GB=50; singularity exec ${img} iMOKA_core create -i ${PWD}/all/${k}/create_matrix.tsv -o ${PWD}/all/${k}/create_matrix.json; singularity exec ${img} iMOKA_core extract -s ${PWD}/all/${k}/create_matrix.json -i ${PWD}/all/${k}/select_kmers.txt -o ${PWD}/all/${k}/select_kmers.tsv" >> iMOKA_commands
done

commands_array_wrapper.bash --array_file iMOKA_commands --time 720 --threads 8 --mem 60G 
```









##	20240102



Only want to count the blank samples as have already counted the others.

```
for id in \
  $( awk -F, '($7=="blank"){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  echo $id
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done
```


```
awk -v pwd=${PWD} 'BEGIN{FS=OFS="\t"}($7=="blank"){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$7,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.tsv > source.blanks.tsv
```

7_7 and 8_4 appear rather empty

```
for k in 11 13 16 21 25 31 35 39 43 47 51; do
  iMOKA_count.bash -k ${k} --threads 64 --mem 490 --dir ${PWD}/blank --source_file ${PWD}/source.blanks.tsv
done
```








```
\rm iMOKA_commands
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 11 13 16 21 25 31 35 39 43 47 51; do
mkdir -p ${PWD}/dump/${k}
cat ${PWD}/{out,blank}/${k}/create_matrix.tsv > ${PWD}/dump/${k}/create_matrix.tsv
echo "export SINGULARITY_BINDPATH=/francislab; export APPTAINER_BINDPATH=/francislab; export OMP_NUM_THREADS=32; export IMOKA_MAX_MEM_GB=220; singularity exec ${img} iMOKA_core create -i ${PWD}/dump/${k}/create_matrix.tsv -o ${PWD}/dump/${k}/create_matrix.json; singularity exec ${img} iMOKA_core dump -i ${PWD}/dump/${k}/create_matrix.json -o ${PWD}/dump/${k}/kmers.tsv; gzip ${PWD}/dump/${k}/kmers.tsv" >> iMOKA_commands
done

commands_array_wrapper.bash --array_file iMOKA_commands --time 720 --threads 32 --mem 240G 
```





Note: To perform the Z-score analysis, count.combined files are merged into a table, and columns corresponding with no-serum controls are summed in a column called “input”.


```
	2_2	2_3	2_4	2_5	2_6	2_7	2_9	4_1	4_2	4_4	4_5	4_6	4_7	4_8	SFHH009H	SFHH009L	SFHH009E	SFHH009G	SFHH009I	SFHH009F	SFHH009D	SFHH009N	SFHH009C	SFHH009M	1_11	4_10
group	HGD_or_Invasive_Cancer	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	LGD_or_No_HGD_Carcinoma_seen	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	LGD_or_No_HGD_Carcinoma_seen	HGD_or_Invasive_Cancer	HGD_or_Invasive_Cancer	HGD_or_Invasive_Cancer	HGD_or_Invasive_Cancer	blank	blank
AAAAAAAAAAA	2.06771e+06	1.69886e+06	2.55093e+06	1.4488e+06	1.93295e+06	7.03636e+06	1.62142e+06	3.9394e+06	2.36225e+06	4.31637e+06	2.64691e+06	1.18312e+06	1.31434e+06	1.90985e+06	892033	1.30453e+06	1.79618e+06	1.09389e+06	1.29044e+06	912064	2.04877e+06	1.07429e+06	1.01158e+06	1.30155e+06	1.65182e+07	1.4997e+07
AAAAAAAAAAC	44862.9	42188.3	50952.3	37149.5	47374.8	48311.6	40670.7	43069.7	42519.4	27173.1	30165.9	30920.9	33450.2	38277.3	62640.6	89568.6	108465	81840.1	102271	63458.5	169638	70012.5	72710.3	87598.7	59614.5	63179.1
AAAAAAAAAAG	19860.5	21991.1	27012.8	15947	21304.6	40168.6	18902.9	21521.3	22412.8	20755.5	17560.3	12869.3	14457.7	21410.5	17660.1	27726.5	26185.4	23906.2	26902.1	18239.3	45185.3	21194.1	19587.7	23671.3	88970.2	74422.8
```

```
#for k in 11 13 16 21 25 31 35 39 43 47 51; do
for k in 11 ; do
zcat ${PWD}/dump/${k}/kmers.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-2);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-2);i++){s=s","$i};print s,($(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.count.csv
elledge_Zscore_analysis.R ${PWD}/dump/${k}/kmers.count.csv
gzip ${PWD}/dump/${k}/kmers.count.csv
gzip ${PWD}/dump/${k}/kmers.count.Zscores.csv
done
```




```
zcat dump/11/kmers.tsv.gz | head -101 > dump/11/kmers-head.tsv
head -100 dump/11/kmers.count.csv > dump/11/kmers-head.count.csv
head -100 dump/11/kmers.count.Zscores.csv > dump/11/kmers-head.count.Zscores.csv
box_upload.bash dump/11/kmers-head*
```



20230103 - Just noticed that when I predicted, there was a character difference which made the ratio on the final line wrong.



##	20240103

Gonna recreate the tsv files from the Zscores

Formatted as such .. kmer tab count

```
head testkeepfiles/11/preprocess/1_11/1_11.tsv
AAAAAAAAAAA	36575
AAAAAAAAAAC	132
AAAAAAAAAAG	197
```


```
zcat dump/11/kmers.count.Zscores.csv.gz | head
2_2,2_3,2_4,2_5,2_6,2_7,2_9,4_1,4_2,4_4,4_5,4_6,4_7,4_8,SFHH009H,SFHH009L,SFHH009E,SFHH009G,SFHH009I,SFHH009F,SFHH009D,SFHH009N,SFHH009C,SFHH009M,id,group,input
36.3689380066368,39.5858369142192,22.3216766828456,32.0712772024797,36.8779608338469,40.0408006907355,28.4755974897106,39.516884310819,45.4282202826395,29.3094823820887,33.3536399146908,28.3033528266829,27.6375572204048,23.5447817786111,1.22990407007278,4.22589816106579,2.09968830393785,6.37233479017957,5.93751739308721,3.23956418512876,4.66868291408642,8.96300243347949,8.73863816708344,15.3737611914335,AAAAAAAAAAAAAAAA,39,33001100

zcat dump/11/kmers.count.Zscores.csv.gz | awk 'BEGIN{FS=",";OFS="\t"}
(NR==1){ for(i=1;i<=NF;i++){dir="zscores/11/preprocess/"$i;system("mkdir -p "dir);files[i]=dir"/"$i".tsv"} }
(NR>1){ for(i=1;i<=NF;i++){ print $(NF-2),$i >> files[i] } }'

```



##	20240104

Zscores can be negative and a much smaller range than actual kmer counts.
Expecting a crash.
Only using cyst fluid samples as before.

```
dir=${PWD}/zscores/11/
create_matrix=${dir}/create_matrix.tsv
awk -v d=${dir} 'BEGIN{OFS=FS="\t"}{
 print d"preprocess/"$2"/"$2".tsv",$2,$3
}' ${PWD}/out/11/create_matrix.tsv > ${create_matrix}

k=11
s=11

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${s}" \
  --output="${PWD}/logs/iMOKA.zscore.${s}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1000 --nodes=1 --ntasks=32 --mem=240G \
  ~/.local/bin/iMOKA.bash --dir ${dir} --k ${k} --step create

```

Killed. This was taking forever and seemed to be hung.





###	New direction. Filter kmers

REDO ... ONLY USE THIS DATA. NOT THE SFHH DATA



dump to tsv ... dump/11/kmers.tsv.gz

```
\rm iMOKA_commands
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 11 13 16 21 25 31 35 39 43 47 51; do
mkdir -p ${PWD}/dump/${k}
cat ${PWD}/{out,blank}/${k}/create_matrix.tsv | grep -vs SFHH00 > ${PWD}/dump/${k}/create_matrix.tsv
echo "export SINGULARITY_BINDPATH=/francislab; export APPTAINER_BINDPATH=/francislab; export OMP_NUM_THREADS=32; export IMOKA_MAX_MEM_GB=220; singularity exec ${img} iMOKA_core create -i ${PWD}/dump/${k}/create_matrix.tsv -o ${PWD}/dump/${k}/create_matrix.json; singularity exec ${img} iMOKA_core dump -i ${PWD}/dump/${k}/create_matrix.json -o ${PWD}/dump/${k}/kmers.tsv; gzip ${PWD}/dump/${k}/kmers.tsv" >> iMOKA_commands
done

commands_array_wrapper.bash --array_file iMOKA_commands --time 720 --threads 32 --mem 240G 
```



convert to csv ... dump/11/kmers.count.csv.gz

zscores computed to ... dump/11/kmers.count.Zscores.csv.gz

reorder zscores to ... dump/11/kmers.count.Zscores.reorder.csv.gz
(note leaving the trailing "id,group,input" just cause its easier, then ignore it later.)

```
module load r
#for k in 11 13 16 21 25 31 35 39 43 47 51; do
for k in 11 ; do
zcat ${PWD}/dump/${k}/kmers.tsv.gz | awk 'BEGIN{FS="\t";OFS=","}(NR==1){s="id"; for(i=2;i<=(NF-2);i++){s=s","$i};print s,"input"} (NR>2){s=$1; for(i=2;i<=(NF-2);i++){s=s","$i};print s,($(NF-1)+$NF)}' > ${PWD}/dump/${k}/kmers.count.csv
elledge_Zscore_analysis.R ${PWD}/dump/${k}/kmers.count.csv

sed -i '1 s/,/_z,/g' ${PWD}/dump/${k}/kmers.count.Zscores.csv
awk 'BEGIN{FS=OFS=","}{print $(NF-2),$0}' ${PWD}/dump/${k}/kmers.count.Zscores.csv > ${PWD}/dump/${k}/kmers.count.Zscores.reordered.csv
gzip ${PWD}/dump/${k}/kmers.count.Zscores.csv
done
```



join to ... 

```
join --header -t, dump/11/kmers.count.csv dump/11/kmers.count.Zscores.reordered.csv > dump/11/kmers.count.Zscores.reordered.joined.csv
gzip dump/11/kmers.count.csv
gzip dump/11/kmers.count.Zscores.reordered.csv
```

process compute and print new kmer tsv files


```
head dump/11/kmers.count.Zscores.reordered.joined.csv
id,2_2,2_3,2_4,2_5,2_6,2_7,2_9,4_1,4_2,4_4,4_5,4_6,4_7,4_8,input,2_2_z,2_3_z,2_4_z,2_5_z,2_6_z,2_7_z,2_9_z,4_1_z,4_2_z,4_4_z,4_5_z,4_6_z,4_7_z,4_8_z,id_z,group_z,input
AAAAAAAAAAA,2.06771e+06,1.69886e+06,2.55093e+06,1.4488e+06,1.93295e+06,7.03636e+06,1.62142e+06,3.9394e+06,2.36225e+06,4.31637e+06,2.64691e+06,1.18312e+06,1.31434e+06,1.90985e+06,31515200,26.530141064702,30.8919296420663,18.6911943122779,22.5309953123833,29.3785741467186,23.7866483797062,18.6837993684122,30.0653679842025,31.3780339725042,16.0718009181584,17.8393861395377,15.7809851614883,16.6344122131289,13.1957945288144,AAAAAAAAAAA,73,31515200
AAAAAAAAAAC,44862.9,42188.3,50952.3,37149.5,47374.8,48311.6,40670.7,43069.7,42519.4,27173.1,30165.9,30920.9,33450.2,38277.3,122794,-0.57800306559934,-0.570723514857385,-0.479477805288554,-0.648244309535677,-0.537642773616751,-0.511306013336593,-0.608975875091876,2.33061579842224,-0.544299084571831,-0.354066676911819,-0.607227720803483,-0.649723217813516,-0.627730198719661,-0.687604090239235,AAAAAAAAAAC,69,122794
AAAAAAAAAAG,19860.5,21991.1,27012.8,15947,21304.6,40168.6,18902.9,21521.3,22412.8,20755.5,17560.3,12869.3,14457.7,21410.5,163393,-0.769270301537397,-0.746684201634108,-1.10635884698986,-0.751228254954141,-0.751623594775967,-0.681186790924955,-0.81213310982856,-0.136328788785707,-0.747129289391139,-0.585096423534813,-0.706870511412341,-0.749373278577219,-0.760092743561761,-0.923653158457521,AAAAAAAAAAG,70,163393
```



```

head dump/11/kmers.count.Zscores.reordered.joined.csv | awk -F, '(NR==1){ for(i=1;i<=NF;i++){ if($i=="input"){input_col=i;break}} print input_col}'



```









