

```
https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA736483
```

It looks like to download this data, you need to transfer it to one of our buckets. Then download from there.

```
aws --profile jake s3 sync s3://jakewendt-nih/ ./nih/
```


