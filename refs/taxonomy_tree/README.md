
#	refs/taxonomy_tree



For some reason, taxadb does not include all of the data in taxdump?

```
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/pdb.accession2taxid.gz
```

Not sure why so many missing, so I will try to create my own csv files for direct import to database.
Gotta merge nodes.dmp and names.dmp to make the "taxa" table.
The accessions tables is just all of the accession2taxid file.


Found another cool tool. http://etetoolkit.org/

```

tar xfvz taxdump.tar.gz names.dmp
names.dmp
tar xfvz taxdump.tar.gz nodes.dmp
nodes.dmp

nodes.dmp file consists of taxonomy nodes. The description for each node includes the following
fields:
	tax_id					-- node id in GenBank taxonomy database
 	parent tax_id				-- parent node id in GenBank taxonomy database
 	rank					-- rank of this node (superkingdom, kingdom, ...) 
 	embl code				-- locus-name prefix; not unique
 	division id				-- see division.dmp file
 	inherited div flag  (1 or 0)		-- 1 if node inherits division from parent
 	genetic code id				-- see gencode.dmp file
 	inherited GC  flag  (1 or 0)		-- 1 if node inherits genetic code from parent
 	mitochondrial genetic code id		-- see gencode.dmp file
 	inherited MGC flag  (1 or 0)		-- 1 if node inherits mitochondrial gencode from parent
 	GenBank hidden flag (1 or 0)            -- 1 if name is suppressed in GenBank entry lineage
 	hidden subtree root flag (1 or 0)       -- 1 if this subtree has no sequence data yet
 	comments				-- free-text comments and citations

Taxonomy names file (names.dmp):
	tax_id					-- the id of node associated with this name
	name_txt				-- name itself
	unique name				-- the unique variant of this name if name not unique
	name class				-- (synonym, common name, ...)

sqlite> select * from taxa limit 10;
1|1|root|no rank
2|131567|Bacteria|superkingdom
6|335928|Azorhizobium|genus
7|6|Azorhizobium caulinodans|species
9|32199|Buchnera aphidicola|species
10|1706371|Cellvibrio|genus
11|1707|Cellulomonas gilvus|species
13|203488|Dictyoglomus|genus
14|13|Dictyoglomus thermophilum|species
16|32011|Methylophilus|genus



sqlite3 taxadb_full.sqlite
sqlite> .schema
CREATE TABLE IF NOT EXISTS "taxa" ("ncbi_taxid" INTEGER NOT NULL PRIMARY KEY, "parent_taxid" INTEGER NOT NULL, "tax_name" VARCHAR(255) NOT NULL, "lineage_level" VARCHAR(255) NOT NULL);
CREATE TABLE IF NOT EXISTS "accession" ("id" INTEGER NOT NULL PRIMARY KEY, "taxid_id" INTEGER NOT NULL, "accession" VARCHAR(255) NOT NULL, FOREIGN KEY ("taxid_id") REFERENCES "taxa" ("ncbi_taxid"));
CREATE INDEX "accession_taxid_id" ON "accession" ("taxid_id");
CREATE UNIQUE INDEX "accession_accession" ON "accession" ("accession");

select * from taxa where ncbi_taxid = 2717128;


taxa
ncbi_taxid,parent_taxid,tax_name,lineage_level

accession
taxid_id,accession

```

Better choose columns. taxid,parent_taxid,tax_name,lineage_level and taxid,accession


```
zcat *.accession2taxid.gz | awk 'BEGIN{FS="\t";OFS=","}($1!="accession"){print $3,$1}' > accession.unsorted.csv
zcat /francislab/data1/refs/taxadb/nr.aT.csv.gz | awk 'BEGIN{FS=OFS=","}{print $2,$1}' >> accession.unsorted.csv
#sort -t , -k 2 accession.unsorted.csv > accession.sorted.csv
#uniq -d accession.sorted.csv

```
Using tabs as separators for simplicity. Outputing pipes as separators as commas and quotes in data.

