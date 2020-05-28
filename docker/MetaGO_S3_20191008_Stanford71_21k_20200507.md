
Each line is the complete path of raw data, such as the first line is '/home/user/MetaGO/testData/H1.fasta', and the second line is '/home/user/MetaGO/testData/H2.fasta' ... Furthermore, and the samples belong to same group must arrange togther(e.g. line1 to linek of the list belongs to group 1 (health) and linek+1 to lineN belongs to group 2 (patient) ).
-N	--n1	The number of samples belong to group 1.
-M	--n2	The number of samples belong to group 2.


tail -n +2 /francislab/data1/raw/20191008_Stanford71/metadata.csv | awk -F, '{print "ln -s /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/"$1".h38au.bowtie2-e2e.unmapped.fasta.gz ./"$2"-"$1".unmapped.fasta.gz"}' | bash
ll Control-* | wc -l
36
ll Case-* | wc -l
41

aws s3 sync ~/MetaGO_S3_20191008_Stanford71/ s3://herv-unr/MetaGO_S3_20191008_Stanford71/

try i3.2xlarge

create_ec2_instance.bash --image-id ami-0323c3dd2da7fb37d --instance-type i3.8xlarge --key-name ~/.aws/JakeHervUNR.pem --NOT-DRY-RUN
ssh ...
sudo yum update
lsblk
sudo mkfs -t xfs /dev/nvme0n1
mkdir ssd0
sudo mount /dev/nvme0n1 ssd0/
sudo chown ec2-user ssd0/
aws s3 sync s3://herv-unr/MetaGO_S3_20191008_Stanford71/ ~/ssd0/MetaGO_S3_20191008_Stanford71/ 
#
sudo mkfs -t xfs /dev/nvme1n1
mkdir ssd1
sudo mount /dev/nvme1n1 ssd1/
sudo chown ec2-user ssd1/
mkdir ssd1/MetaGO_Result
#
sudo mkfs -t xfs /dev/nvme2n1
mkdir ssd2
sudo mount /dev/nvme2n1 ssd2/
sudo chown ec2-user ssd2/
#
sudo yum install docker htop
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo bash -c 'echo { \"data-root\":\"/home/ec2-user/ssd2/\" } >> /etc/docker/daemon.json'
sudo service docker restart
exit
ssh ...


Using ssd0 as data in, ssd1 as data out and ssd2 as docker storage


mkdir ~/tmp/
cd ~/tmp/
wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/docker/MetaGO_demo.Dockerfile
docker build -t metago --file MetaGO_demo.Dockerfile ./





docker run -v /home/ec2-user/:/mnt --memory 200GB --rm -it metago

memory do anything???


ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Control* > /root/fileList.txt
ls -1 /mnt/ssd0/MetaGO_S3_20191008_Stanford71/Case*   >> /root/fileList.txt

bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh --inputData RAW --fileList /root/fileList.txt --n1 36 --n2 41 --kMer 21 --min 1 -P 16 --ASS 0.65 --WilcoxonTest 0.1 --LogicalRegress 0.5 --filterFuction ASS --outputPath /mnt/ssd1/MetaGO_Result --Union --sparse





