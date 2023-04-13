
#	


```
faSplit byname viral.protein.faa.gz viral.protein/


zcat viral.*.genomic.fna.gz | sed -e '/^>/s/[ \/,]/_/g' -e '/^>/s/\(^.\{1,250\}\).*/\1/' | gzip > viral.genomic.fna.gz
mkdir viral.genomic
faSplit byname viral.genomic.fna.gz viral.genomic/
```


