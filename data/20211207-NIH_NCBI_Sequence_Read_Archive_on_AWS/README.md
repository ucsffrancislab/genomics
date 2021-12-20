
#	NIH NCBI Sequence Read Archive (SRA) on AWS



##	Data


https://registry.opendata.aws/ncbi-sra/




##	Metadata


https://www.ncbi.nlm.nih.gov/books/NBK242621/#_SRA_Download_Guid_BK_Downloading_metadat_

https://www.ncbi.nlm.nih.gov/sra/docs/submitmeta/

ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/

wget ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/NCBI_SRA_Metadata_Full_20211218.tar.gz 
wget ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab 
wget ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Run_Members.tab 

esearch -db sra -query SRR5070677 | efetch -format runinfo


esearch -db sra -query PRJNA279196 | efetch -format runinfo




