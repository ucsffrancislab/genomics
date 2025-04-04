#	20250128-Illumina-PhIP/20250312-tensorflow


Running SHAP in Rmd doesn't not produce an HTML file with the graphics.
There may be a workaround but I have not found one.

Trying to create simple python scripts, convert them to notebooks, then execute to create HTML

```
python3 -m pip install --user --upgrade jupyter jupyter-core jupytext nbconvert

```


Something like 
```
jupytext --to notebook test.py 
[jupytext] Reading test.py in format py
[jupytext] Writing test.ipynb (destination file replaced [use --update to preserve cell outputs and ids])

jupyter nbconvert --execute test.ipynb --to html
[NbConvertApp] Converting notebook test.ipynb to html
[NbConvertApp] Writing 273362 bytes to test.html
```


Here we go.


```
jupytext --to notebook 20250313-predict_HHV8_ORF73.py
jupyter nbconvert --execute --to html 20250313-predict_HHV8_ORF73.ipynb 
box_upload.bash 20250313-predict_HHV8_ORF73.html


jupytext --to notebook 20250313-SHAP-Census_income_classification_with_Keras.py
jupyter nbconvert --execute --to html 20250313-SHAP-Census_income_classification_with_Keras.ipynb
box_upload.bash 20250313-SHAP-Census_income_classification_with_Keras.html 

```

it'd be nice to allow the output cells to minimize in html as they do in the live notebook






```
jupytext --to notebook 20250314-predict_HHV8_ORF73.py
jupyter nbconvert --execute --to html 20250314-predict_HHV8_ORF73.ipynb 
box_upload.bash 20250314-predict_HHV8_ORF73.html
```



Create `footer.html` that should be include in the generated html files.
It creates toggles to shrink the output cells.




##	20250317


Could convert in a one-liner, but just trades clarity for confusion
```
jupyter nbconvert --execute --to html --output-dir ${PWD} --output testing <( jupytext --to notebook 20250317-SHAP-README.py -o - )
```

```
jupytext --to notebook 20250317-SHAP-README.py
jupyter nbconvert --execute --to html 20250317-SHAP-README.ipynb
box_upload.bash 20250317-SHAP-README.html
```





HeV9 - Human erythrovirus V9
HIV1 - Human immunodeficiency virus 1
HPV180 - Human papillomavirus type me180




```
for f in 20250317-predict_HHV8_ORF73 20250317-predict_HHV3_ORF66 20250317-predict_HHV3 20250317-predict_HHV8 20250317-predict_HeV9 20250317-predict_HIV1 20250317-predict_HPV180 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${f#20250317-predict_} --output=${PWD}/${f}.out --wrap="${PWD}/${f}.py"
done

for f in 20250317-predict_HHV8_ORF73 20250317-predict_HHV3_ORF66 20250317-predict_HHV3 20250317-predict_HHV8 20250317-predict_HeV9 20250317-predict_HIV1 20250317-predict_HPV180 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${f#20250317-predict_} --output=${PWD}/${f}.jupyter.out --wrap="jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --to html --output-dir ${PWD} --output ${f}"
done

cat footer.html >> 20250317-predict_HHV3.html
box_upload.bash 20250317-predict_HHV3.html

cat footer.html >> 20250317-predict_HHV3_ORF66.html
box_upload.bash 20250317-predict_HHV3_ORF66.html

cat footer.html >> 20250317-predict_HHV8.html
box_upload.bash 20250317-predict_HHV8.html

cat footer.html >> 20250317-predict_HHV8_ORF73.html
box_upload.bash 20250317-predict_HHV8_ORF73.html
```




Should make the number of nodes relative to the number of tiles.

grep -c "Human erythrovirus V9" VIR3_clean.id_species_protein.uniq.csv 
10
grep -c "Human immunodeficiency virus 1" VIR3_clean.id_species_protein.uniq.csv 
2500
grep -c "Human papillomavirus type me180" VIR3_clean.id_species_protein.uniq.csv 
24
grep -c "Human herpesvirus 8" VIR3_clean.id_species_protein.uniq.csv 
2325
grep -c "Human herpesvirus 3" VIR3_clean.id_species_protein.uniq.csv 
1653



