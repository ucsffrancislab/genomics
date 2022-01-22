



Chimeric pairs to the hg38 + doubly masked viral




```
nohup ./report.bash > report.md &
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```


