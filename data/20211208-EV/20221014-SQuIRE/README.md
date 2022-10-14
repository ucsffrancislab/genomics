
#	#	SQuIRE

https://github.com/wyang17/SQuIRE



The .fqgz extension confuses STAR and it seems to expect it to be uncompressed so link with a different extension.

```
RAW="/francislab/data1/working/20211208-EV/20221014-SQuIRE/raw"
mkdir -p $RAW
for f in /francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi/*quality.format.t1.t3.notphiX.notviral.?.fqgz ; do
echo $f
l=$( basename ${f/quality.format.t1.t3.notphiX.notviral./R} .fqgz ).fastq.gz
ln -s $f ${RAW}/${l}
done
```