Then make these calls a single prediction script with parameters, again.


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=test --output=${PWD}/Human_erythrovirus_V9.out --wrap="${PWD}/20250318-predict.py --species 'Human erythrovirus V9'"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=test --output=${PWD}/Human_papillomavirus_type_me180.out --wrap="${PWD}/20250318-predict.py --species 'Human papillomavirus type me180'"
```


##	20250319

Notebooks don't inherently read command line params when run with nbconvert. 
papermill is a possibly alternative, but for now environment variables are used.


```

f=20250318-predict

s='Human papillomavirus type me180'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human erythrovirus V9'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human immunodeficiency virus 1'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human immunodeficiency virus 2'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human herpesvirus 5'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Alphapapillomavirus 9'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"



s='Human herpesvirus 8'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.AllORF73"


f=20250318-predict
s='Human herpesvirus 8'
i=0
for p in "ORF 73" "Orf73" "ORF73" "Protein ORF73" ; do
i=$[i+1]
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${i}.${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${p// /_}.$i"
done

```





##	20250320


```
f=20250320-predict
s='Human herpesvirus 8'
i=0
for p in "ORF 73" "Orf73" "ORF73" "Protein ORF73" ; do
i=$[i+1]
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${i}.${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${p// /_}.$i"
done

p=UL9
s="Human herpesvirus 5"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${p// /_}"

p="Serine/threonine-protein kinase US3 homolog (Protein kinase ORF66) (EC 2.7.11.1)"
s="Human herpesvirus 3"
safe_p=${p//[^a-zA-Z0-9_]/}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${safe_p}.${s// /_} --output=${PWD}/${f}.${s// /_}.${safe_p}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${safe_p}"



f=20250320-predict
s='Human herpesvirus 8'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.AllORF73"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73b.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73b.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; ${PWD}/${f}.py"


f=20250321-predict_sklearn
s='Human herpesvirus 8'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; ${PWD}/${f}.py"

```


The option --ExecutePreprocessor.timeout=-1 disables the cell execution timeout whose default value is 30 seconds.


sklearn models were never better than 56%


##	20250324


```
f=20250320-predict

p=UL9
s="Human herpesvirus 5"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${p// /_}"

p="Serine/threonine-protein kinase US3 homolog (Protein kinase ORF66) (EC 2.7.11.1)"
s="Human herpesvirus 3"
safe_p=${p//[^a-zA-Z0-9_]/}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${safe_p}.${s// /_} --output=${PWD}/${f}.${s// /_}.${safe_p}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${safe_p}"

s='Human herpesvirus 8'
i=0
for p in "ORF 73" "Orf73" "ORF73" "Protein ORF73" ; do
i=$[i+1]
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${i}.${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${p// /_}.$i"
done

s='Human herpesvirus 8'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.AllORF73"

s='Alphapapillomavirus 9'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human papillomavirus type me180'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"



s='Human immunodeficiency virus 1'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"

s='Human immunodeficiency virus 2'
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}"



nbclient.exceptions.DeadKernelError: Kernel died

Rerunning HHV5 with 120G to test. Died again.

f=20250320-predict
s="Human herpesvirus 5"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${s// /_} --output=${PWD}/${f}.${s// /_}.jupyter.out --wrap="export SPECIES='${s}'; ${PWD}/${f}.py"

s="Human herpesvirus 6A" failed as well
s="Human herpesvirus 7" failed as well
Think this is due to too many nodes in the NN





python3 -m pip install --upgrade --user pip numpy numba tensorflow-cpu shap==0.47.0 pandas jupyter jupytext matplotlib


##	20250326


```
f=20250320-predict

s='Alphapapillomavirus 9'
for p in "E1 (Fragment)" "Major capsid protein L1" "Minor capsid protein L2" "Replication protein E1 (EC 3.6.4.12) (ATP-dependent helicase E1)" ; do
safe_p=${p//[^a-zA-Z0-9_]/}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${safe_p}.${s// /_} --output=${PWD}/${f}.${s// /_}.${safe_p}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${safe_p}"
done

s='Human herpesvirus 3'
for p in "Deneddylase (EC 3.4.19.12) (EC 3.4.22.-) (Ubiquitin thioesterase)" "Putative uncharacterized protein" "Tegument protein" ; do
safe_p=${p//[^a-zA-Z0-9_]/}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${safe_p}.${s// /_} --output=${PWD}/${f}.${s// /_}.${safe_p}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${safe_p}"
done

s='Human herpesvirus 5'
for p in "Deneddylase (EC 3.4.19.12) (EC 3.4.22.-) (Tegument protein VP1-2) (Tegument protein VP1/2)" "Envelope glycoprotein O" "Glycoprotein B (Fragment)" "Large structural phosphoprotein (150 kDa matrix phosphoprotein) (150 kDa phosphoprotein) (pp150) (Basic phosphoprotein) (BPP) (Phosphoprotein UL32) (Tegument protein UL32)" "Membrane protein RL12" "Protein UL150" ; do
safe_p=${p//[^a-zA-Z0-9_]/}
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${safe_p}.${s// /_} --output=${PWD}/${f}.${s// /_}.${safe_p}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.${safe_p}"
done
```


##	20250327


```
f=20250327-predict
s="Human herpesvirus 8"
p="ORF 73"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=${p// /_}.${s// /_} --output=${PWD}/${f}.${s// /_}.${p// /_}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='${p}'; ${PWD}/${f}.py"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; ${PWD}/${f}.py"

for i in 1 2 3 4 5 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${i}.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.${i}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.AllORF73.${i}"
done
```




```

./20250327-predict.bash > commands
commands_array_wrapper.bash --array_file commands --time 1-0 --threads 2 --mem 15G 

grep -h "^All stat" logs/commands_array_wrapper.bash.20250327154602232232053-575649_*.out.log | sort -k3n,3
```


```
for i in 1 2 3 4 5 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 10-0 --nodes=1 --ntasks=4 --mem=60G --export=None --job-name=AllORF73.${i}.${s// /_} --output=${PWD}/${f}.${s// /_}.AllORF73.${i}.jupyter.out --wrap="export SPECIES='${s}'; export PROTEINS='ORF 73,Orf73,ORF73,Protein ORF73'; jupytext --to notebook ${PWD}/${f}.py -o - | jupyter nbconvert --stdin --execute --allow-errors --to html --output-dir ${PWD} --output ${f}.${s// /_}.AllORF73.${i}"
done
```




##	20250402

After having modified the processing script to output the "feature importances" as per SHAP only if the prediction of ALL samples is greater than 85%. I included the scores in the csv filename (Train, Test, All) so could filter this further if desired.


Select the top of the top 3 tiles from all csv files.
```
head -q -n 4 20250328/*.csv | grep -vs value | cut -d, -f1 | sort | uniq -c | sort -k1n,1 | awk '($1>=10){print "^"$2","}' > TopHHV8ORF73.ids
```

Extract the actual peptide sequences from those.
```
grep -f TopHHV8ORF73.ids /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species_protein_gene_sequence_peptide.uniq.csv | cut -d, -f1,6
```


```

grep "^18189," /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/out.all/All.count.Zscores.minimums.csv | datamash transpose -t, | tail -n +2 | datamash min 1 q1 1 median 1 q3 1 max 1

cat /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/20250319/Counts.normalized.subtracted.protein.select.t.mins.reorder.csv | datamash transpose -t, | grep "^18189," | datamash transpose -t, | tail -n +4  | datamash min 1 q1 1 median 1 q3 1 max 1

``` 



```
head -q -n 4 20250402/*.csv | grep -vs value | cut -d, -f1 | sort | uniq -c | sort -k1n,1 | awk '($1>=10){print "^"$2","}' > TopHHV8ORF73.ids
```

Extract the actual peptide sequences from those.
```
grep -f TopHHV8ORF73.ids /francislab/data1/refs/PhIP-Seq/VIR3_clean.id_species_protein_gene_sequence_peptide.uniq.csv | cut -d, -f1,6
```


