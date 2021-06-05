#!/bin/bash

cd ~
if [ -x $(command -v curl) ]
then
  curl -s "ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.tar.gz" -o "edirect.tar.gz"
elif [ -x $(command -v wget) ]
then
  wget "ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.tar.gz"
else
  perl -MNet::FTP -e \
    '$ftp = new Net::FTP("ftp.ncbi.nlm.nih.gov", Passive => 1);
     $ftp->login; $ftp->binary;
     $ftp->get("/entrez/entrezdirect/edirect.tar.gz");'
fi
if [ -s "edirect.tar.gz" ]
then
  gunzip -c edirect.tar.gz | tar xf -
  rm edirect.tar.gz
fi
if [ ! -d "edirect" ]
then
  echo "Unable to download EDirect archive"
  exit 1
fi
export PATH=${PATH}:$HOME/edirect
./edirect/setup.sh

