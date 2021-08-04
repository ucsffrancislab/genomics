


```
mkdir -p raw
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.cutadapt2.fastq.gz ; do
echo $f
base=$( basename $f .cutadapt2.fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```

Remove control data

```
awk -F, '($1~/_11$/){print "rm -f raw/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv

rm -f raw/SFHH005k.fastq.gz
rm -f raw/SFHH005v.fastq.gz
rm -f raw/SFHH005ag.fastq.gz
rm -f raw/SFHH005ar.fastq.gz
```


```
awk 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/Astro/){group="Astro"}($4~/Oligo/){group="Oligo"}($4~/GBM, IDH-mutant/){group="GBMmut"}($4~/GBM, IDH1R132H WT/){group="GBMWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20210706-iMoka/raw/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > source.tsv
```



```
singularity exec /francislab/data2/refs/singularity/iMOKA.img preprocess.sh -h 

usage: 
	preprocess.sh -i input_file -o output_dir -k kmer_length -l [fr|rf] [-K][-h][-t int][-r int][q][-m int][-c int][-h]

	-i|--input-file STR	 A tab separated value file containing in the first column the sample name, 
				 in the second the group and in the third the file location. 
				 This last can be local, http, ftp or SRR/ERR.
				 If it's a list, it has to be column (;) separated

	-o|--output-dir STR	 The output directory. If doesn't exists, it will be created. Default "./preprocess/"

	-m|--min-counts INT	 Don't consider k-mer present less than the given threshold. Default 5

	-c|--counter-val INT	 Kmc counter value. Suggest to keep the default 4294967295, that is also the maximum available.

	-k|--kmer-length INT	 The length of the k-mer. Default 31

	-l|--library-type [NULL|fr|rf|ff|rr]
				 The type of stranded library. In case of presence of one or more "r" file, it will be converted to its complementary reverse.

	-t|--threads INT	 Number of threads to use. Default 1

	-r|--ram INT		 Max ram used by kmc in Gb. Default 12

	-K|--keep-files		 Keep the intermediate files.

	-q|--use-fastqc		 Assert the quality of the fastq files using fastqc.

	-h|--help		 Show this help.
```

```
date=$( date "+%Y%m%d%H%M%S" )

${sbatch} --job-name=iMOKA --time=60 --ntasks=8 --mem=61G --output=${PWD}/iMOKA.preprocess.21.${date}.txt --wrap="singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA.img preprocess.sh --input-file /francislab/data1/working/20210428-EV/20210706-iMoka/source.tsv --kmer-length 21 --ram 60 --threads 8"
```






```
singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA.img iMOKA_core create -h
Environmental var OMP_NUM_THREADS is not defined. Using 1 thread.
To use a different number of thread, export the variable before running iMOKA:
export OMP_NUM_THREADS=4 
Environmental var IMOKA_MAX_MEM_GB is not defined. Using 2 Gb as default.
 To use a different thershold, export the variable before running iMOKA:
export IMOKA_MAX_MEM_GB=2
ERROR! Missing mandatory argument: input
ERROR! Missing mandatory argument: output
Binary matrix handler
Usage:
  KMA [OPTION...]

  -i, --input arg        Input tsv file containing the informations in three
                         columns:
			[file][id][group]
  -o, --output arg       Output JSON file
  -p, --prefix-size arg  The prefix size to use in the binary databases.
                         Default will compute the best size. (default: -1)
  -h, --help             Show this help
  -r, --rescaling arg    Rescaling factor (default: 1e9)
```

```
date=$( date "+%Y%m%d%H%M%S" )

${sbatch} --job-name=iMOKA --time=1440 --ntasks=8 --mem=61G --output=${PWD}/iMOKA.create.21.${date}.txt --wrap="singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA.img iMOKA_core create --input /francislab/data1/working/20210428-EV/20210706-iMoka/create_matrix.tsv --output /francislab/data1/working/20210428-EV/20210706-iMoka/matrix.json"
```





```
singularity exec /francislab/data2/refs/singularity/iMOKA.img iMOKA_core reduce -h
Environmental var OMP_NUM_THREADS is not defined. Using 1 thread.
To use a different number of thread, export the variable before running iMOKA:
export OMP_NUM_THREADS=4 
Environmental var IMOKA_MAX_MEM_GB is not defined. Using 2 Gb as default.
 To use a different thershold, export the variable before running iMOKA:
export IMOKA_MAX_MEM_GB=2
Help for the classification 
Reduce a k-mer matrix in according to the classification power of each k-mer
Usage:
  iMOKA reduce [OPTION...]

  -i, --input arg               The input matrix JSON header
  -o, --output arg              Output matrix file
  -h, --help                    Show this help
  -a, --accuracy arg            Minimum of accuracy (default: 65)
  -t, --test-percentage arg     The percentage of the min class used as test
                                size (default: 0.25)
  -e, --entropy-adjustment-one arg
                                The a1 adjustment value of the entropy filter
                                (default: 0.25)
  -E, --entropy-adjustment-two arg
                                The a2 adjustment value of the entropy filter
                                (default: 0.05)
  -c, --cross-validation arg    Maximum number of cross validation (default:
                                100)
  -s, --standard-error arg      Standard error to achieve convergence in
                                cross validation. Suggested between 0.5 and 2
                                (default: 0.5)
  -v, --verbose-entropy arg     Print the given number of k-mers for each
                                thread, the entropy and the entropy threshold
                                that would have been used as additional columns.
                                Useful to evaluate the efficency of the
                                entropy filter. Defualt: 0 ( Disabled ) (default: 0)
  -m, --min arg                 Minimum raw count that at least one sample
                                has to have to consider a k-mer (default: 5)
```

