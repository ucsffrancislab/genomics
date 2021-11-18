



```

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-88%1 --job-name="DMV-EV" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G ${PWD}/array_wrapper.bash





python3 ~/.local/bin/merge_uniq-c.py --int out/*.viral.bam.aligned_sequence_counts.txt
```

