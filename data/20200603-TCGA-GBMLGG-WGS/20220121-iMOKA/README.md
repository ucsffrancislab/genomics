

`/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/README.md`

Reference `/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA`





`/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/TQ-A8XE-10A-01D-A367_R1.fastq.gz`

```
ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | wc -l
278

ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/??-????-01*_R1.fastq.gz | wc -l
125
```


```
while read subject field; do
s=${subject#TCGA-}
f=$( ls /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/${s}-01*fastq.gz 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$8}' ) > source.IDH.all.tsv

wc -l source.IDH.all.tsv
123
```

Create source.IDH.tsv for ALL IDH samples that are either Mutant or Wildtype ...
```
awk -F"\t" '( $2 != "NA" )' source.IDH.all.tsv > source.IDH.tsv
```

```
wc -l source.IDH.*
   123 source.IDH.all.tsv
   122 source.IDH.tsv
```


Preprocess all files for k in 11, 21 and 31 ...
```
./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.11 --k 11

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDH.tsv --dir ${PWD}/IDH.31 --k 31




./iMOKA_preprocess.bash --source_file source.IDH.21.tsv --dir ${PWD}/IDH.21 --k 21

./iMOKA_preprocess.bash --source_file source.IDH.31.tsv --dir ${PWD}/IDH.31 --k 31
```




