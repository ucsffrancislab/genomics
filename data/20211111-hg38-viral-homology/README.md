



```

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-982%10 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211111-hg38-viral-homology/array_wrapper.bash

```


```

./prep_refs.bash

```


```
cat for_reference/*.fasta > for_reference.fasta


module load bowtie2

bowtie2-build --threads 16 for_reference.fasta double_masked_viral 
chmod -w double_masked*

```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```




