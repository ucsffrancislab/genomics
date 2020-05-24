
#	ImputationPrep_AGS_GWAS

Pipeline based on https://imputationserver.readthedocs.io/en/latest/prepare-your-data/
and https://topmedimpute.readthedocs.io/en/latest/prepare-your-data/

Update https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip

More info on https://www.well.ox.ac.uk/~wrayner/tools/


This takes less than an hour.



##	Start instance
```BASH
type       vCPUs  Memory  Storage  Storage type Network performance On-Demand Linux pricing
i3.xlarge    4     31232    950      ssd         Up to 10 Gigabit     0.312 USD per Hour
i3.2xlarge   8     62464   1900      ssd         Up to 10 Gigabit     0.624 USD per Hour  
```


```BASH
create_ec2_instance.bash --profile gwendt --image-id ami-0323c3dd2da7fb37d --instance-type i3.xlarge --key-name ~/.aws/JakeHervUNR.pem --NOT-DRY-RUN


ip=$( aws --profile gwendt ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' | tr -d '"' )
echo $ip
ssh -i /Users/jakewendt/.aws/JakeHervUNR.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$ip
```



##	Update instance

```BASH
sudo yum -y update
sudo yum -y install docker htop
```



##	Prepare attached ssd

The instance only has 8GB by default which will be rather full already.
This data will take up a couple GB.
Docker related data will take up over 20GB.
Use the SSD for data and docker. Its faster too.

```BASH
lsblk
sudo mkfs -t xfs /dev/nvme0n1
sudo mkdir -p /ssd0/
sudo mount /dev/nvme0n1 /ssd0/
sudo chown ec2-user /ssd0/
mkdir -p /ssd0/data
mkdir -p /ssd0/docker
```


##	Download data

```BASH
aws s3 sync s3://herv-unr/20200520_Adult_Glioma_Study_GWAS/ /ssd0/data/
```



##	Setup docker

```BASH
sudo bash -c 'echo { \"data-root\":\"/ssd0/docker/\" } >> /etc/docker/daemon.json'
sudo service docker start
sudo usermod -a -G docker ec2-user
```


##	Exit and reconnect ( apparently for the usermod permissions to docker )

```BASH
exit
```

```BASH
ssh -i /Users/jakewendt/.aws/JakeHervUNR.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$ip
```



##	Get docker file

```BASH
wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/docker/ImputationPrep.Dockerfile
```



##	Build it

```BASH
docker build -t impute --file ~/ImputationPrep.Dockerfile ./
```

##	Run it in the background

```BASH
docker run -v /ssd0/data:/data -itd impute
```

##	Connect to it

```BASH
docker exec -it $( docker ps -aq ) bash
```


## Convert ped/map to bed ( I already have the bed files. And don't have ped/map files. )




##	Move / Copy / Filter into /data/out directory

JAKE ADDED - filter out chromosome 0 with `--not-chr 0`
Nevermind. Filtering nnecessary. Use the `*-updated-chr*` bed files.

Do need to copy the files and remaking them cleans them up a bit.


```BASH
mkdir /data/out/
plink --bfile /data/il370_4677 --make-bed --out /data/out/il370_4677
plink --bfile /data/onco_1347  --make-bed --out /data/out/onco_1347
```



##	Create a frequency file

```BASH
plink --freq --bfile /data/out/il370_4677 --out /data/out/il370_4677.freq
plink --freq --bfile /data/out/onco_1347  --out /data/out/onco_1347.freq
```


##	Execute script ( failed on my laptop as ran out of memory (15GB) )

Original version, loading tab goes up to 40400000 and uses about 22GB memory and create Run-plink.sh

New version goes up to 40405506 and uses less than 1 GB of memory!
This could now be run on a laptop.


```BASH
cd /data/out

perl /home/HRC-1000G-check-bim.pl -b /data/out/il370_4677.bim -f /data/out/il370_4677.freq.frq -r /home/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

mv Run-plink.sh Run-plink-il370_4677.sh
sh Run-plink-il370_4677.sh

perl /home/HRC-1000G-check-bim.pl -b /data/out/onco_1347.bim -f /data/out/onco_1347.freq.frq -r /home/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

mv Run-plink.sh Run-plink-onco_1347.sh
sh Run-plink-onco_1347.sh
```

##	Create vcf using [VcfCooker](http://genome.sph.umich.edu/wiki/VcfCooker)

Which reference? Does it really matter? Probably needs matching chomosome names?

USE -updated file.

