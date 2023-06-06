
#	20210428-EV/20230605-preprocessing





```
mkdir -p in

for f in /francislab/data1/raw/20210428-EV/Hansen/SFHH00*_R1_001.fastq.gz ; do
echo $f
l=$( basename ${f} _R1_001.fastq.gz )
echo $l
l=${l%_S*}
echo ${l}
ln -s ${f} in/${l}.fastq.gz
done
```



```
EV_preprocessing_array_wrapper.bash \
--extension .fastq.gz \
--out ${PWD}/out \
${PWD}/in/SFHH00*.fastq.gz
```



