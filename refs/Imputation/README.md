
#	GWAS / Imputation


https://www.chg.ox.ac.uk/~wrayner/tools/


https://www.chg.ox.ac.uk/~wrayner/tools/CreateTOPMed.zip




https://legacy.bravo.sph.umich.edu/freeze5/hg38/download





https://topmedimpute.readthedocs.io/en/latest/

https://imputationserver.readthedocs.io/en/latest/prepare-your-data/


If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).


more ../../20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/README.md 


```
#wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip

wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip

wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
```


##	Download full HAPMAP2 reference panel

Number of Samples	60

Sites (chr1-22)	2,542,916

Chromosomes	1-22

Website:	http://www.hapmap.org


```
mkdir hapmap2
cd hapmap2
wget https://imputationserver.sph.umich.edu/resources/ref-panels/imputationserver2-hapmap2.zip
unzip imputationserver2-hapmap2.zip 
```


##	Download full 1KG Phase 3 reference panel

1000 Genomes Phase 3 (Version 5)

Phase 3 of the 1000 Genomes Project consists of 5,008 haplotypes from 26 populations across the world.

Number of Samples	2,504

Sites (chr1-22)	49,143,605

Chromosomes	1-22, X

Website	http://www.internationalgenome.org

```
mkdir 1kgp3
cd 1kgp3
wget https://imputationserver.sph.umich.edu/resources/ref-panels/imputationserver2-1000genomes-phase3-public.zip
unzip imputationserver2-1000genomes-phase3-public.zip
```











Not sure where these will go

```
wget https://imputationserver.sph.umich.edu/resources/pgs-catalog/pgs-catalog-20230119-hg19.zip
wget https://imputationserver.sph.umich.edu/resources/pgs-catalog/pgs-catalog-20230119-hg38.zip
```








##	Download Other reference panels

https://genome.sph.umich.edu/wiki/Minimac3

https://genome.sph.umich.edu/wiki/Minimac4

1000 Genomes Phase 3 (version 5)
```
mkdir G1K_P3/
cd G1K_P3/
wget http://share.sph.umich.edu/minimac3/G1K_P3_VCF_Files.tar.gz
#wget http://share.sph.umich.edu/minimac3/G1K_P3_M3VCF_FILES_NO_ESTIMATES.tar.gz
wget http://share.sph.umich.edu/minimac3/G1K_P3_M3VCF_FILES_WITH_ESTIMATES.tar.gz
mkdir m3vcfs
cd m3vcfs
tar xfvz G1K_P3_M3VCF_FILES_WITH_ESTIMATES.tar.gz
cd ..
mkdir vcfs
cd vcfs
tar xfvz G1K_P3_VCF_Files.tar.gz
cd ..
```

minimac4 --compress-reference input.vcf.gz -o compressed_output.msav

plink convert vcf to map - same map? NO

chr position COMBINED_rate(cM/Mb) Genetic_Map(cM)
1 55550 0 0
1 568322 0 0
1 568527 0 0
1 721290 2.685807669 0.410292036939447
1 723819 2.8222713027 0.417429561063975
1 723891 2.9813105581 0.417644215424158









I want the TOPMed reference panel.

curl 'https://legacy.bravo.sph.umich.edu/freeze8/hg38/downloads/vcf/1' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA1.1.1792212135.1750794773;_ga_5B596RM26L=GS2.1.s1750795707$o1$g1$t1750796317$j60$l0$h0;_ga_HD76LS6C66=GS2.1.s1750860838$o2$g0$t1750860838$j60$l0$h0;remember_token=jakewendt@gmail.com|bd6efabcfa811a0e58807a44b05a6d5f7587a449dd8d210a93e9dc3265df056743f92ee94aef628d504e6bc3e888e39f99de92062543670839d3f76e3b5fb802;session=.eJwdj0FOwzAQRe_idVXN2OOxkxUH6AJYtWyieGYMLSQRSUqLEHcnYvul9_T-j-vqbMuba9f5ajvXndW1DvuYGqSeUIGgigEhsMWMNdcUqGiS7D17alg8SJMK5MBNrbwtkYkjRPGFgdRjVJAkwN5QUtBIAb2KYi4hmzAkpuATSVMLsmQMwe3cbIMNxeZuMZlGXVybmQD2sHPL2q-2Vd6nY3jWw_fLKT6W-YZ4svPh_oVPadTP4-a4Lhv_f-jSv9vNRl0fXof-_LGXaXC_f7_qShI.aFwEOQ.oI8t_aBnzv91XKcFB4onYc7LRJ0;' --compressed > chr1.BRAVO_TOPMed_Freeze_8.vcf.gz

curl 'https://legacy.bravo.sph.umich.edu/freeze8/hg38/downloads/coverage/1' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA1.1.1792212135.1750794773;_ga_5B596RM26L=GS2.1.s1750795707$o1$g1$t1750796317$j60$l0$h0;_ga_HD76LS6C66=GS2.1.s1750860838$o2$g0$t1750860838$j60$l0$h0;remember_token=jakewendt@gmail.com|bd6efabcfa811a0e58807a44b05a6d5f7587a449dd8d210a93e9dc3265df056743f92ee94aef628d504e6bc3e888e39f99de92062543670839d3f76e3b5fb802;session=.eJwdj0FOwzAQRe_idVXN2OOxkxUH6AJYtWyieGYMLSQRSUqLEHcnYvul9_T-j-vqbMuba9f5ajvXndW1DvuYGqSeUIGgigEhsMWMNdcUqGiS7D17alg8SJMK5MBNrbwtkYkjRPGFgdRjVJAkwN5QUtBIAb2KYi4hmzAkpuATSVMLsmQMwe3cbIMNxeZuMZlGXVybmQD2sHPL2q-2Vd6nY3jWw_fLKT6W-YZ4svPh_oVPadTP4-a4Lhv_f-jSv9vNRl0fXof-_LGXaXC_f7_qShI.aFwEOQ.oI8t_aBnzv91XKcFB4onYc7LRJ0;' --compressed > chr1.BRAVO_TOPMed_coverage_hg38.txt.gz



##	Create an imputation reference panel

20250625

minimac3 or minimac4

TOPMed r3?

https://legacy.bravo.sph.umich.edu/freeze5/hg38/download

bravo-dbsnp-all.vcf.gz


hmm 





Reference Panel Creation
If an M3VCF file is already available, it can be converted to the new MVCF format with:

minimac4 --update-m3vcf reference.m3vcf.gz > reference.msav
Otherwise, phased VCFs containing the reference haplotypes can be compressed into an MVCF with:

minimac4 --compress-reference reference.{sav,bcf,vcf.gz} > reference.msav