Create subdirs
Link preprocess dir from previous runs.
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
mkdir -p IDH.${k}.${s}
ln -s ../IDH.${k}/preprocess IDH.${k}.${s}
done ; done
```





ACTUALLY, NEED TO CREATE SUBSETS OF THE CREATE_MATRIX CREATED IN PREPROCESSING

We want the same subset so use `IDH.11/create_matrix.tsv` as single source

Prepare create_matrix.tsv for each dir

Create base and split by IDH
```
dir1=${PWD}/IDH.11
dir2=${PWD}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.tsv > create_matrix.tsv
awk -F"\t" '( $3 == "Mutant" )' create_matrix.tsv > create_matrix.Mutant.tsv
awk -F"\t" '( $3 == "WT" )' create_matrix.tsv > create_matrix.WT.tsv
```

Create 80% subsets.
```
m=$( cat create_matrix.Mutant.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.Mutant.tsv > create_matrix.80c.tsv

m=$( cat create_matrix.WT.tsv | wc -l )
mc=$( echo "0.8 * ${m}" | bc -l 2> /dev/null)
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80a.tsv
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80b.tsv
shuf --head-count ${mc} create_matrix.WT.tsv >> create_matrix.80c.tsv
```

Disperse.
```
for k in 11 21 31 ; do
for s in 80a 80b 80c ; do
dir1=${PWD}
dir2=${PWD}/IDH.${k}.${s}
sed "s'${dir1}'${dir2}'" ${dir1}/create_matrix.${s}.tsv > ${dir2}/create_matrix.tsv
done ; done
```










Wait until cluster is rebooted Feb 3





There is not enough space on scratch to run 21 and 31.
The script copies all of preprocess to scratch and its more than 2TB.
This needs to be done off scratch.




```
date=$( date "+%Y%m%d%H%M%S" )

for k in 11 21 31 ; do
for s in a b c ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=D${k}${s} --time=20160 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --local --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step create
done ; done

```


Aggregation failed for k=21. k=31 will likely fail the same way.

Only running 1 k=31 as will likely take way too long.
```
date=$( date "+%Y%m%d%H%M%S" )
for k in 31 ; do
for s in b c ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=D${k}${s} --time=20160 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.%j.txt \
 ${PWD}/iMOKA_scratch.bash --local --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step reduce
done ; done
```

Waiting for final 21 to fail then rerunning with modified aggregation step.


```
date=$( date "+%Y%m%d%H%M%S" )

for k in 21 ; do
for s in a b c; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=D${k}${s} --time=20160 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:1500G \
 --output=${PWD}/IDH.${k}.80${s}/iMOKA_scratch.${date}.txt \
 ${PWD}/iMOKA_scratch.bash --local --dir ${PWD}/IDH.${k}.80${s} -k ${k} --step aggregate
done ; done

```

```
Default (80) - fails
Step 2 : Building the groups...done.
	Found 16539 graphs : 
	  - complex: 16,649
	  - linear: 16523,126620
	 Nodes used: 127269/146632 ( 19363 discarded )
	Space occupied: 98.660Mb
Step 3 : Extracting the sequences... done. 
	Found  6021 sequences.
	[ Average sequence lenght: 36 ]

Change (90) (Better?) - still fails
Step 2 : Building the groups...done.
	Found 642 graphs : 
	  - complex: 10,581
	  - linear: 632,33144
	 Nodes used: 33725/146632 ( 112907 discarded )
	Space occupied: 65.750Mb
Step 3 : Extracting the sequences... done. 
	Found  565 sequences.
	[ Average sequence lenght: 79 ]

Change (95) (perhaps too high?) - still fails
Step 2 : Building the groups...done.
	Found 2 graphs : 
	  - complex: 2,220
	 Nodes used: 220/146632 ( 146412 discarded )
	Space occupied: 62.785Mb
Step 3 : Extracting the sequences... done. 
	Found  6 sequences.
	[ Average sequence lenght: 56 ]


97 ... 
98 ... 
99 ... 

```


OK. So I either run out of memory with too many or seg fault with 0.
Can't really find a happy middle.
Gonna try AWS.


My `~/.aws/config` and `~/.aws/credentials` are set to use my ucsf profile by default


Start AWS session
```
aws-adfs login 
```

Upload to S3
```
aws s3 cp --sse aws:kms --sse-kms-key-id alias/managed-s3-key /francislab/data1/refs/singularity/iMOKA_extended-1.1.5.img s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/

cd /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA
for d in IDH.21.80? ; do
for f in reduced.matrix.json reduced.matrix matrix.json config.json ; do
aws s3 cp --sse aws:kms --sse-kms-key-id alias/managed-s3-key ${d}/${f} s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/${d}/
done ; done
```

UPLOAD THE PREPROCESS KMER COUNTS DATA TO S3 (IDH.21) (over 2TB)
```
aws s3 sync --sse aws:kms --sse-kms-key-id alias/managed-s3-key /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21/preprocess/ s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21/preprocess/
```



Start instance
Not entirely certain of all differences of the "-dl-" images. They only appear to have larger disk space.

dl == Deep Learning?

```
aws-adfs login 

ami_id=$( aws ec2 describe-images --owners 013463732445  | jq -r '.Images | map(select(.Name | test("^base-ubuntu-18-ami"))) | sort_by(.CreationDate)[].ImageId' | tail -1 )
echo $ami_id

subnet_id=$( aws ec2 describe-subnets | jq -r '.Subnets | sort_by(.AvailableIpAddressCount) | reverse[0].SubnetId' )
echo ${subnet_id}

ssm_security_group_id=$( aws ec2 describe-security-groups | jq -r '.SecurityGroups | map(select( .GroupName == "managed-ssm" ))[].GroupId' )
echo $ssm_security_group_id

mns_security_group_id=$( aws ec2 describe-security-groups | jq -r '.SecurityGroups | map(select( .GroupName == "managed-network-services" ))[].GroupId' )
echo $mns_security_group_id

security_ids="${ssm_security_group_id} ${mns_security_group_id}"
echo $security_ids



#	instance type? need 1 tb memory
#
#     type      Cos/Hr CPU   Mem    Storage / Network
#  x1.16xlarge   6.669  64    976  1 x 1,920  7,000  10
#  x1.32xlarge  13.338 128  1,952  2 x 1,920  14,000  25
#  x1e.4xlarge	$3.336  16    488  1 x 480 SSD
#  x1e.8xlarge   6.672  32    976  1 x 960  3,500  Up to 10
#  x1e.16xlarge 13.344  64  1,952  1 x 1,920  7,000  10
#  x1e.32xlarge 26.688 128  3,904  2 x 1,920  14,000  25

#	disk space?
#	"--block-device-mappings DeviceName=/dev/xvda,Ebs={VolumeSize=${1},VolumeType=gp2}"

#aws ec2 run-instances --image-id ${ami_id} --instance-type c5.large --subnet-id ${subnet_id} --security-group-ids ${security_ids} --iam-instance-profile Name=managed-service-ec2-standard --dry-run

instance_id=$( aws ec2 run-instances --image-id ${ami_id} --instance-type c5.large --subnet-id ${subnet_id} --security-group-ids ${security_ids} --iam-instance-profile Name=managed-service-ec2-standard  | jq -r '.Instances[].InstanceId' )
echo ${instance_id}

#	instance_id=$( aws ec2 describe-instances | jq -r '.Reservations[].Instances | map(select( .State.Name == "running"))[].InstanceId' )
#	echo ${instance_id}

#	... WAIT A MINUTE TO LET THE INSTANCE SPIN UP AND CONNECT ...


#sudo sed -i '/ssm-user/s/sh/bash/' /etc/passwd # doesn't change anything
#aws ssm start-session --target ${instance_id}

#	SET SHELL DEFAULT TO BASH!

#	sudo chsh -s /bin/bash ssm-user	# doesn't do anythin



aws ssm start-session --target ${instance_id}

sudo chmod o+r /etc/apt/sources.list.d/sdcss.list
sudo chown ssm-user $HOME
cd
wget https://raw.githubusercontent.com/ucsffrancislab/home/master/.inputrc
wget https://raw.githubusercontent.com/ucsffrancislab/home/master/.vimrc
bash
alias ll="ls -l"


#	Looks like apt update runs automatically and can't run 2 at the same time.
#	There may be collisions. Try rerunning.
#	Or maybe I'm not supposed to run it at all?
#	The user guide does use it to install a couple things.


#	wait until nothing ...
ps -ef | grep apt


sudo apt-get clean all
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove




#wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/aws/ec2_install_singularity.bash
#chmod +x ec2_install_singularity.bash
#./ec2_install_singularity.bash

#/bin/bash <( curl -fsSL https://raw.githubusercontent.com/ucsffrancislab/genomics/master/aws/ec2_install_singularity.bash )
curl https://raw.githubusercontent.com/ucsffrancislab/genomics/master/aws/ec2_install_singularity.bash | bash -s







#	test this
#	curl http://domain/path/to/script.sh | bash -s arg1 arg2
#	not yet
#/bin/bash <( curl -fsSL https://raw.githubusercontent.com/ucsffrancislab/genomics/master/aws/ec2_add_ebs_storage_to_self.bash )
# curl https://raw.githubusercontent.com/ucsffrancislab/genomics/master/aws/ec2_add_ebs_storage_to_self.bash | bash -s -size 4000 -loc /home/ssm-user/data



#	it looks like I'm gonna need to create a large storage as the data is over 2TB

#	az=$( curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ )
#	region=$( curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq '.region' | tr -d '"' )
#
#	https://stackoverflow.com/questions/625644/how-to-get-the-instance-id-from-within-an-ec2-instance
#wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document
#
#This will get you JSON data such as this - with only a single request.
#
#{
#    "devpayProductCodes" : null,
#    "privateIp" : "10.1.2.3",
#    "region" : "us-east-1",
#    "kernelId" : "aki-12345678",
#    "ramdiskId" : null,
#    "availabilityZone" : "us-east-1a",
#    "accountId" : "123456789abc",
#    "version" : "2010-08-31",
#    "instanceId" : "i-12345678",
#    "billingProducts" : null,
#    "architecture" : "x86_64",
#    "imageId" : "ami-12345678",
#    "pendingTime" : "2014-01-23T45:01:23Z",
#    "instanceType" : "m1.small"
#}

# https://github.com/unreno/genomics/blob/2a2198fe84a5a1186eba6b60068732d6573418b5/scripts/aws_1000genomes_extract_locally_aligned.bash


sudo apt-get install -y jq

TOKEN=$( curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") 
instance_id=$( curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null )
echo $instance_id 
az=$( curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone 2> /dev/null )
echo $az
region=$( curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/region 2> /dev/null )
echo $region


# in GB (what is max?)
ebs_size=4000



#	CREATE THE EBS VOLUME DURING INSTANCE CREATION BY ADDING  (64TB maximum)
#	--block-device-mappings "DeviceName=/dev/nvme,Ebs={VolumeSize=64000,VolumeType=gp2}" 
#	--block-device-mappings "DeviceName=/dev/xvda,Ebs={VolumeSize=2000,VolumeType=gp2}"



#	no permission to describe or create volumes.





command="aws ec2 create-volume --region ${region} --availability-zone ${az} --volume-type gp2 --size ${ebs_size}"
echo $command
response=$( $command )
echo "$response"
volume_id=$( echo "$response" | jq -r '.VolumeId' )
echo $volume_id

aws ec2 describe-volumes --region ${region} --volume-id $volume_id

#	device names ... /dev/sd[f-p]
state="creating"
echo "Waiting for state to become 'available' ..."
until [ "$state" == "available" ] ; do
	state=$( aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} | jq -r '.Volumes[0].State' )
done

command="aws ec2 attach-volume --region ${region} --device xvdf --instance-id ${instance_id} --volume-id ${volume_id}"
echo $command
response=$( $command )
echo "$response"

state="attaching"
echo "Waiting for state to become 'in-use' ..."
until [ "$state" == "in-use" ] ; do
	state=$( aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} | jq -r '.Volumes[0].State' )
