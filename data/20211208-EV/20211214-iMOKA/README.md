
#	20211208-EV/20211214-iMOKA




/francislab/data1/working/20210428-EV/20211014-iMOKA/


/c4/home/gwendt/github/ucsffrancislab/genomics/data/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/iMOKA_scratch.bash




Link raw files to replace .fqgz to .fastq.gz
```
DIR=/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi
RAW=/francislab/data1/working/20211208-EV/20211214-iMOKA/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.format.t1.t3.notphiX.notviral.nothg38.?.fqgz ; do
ln -s $f ${RAW}/$( basename $f .fqgz ).fastq.gz
done

```




sample - group - filelist

```
DIR=/francislab/data1/working/20211208-EV/20211214-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.quality.format.t1.t3.notphiX.notviral.nothg38.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}($5 ~ /(IPMN|MCN|PDAC)/){print $1,$5}' /francislab/data1/raw/20211208-EV/adapter\ and\ indexes\ for\ QB3_NovaSeq\ SP\ 150PE_SFHH009\ S\ Francis_11-16-2021.csv ) > source.tsv
```




```

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="/francislab/data1/working/20211208-EV/20211214-iMOKA/iMOKA.${date}.out" --time=14400 --nodes=1 --ntasks=56 --mem=439G /francislab/data1/working/20211208-EV/20211214-iMOKA/iMOKA.bash


```



