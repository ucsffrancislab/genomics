

The TOPMed reference panel is not available for direct download from this site, it needs to be created from the VCF of dbSNP submitted sites (currently ALL.TOPMed_freeze5_hg38_dbSNP.vcf.gz).

Once logged in, there is a command to download on the command line via curl.

https://bravo.sph.umich.edu/freeze5/hg38/download

Something like ...
```
curl 'https://bravo.sph.umich.edu/freeze5/hg38/download/all' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA199999; _gid=GA19; remember_token="me@here.com|ASDFASDFASDF"; _gat_gtag_UA_73910830_2=1' --compressed > bravo-dbsnp-all.vcf.gz
```

~6.4 GB



