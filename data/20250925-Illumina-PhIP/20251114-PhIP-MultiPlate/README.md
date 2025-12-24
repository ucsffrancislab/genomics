
#	20250925-Illumina-PhIP/20251114-PhIP-MultiPlate







This is downsampled data. You probably don't want to use it.











reference 20250409-Illumina-PhIP/20250414-PhIP-MultiPlate

```
ln -s /francislab/data1/working/20241204-Illumina-PhIP/20251113-PhIP/out.plate1
ln -s /francislab/data1/working/20241204-Illumina-PhIP/20251113-PhIP/out.plate13
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20251113-PhIP/out.plate2
ln -s /francislab/data1/working/20241224-Illumina-PhIP/20251113-PhIP/out.plate14
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20251113-PhIP/out.plate3
ln -s /francislab/data1/working/20250128-Illumina-PhIP/20251113-PhIP/out.plate4
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20251113-PhIP/out.plate5
ln -s /francislab/data1/working/20250409-Illumina-PhIP/20251113-PhIP/out.plate6
ln -s /francislab/data1/working/20250822-Illumina-PhIP/20251113-PhIP/out.plate15
ln -s /francislab/data1/working/20250822-Illumina-PhIP/20251113-PhIP/out.plate16
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20251113-PhIP/out.plate17
ln -s /francislab/data1/working/20250925-Illumina-PhIP/20251113-PhIP/out.plate18
```



```bash

merge_matrices.py --axis columns --de_nan --de_neg --int \
  --header_rows 9 --index_col id --index_col species \
  --out ${PWD}/out.123456131415161718/Counts.csv \
  ${PWD}/out.plate{1,2,3,4,5,6,13,14,15,16,17,18}/Counts.csv

```



```bash

./prep_zscores_for_merging.bash

```



```bash

merge_matrices.py --axis columns --de_nan --de_neg \
  --header_rows 10 --index_col id --index_col species \
  --out ${PWD}/out.123456131415161718/Zscores.manifest.csv \
  ${PWD}/out.plate{1,2,3,4,5,6,13,14,15,16,17,18}/Zscores.manifest.csv

```

