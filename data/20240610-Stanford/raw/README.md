
#	20240610-Stanford


```
for f in $( curl -sl -netrc --create-dirs "ftps://ftp.box.com/Francis _Lab_Share/Clinto/" ) ; do
echo $f
if [ $f == "." ] || [ ${f} == ".." ] ; then 
echo Skip
else echo Downloading
curl -netrc --create-dirs "ftps://ftp.box.com/Francis _Lab_Share/Clinto/${f}" -o ${f}
fi
done

```


