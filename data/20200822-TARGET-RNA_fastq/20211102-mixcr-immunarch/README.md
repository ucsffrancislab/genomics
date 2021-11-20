
#	MiXCR test


```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-689%10 --job-name="MiXCR" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G ${PWD}/array_wrapper.bash



mkdir data
cp -u out/*.txt data/
./make_metadata.bash > data/metadata.txt
```



fastq-nodots/10-PAPNNX-09A-01R R1 was really short. R2 was much longer.


