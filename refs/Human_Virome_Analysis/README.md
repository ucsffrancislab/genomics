
#	Human_Virome_Analysis

Original ... https://github.com/TheSatoLab/Human_Virome_analysis

Our fork ... https://github.com/ucsffrancislab/Human_Virome_analysis




##	Second Blast DB




```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name=makeblastdb --output=${PWD}/makeblastdb.$(date "+%Y%m%d%H%M%S").out --time=10000 --nodes=1 --ntasks=4 --mem=30G ${PWD}/makeblastdb.bash

```


--wrap="module load blast && zcat /c4/home/gwendt/github/ucsffrancislab/Human_Virome_analysis/virus_genome_for_second_blast.fas.gz /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.fa.gz /francislab/data1/refs/refseq/archaea-20230714/archaea.*.genomic.fna.gz /francislab/data1/refs/refseq/bacteria-20210916/bacteria.*.genomic.fna.gz | makeblastdb -input_type fasta -dbtype nucl -parse_seqids -out ${PWD}/virus_genome_for_second_blast -title virus_genome_for_second_blast"

