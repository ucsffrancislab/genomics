


```
Add "machine gslanalyzer.qb3.berkeley.edu login ########## password ##########" to ~/.netrc

Then DO NOT USE the "ftp://" prefix or "-u username,password" in command 

So I put the username and password into my ~/.netrc and then downloaded all data.

lftp -c 'set ssl:verify-certificate no set ftp:ssl-protect-data true set ftp:ssl-force true; open -e "mirror -c; quit" gslanalyzer.qb3.berkeley.edu:990'
```



MANUALLY EDIT THE COVARIATE FILE
CHANGE "post recurrence" to "post-recurrence"





```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/raw"
curl -netrc -X MKCOL "${BOX}/"

for f in *fastqc*; do
echo $f
curl -netrc -T $f "${BOX}/"
done
```