```
awk 'BEGIN{FS="\t";OFS="|"}(FNR==NR && $7=="scientific name"){taxid_names[$1]=$3}(FNR!=NR){print $1,$3,taxid_names[$1],$5}' names.dmp  nodes.dmp > taxa.csv



sqlite3 /francislab/data1/refs/taxadb/taxadb_full.sqlite
select count(1) from accession;
select count(1) from taxa;



sqlite3 taxonomy.sqlite
CREATE TABLE IF NOT EXISTS "taxa" ("taxid" INTEGER NOT NULL PRIMARY KEY, "parent_taxid" INTEGER NOT NULL, "tax_name" VARCHAR(255) NOT NULL, "lineage_level" VARCHAR(255) NOT NULL);
CREATE TABLE IF NOT EXISTS "accession" ("taxid" INTEGER NOT NULL, "accession" VARCHAR(255) NOT NULL, FOREIGN KEY ("taxid") REFERENCES "taxa" ("taxid"));
CREATE INDEX "accession_taxid" ON "accession" ("taxid");
CREATE UNIQUE INDEX "accession_accession" ON "accession" ("accession");
CREATE INDEX "taxa_parent_taxid" ON "taxa" ("parent_taxid");
CREATE UNIQUE INDEX "taxa_taxid" ON "taxa" ("taxid");
.separator "|"
.import taxa.csv taxa
.separator ,
.import accession.unsorted.csv accession



SELECT a.* FROM accession a LEFT JOIN taxa t ON a.taxid = t.taxid WHERE t.taxid IS NULL;



zcat *.accession2taxid.gz | awk 'BEGIN{FS="\t";OFS=","}($1!="accession"){print $3,$1}' > accession.working.unsorted.csv
zcat /francislab/data1/refs/taxadb/nr.aT.csv.gz | awk 'BEGIN{FS=OFS=","}{print $2,$1}' >> accession.working.unsorted.csv
sort -t , -k 2 accession.unsorted.csv > accession.working.sorted.csv
uniq -d accession.working.sorted.csv > accession.working.sorted.dups.csv
uniq accession.working.sorted.csv > accession.working.sorted.uniq.csv


CREATE TABLE IF NOT EXISTS "accession" ("id" INTEGER NOT NULL PRIMARY KEY, "taxid_id" INTEGER NOT NULL, "accession" VARCHAR(255) NOT NULL, FOREIGN KEY ("taxid_id") REFERENCES "taxa" ("ncbi_taxid"));
Don't need "id" column, do we?
Keep the old column names so no change needed in scripts
NR and NCBI contain duplicates with differing data. Keep separate. NCBI seems newer. Load it first.
NCBI has 3x NR, many of which will be duplicates. Try to load it anyway.




zcat accession.ncbi.unsorted.csv.gz | sort --parallel=32 -t , -k 2 > accession.ncbi.sorted.csv
uniq -d accession.ncbi.sorted.csv > accession.ncbi.sorted.dups.csv
uniq accession.ncbi.sorted.csv > accession.ncbi.sorted.uniq.csv
wc -l accession.ncbi.sorted.csv > accession.ncbi.sorted.csv.wc-l
wc -l accession.ncbi.sorted.dups.csv > accession.ncbi.sorted.dups.csv.wc-l
wc -l accession.ncbi.sorted.uniq.csv > accession.ncbi.sorted.uniq.csv.wc-l

zcat /francislab/data1/refs/taxadb/nr.aT.csv.gz | awk 'BEGIN{FS=OFS=","}{print $2,$1}' > accession.nr.unsorted.csv
sort --parallel=32 -t , -k 2 accession.nr.unsorted.csv > accession.nr.sorted.csv
uniq -d accession.nr.sorted.csv > accession.nr.sorted.dups.csv
uniq accession.nr.sorted.csv > accession.nr.sorted.uniq.csv
wc -l accession.nr.sorted.csv > accession.nr.sorted.csv.wc-l
wc -l accession.nr.sorted.dups.csv > accession.nr.sorted.dups.csv.wc-l
wc -l accession.nr.sorted.uniq.csv > accession.nr.sorted.uniq.csv.wc-l

chmod -w accession*
gzip accession.n*.sorted.csv &
gzip accession.n*.sorted.dups.csv &




sqlite3 taxonomy.sqlite
CREATE TABLE IF NOT EXISTS "taxa" ("ncbi_taxid" INTEGER NOT NULL PRIMARY KEY, "parent_taxid" INTEGER NOT NULL, "tax_name" VARCHAR(255) NOT NULL, "lineage_level" VARCHAR(255) NOT NULL);
CREATE TABLE IF NOT EXISTS "accession" ("taxid_id" INTEGER NOT NULL, "accession" VARCHAR(255) NOT NULL, FOREIGN KEY ("taxid_id") REFERENCES "taxa" ("ncbi_taxid"));
CREATE INDEX "accession_taxid_id" ON "accession" ("taxid_id");
CREATE UNIQUE INDEX "accession_accession" ON "accession" ("accession");
.separator "|"
.import taxa.csv taxa
.separator ,
.import accession.ncbi.sorted.uniq.csv accession
#	select count(1) from accession;
#	1586674699
.import accession.nr.sorted.uniq.csv accession
#	nearly all failed as not unique.
#	select count(1) from accession;
#	



```




##	20231122

Rebuilding with the latest data


