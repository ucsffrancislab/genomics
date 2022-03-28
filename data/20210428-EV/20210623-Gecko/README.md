

```
git clone https://github.com/ucsffrancislab/GECKO.git
Don't do this. You'll need to compile everything.
ln -s ~/github/ucsffrancislab/GECKO

4 meta data files

4 matrices with k=21
GBM-WT vs All others
GBM-mutant vs All others
Oligo vs All others
Astro vs All others

Each run through the GA with conf parameters
kmer=10 and 20
Generation=5000
Individuals=600
Elite=5
generationRefreshLog=100
```

---

DO NOT USE --export=None with sbatch HERE. IT WILL FAIL.




```
export sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
export GECKO=/francislab/data1/working/20210428-EV/20210623-Gecko/GECKO
export GDATA=/francislab/data1/working/20210428-EV/20210623-Gecko/data
mkdir ${GDATA}
export k=21
date=$( date "+%Y%m%d%H%M%S" )
```






I am going to try to minimize duplicate processing so I will process the first steps just once.

Then I will have to split into 4 different subsets due to the 4 different comparisons.

I will then split each of those into 2 different GA runs.

All this needs to be run from a dev node due to Java VM related issues.



```
mkdir -p ${GDATA}/input
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.cutadapt2.fastq.gz ; do
echo $f
base=$( basename $f .cutadapt2.fastq.gz )
ln -s $f ${GDATA}/input/${base}.fastq.gz
done
```

Remove control data

```
awk -F, '($1~/_11$/){print "rm -f ${GDATA}/input/"$2".fastq.gz"}' /francislab/data1/raw/20210428-EV/metadata.csv
rm -f ${GDATA}/input/SFHH005k.fastq.gz
rm -f ${GDATA}/input/SFHH005v.fastq.gz
rm -f ${GDATA}/input/SFHH005ag.fastq.gz
rm -f ${GDATA}/input/SFHH005ar.fastq.gz
```

Create matrix conf files.

```
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/Oligodendroglioma/)?"Oligo":"nonOligo"; print "'${GDATA}/import/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/Oligo.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/Astrocytoma/)?"Astro":"nonAstro"; print "'${GDATA}/import/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/Astro.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/GBM, IDH1R132H WT/)?"GBMWT":"nonGBMWT"; print "'${GDATA}/import/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/GBMWT.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/GBM, IDH-mutant/)?"GBMmut":"nonGBMmut"; print "'${GDATA}/import/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/GBMmut.metadata.conf
```

Nextflow uses a Java VM so needs to be from a non-login dev node ( or as a job on the cluster )

```BASH
cd ${GECKO}/ImportMatrix
mkdir ${GDATA}/import
#/bin/rm -rf ${GDATA}/import/* ${GECKO}/ImportMatrix/work/* ${GECKO}/ImportMatrix/results/*

${sbatch} --job-name=decomposition --time=480 --ntasks=4 --mem=30G --output=${GDATA}/decomposition.${date}.txt ${GECKO}/ImportMatrix/main.pl decomposition --singleEnd --outdir ${GDATA}/import --reads ${GDATA}/input/\*.fastq.gz --kmersize ${k}
```

Can take quite a while depending on file size. 

Then cleanup.


```
rm work/* -rf
find ${GDATA}/import -type f -exec chmod a-w {} \;
```






1440 = 24 hours
2880 = 48 hours
5760 = 96 hours



Now we need to split, which may be tricky.

```
cd ${GECKO}/ImportMatrix

for subset in Astro Oligo GBMWT GBMmut ; do
mkdir -p ${GDATA}/${subset}
${sbatch} --job-name=${subset}importation --time=2880 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.importation.${date}.txt ${GECKO}/ImportMatrix/main.pl importation --groupconfig ${GDATA}/${subset}.metadata.conf --outdir ${GDATA}/${subset}
done
```





For the moment, this next step must be submitted and dealt with 1 at a time. 
The output goes to the same place so afterwards, the output will need to be moved before another data set can be run.
Not sure what is special about this step.


```
cd ${GECKO}/ImportMatrix
date=$( date "+%Y%m%d%H%M%S" )

subset=Astro
${sbatch} --job-name=${subset}discretization --time=2880 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.discretization.${date}.txt ${GECKO}/ImportMatrix/main.pl discretization --matrix ${GDATA}/${subset}/rawimport/matrix/RAWmatrix.matrix –-outdir ${GDATA}/${subset}
mv ${GECKO}/ImportMatrix/results/discretization ${GDATA}/${subset}/


subset=Oligo
${sbatch} --job-name=${subset}discretization --time=2880 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.discretization.${date}.txt ${GECKO}/ImportMatrix/main.pl discretization --matrix ${GDATA}/${subset}/rawimport/matrix/RAWmatrix.matrix –-outdir ${GDATA}/${subset}
mv ${GECKO}/ImportMatrix/results/discretization ${GDATA}/${subset}/


subset=GBMWT
${sbatch} --job-name=${subset}discretization --time=2880 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.discretization.${date}.txt ${GECKO}/ImportMatrix/main.pl discretization --matrix ${GDATA}/${subset}/rawimport/matrix/RAWmatrix.matrix –-outdir ${GDATA}/${subset}
mv ${GECKO}/ImportMatrix/results/discretization ${GDATA}/${subset}/


subset=GBMmut
${sbatch} --job-name=${subset}discretization --time=2880 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.discretization.${date}.txt ${GECKO}/ImportMatrix/main.pl discretization --matrix ${GDATA}/${subset}/rawimport/matrix/RAWmatrix.matrix –-outdir ${GDATA}/${subset}
mv ${GECKO}/ImportMatrix/results/discretization ${GDATA}/${subset}/
```


