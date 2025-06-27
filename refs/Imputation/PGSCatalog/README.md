
#	Imputation/PGSCatalog

Acquiring all PGS catalogs and then combining them for use with our imputation server


Being gentle. There are over 5000



```
./download.bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=prep \
  --output="${PWD}/prep.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=4 --mem=30G ${PWD}/prep.bash
```


```
pgs-calc create-collection --out=hg19.collection.txt.gz PGS??????.txt.gz
```
Wrote 7650044 unique variants and 98 scores.

```
module load htslib
tabix -p vcf hg19.collection.txt.gz
```
[E::get_intv] Failed to parse TBX_VCF: was wrong -p [type] used?
The offending line was: "chr_name	chr_position	effect_allele	other_allele	PGS000001	PGS000002	PGS000003	PGS000004PGS000005	PGS000006	PGS000007	PGS000008	PGS000009	PGS000010	PGS000011	PGS000012	PGS000013	PGS000014	PGS000015	PGS000016	PGS000017	PGS000018	PGS000019	PGS000020	PGS000021	PGS000022	PGS000023PGS000024	PGS000025	PGS000026	PGS000027	PGS000028	PGS000029	PGS000030	PGS000031	PGS000032	PGS000033	PGS000034	PGS000035	PGS000036	PGS000037	PGS000038	PGS000039	PGS000040	PGS000041	PGS000042PGS000043	PGS000044	PGS000045	PGS000046	PGS000047	PGS000048	PGS000049	PGS000050	PGS000051	PGS000052	PGS000053	PGS000054	PGS000055	PGS000056	PGS000057	PGS000058	PGS000059	PGS000060	PGS000061PGS000062	PGS000063	PGS000064	PGS000065	PGS000066	PGS000067	PGS000068	PGS000069	PGS000070	PGS000071	PGS000072	PGS000073	PGS000074	PGS000075	PGS000076	PGS000077	PGS000078	PGS000079	PGS000080PGS000081	PGS000082	PGS000083	PGS000084	PGS000086	PGS000087	PGS000088	PGS000089	PGS000090	PGS000091	PGS000092	PGS000093	PGS000094	PGS000095	PGS000096	PGS000097	PGS000098	PGS000099"

Is that gonna be acceptable?






Need to build the metadata json file now and not real sure how to do that.





There is a json file included, but the giant matrix is not.

wget https://imputationserver.sph.umich.edu/resources/pgs-catalog/pgs-catalog-20230119-hg19.zip


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



