

```
git clone https://github.com/ucsffrancislab/GECKO.git

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
export sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
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
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/Oligodendroglioma/)?"Oligo":"nonOligo"; print "'${GDATA}/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/Oligo.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/Astrocytoma/)?"Astro":"nonAstro"; print "'${GDATA}/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/Astro.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/GBM, IDH1R132H WT/)?"GBMWT":"nonGBMWT"; print "'${GDATA}/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/GBMWT.metadata.conf
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")"}((NR>1)&&($1!~/_11$/)){ g=($4~/GBM, IDH-mutant/)?"GBMmut":"nonGBMmut"; print "'${GDATA}/jellyfish/text/'"$2".ojf.tab\t"++i"\t"g}' /francislab/data1/raw/20210428-EV/metadata.csv > ${GDATA}/GBMmut.metadata.conf
```

Nextflow uses a Java VM so needs to be from a non-login dev node ( or as a job on the cluster )

```BASH
cd ${GECKO}/ImportMatrix
mkdir ${GDATA}/import
#/bin/rm -rf ${GDATA}/import/* ${GECKO}/ImportMatrix/work/* ${GECKO}/ImportMatrix/results/*

${sbatch} --job-name=decomposition --time=9999 --ntasks=4 --mem=30G --output=${GDATA}/decomposition.${date}.txt ${GECKO}/ImportMatrix/main.pl decomposition --singleEnd --outdir ${GDATA}/import --reads \'${GDATA}/input/\*.fastq.gz\' --kmersize ${k}
```




Can take quite a while depending on file size. 

Then cleanup.


















```
rm work/* -rf
find ${GDATA}/import -type f -exec chmod a-w {} \;
```




Now we need to split, which may be tricky.

```
cd ${GECKO}/ImportMatrix

for subset in Astro Oligo GBMWT GBMmut ; do
mkdir -p ${GDATA}/${subset}
${sbatch} --job-name=${subset}importation --time=9999 --ntasks=4 --mem=30G --output=${GDATA}/${subset}.importation.${date}.txt ${GECKO}/ImportMatrix/main.pl importation --groupconfig ${GDATA}/${subset}.metadata.conf --outdir ${GDATA}/${subset}
done
```













---


From notes and need "converted" ... ( note change of GDATA to GDATA/import



```
cd ${GECKO}/ImportMatrix

${sbatch} --job-name=importation --time=9999 --ntasks=4 --mem=30G --output=${GDATA}/importation.${date}.txt ${GECKO}/ImportMatrix/main.pl importation --groupconfig ${GECKO}/EV_IDHWT_metadata.conf --outdir ${GDATA}

${sbatch} --job-name=discretization --time=9999 --ntasks=4 --mem=30G --output=${GDATA}/discretization.${date}.txt ${GECKO}/ImportMatrix/main.pl discretization --matrix ${GDATA}/rawimport/matrix/RAWmatrix.matrix –-outdir ${GDATA}
```









The above does not put the output in `ev_IDHWT_import`.
Initially it had `-outdir` and not `--outdir`, which was incorrect, but not the problem.
Not sure what is special about this step.

This next step (filter) can take days depending on data size so ALWAYS run with nohup (or submit to queue).


```
mv ${GECKO}/ImportMatrix/results/discretization ${GDATA}/

${sbatch} --job-name=filter --time=9999 --ntasks=8 --mem=61G --output=${GDATA}/filter.${date}.txt ${GECKO}/ImportMatrix/main.pl filter --matrix ${GDATA}/discretization/matrix/DISCRETmatrix.matrix --outdir ${GDATA}


${sbatch} --job-name=real --time=999 --ntasks=8 --mem=61G --output=${GDATA}/real.${date}.txt ${GECKO}/ImportMatrix/main.pl real --matrixDiscrete ${GDATA}/filtering/matrix/FILTEREDmatrix.matrix --matrixRaw ${GDATA}/rawimport/matrix/RAWmatrix.matrix --outdir ${GDATA}


cd ${GECKO}/Gecko/algoGen/Producteurv2/utils

${sbatch} --job-name=transformIntoBinary --time=999 --ntasks=8 --mem=61G --output=${GDATA}/transformIntoBinary.${date}.txt --wrap="${GECKO}/Gecko/algoGen/Producteurv2/utils/transformIntoBinary ${GDATA}/filtering/final/FILTEREDmatrix_RealCounts.matrix ${GDATA}/filtering/final/FILTEREDmatrix_RealCounts.bin"

mkdir ${GDATA}/filtering/final/CutMatrix/

${sbatch} --job-name=indexBinary --time=999 --ntasks=8 --mem=61G --output=${GDATA}/indexBinary.${date}.txt --wrap="${GECKO}/Gecko/algoGen/Producteurv2/utils/indexBinary ${GDATA}/filtering/final/FILTEREDmatrix_RealCounts.bin ${GDATA}/filtering/final/CutMatrix/example.bin 1000"
```




```
cd ${GECKO}/Gecko/algoGen

/bin/rm -rf ../../Demo/DemoGeneticAlgResultDir/ slurm-*.out GECKO_*.* __pycache__/ plot_analysis_*.* 

find ${GDATA}/ -type f -exec chmod a-w {} \;


cd ${GECKO}/Gecko/algoGen

mkdir /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT
mkdir /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT/GeneticAlgResultDir
ln -s /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT/GeneticAlgResultDir ${GECKO}/EV_IDHWT/
${sbatch} --job-name=multipleGeckoStart --time=9999 --ntasks=4 --mem=30G --output=${GECKO}/EV_IDHWT/GeneticAlgResultDir/multipleGeckoStart.${date}.txt ${GECKO}/Gecko/algoGen/multipleGeckoStart.py ${GECKO}/EV_IDHWT/GA.conf ${k}

```

Job is submitted. Waiting ...




If running many, wrap it in a loop.

```


cd ${GECKO}/Gecko/algoGen

date=$( date "+%Y%m%d%H%M%S" )
#for i in $( seq 0 9 ) ; do

i=5
mkdir /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT/GeneticAlgResult${i}Dir
ln -s /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT/GeneticAlgResult${i}Dir ${GECKO}/EV_IDHWT/

cp ${GECKO}/EV_IDHWT/GA.conf ${GECKO}/EV_IDHWT/GA${i}.conf
vi ${GECKO}/EV_IDHWT/GA${i}.conf

${sbatch} --job-name=${i}multipleGeckoStart --time=999 --ntasks=4 --mem=30G --output=${GECKO}/EV_IDHWT/GeneticAlgResult${i}Dir/multipleGeckoStart.${date}.txt ${GECKO}/Gecko/algoGen/multipleGeckoStart.py ${GECKO}/EV_IDHWT/GA${i}.conf ${k}

#done

```



```
tar --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ cvf - /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/EV_IDHWT | gzip > 20210615-EV_IDHWT-Gecko.tar.gz

tar -cv --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ -f - EV_IDHWT | gzip > 20210615-EV_IDHWT-Gecko.tar.gz



tar -cv --directory /francislab/data1/users/gwendt/github/ucsffrancislab/GECKO/ -f - EV_IDHWT/GeneticAlgResult4Dir | gzip > 20210616-EV_IDHWT-Gecko.tar.gz

BOX="https://dav.box.com/dav/Francis _Lab_Share"

curl -netrc -T 20210616-EV_IDHWT-Gecko.tar.gz "${BOX}/"
```