```
date=$( date "+%Y%m%d%H%M%S" )

${sbatch} --job-name=iMOKA --time=1440 --ntasks=8 --mem=61G --output=${PWD}/iMOKA.reduce.21.${date}.txt --wrap="singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA.img iMOKA_core reduce --input /francislab/data1/working/20210428-EV/20210706-iMoka/matrix.json --output /francislab/data1/working/20210428-EV/20210706-iMoka/reduced.matrix"
```







```
singularity exec /francislab/data2/refs/singularity/iMOKA.img iMOKA_core aggregate -h

Environmental var OMP_NUM_THREADS is not defined. Using 1 thread.
To use a different number of thread, export the variable before running iMOKA:
export OMP_NUM_THREADS=4 
Environmental var IMOKA_MAX_MEM_GB is not defined. Using 2 Gb as default.
 To use a different thershold, export the variable before running iMOKA:
export IMOKA_MAX_MEM_GB=2
ERROR! Missing mandatory argument: input
ERROR! Missing mandatory argument: output

Aggregate overlapping k-mers
Usage:
  iMOKA [OPTION...]

  -i, --input arg               Input file containing the informations...
  -o, --output arg              Basename of the output files (default:
                                ./aggregated)
  -h, --help                    Show this help
  -w, --shift arg               Maximum shift considered during the edges
                                creation (default: 1)
  -t, --origin-threshold arg    Mininum value needed to create a graph
                                (default: 80)
  -T, --global-threshold arg    Global minimum value for whom the nodes will
                                be used to build the graphs (default: 70)
  -d, --de-coverage-threshold arg
                                Consider ad differentially expressed a gene
                                if at least one trascipt is covered for more
                                than this threshold in sequences. (default: 50)
  -m, --mapper-config arg       Mapper configuration JSON file (default:
                                nomap)
      --corr arg                Agglomerate k-mers with a correlation higher
                                than this threshold and in the same gene or
                                unmapped. (default: 1)
  -c, --count-matrix arg        The count matrix. (default: nocount)
  -p, --perfect-match           Don't consider sequences with mismatches or
                                indels
```

```
date=$( date "+%Y%m%d%H%M%S" )

${sbatch} --job-name=iMOKA --time=1440 --ntasks=8 --mem=61G --output=${PWD}/iMOKA.aggregate.21.${date}.txt --wrap="singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA-1.0.img iMOKA_core aggregate --input /francislab/data1/working/20210428-EV/20210706-iMoka/reduced.matrix --count-matrix /francislab/data1/working/20210428-EV/20210706-iMoka/matrix.json --mapper-config default --output /francislab/data1/working/20210428-EV/20210706-iMoka/aggregated"
```


Aggregate step complains but works only with iMOKA-1.0.img





```
singularity exec /francislab/data2/refs/singularity/iMOKA.img random_forest.py -h

usage: random_forest.py [-h] [-r ROUNDS] [-t THREADS] [-m MAX_FEATURES]
                        [-n N_TREES] [-c CROSS_VALIDATION]
                        [-p PROPORTION_TEST]
                        input output

Find the most important fatures using random forest classifiers.

positional arguments:
  input                 Input file, containing the k-mer or feature matrix.
                        First line have to contain the samples names, the
                        second line the corresponding groups, or NA if
                        unknown. The first column has to be the feaures names.
                        The matrix is then organized with features on the rows
                        and samples on the columns.
  output                Output file in json format

optional arguments:
  -h, --help            show this help message and exit
  -r ROUNDS, --rounds ROUNDS
                        The number of random forests to create. Default:1
  -t THREADS, --threads THREADS
                        The number of threads to use. Default: -1 (automatic)
  -m MAX_FEATURES, --max-features MAX_FEATURES
                        The maximum number of features to use. Default: 10
  -n N_TREES, --n-trees N_TREES
                        The number of trees used to evaluate the feature
                        importance. Default: 1000
  -c CROSS_VALIDATION, --cross-validation CROSS_VALIDATION
                        Cross validation used to determine the metrics of the
                        models. Default: 10
  -p PROPORTION_TEST, --proportion-test PROPORTION_TEST
                        Proportion of test set
```