done





aws ec2 describe-volumes --region ${region} --volume-id ${volume_id} 




echo "Waiting for mount point to be created ..."
until [ -a /dev/xvdf ] ; do
	sleep 2
done

#	as it is possible that some mount points may linger, check ?
#	[ -e /dev/xvdf ] ....

sudo file -s /dev/xvdf
#	-> data
#	(/dev/sdf would be a link so not helpful)

#	Need to create file system on volume
sudo mkfs -t ext4 /dev/xvdf

sudo file -s /dev/xvdf
#	-> /dev/xvdf: Linux rev 1.0 ext4 filesystem data, UUID=0366fdd8-7691-4b3f-be37-2b03a33586a9 (extents) (large files) (huge files)

sudo mount /dev/xvdf $HOME/data

df -h $HOME/data
#	Filesystem      Size  Used Avail Use% Mounted on
#	/dev/xvdf       976M  1.3M  908M   1% /home/ec2-user/ebsdrive

#	Note the loss of 1%

#	Owned by root so only writable by root unless ...
sudo chmod 777 $HOME/data











#			Use "/home/ssm-user/data/"  or simply /data/ ?



aws s3 ls s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/

aws s3 cp s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/iMOKA_extended-1.1.5.img ./





aws s3 sync s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21/ ./IDH.21/
aws s3 sync s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21.80a/ ./IDH.21.80a/
aws s3 sync s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21.80b/ ./IDH.21.80b/
aws s3 sync s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21.80c/ ./IDH.21.80c/

