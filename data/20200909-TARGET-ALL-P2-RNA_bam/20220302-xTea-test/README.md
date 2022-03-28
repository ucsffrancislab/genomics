

https://github.com/parklab/xTea




```
mkdir rep_lib_annotation
cd rep_lib_annotation
wget --no-verbose https://github.com/parklab/xTea/raw/master/rep_lib_annotation.tar.gz
tar xfz rep_lib_annotation.tar.gz
cd ..
```


```
for bam in /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/10-PAUB*bam ; do
base=$( basename $bam .bam )
echo -e "${base}\t${bam}" >> bam_list.txt
echo -e "${base}" >> sample_id.txt
done
```

Why are both needed? Opens up for errors. Software should create one from the other.


/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220302-xTea-test/rep_lib_annotation/


From ...
https://github.com/parklab/xTea/issues/10
... use 1555 instead of 5907 for HERV

changing
```
-f 5907 -y 15
```
to
```
-f 1555 -y 8
```

```
help="Flag indicates which step to run (1-clip, 2-disc, 4-barcode, 8-xfilter, 16-filter, 32-asm)")

plus some other undocumented stuff it would appear.
```



```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=xTea --time=60 --nodes=1 --ntasks=8 --mem=30G --output=${PWD}/xTea.txt --wrap "singularity exec --bind /francislab /francislab/data1/refs/singularity/xTea.img xtea -i ${PWD}/sample_id.txt -b ${PWD}/bam_list.txt -x null -p ${PWD}/tmp/ -o submit_jobs.sh -l ${PWD}/rep_lib_annotation/ -r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa -g /francislab/data1/refs/sources/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_33/gencode.v33.chr_patch_hapl_scaff.annotation.gff3 -f 1555 -y 8 -n 16 -m 60"

chmod +x /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220302-xTea-test/tmp/*/HERV/run_xTEA_pipeline.sh

for dir in /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220302-xTea-test/tmp/10-PAUB* ; do 
base=$( basename $dir )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=60G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${dir}/HERV/run_xTEA_pipeline.sh"
done
```


Don't use the "chr_patch_hapl_scaff" version.


Pipelines completed, but results are mostly empty as this is RNA. Duh.