```
date=$( date "+%Y%m%d%H%M%S" )

${sbatch} --job-name=iMOKA --time=1440 --ntasks=8 --mem=61G --output=${PWD}/iMOKA.random_forest.21.${date}.txt --wrap="singularity exec --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA_extended-1.1.img random_forest.py --threads 8 /francislab/data1/working/20210428-EV/20210706-iMoka/aggregated.kmers.matrix /francislab/data1/working/20210428-EV/20210706-iMoka/output"
```




```
singularity instance start --bind=/francislab/:/francislab/ /francislab/data2/refs/singularity/iMOKA_extended-1.1.img instance_name
singularity instance list
singularity shell instance://instance_name
singularity instance list
singularity instance stop --all
singularity instance list
```




```

iMOKA-1.1 preprocess produces no kmer binary files???

Warning! File /francislab/data1/working/20210428-EV/20210706-iMoka/17/preprocess/SFHH005a/SFHH005a.tsv is empty and will be ignored.
Error! Empty file ./tmp_dir/kma.input
[gwendt@c4-dev1 /francislab/data1/working/20210428-EV/20210706-iMoka]$ cat 17/preprocess/SFHH005a/logs/kmc.out 

Stage 1: 100%
Stage 2: 100%
1st stage: 6.36902s
2nd stage: 1.4746s
Total    : 7.84362s
Tmp size : 208MB

Stats:
   No. of k-mers below min. threshold :     28740666
   No. of k-mers above max. threshold :            0
   No. of unique k-mers               :     36260819
   No. of unique counted k-mers       :      7520153
   Total no. of k-mers                :    140002273
   Total no. of reads                 :      3185159
   Total no. of super-k-mers          :     31315687
```




```
./iMOKA.bash
```




```

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV/21"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 21/aggregated.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV/31"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 31/aggregated.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV/35"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 35/aggregated.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV/37"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 37/aggregated.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210706-iMoka_20210428-EV/41"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 41/aggregated.json "${BOX}/"
```




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka"
curl -netrc -X MKCOL "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/31"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 31/aggregated.json "${BOX}/"
curl -netrc -T 31/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/41"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 41/aggregated.json "${BOX}/"
curl -netrc -T 41/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/51"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 51/aggregated.json "${BOX}/"
curl -netrc -T 51/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/61"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 61/aggregated.json "${BOX}/"
curl -netrc -T 61/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/71"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 71/aggregated.json "${BOX}/"
curl -netrc -T 71/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/81"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 81/aggregated.json "${BOX}/"
curl -netrc -T 81/output.json "${BOX}/"
```


```
for s in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005z.*.fastq.gz ; do 
s=$( basename $s .fastq.gz )
s=${s#SFHH005z.}
dir=raw.${s}
mkdir -p ${dir}
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.${s}.fastq.gz ; do
echo $f
base=$( basename $f .${s}.fastq.gz )
ln -s $f ${dir}/${base}.fastq.gz
done
awk -F, -v dir=${dir} '($1~/_11$/){print "rm -f "dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv
awk -v dir=${dir} 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/Astro/){group="Astro"}($4~/Oligo/){group="Oligo"}($4~/GBM, IDH-mutant/){group="GBMmut"}($4~/GBM, IDH1R132H WT/){group="GBMWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20210706-iMoka/"dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > ${dir}.source.tsv
done
```



```
s=31.cutadapt2
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=31.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=25.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"

s=31.cutadapt2.IDH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
```



```
for s in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005z.*.fastq.gz ; do 
s=$( basename $s .fastq.gz )
s=${s#SFHH005z.}
dir=raw.${s}
awk -v dir=${dir} 'BEGIN{FPAT = "([^,]+)|(\"[^\"]+\")";OFS="\t"}{group=""}( (NR==1) || ($4~/blank/) || ($4~/control/) ){next}($4~/IDH-mutant/){group="IDHmut"}($4~/IDH1R132H WT/){group="IDHWT"}{print $2,group,"/francislab/data1/working/20210428-EV/20210706-iMoka/"dir"/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv > ${dir}.source.IDH.tsv
done
```

```
for i in 16 17 19 21 23 25 ; do
s=${i}.cutadapt2.lte30
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done

for i in 21 27 29 ; do
s=${i}.cutadapt2.IDH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```






```
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="Oligo"){$2="nonOligo"}{print}' > cutadapt2.source.Oligo.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="Astro"){$2="nonAstro"}{print}' > cutadapt2.source.Astro.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="GBMmut"){$2="nonGBMmut"}{print}' > cutadapt2.source.GBMmut.tsv
cat cutadapt2.source.tsv  | awk 'BEGIN{FS=OFS="\t"}($2!="GBMWT"){$2="nonGBMWT"}{print}' > cutadapt2.source.GBMWT.tsv

./iMOKA.bash

for i in 25 30 35 ; do
for x in Astro Oligo GBMWT GBMmut ; do
s=${i}.cutadapt2.${x}
echo $s
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done ; done

for i in 45 50 55 60 65 70 75 ; do
s=${i}.cutadapt2
echo $s
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210706-iMoka/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done
```




