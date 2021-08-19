# Kallisto / Sleuth


```
./kallisto.bash
```



```
module load r
R

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(version = "3.13", update = TRUE, ask = FALSE)
BiocManager::install(c("rhdf5"), version = "3.13", update = TRUE, ask = FALSE)


install.packages(c("devtools","cowplot"))
devtools::install_github("pachterlab/sleuth")


install.packages('IRkernel')
IRkernel::installspec()
IRkernel::installspec(user = TRUE)

```


Not sure if sleuth works for more than 2 groups
```
echo "id,cc" > metadata.csv
awk '{print $1","$2}' /francislab/data1/working/20210428-EV/20210706-iMoka/source.tsv >> metadata.csv
```



```
export metadata=/francislab/data1/working/20210428-EV/20210818-kallisto/metadata.csv
export datapath=/francislab/data1/working/20210428-EV/20210818-kallisto/kallisto/
export suffix=hrna_15

jupyter nbconvert --to html --execute --ExecutePreprocessor.timeout=600 --output test.html ~/.local/bin/sleuth.ipynb

sed -i "s/<title>sleuth<\/title>/<title>${suffix}<\/title>/" ${output}
sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${suffix}'<\/h1>/' ${output}
```



