
#	Human_Virome_Analysis

Original ... https://github.com/TheSatoLab/Human_Virome_analysis

Our fork ... https://github.com/ucsffrancislab/Human_Virome_analysis




##	Second Blast DB




```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=makeblastdb --output=${PWD}/makeblastdb.$(date "+%Y%m%d%H%M%S").out --time=10000 --nodes=1 --ntasks=4 --mem=30G ${PWD}/makeblastdb.bash

```



Make a bowtie2 reference using the same files

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=bowtie2-build --output=${PWD}/bowtie2-build.$(date "+%Y%m%d%H%M%S").out --time=10000 --nodes=1 --ntasks=64 --mem=490G ${PWD}/bowtie2-build.bash

```
OUT OF MEMORY

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=bowtie2-build --output=${PWD}/bowtie2-build.$(date "+%Y%m%d%H%M%S").out --time=10000 --nodes=1 --ntasks=64 --mem=1000G ${PWD}/bowtie2-build.bash

```
STILL WAITING ....




Make a bwa reference using the same files

64/490/10000 ran out of time
16/120/20160 ran out of memory
32/240/20160 ran out of memory
64/490/20160 ran out of memory


```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=bwa-index --output=${PWD}/bwa-index.$(date "+%Y%m%d%H%M%S").out --time=20160 --nodes=1 --ntasks=64 --mem=490G ${PWD}/bwa-index.bash

```



