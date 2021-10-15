

# iMOKA cross validation approach. 

Briefly, run iMOKA from start to finish separately on 5 different subsets of the dataset, and evaluate performance each time on the small held out test set. 

Do this for each of the 1 vs rest comparisons, total of four "1 v rest" comparisons. (GBMWT GBMmut Oligo Astro)

Do a 5-fold cross validation of iMOKA
For i in  of 1..5: 
* remove 2 samples from the 10 group, and 6 samples from the 30 "rest" group, save these as test set. 
  * Across the 5 iterations, every sample should only be held out once. 
* RUN iMOKA (from matrix reduction to end) on the 8 + 24 = 32 samples remaining as a training set for k=25 (I think that was the optimal one) 
* Record the average "acc" measurement and the average "ROC" measurement across the 50 RF models produced (on the training set). 
* If we can, run the left-out test samples through all 50 RFs and produce an average acc and average ROC.  Else, run the test samples on the BEST RF model if we can only access one model in the pickle file, IF SO, only record the acc and ROC for the step above on the training set on the same "best" model.  
* Output Training acc and ROC and Testing acc and ROC
done 

Overall output should be 4 columns of 5 values. (Train acc train ROC test acc test ROC)




```

ln -s /francislab/data1/raw/20210428-EV/metadata.csv
ln -s /francislab/data1/working/20210428-EV/20210830-iMOKA/config.json


for f in GBMWT GBMmut Oligo Astro ; do
for i in 1 2 3 4 5 ; do
dir=cutadapt2.25.${f}.${i}
mkdir -p ${dir}
ln -s /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25/preprocess ${dir}/

cat /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25/create_matrix.tsv \
  | awk 'BEGIN{FS=OFS="\t"}( ((x[$3]++)%5+1)!='${i}' ){print}' \
  | awk 'BEGIN{FS=OFS="\t"}($3!="'${f}'"){$3="non'${f}'"}{print}' > ${dir}/create_matrix.tsv

done ; done
```


Run each group vs nongroup

```
for f in Astro GBMmut GBMWT Oligo ; do
for i in 1 2 3 4 5 ; do
./iMOKA.bash --threads 64 -k 25 -s cutadapt2. -f ".${f}.${i}"
done ; done
```

Could have done something like ...
/c4/home/gwendt/github/ucsffrancislab/genomics/data/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/iMOKA_scratch.bash

