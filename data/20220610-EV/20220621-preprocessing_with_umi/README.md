

Same as 20220614 except minimum read length of 10 instead of 15


```
mkdir -p /francislab/data1/working/20220610-EV/20220621-preprocessing_with_umi/logs

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="/francislab/data1/working/20220610-EV/20220621-preprocessing_with_umi/logs/preprocess.${date}-%A_%a.out" --time=360 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20220621-preprocessing_with_umi/array_wrapper.bash

```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220621-preprocessing_with_umi"
curl -netrc -X MKCOL "${BOX}/"

for f in out/*fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```







```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```