Seems that the imputation server uses the individual chromosome files so NOT this ...

```BASH
vcfCooker --in-bfile /data/out/il370_4677-updated --ref /home/hs37d5.fa --out /data/out/il370_4677.vcf --write-vcf
bgzip /data/out/il370_4677.vcf

vcfCooker --in-bfile /data/out/onco_1347-updated  --ref /home/hs37d5.fa --out /data/out/onco_1347.vcf  --write-vcf
bgzip /data/out/onco_1347.vcf
```

But something more like this ...

```BASH
	for i in $( seq 1 23 ) ; do
		vcfCooker --in-bfile /data/out/${s}-updated-chr${i} \
			--ref /home/hs37d5.fa \
			--out /data/out/${s}-updated-chr${i}.vcf \
			--write-vcf
		bgzip /data/out/${s}-updated-chr${i}.vcf
	done
```


##	Exit Docker and Copy out data

```BASH
exit

aws s3 sync /ssd0/data/out/ s3://herv-unr/20200520_Adult_Glioma_Study_GWAS_OUTPUT/
```


##	Kill Instance

Assuming that this is the ONLY container, stop it and remove it when done.
Of course, if you are about to shutdown the AWS instance, its irrelevant.

```BASH
docker stop $( docker ps -aq )

docker rm $( docker ps -aq )

sudo shutdown now
```










#	Additional Tools

While I don't use these tools, I do use the `checkVCF` provided reference.
Although, since I haven't seen any results, this and anything could change.


##	Convert ped/map files to VCF files

Several tools are available: [plink2](https://www.cog-genomics.org/plink2/), [BCFtools](https://samtools.github.io/bcftools) or [VcfCooker](http://genome.sph.umich.edu/wiki/VcfCooker).
```BASH
plink --ped study_chr1.ped --map study_chr1.map --recode vcf --out study_chr1
```

Create a sorted vcf.gz file using [BCFtools](https://samtools.github.io/bcftools):
```BASH
bcftools sort study_chr1.vcf -Oz -o study_chr1.vcf.gz
```

##	CheckVCF

Use [checkVCF](https://github.com/zhanxw/checkVCF) to ensure that the VCF files are valid. checkVCF proposes "Action Items" (e.g. upload to sftp server), which can be ignored. Only the validity should be checked with this command.
```BASH
checkVCF.py -r human_g1k_v37.fasta -o out mystudy_chr1.vcf.gz
```










#	Imputation Server

Redo and process per chromosome.


```BASH
set -v
mkdir /data/out/
for s in il370_4677 onco_1347 ; do
  plink --bfile /data/${s} --make-bed --out /data/out/${s}
  plink --freq --bfile /data/out/${s} --out /data/out/${s}.freq

  cd /data/out

  perl /home/HRC-1000G-check-bim.pl \
    -b /data/out/${s}.bim \
    -f /data/out/${s}.freq.frq \
    -r /home/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

  mv Run-plink.sh Run-plink-${s}.sh
  sh Run-plink-${s}.sh

  for i in $( seq 1 23 ) ; do
    vcfCooker --in-bfile /data/out/${s}-updated-chr${i} \
      --ref /home/hs37d5.fa \
      --out /data/out/${s}-updated-chr${i}.vcf \
      --write-vcf
    bgzip /data/out/${s}-updated-chr${i}.vcf
  done

done
aws s3 sync /ssd0/data/out/ s3://herv-unr/20200520_Adult_Glioma_Study_GWAS_OUTPUT_$(date "+%Y%m%d")/
```

Apparently there is a way to load into imputation server from S3, but haven't figured it out yet.
Download locally, then upload to server.

Use [TopMed's Server](https://imputation.biodatacatalyst.nhlbi.nih.gov/)

With these options

* Reference Panel: TOPMed r2
* Array build: GRCh37/hg19
* rsq Filter: 0.1 (To start, may bump this up to 0.3 later, we can post filter these ones later too.)
* Phasing: Eagle w/e
* Mode: Quality Control & Imputation [ or Quality Control & Phasing Only or Quality Control Only 

* Phasing: Eagle v2.4 (phased output) [or no phasing]
* Population: All [or Mixed]

* O : AES 256 encryption
* X : I will not attempt to re-identify or contact research participants.
* X : I will report any inadvertant data release, security breach or other data management incident of which I become aware.


Data sets must be uploaded separately.

Each file is validated.
The reference panel is hg38 but the data is hg19 so it needs to be lifted over.
This is taking a while.
I would not be be surprised if this takes a day or so.





