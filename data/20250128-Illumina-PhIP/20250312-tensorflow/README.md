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