cd ~/IDH.21.80a
cd ~/IDH.21.80b
cd ~/IDH.21.80c



sed -i "s'/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21.80a/'/home/ssm-user/IDH.21/'g" matrix.json
sed "1s'/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/'/home/ssm-user/'g" reduced.matrix
sed "1s'/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/'/home/ssm-user/'g" reduced.matrix.json





#	correct file paths in files
#	WARNING! Database /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.21.80a/preprocess/27-2523/27-2523.tsv.sorted.bin is empty! 







#	Environmental var OMP_NUM_THREADS is not defined. Using 1 thread.
#	To use a different number of thread, export the variable before running iMOKA:
#	export OMP_NUM_THREADS=4 
#	Environmental var IMOKA_MAX_MEM_GB is not defined. Using 2 Gb as default.
#	 To use a different thershold, export the variable before running iMOKA:
#	export IMOKA_MAX_MEM_GB=2

date=$( date "+%Y%m%d%H%M%S" )
singularity exec ~/iMOKA_extended-1.1.5.img iMOKA_core aggregate --input reduced.matrix --count-matrix matrix.json --mapper-config config.json --output aggregated > iMOKA_AWS.${date}.log






#upload log and aggregated* to s3



#download log and aggregated* from s3






exit
exit

aws ec2 terminate-instances --instance-ids ${instance_id}

aws ec2 describe-instances | jq -r '.Reservations[].Instances[].State.Name'


aws ssm describe-sessions --state Active

for sid in $( aws ssm describe-sessions --state Active | jq -r '.Sessions[].SessionId' ); do
echo "Terminating ${sid}"
aws ssm terminate-session --session-id ${sid}
done

```







Predict.
```
nohup ./predict.bash > predict.out &
```

Better matrix of important kmers.
```
nohup ./matrices_of_select_kmers.bash > matrices_of_select_kmers.out &
```

Upload.
```
./upload.bash
```

