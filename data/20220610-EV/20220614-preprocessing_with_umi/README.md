
```
mkdir -p /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/logs

date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="/francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/logs/preprocess.${date}-%A_%a.out" --time=1440 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/array_wrapper.bash

```



```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```
