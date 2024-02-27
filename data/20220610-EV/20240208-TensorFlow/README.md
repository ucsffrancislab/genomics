
#	20220610-EV/20240208-TensorFlow



```
ln -s ../20240201-iMOKA/in
ln -s ../20240201-iMOKA/out
ln -s ../20240201-iMOKA/20210428.metadata.csv
ln -s ../20240201-iMOKA/20220610.metadata.csv
```



```
awk -F, '{print $2,$3}' 20210428.metadata.csv | sort | uniq -c
      1 blank1-(C1) 
      1 blank-2-(C1) 
     10 Diffuse-Astrocytoma IDH-mutant
     10 GBM IDH1R132H-WT
     10 GBM IDH-mutant
     10 Oligodendroglioma IDH-mutant
      2 V01-control-(S1) 
```



```
awk 'BEGIN{FS=",";OFS="\t"}($2=="Diffuse-Astrocytoma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="Oligodendroglioma"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH-mutant"){print $1,"IDH-MT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($2=="GBM" && $3=="IDH1R132H-WT"){print $1,"IDH-WT"}' 20210428.metadata.csv | shuf|shuf|shuf | tee >(head -8 >> train_ids.tsv) | tail -n 2 >> test_ids.tsv
```


```
awk -F, '{print $7,$8,$9}' 20220610.metadata.csv | sort | uniq -c
     18 case control control control
     18 case control GBM Primary
     17 case control GBM Recurrent
      6 longitudinal GBM pre-progression
      6 longitudinal GBM pre-surg
      6 longitudinal GBM progression
      5 longitudinal GBM stable
      1 Panattoni GBM post-recurrence
      1 Panattoni GBM recurence
      1 Panattoni LrGG primary
      1 Panattoni LrGG(?) scan
      6 Test-SE Test-SE Test-SE
```


```

awk 'BEGIN{FS=",";OFS="\t"}($7=="case control" && $8=="GBM" && $9=="Primary"){print $1,"IDH-WT"}' 20220610.metadata.csv | shuf|shuf|shuf | tee >(head -14 >> train_ids.tsv) | tail -n 4 >> test_ids.tsv
awk 'BEGIN{FS=",";OFS="\t"}($7=="case control" && $8=="control" && $9=="control"){print $1,"control"}' 20220610.metadata.csv | shuf|shuf|shuf | tee >(head -14 >> train_ids.tsv) | tail -n 4 >> test_ids.tsv

```

```
chmod 400 test_ids.tsv train_ids.tsv
```






```
for k in 10 ; do
./tf.bash ${k}
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}" --output="${PWD}/logs/tf.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n38 --wrap="module load WitteLab python3/3.9.1; ${PWD}/tf.py ${k}"
done
```





##	20240214

```
k=18
[gwendt@c4-dev3 /francislab/data1/working/20220610-EV/20240208-TensorFlow]$ sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="${k}" --output="${PWD}/tf_dt.${k}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=64 --mem=490G --exclude=c4-n38 --wrap="module load WitteLab python3/3.9.1 ; ${PWD}/tf_dt.py ${k}"
Submitted batch job 1684615
```




```
threads=16
maxRam=64
minCounts="0"
file_type="fq"
kmcCounterVal="4294967295"

mkdir kmc_dir

for kmer_len in 18 ; do
echo $kmer_len
for id in $( cut -f2 tf/18/create_matrix.tsv | paste -sd" " ) ; do
echo $id
ls -1 in/${id}_*.fastq.gz > kmc_dir/kmc_input
./bin/kmc -k${kmer_len} -t${threads} -m${maxRam} -cs${kmcCounterVal} -ci${minCounts} -b -${file_type} @kmc_dir/kmc_input kmc_dir/${id}.${kmer_len} ${TMPDIR} 2>> kmc_dir/kmc.err >> kmc_dir/kmc.out
done
done



for kmer_len in 18 ; do
echo $kmer_len
for id in $( cut -f2 tf/18/create_matrix.tsv | paste -sd" " ) ; do
id=${id}.${kmer_len}
echo $id
./bin/kmc_tools transform kmc_dir/${id} dump -s kmc_dir/${id}.raw.tsv
cat kmc_dir/${id}.raw.tsv | datamash sum 2 > kmc_dir/${id}.total_kmer_count
total_kmer_count=$( cat kmc_dir/${id}.total_kmer_count )
awk -v sample=${id} -v total_kmer_count=${total_kmer_count} 'BEGIN{FS=OFS="\t";print "kmer",sample}{$2=$2*1000000000/total_kmer_count;print}' kmc_dir/${id}.raw.tsv > kmc_dir/${id}.normalized.tsv
done
done


```




