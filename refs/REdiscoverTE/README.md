
#	REdiscoverTE

```
R
rds=readRDS('rmsk_annotation.RDS')
write.table(as.data.frame(rds),file="rmsk_annotation.csv", quote=F,sep=",",row.names=F)
```


