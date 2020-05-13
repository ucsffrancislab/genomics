



For some reason, taxadb does not include all of the data in taxdump?

wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/pdb.accession2taxid.gz

Not sure why so many missing, so I will try to create my own csv files for direct import to database.
Gotta merge nodes.dmp and names.dmp to make the "taxa" table.
The accessions tables is just all of the accession2taxid file.


Found another cool tool. http://etetoolkit.org/


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


Better choose columns. taxid,parent_taxid,tax_name,lineage_level and taxid,accession


zcat *.accession2taxid.gz | awk 'BEGIN{FS="\t";OFS=","}($1!="accession"){print $3,$1}' > accession.unsorted.csv
zcat /francislab/data1/refs/taxadb/nr.aT.csv.gz | awk 'BEGIN{FS=OFS=","}{print $2,$1}' >> accession.unsorted.csv
#sort -t , -k 2 accession.unsorted.csv > accession.sorted.csv
#uniq -d accession.sorted.csv

Using tabs as separators for simplicity. Outputing pipes as separators as commas and quotes in data.

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








