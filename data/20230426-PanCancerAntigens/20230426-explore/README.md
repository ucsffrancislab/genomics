
#	20230426-PanCancerAntigens/20230426-explore



Lets take the proteins in S2 (the filtered ones) and make a blastdb of the corresponding proteins from S10.  Lets at least keep the the transcript name (and any-other info possible) attached.

Select the "Protein Sequence" from S10 whose Transcript ID is in the list on S2.

Make blast db.




Lets Make a second blast db with all the proteins that are found in either the LGG or GBM samples (from s10). Thsi will be much bigger but worth a search.






then, lets take the VZV proteins and search against these databases to see if there are any solid hits.



```


blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences -query /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa > Human_alphaherpesvirus_3_proteins_IN_S10_All_ProteinSequences.blastp.txt

blastp -db /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa -query /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences.fa > S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.blastp.txt


```




```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in Human_alphaherpesvirus_3_proteins_IN_S10_All_ProteinSequences.blastp.txt S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.blastp.txt ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


```




