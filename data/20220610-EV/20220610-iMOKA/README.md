
#	20220610-EV/20220610-iMOKA

/francislab/data1/working/20210428-EV/20211014-iMOKA/
/francislab/data1/working/20211208-EV/20211214-iMOKA


/c4/home/gwendt/github/ucsffrancislab/genomics/data/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/iMOKA_scratch.bash




Link raw files to replace .fqgz to .fastq.gz
```
DIR=/francislab/data1/working/20220610-EV/20220610-preprocessing/out
RAW=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
mkdir -p $RAW
for f in ${DIR}/*.quality.t1.t3.notphiX.?.fqgz ; do
l=$( basename $f .fqgz )
l=${l/.quality.t1.t3.notphiX/}
ln -s $f ${RAW}/${l}.fastq.gz
done
```



```
DIR=/francislab/data1/working/20220610-EV/20220610-iMOKA/raw
while read subject field; do
f=$( ls ${DIR}/${subject}.?.fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${subject}\t${field}\t${f}"
fi
done < <( awk 'BEGIN{FS=",";OFS="\t"}( $9 ~ /Primary|Recurrent|control/ ){print $1,$9}' /francislab/data1/raw/20220610-EV/Sample\ covariate\ file_ids\ and\ indexes_for\ QB3_NovSeq\ SP\ 150PE_SFHH011\ S\ Francis_5-2-22hmh.csv ) > source.tsv
```