This next step (filter) can take days depending on data size so ALWAYS run with nohup (or submit to queue).


```
cd ${GECKO}/ImportMatrix
date=$( date "+%Y%m%d%H%M%S" )

for subset in Astro Oligo GBMWT GBMmut ; do
${sbatch} --job-name=${subset}filter --time=2880 --ntasks=8 --mem=61G --output=${GDATA}/${subset}.filter.${date}.txt ${GECKO}/ImportMatrix/main.pl filter --matrix ${GDATA}/${subset}/discretization/matrix/DISCRETmatrix.matrix --outdir ${GDATA}/${subset}
done
```

```
export sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
export GECKO=/francislab/data1/working/20210428-EV/20210623-Gecko/GECKO
export GDATA=/francislab/data1/working/20210428-EV/20210623-Gecko/data
export k=21

date=$( date "+%Y%m%d%H%M%S" )
cd ${GECKO}/ImportMatrix

for subset in Astro Oligo GBMWT GBMmut ; do
${sbatch} --job-name=${subset}real --time=1440 --ntasks=8 --mem=61G --output=${GDATA}/${subset}.real.${date}.txt ${GECKO}/ImportMatrix/main.pl real --matrixDiscrete ${GDATA}/${subset}/filtering/matrix/FILTEREDmatrix.matrix --matrixRaw ${GDATA}/${subset}/rawimport/matrix/RAWmatrix.matrix --outdir ${GDATA}/${subset}
done
```





```
export sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
export GECKO=/francislab/data1/working/20210428-EV/20210623-Gecko/GECKO
export GDATA=/francislab/data1/working/20210428-EV/20210623-Gecko/data
export k=21

date=$( date "+%Y%m%d%H%M%S" )
cd ${GECKO}/Gecko/algoGen/Producteurv2/utils

for subset in Astro Oligo GBMWT GBMmut ; do
${sbatch} --job-name=${subset}transformIntoBinary --time=1440 --ntasks=8 --mem=61G --output=${GDATA}/${subset}.transformIntoBinary.${date}.txt --wrap="${GECKO}/Gecko/algoGen/Producteurv2/utils/transformIntoBinary ${GDATA}/${subset}/filtering/final/FILTEREDmatrix_RealCounts.matrix ${GDATA}/${subset}/filtering/final/FILTEREDmatrix_RealCounts.bin"
done
```







Not sure of the purpose of this step. Skipping to see if any repercussions(sp?)

```
date=$( date "+%Y%m%d%H%M%S" )
cd ${GECKO}/Gecko/algoGen/Producteurv2/utils

for subset in Astro Oligo GBMWT GBMmut ; do
mkdir ${GDATA}/${subset}/filtering/final/CutMatrix/
${sbatch} --job-name=${subset}indexBinary --time=1440 --ntasks=8 --mem=61G --output=${GDATA}/${subset}.indexBinary.${date}.txt --wrap="${GECKO}/Gecko/algoGen/Producteurv2/utils/indexBinary ${GDATA}/${subset}/filtering/final/FILTEREDmatrix_RealCounts.bin ${GDATA}/${subset}/filtering/final/CutMatrix/example.bin 1000"
done
```










```
cd ${GECKO}/Gecko/algoGen

/bin/rm -rf ../../Demo/DemoGeneticAlgResultDir/ slurm-*.out GECKO_*.* __pycache__/ plot_analysis_*.* 

find ${GDATA}/ -type f -exec chmod a-w {} \;
```



Prepare GA conf files for all runs.

```
vi ${GDATA}/GA.conf

Generation=5000
Individuals=600
Elite=5
generationRefreshLog=100
```


Copy GA conf files for each run.
```
for subset in Astro Oligo GBMWT GBMmut ; do
cp ${GDATA}/GA.conf ${GDATA}/${subset}/GA.10.conf
cp ${GDATA}/GA.conf ${GDATA}/${subset}/GA.20.conf
done
```


Set pathLog and pathData
Set kmer=10 and 20

```
vi ${GDATA}/*/GA.??.conf
```


```
date=$( date "+%Y%m%d%H%M%S" )
cd ${GECKO}/Gecko/algoGen

for subset in Astro Oligo GBMWT GBMmut ; do
for kmer in 10 20 ; do
${sbatch} --job-name=${subset}${kmer}multipleGeckoStart --time=5760 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.${kmer}.multipleGeckoStart.${date}.txt ${GECKO}/Gecko/algoGen/multipleGeckoStart.py ${GDATA}/${subset}/GA.${kmer}.conf ${k}
done ; done
```

Job is submitted. Waiting ...



```
cd /francislab/data1/working/20210428-EV/
tar cvf - 20210623-Gecko/data | gzip > 20210623-Gecko.tar.gz

BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV"

curl -netrc --progress-bar -T 20210623-Gecko.tar.gz "${BOX}/"
```







---


From notes and need "converted" ... ( note change of GDATA to GDATA/import








```
tar --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ cvf - /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT | gzip > 20210615-EV_IDHWT-Gecko.tar.gz

tar -cv --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ -f - EV_IDHWT | gzip > 20210615-EV_IDHWT-Gecko.tar.gz



tar -cv --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ -f - EV_IDHWT/GeneticAlgResult4Dir | gzip > 20210616-EV_IDHWT-Gecko.tar.gz

BOX="https://dav.box.com/dav/Francis _Lab_Share"

curl -netrc -T 20210616-EV_IDHWT-Gecko.tar.gz "${BOX}/"
```