```

Two set of files are available for download. 
The first set contains accession to taxid mapping for live sequence records:

nucl_wgs.accession2taxid.gz
TaxID mapping for live nucleotide sequence records of type WGS or TSA.

nucl_gb.accession2taxid.gz
TaxID mapping for live nucleotide sequence records that are not WGS or TSA.

prot.accession2taxid.gz
TaxID mapping for live protein sequence records which have GI identifiers.

prot.accession2taxid.FULL.gz
TaxID mapping for all live protein sequence records, including GI-less WGS proteins

prot.accession2taxid.FULL.NN.gz
TaxID mapping for all live protein sequence records, split into smaller files
containing 400 million rows each.
```



```
mkdir 20231122
cd 20231122

wget -b ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
wget -b ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
wget -b ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
wget -b ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
wget -b ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/pdb.accession2taxid.gz
```



```
zcat *.accession2taxid.gz | head -3
accession	accession.version	taxid	gi
A00001	A00001.1	10641	58418
A00002	A00002.1	9913	2
```



```
awk 'BEGIN{FS="\t";OFS="|"}(FNR==NR && $7=="scientific name"){taxid_names[$1]=$3}(FNR!=NR){print $1,$3,taxid_names[$1],$5}' names.dmp  nodes.dmp > taxa.csv



zcat *.accession2taxid.gz | awk 'BEGIN{FS="\t";OFS=","}(($1!="accession")&&($3!=0)){print $3,$1}' > accession.unsorted.csv
chmod 400 accession.unsorted.csv
```

Don't use prot.accession2taxid.FULL.gz
It contains duplicates and pairings of accession and taxid that are different in the other files.
As well as extra fields with colons and commas.
Note the differences in fields from the WITHGI and FULL versions

```
zgrep -n : prot.accession2taxid.FULL.gz
42:0403181A:PDB=1BP2,2BPP	9913
59:0407244A:PDB=1GF2	9606
313:0706243A:PDB=1HOE,2AIT,3AIT,4AIT	1932
321:0707237A:PDB=3ICB	9913
346:0710290A:PDB=1CTS	9825
373:0801257A:PDB=2STV	12054
465:0807298A:PDB=3PGM	4932
570:0902204A:PDB=2MCM	1917
862:1004262A:PDB=1C5A	9825
1813:1202232A:PDB=1IFC	10116
2727:1309311A:PDB=1EMD,2CMD	562
3229:1411165A:PDB=1PPO	3649
3575:1513188A:PDB=1BBC,1POD	9606
```


```
sort --parallel=32 -t, -k2,2 -k1,1r accession.unsorted.csv > accession.sorted.csv
uniq -d accession.sorted.csv > accession.sorted.dups.csv
uniq accession.sorted.csv > accession.sorted.uniq.csv
gzip accession.sorted.csv &
gzip accession.unsorted.csv &
```

No dupes here.




Let's see if there are any repeated accessions.


```


module load sqlite


sqlite3 taxonomy.sqlite
CREATE TABLE IF NOT EXISTS "taxa" ("taxid" INTEGER NOT NULL PRIMARY KEY, "parent_taxid" INTEGER NOT NULL, "tax_name" VARCHAR(255) NOT NULL, "lineage_level" VARCHAR(255) NOT NULL);
CREATE TABLE IF NOT EXISTS "accession" ("taxid" INTEGER NOT NULL, "accession" VARCHAR(255) NOT NULL, FOREIGN KEY ("taxid") REFERENCES "taxa" ("taxid"));
CREATE INDEX "accession_taxid" ON "accession" ("taxid");
CREATE UNIQUE INDEX "accession_accession" ON "accession" ("accession");
CREATE INDEX "taxa_parent_taxid" ON "taxa" ("parent_taxid");
CREATE UNIQUE INDEX "taxa_taxid" ON "taxa" ("taxid");
.separator "|"
.import taxa.csv taxa
.separator ,
.import accession.sorted.uniq.csv accession

```






```

select a.accession, t1.taxid, t1.tax_name, t1.lineage_level, t2.taxid, t2.tax_name, t2.lineage_level, t3.taxid, t3.tax_name, t3.lineage_level, t4.taxid, t4.tax_name, t4.lineage_level, t5.taxid, t5.tax_name, t5.lineage_level, t6.taxid, t6.tax_name, t6.lineage_level from accession a join taxa t1 on t1.taxid = a.taxid join taxa t2 on t2.taxid = t1.parent_taxid join taxa t3 on t3.taxid = t2.parent_taxid join taxa t4 on t4.taxid = t3.parent_taxid join taxa t5 on t5.taxid = t4.parent_taxid join taxa t6 on t6.taxid = t5.parent_taxid where a.accession = 'NC_006273';
```









```


select a.accession, t.tax_name from accession a join taxa t on t.taxid=a.taxid where a.accession== "NP_040188";
accession|tax_name
NP_040188|Human alphaherpesvirus 3


```



