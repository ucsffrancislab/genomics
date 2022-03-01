#!/usr/bin/env bash



#	Add option for 

#	GB
#	mount point?



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
metadata=$( curl wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document )
echo ${metadata}
az=$( echo "${metadata}" |  jq -r '.availabilityZone' )
region=$( echo "${metadata}" |  jq -r '.region' )
instance_id=$( echo "${metadata}" |  jq -r '.instanceId' )

# in GB (what is max?)
ebs_size=4000

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

#	I can't imaging that these device names are always the same
#	How to determine?


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





