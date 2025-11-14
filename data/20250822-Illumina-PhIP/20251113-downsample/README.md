
#	20250822-Illumina-PhIP/20251113-downsample

Downsample prior bowtie2 run to 1,000,000 reads

Perhaps do this several times some have somethings to compare.

Then test run normalization analyses

And eventually PhIPseq analyses?


Downsampling is done by adjusting the random probability to target the desired count, so results won't be exact counts.


```BASH

samtools_downsample_array_wrapper.bash --iterations 5 --read_count 750000 --outdir ${PWD}/out/ ${PWD}/../20250822b-bowtie2/out/S*bam

```

