
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


Not sure how much mem it will need so giving it all of it.

Doesn't really need anywhere near this much.

It will take about a day to compile all PGS scores.

```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=8 --mem=60G ${PWD}/create_collection.bash
```

Manual fix of one line in PGS005164_hmPOS_GRCh37.txt.gz.
I joined and removed the double quotes.

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

It would be nice if this could be parallelized by chromosome.
Would probably require splitting each PGS file by chromosome, then pgs-calc create-collection, then concat.
It is unclear what would happen when the PGS file is empty for a given chromosome. (no problem)

PGS004893 and PGS004895 both had some Y chromosome stuff which I removed




splitting each PGS file by chromosome, then pgs-calc create-collection, then concat.

```
ls -1 *_hmPOS_GRCh37.txt.gz | xargs -I% echo prep_individual_split.bash % > commands
commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```


```
for chr in {1..22} X ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${chr} \
  --output="${PWD}/${chr}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="${PWD}/pgs-calc create-collection --out=${PWD}/hg19.${chr}.txt.gz ${chr}/PGS??????.txt.gz;chmod -w ${PWD}/hg19.${chr}.txt.gz ${PWD}/hg19.${chr}.txt.gz.info"
done
```


Check that they all have the same number of columns

```
for f in hg19.*.txt.gz ; do
echo $f 
header_line=$( zgrep -m 1 -n "^chr" $f | cut -d: -f1 )
zcat $f | tail -n +$[header_line] | head -1 | awk -F"\t" '{print NF}'
done
```


zcat each skipping header line in all but first

You probably can just concatenate the bgzipped files, but you need to remove the comments lines so ...

```
module load htslib
zcat hg19.1.txt.gz > hg19.merged.txt
for chr in {2..22} X ; do
zcat hg19.${chr}.txt.gz | tail -n +6 >> hg19.merged.txt
done
bgzip hg19.merged.txt
tabix -S 5 -p vcf hg19.merged.txt.gz
chmod -w hg19.merged.txt.gz hg19.merged.txt.gz.tbi
```

-rw-r----- 1 gwendt francislab 248583639886 Jun 28 16:37 hg19.merged.txt



Some alleles are duplicated? Why? Problem?
```
20	57851950	G	C     <--
20	57851950	A	C
20	57851950	G	C     <--
20	57851950	T	C
```


java.lang.RuntimeException: PGS002252.txt.gz: Not sorted. 1:22587728 is before Y:27332051

java.lang.RuntimeException: PGS000701.txt.gz: Not sorted. 1:850780 is before XY:180351




how to combine the info files?

```
cat > hg19.merged.txt.gz.info << EOF
# PGS-Collection v1
# Date=Sat Jun 28 14:46:23 PDT 2025
# Scores=5106
# Updated by pgs-calc 1.6.1
EOF
echo -e "score\tvariants\tignored" >> hg19.merged.txt.gz.info

tail -q -n +6 hg19.{?,??}.txt.gz.info | awk 'BEGIN{FS=OFS="\t"}{variants[$1]+=$2;ignored[$1]+=$3}END{ for( pgs in variants ){ print pgs,variants[pgs],ignored[pgs] } }' | sort -k1,1 >> hg19.merged.txt.gz.info
chmod -w hg19.merged.txt.gz.info
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





```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection9 --time=14-0 --export=None \
  --output="${PWD}/create_collection9.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0009.txt.gz PGS00000?.txt.gz;tabix -S 5 -p vcf hg19.0001-0009.txt.gz;chmod -w hg19.0001-0009.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection99 --time=14-0 --export=None \
  --output="${PWD}/create_collection99.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0099.txt.gz PGS0000??.txt.gz;tabix -S 5 -p vcf hg19.0001-0099.txt.gz;chmod -w hg19.0001-0099.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection999 --time=14-0 --export=None \
  --output="${PWD}/create_collection999.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0999.txt.gz PGS000???.txt.gz;tabix -S 5 -p vcf hg19.0001-0999.txt.gz;chmod -w hg19.0001-0999.txt.gz*"


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection9999 --time=14-0 --export=None \
  --output="${PWD}/create_collection9999.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-9999.txt.gz PGS00????.txt.gz;tabix -S 5 -p vcf hg19.0001-9999.txt.gz;chmod -w hg19.0001-9999.txt.gz*"





sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection999 --time=14-0 --export=None \
  --output="${PWD}/create_collection999.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="singularity exec --writable-tmpfs --bind /francislab,/scratch /francislab/data1/refs/singularity/quay.io-genepi-imputationserver2-v2.0.7.img pgs-calc create-collection --out=hg19.0001-0999.singularity.txt.gz PGS000???.txt.gz;tabix -S 5 -p vcf hg19.0001-0999.singularity.txt.gz;chmod -w hg19.0001-0999.singularity.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection999 --time=14-0 --export=None \
  --output="${PWD}/create_collection999.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0999.uniq.txt.gz PGS000???.txt.gz;tabix -S 5 -p vcf hg19.0001-0999.uniq.txt.gz;chmod -w hg19.0001-0999.uniq.txt.gz*"


```







extract subset from json

```
cat pgs-catalog-20230119-hg19/scores.meta.json | jq | head
cat pgs-catalog-20230119-hg19/scores.meta.json | jq '.[] | select(.id | match("PGS00000"))' > hg19.0001-0009.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq '.[] | select(.id | match("PGS0000"))' > hg19.0001-0099.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq '.[] | select(.id | match("PGS000"))' > hg19.0001-0999.scores.json

cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS00000")))' > hg19.0001-0009.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS0000")))' > hg19.0001-0099.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS000")))' > hg19.0001-0999.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS00")))' > hg19.0001-9999.scores.json

cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS000[0-3]")))' > hg19.0001-0399.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS000[0-2]")))' > hg19.0001-0299.scores.json
cat pgs-catalog-20230119-hg19/scores.meta.json | jq -r 'with_entries(select(.key | match("PGS000[0-1]")))' > hg19.0001-0199.scores.json

```

check their existance





```
zcat hg19.0001-0999.txt.gz| cut -f1-4 | tail -n +6 | uniq -D | head
1	3329384	T	C
1	3329384	T	C
1	8481016	G	T
1	8481016	G	T
1	27138393	T	C
1	27138393	T	C
1	43926305	C	T
1	43926305	C	T
1	55496039	C	T
1	55496039	C	T
```


Takes about 341GB of memory. The full matrix would be impossible here.
Processing takes about 30 minutes. Writing the results takes about 13 hours.
```
sbatch --nodes=1 --time=1-0 --ntasks=60 --mem=480G --export=None --wrap="python3 -c \"import pandas as pd;pd.read_csv('hg19.0001-0999.uniq.txt.gz',header=4,sep='\t',low_memory=False).groupby(['chr_name','chr_position','effect_allele','other_allele'],dropna=False).sum().to_csv('hg19.0001-0999.uniq.sum2.txt',sep='\t')\";module load htslib;bgzip hg19.0001-0999.uniq.sum2.txt"

