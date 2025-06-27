
#	Imputation/PGSCatalog

Acquiring all PGS catalogs and then combining them for use with our imputation server


Being gentle. There are over 5000



```
./download.bash

#sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=prep \
#  --output="${PWD}/prep.$( date "+%Y%m%d%H%M%S%N" ).out" \
#  --time=14-0 --nodes=1 --ntasks=4 --mem=30G ${PWD}/prep.bash
```

Preferably ...
```
ls -1 *_hmPOS_GRCh37.txt.gz | xargs -I% echo prep_individual.bash % > commands
commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


Not sure how much mem it will need so giving it all of it
Doesn't really need anywhere near this much.

```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=64 --mem=490G ${PWD}/create_collection.bash
```

Manual fix of one line in PGS005164_hmPOS_GRCh37.txt.gz 

```
rs8176636	9	136151579	T	"TGGTGCAGGCGCAGGAAA
AAATTGTGGCAATTCCTCA"	0.039	ENSEMBL	rs8176636	9	136151580		True	False
```

```
Column 'effect_weight' not found in 'PGS004255.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004256.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004258.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004259.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004260.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004261.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004262.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004263.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004264.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004272.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004273.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004280.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004299.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004301.txt.gz'. Ignore.
Column 'effect_weight' not found in 'PGS004304.txt.gz'. Ignore.
```





Need to build the metadata json file now and not real sure how to do that.


There is a json file included, but the giant matrix is not.

wget https://imputationserver.sph.umich.edu/resources/pgs-catalog/pgs-catalog-20230119-hg19.zip

```
"PGS001909":{"id":"PGS001909",
"trait":"Red blood cell (erythrocyte) count",
"efo":[{"id":"EFO_0004305",
"label":"erythrocyte count",
"description":"The number of red blood cells per unit volume in a sample of venous blood.",
"url":"http://www.ebi.ac.uk/efo/EFO_0004305"}],
"publication":{"date":"2022-01-06",
"journal":"Am J Hum Genet",
"firstauthor":"Privé F",
"doi":"10.1016/j.ajhg.2021.11.008"},
"variants":81887,
"repository":"PGS-Catalog",
"link":"https://www.pgscatalog.org/score/PGS001909",
"samples":0},
```


