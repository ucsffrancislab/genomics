#!/usr/bin/env bash


cp /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/*snps.vcf{,.idx} ./


#	there are several duplicate file namess
#	I'm manually selecting the NEWEST


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/GBM02.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 23468644 Aug 16  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM02/germline/GBM02.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 59771802 Feb 15  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM02.old/germline/GBM02.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/GBM02/germline/GBM02.UG.snps.vcf{,.idx} ./

#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/GBM05.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 19059756 Jan 20  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM05/germline/GBM05.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 27487037 Aug  6  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM05-Z385/germline/GBM05.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/GBM05-Z385/germline/GBM05.UG.snps.vcf{,.idx} ./

#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/GBM06.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 19251123 Aug  4  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM06/germline/GBM06.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 14570350 Feb 18  2016 /costellolab/data3/jocostello/LG3/exomes_recal/GBM06.old/germline/GBM06.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/GBM06/germline/GBM06.UG.snps.vcf{,.idx} ./


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient303.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 39603918 Dec  9  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient303/germline/Patient303.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 37187978 Dec  3  2017 /costellolab/data3/jocostello/LG3/exomes_recal/Patient303.old/germline/Patient303.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient303/germline/Patient303.UG.snps.vcf{,.idx} ./

#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient375.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 43085767 Dec  9  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient375.13samples/germline/Patient375.UG.snps.vcf
#	-rw-r--r-- 1 jocostello costellolab 45570767 Apr 14  2022 /costellolab/data3/jocostello/LG3/exomes_recal/Patient375/germline/Patient375.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 40648024 Jun  7  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient375.old/germline/Patient375.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient375/germline/Patient375.UG.snps.vcf{,.idx} ./

#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient469.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 50938509 Jun 25  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient469.13samples/germline/Patient469.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 21873820 Feb 13  2021 /costellolab/data3/jocostello/LG3/exomes_recal/Patient469/germline/Patient469.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient469/germline/Patient469.UG.snps.vcf{,.idx} ./


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient470.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 44889673 Dec 22  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient470/germline/Patient470.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 42493373 Jun 20  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient470.old/germline/Patient470.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient470/germline/Patient470.UG.snps.vcf{,.idx} ./


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient486.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 32969689 Dec 11  2019 /costellolab/data3/jocostello/LG3/exomes_recal/Patient486.6samples/germline/Patient486.UG.snps.vcf
#	-rwxrwxr-x 1 root costellolab 14611731 Feb  6  2021 /costellolab/data3/jocostello/LG3/exomes_recal/Patient486/germline/Patient486.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient486/germline/Patient486.UG.snps.vcf{,.idx} ./


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient516.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 28693232 Dec 26  2020 /costellolab/data3/jocostello/LG3/exomes_recal/Patient516.16samples/germline/Patient516.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 32164373 Feb 20  2021 /costellolab/data3/jocostello/LG3/exomes_recal/Patient516.18samples/germline/Patient516.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 32164373 Feb 20  2021 /costellolab/data3/jocostello/LG3/exomes_recal/Patient516/germline/Patient516.UG.snps.vcf
#	-rw-r--r-- 1 jocostello costellolab 15575812 Jun 29  2022 /costellolab/data3/jocostello/LG3/exomes_recal/Patient516.new/germline/Patient516.UG.snps.vcf

cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient516.new/germline/Patient516.UG.snps.vcf{,.idx} ./


#	[gwendt@c4-dt1 /francislab/data1/raw/20230217_costello_LG3_exomes_recal]$ ll /costellolab/data3/jocostello/LG3/exomes_recal/*/germline/Patient83.UG.snps.vcf
#	-rwxrwxr-x 1 root       costellolab 29018311 Jul 11  2017 /costellolab/data3/jocostello/LG3/exomes_recal/Patient83.7samples/germline/Patient83.UG.snps.vcf
#	-rw-r--r-- 1 jocostello costellolab 50827987 May  3  2022 /costellolab/data3/jocostello/LG3/exomes_recal/Patient83/germline/Patient83.UG.snps.vcf


cp -f /costellolab/data3/jocostello/LG3/exomes_recal/Patient83/germline/Patient83.UG.snps.vcf{,.idx} ./


