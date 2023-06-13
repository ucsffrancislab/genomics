
#	20230217_costello_LG3_exomes_recal/20230613-MEGAnE





MEGAnE only supports paired-end WGS. Single-end WGS is not compatible. MEGAnE does not support WES.






/francislab/data1/refs/MEGAnE


```
mkdir in
for f in /costellolab/data3/jocostello/LG3/exomes_recal/*/*.bwa.realigned.rmDups.recal.bam ;do
b=$( basename $f .bwa.realigned.rmDups.recal.bam )
d=$( basename $( dirname $f ))
echo $f
echo $b
echo $d
if [ -s $f ] ; then
ln -s $f in/${d}.${b}.bam
ln -s $f.bai in/${d}.${b}.bam.bai
fi
done
```


Oddities

```
\rm in/PatientWU1.K00001.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00001.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00001.bam.bai
\rm in/PatientWU1.K00002.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00002.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00002.bam.bai
\rm in/PatientWU1.K00003.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00003.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00003.bam.bai
```




```

MEGAnE_array_wrapper.bash --threads 8 --extension .bam \
 --out ${PWD}/out \
 ${PWD}/in/*bam

```








---













MEGAnE doesn't seem to work with read length < 100

Check read lengths to see what completed

```
grep -l "read lenth = 51" out/*/for_debug.log | wc -l
104
```


Check for absent_MEs_genotyped.vcf to see if processing completed

```
ll -d out/* | wc -l
278

ll -d out/*/absent_MEs_genotyped.vcf | wc -l
174
```




This will create an outdir called `jointcall_out`

```

MEGAnE_aggregation_steps.bash --threads 64 \
--in  /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE

```



