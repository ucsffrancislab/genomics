
#	20240925-Illumina-PhIP/20241122-PhIP-test

THIS IS A TEST OF THE DEVELOPING SCRIPT.

THE DATA FOUND IN HERE IS LIKELY INVALID.





```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash --manifest ${PWD}/manifest.csv --output ${PWD}/out
```

