

#	RepEnrich2

https://github.com/nerettilab/RepEnrich2


##	Step 1) Attain repetitive element annotation
```
wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAD8FJm28zWy6kVy0WIcpz77a/hg38_repeatmasker_clean.txt.gz

gunzip hg38_repeatmasker_clean.txt.gz

wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAAovLTYE93PjBIlRRToO59la/Repenrich2_setup_hg38.tar.gz
```

##	Step 2) Run the setup for RepEnrich2

This took about a day.
```
singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2_setup.py ${PWD}/hg38_repeatmasker_clean.txt /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${PWD}/setup_folder_hg38 --threads 32
```



I'm not sure that that was needed. I think that contents of the one download contain the same files.

```
tar tvfz Repenrich2_setup_hg38.tar.gz | wc -l
8872
ll setup_folder_hg38/ | wc -l
8872
```