df.loc[('1',3329384,'T','C')]
```



sed ':x;s/,0.0,/,,/g;t x' hg19.0001-0999.uniq.sum.raw.txt > hg19.0001-0999.uniq.sum.txt
sed -i 's/,0.0$/,/' hg19.0001-0999.uniq.sum.txt
bgzip
tabix

sed ':x;s/,0.0,/,,/g;t x;s/,0.0$/,/;s/,/\t/g' hg19.0001-0999.uniq.sum.raw.txt > hg19.0001-0999.uniq.sum.txt2 &

zcat hg19.0001-0999.txt.gz| cut -f1-4 | tail -n +6 | uniq -D | head


-r--r----- 1 gwendt francislab 43169227549 Jul  1 21:13 hg19.0001-0999.uniq.sum.raw.txt
-r--r----- 1 gwendt francislab 15201388888 Jul  2 07:17 hg19.0001-0999.uniq.sum.txt
-rw-r----- 1 gwendt francislab  7543259136 Jul  2 07:18 hg19.0001-0999.uniq.sum.txt2
-rw-r----- 1 gwendt francislab    18874368 Jul  2 07:18 hg19.0001-0999.uniq.sum.txt.gz
-r--r----- 1 gwendt francislab       16857 Jul  1 08:42 hg19.0001-0999.uniq.sum.txt.gz.info
-r--r----- 1 gwendt francislab  3098683305 Jun 30 19:06 hg19.0001-0999.uniq.txt.gz
-r--r----- 1 gwendt francislab       16857 Jun 30 19:06 hg19.0001-0999.uniq.txt.gz.info
-r--r----- 1 gwendt francislab     2310444 Jun 30 19:08 hg19.0001-0999.uniq.txt.gz.tbi

uniq and sum didn't make much difference. initially fails one way then divide by zero

```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection199 --time=14-0 --export=None \
  --output="${PWD}/create_collection199.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0199.uniq.txt.gz PGS000[0-1]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0199.uniq.txt.gz;chmod -w hg19.0001-0199.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection299 --time=14-0 --export=None \
  --output="${PWD}/create_collection299.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0299.uniq.txt.gz PGS000[0-2]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0299.uniq.txt.gz;chmod -w hg19.0001-0299.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection399 --time=14-0 --export=None \
  --output="${PWD}/create_collection399.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0399.uniq.txt.gz PGS000[0-3]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0399.uniq.txt.gz;chmod -w hg19.0001-0399.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection499 --time=14-0 --export=None \
  --output="${PWD}/create_collection499.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0499.uniq.txt.gz PGS000[0-4]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0499.uniq.txt.gz;chmod -w hg19.0001-0499.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection599 --time=1-0 --export=None \
  --output="${PWD}/create_collection599.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0599.uniq.txt.gz PGS000[0-5]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0599.uniq.txt.gz;chmod -w hg19.0001-0599.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection699 --time=1-0 --export=None \
  --output="${PWD}/create_collection699.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0699.uniq.txt.gz PGS000[0-6]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0699.uniq.txt.gz;chmod -w hg19.0001-0699.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection799 --time=1-0 --export=None \
  --output="${PWD}/create_collection799.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0799.uniq.txt.gz PGS000[0-7]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0799.uniq.txt.gz;chmod -w hg19.0001-0799.uniq.txt.gz*"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection899 --time=1-0 --export=None \
  --output="${PWD}/create_collection899.uniq.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-0899.uniq.txt.gz PGS000[0-8]??.txt.gz;tabix -S 5 -p vcf hg19.0001-0899.uniq.txt.gz;chmod -w hg19.0001-0899.uniq.txt.gz*"

```

Collections seem to require the comment header lines.
Not sure if its all but without them, they crash "cannot find column 'effect_weight'"






Empty Columns 
340 - PGS000337
346 - PGS000343


Why are there so few for some? Manually filtered.
Why are they ignored? hm_inferOtherAllele column is empty

tail -n +6 hg19.0001-0999.uniq.txt.gz.info | awk '($2==$3)'
PGS000337	75028	75028
PGS000343	0	0
PGS000833	66	66
PGS000864	389243	389243
PGS000904	582	582
PGS000905	743	743
PGS000941	1	1
PGS000966	1	1


These 2 do not have any rows after my filteration. hm_chr and hm_pos are empty.
PGS000343_hmPOS_GRCh37.txt.gz
PGS003757_hmPOS_GRCh37.txt.gz


```
\rm PGS000343.txt.gz PGS003757.txt.gz
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection9999 --time=14-0 --export=None \
  --output="${PWD}/create_collection9999.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=hg19.0001-9999.txt.gz PGS00????.txt.gz;tabix -S 5 -p vcf hg19.0001-9999.txt.gz;chmod -w hg19.0001-9999.txt.gz*"
```





`pgs-calc apply` apparently needs the the FORMAT field DS to work. This does not appear to be in a standard VCF, but is in imputed vcf.



```
ls -1 *_hmPOS_GRCh38.txt.gz | xargs -I% echo prep_individual.bash % > commands
commands_array_wrapper.bash --array_file commands --time 4-0 --threads 2 --mem 15G
```

```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=create_collection --time=2-0 --export=None \
  --output="${PWD}/create_collection.$( date "+%Y%m%d%H%M%S%N" ).out" --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load htslib;pgs-calc create-collection --out=pgs-collection.txt.gz PGS??????.txt.gz;tabix -S 5 -p vcf pgs-collection.txt.gz;chmod -w pgs-collection.txt.gz*"
```



