
#	MetaGO Run on AWS Instance

Each line is the complete path of raw data, such as the first line is `/home/user/MetaGO/testData/H1.fasta`, and the second line is `/home/user/MetaGO/testData/H2.fasta` ... Furthermore, and the samples belong to same group must arrange togther(e.g. line1 to linek of the list belongs to group 1 (health) and linek+1 to lineN belongs to group 2 (patient) ).

```
-N	--n1	The number of samples belong to group 1.
-M	--n2	The number of samples belong to group 2.
```




```BASH
/francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/SD60.hg38.bowtie2-e2e.unmapped.fasta.gz

tail -n +2 /francislab/data1/raw/20200407_Schizophrenia/metadata.csv | awk -F, '{print "ln -s /francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/"$1".hg38.bowtie2-e2e.unmapped.fasta.gz ./"$2"-"$1"-unmapped.fasta.gz"}' | bash
ll Control-* | wc -l
29
ll Case-* | wc -l
30

aws s3 sync ~/MetaGO_S3_20200407_Schizophrenia/ s3://herv-unr/MetaGO_S3_20200407_Schizophrenia/
```


i3.2xlarge - 8/60GB

i3.8xlarge - 32/240GB


Started May 27, 7:40am

```BASH
create_ec2_instance.bash --profile gwendt --image-id ami-0323c3dd2da7fb37d --instance-type i3.2xlarge --key-name ~/.aws/JakeHervUNR.pem --NOT-DRY-RUN


ip=$( aws --profile gwendt ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' --instance-ids i-035cd8d50cb395c2c | tr -d '"' )
echo $ip
ssh -i /Users/jakewendt/.aws/JakeHervUNR.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$ip




sudo yum -y update
sudo yum -y install docker htop

lsblk
sudo mkfs -t xfs /dev/nvme0n1
mkdir -p ~/ssd0/
sudo mount /dev/nvme0n1 ~/ssd0/
sudo chown ec2-user ~/ssd0/
mkdir -p ~/ssd0/MetaGO_Result


aws s3 sync s3://herv-unr/MetaGO_S3_20200407_Schizophrenia/ ~/ssd0/MetaGO_S3_20200407_Schizophrenia/ 


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


up memory in ~/github/MetaGO/MetaGO_SourceCode/spark.conf 
spark.driver.memory	35G
spark.executor.memory   7G

spark.driver.memory	50G   <---- trying this now if conf file reread.
OR
spark.executor.memory   20G		<---- trying ... didn't make any diff still using around 38GB






```BASH
ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Control* > /root/fileList.txt
ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Case*   >> /root/fileList.txt

sed -i '/^spark.driver.memory/s/35G/50G/' spark.conf 

nohup bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh --inputData RAW --fileList /root/fileList.txt \
	--n1 $( ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Control* | wc -l ) \
	--n2 $( ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Case* | wc -l ) \
	--kMer 31 --min 1 -P 8 \
	--ASS 0.75 --WilcoxonTest 0.05 --LogicalRegress 0.75 --cleanUp \
	--filterFuction ASS --outputPath /mnt/ssd0/MetaGO_Result --Union --sparse \
	> /mnt/ssd0/MetaGO_Result/MetaGO.output.txt 2>&1 &
```

Wait until completion

Ended about 5/28 5:30am

Just under 24 hours.


[ec2-user@ip-172-31-69-79 ~]$ du -sh ssd0/MetaGO_S3_20200407_Schizophrenia/
15G	ssd0/MetaGO_S3_20200407_Schizophrenia/
[ec2-user@ip-172-31-69-79 ~]$ du -sh ssd0/MetaGO_Result/
564G	ssd0/MetaGO_Result/
[ec2-user@ip-172-31-69-79 ~]$ 



[ec2-user@ip-172-31-69-79 ~]$ du -sk ssd0/MetaGO_Result/* | sort -n
4	ssd0/MetaGO_Result/TupleNumber.txt
488	ssd0/MetaGO_Result/WR_filtered_down_6
500	ssd0/MetaGO_Result/ASS_filtered_down_6
804	ssd0/MetaGO_Result/WR_filtered_down_5
808	ssd0/MetaGO_Result/ASS_filtered_down_5
1444	ssd0/MetaGO_Result/WR_filtered_down_8
1460	ssd0/MetaGO_Result/ASS_filtered_down_8
2020	ssd0/MetaGO_Result/WR_filtered_down_7
2036	ssd0/MetaGO_Result/ASS_filtered_down_7
2332	ssd0/MetaGO_Result/WR_filtered_down_4
2396	ssd0/MetaGO_Result/ASS_filtered_down_4
3584	ssd0/MetaGO_Result/WR_filtered_down_2
3672	ssd0/MetaGO_Result/ASS_filtered_down_2
5108	ssd0/MetaGO_Result/WR_filtered_down_3
5228	ssd0/MetaGO_Result/ASS_filtered_down_3
5676	ssd0/MetaGO_Result/WR_filtered_down_1
5848	ssd0/MetaGO_Result/ASS_filtered_down_1
37332	ssd0/MetaGO_Result/filter_sparse_6
48016	ssd0/MetaGO_Result/MetaGO.output.txt
110720	ssd0/MetaGO_Result/filter_sparse_5
194556	ssd0/MetaGO_Result/filter_sparse_8
263324	ssd0/MetaGO_Result/filter_sparse_7
341048	ssd0/MetaGO_Result/filter_sparse_4
491652	ssd0/MetaGO_Result/filter_sparse_2
898028	ssd0/MetaGO_Result/filter_sparse_3
901420	ssd0/MetaGO_Result/filter_sparse_1
6312532	ssd0/MetaGO_Result/tuple_union_6
20569272	ssd0/MetaGO_Result/tuple_union_5
38815656	ssd0/MetaGO_Result/tuple_union_8
57039760	ssd0/MetaGO_Result/tuple_union_7
64770620	ssd0/MetaGO_Result/tuple_union_4
102113504	ssd0/MetaGO_Result/tuple_union_2
139015048	ssd0/MetaGO_Result/tuple_union_3
159199100	ssd0/MetaGO_Result/tuple_union_1




```BASH

aws s3 sync --delete ~/ssd0/MetaGO_Result/ s3://herv-unr/MetaGO_S3_20200407_Schizophrenia-MetaGO_Results_k31.$( date "+%Y%m%d" )

```


