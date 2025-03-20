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


