


https://github.com/nerettilab/RepEnrich2






```
wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAD8FJm28zWy6kVy0WIcpz77a/hg38_repeatmasker_clean.txt.gz
gunzip hg38_repeatmasker_clean.txt.gz

wget --no-verbose https://www.dropbox.com/sh/ovf1t2gn5lvmyla/AAAovLTYE93PjBIlRRToO59la/Repenrich2_setup_hg38.tar.gz
```


This took about a day.
```
singularity exec --bind /francislab /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2_setup.py ${PWD}/hg38_repeatmasker_clean.txt /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${PWD}/setup_folder_hg38 --threads 32
```























```
wget -O TEtranscripts_TE_GTF.zip  https://uc53b585e53a393f9d27d7769e11.dl.dropboxusercontent.com/zip_download_get/BEJKmOHO6KeqZfSpRpaJ73wFWJXfV3QfiPspE4Xb9SbcpsFCx8vFHBgu-RYJwtqx5x8TxofKVyvAw7vqdNjghUlGT99STclrzz6MuA-zWAF2Iw?_download_id=336660912494330728897755899078703441317967690786358948716950072471

mkdir TEtranscripts_TE_GTF
cd TEtranscripts_TE_GTF

UNZIP_DISABLE_ZIPBOMB_DETECTION=TRUE unzip ../TEtranscripts_TE_GTF.zip 
```




Not sure if hg38.ncbiRefSeq.gtf is the correct GTF file.


```
for bam in /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/10-PAUB*bam ; do
  base=$( basename $bam .bam )
  sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab /francislab/data1/refs/singularity/TEtranscripts.img TEcount --sortByPos --format BAM --mode multi -b ${bam} --project ${base} --GTF /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf --TE ${PWD}/TEtranscripts_TE_GTF/hg38_rmsk_TE.gtf"
done
```


