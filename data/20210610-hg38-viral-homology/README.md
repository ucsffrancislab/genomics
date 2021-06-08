# Human / Viral homology analysis

On a number of occasions, reads have aligned to viral genomes suggesting their presence in the sample.
Unfortunately, these were false positives due to simple repeats.
Sadly, RepeatMasker doesn't always mask these regions.

My intention here is to take a number of viral references, break them into many overlapping 100bp reads and align them to the hg38 reference.

I will then run RepeatMasker on the viral references and repeat the previous exercise.

Any viral regions that align to human will be marked for masking with a bed file.


All future viral references will be created from these multi-masked sequences.



I've done this before, but can find no reference to it.




