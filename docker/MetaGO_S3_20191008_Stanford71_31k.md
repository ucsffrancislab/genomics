
#	MetaGO Run on AWS Instance
Each line is the complete path of raw data, such as the first line is '/home/user/MetaGO/testData/H1.fasta', and the second line is '/home/user/MetaGO/testData/H2.fasta' ... Furthermore, and the samples belong to same group must arrange togther(e.g. line1 to linek of the list belongs to group 1 (health) and linek+1 to lineN belongs to group 2 (patient) ).
-N	--n1	The number of samples belong to group 1.
-M	--n2	The number of samples belong to group 2.

```BASH
tail -n +2 /francislab/data1/raw/20191008_Stanford71/metadata.csv | awk -F, '{print "ln -s /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/"$1".h38au.bowtie2-e2e.unmapped.fasta.gz ./"$2"-"$1"-unmapped.fasta.gz"}' | bash
ll Control-* | wc -l
36
ll Case-* | wc -l
41

aws s3 sync ~/MetaGO_S3_20191008_Stanford71/ s3://herv-unr/MetaGO_S3_20191008_Stanford71/
```






i3.2xlarge - 8/60GB 
i3.8xlarge - 32/240GB 

```BASH

create_ec2_instance.bash --profile gwendt --image-id ami-0323c3dd2da7fb37d --instance-type i3.2xlarge --key-name ~/.aws/JakeHervUNR.pem --NOT-DRY-RUN

ip=$( aws --profile gwendt ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' --instance-ids i-08bdc44cc23b2e686 | tr -d '"' )
echo $ip
ssh -i /Users/jakewendt/.aws/JakeHervUNR.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$ip





sudo yum -y update
sudo yum -y install docker htop


lsblk
sudo mkfs -t xfs /dev/nvme0n1
mkdir -p ~/ssd0/
sudo mount /dev/nvme0n1 ssd0/
sudo chown ec2-user ssd0/
mkdir -p ~/ssd0/MetaGO_Result


aws s3 sync s3://herv-unr/MetaGO_S3_20191008_Stanford71/ ~/ssd0/MetaGO_S3_20191008_Stanford71/ 


sudo bash -c 'echo { \"data-root\":\"/home/ec2-user/ssd0/\" } >> /etc/docker/daemon.json'
sudo service docker start
sudo usermod -a -G docker ec2-user
exit


ssh -i /Users/jakewendt/.aws/JakeHervUNR.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$ip



mkdir ~/tmp/
cd ~/tmp/
wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/docker/MetaGO_demo.Dockerfile
docker build -t metago --file MetaGO_demo.Dockerfile ./





docker run -v /home/ec2-user/:/mnt -itd metago



docker exec -it $( docker ps -aq ) bash

```


Create filelist on docker instance so path is correct


```BASH

ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Control* > /root/fileList.txt
ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Case*   >> /root/fileList.txt


nohup bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh --inputData RAW --fileList /root/fileList.txt \
	--n1 $( ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Control* | wc -l ) \
	--n2 $( ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Case* | wc -l ) \
	--kMer 31 --min 1 -P 8 \
	--ASS 0.75 --WilcoxonTest 0.05 --LogicalRegress 0.75 --cleanUp \
	--filterFuction ASS --outputPath /mnt/ssd0/MetaGO_Result --Union --sparse \
	> /mnt/ssd0/MetaGO_Result/MetaGO.output.txt 2>&1 &

```



Wait until completion



```BASH

aws s3 sync --delete ~/ssd0/MetaGO_Result/ s3://herv-unr/MetaGO_S3_20191008_Stanford71-MetaGO_Results_k31.$( date "+%Y%m%d" )

```
